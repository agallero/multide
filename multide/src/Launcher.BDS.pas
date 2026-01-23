unit Launcher.BDS;

interface
uses Classes, SysUtils, Generics.Collections, Model.Entry;

type
  TBDSVariables = record
  public
    SmartSetupFolder: string;
    constructor Create(const aSmartSetupFolder: string);
  end;

  TBDSLauncher = record
  private
    class var BDSVariables: TBDSVariables;

    class function FindBDS(const ProductId, Version: string; const Bitness: TIDEBitness): string; static;
    class procedure ShowError(const msg: string); static;
    class procedure SyncRegistry(const ProductId, Version: string); static;
    class function SyncPath(const ProductId: string): string; static;
  public
    class procedure Launch(const ProductId, Version, ExtraBDSParams: string); static;
  end;

implementation
uses Forms, ShellApi, Windows, Registry, Global.Config, IOUtils, Dialogs, Model.Persistence, Masks;

{ TBDSVariables }

constructor TBDSVariables.Create(const aSmartSetupFolder: string);
begin
  SmartSetupFolder := aSmartSetupFolder;
end;

{ TBDSLauncher }

class procedure TBDSLauncher.ShowError(const msg: string);
begin
  MessageBox(0, PCHAR(msg), 'MultIDE', MB_OK or MB_ICONERROR);
end;

class function TBDSLauncher.FindBDS(const ProductId, Version: string; const Bitness: TIDEBitness): string;
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKeyReadOnly(RegistryKeys.EmbarcaderoEntry(ProductId, Version)) then exit('');
    if (Bitness = TIDEBitness.Bit64) then
    begin
      Result := Reg.ReadString('App x64');
    end else
    begin
      Result := Reg.ReadString('App');
    end;
  finally
    Reg.Free;
  end;

end;

function ReplaceVariables(const s: string): string;
begin
  Result := s.Replace('$(SmartSetup)', TBDSLauncher.BDSVariables.SmartSetupFolder, [rfReplaceAll, rfIgnoreCase]);
end;

function IsIncluded(const RelativePath: string;
  const EntriesToSync: TArray<string>): Boolean;
begin
  Result := False;
  for var Entry in EntriesToSync do
  begin
    var Mask := ReplaceVariables(Entry.Trim);
    if Length(Mask) = 0 then continue;

    var Include := 0;
    if Mask.StartsWith('#') then continue;
    if Mask.StartsWith('-') then
    begin
      Include := -1;
    end else
    if Mask.StartsWith('+') then
    begin
      Include := 1;
    end;
    if Include = 0 then
    begin
      raise Exception.Create('Error in line: "' + Entry + '". Lines must start with "+", "-" or "#"');
    end;

    if not MatchesMask(RelativePath, Mask.Substring(1)) then continue;
    if Include = -1 then exit(false);
    if Include = 1 then Result := true;
  end;
end;

class procedure TBDSLauncher.SyncRegistry(const ProductId, Version: string);

  procedure CopyRegistryValue(const SourceReg, TargetReg: TRegistry;
    const SourceKey, TargetKey, ValueName: string);
  begin
    if not SourceReg.OpenKeyReadOnly(SourceKey) then exit;
    try
      if not SourceReg.ValueExists(ValueName) then exit;

      var ValueType := SourceReg.GetDataType(ValueName);

      if not TargetReg.OpenKey(TargetKey, True) then exit;
      try
        case ValueType of
          rdString, rdExpandString:
            TargetReg.WriteString(ValueName, SourceReg.ReadString(ValueName));
          rdInteger:
            TargetReg.WriteInteger(ValueName, SourceReg.ReadInteger(ValueName));
          rdBinary:
            begin
              var ValueSize := SourceReg.GetDataSize(ValueName);
              var ValueData: TBytes;
              SetLength(ValueData, ValueSize);
              if ValueSize > 0 then
              begin
                SourceReg.ReadBinaryData(ValueName, ValueData[0], ValueSize);
                TargetReg.WriteBinaryData(ValueName, ValueData[0], ValueSize);
              end;
            end;
          rdMultiString:
            TargetReg.WriteMultiString(ValueName, SourceReg.ReadMultiString(ValueName));
        end;
      finally
        TargetReg.CloseKey;
      end;
    finally
      SourceReg.CloseKey;
    end;
  end;

  procedure SyncKeyRecursive(const SourceReg, TargetReg: TRegistry;
    const SourceBasePath, TargetBasePath, CurrentRelPath: string;
    const EntriesToSync: TArray<string>);
  begin
    var FullSourcePath := SourceBasePath;
    if CurrentRelPath <> '' then
      FullSourcePath := SourceBasePath + '\' + CurrentRelPath;

    if not SourceReg.OpenKeyReadOnly(FullSourcePath) then exit;

    var SubKeys := TStringList.Create;
    try
      var ValueNames := TStringList.Create;
      try
        SourceReg.GetKeyNames(SubKeys);
        SourceReg.GetValueNames(ValueNames);
        SourceReg.CloseKey;

        // Process values in this key
        for var ValueName in ValueNames do
        begin
          var ValueRelPath := CurrentRelPath;
          if ValueRelPath <> '' then
            ValueRelPath := ValueRelPath + '\' + ValueName
          else
            ValueRelPath := ValueName;

          if IsIncluded(ValueRelPath, EntriesToSync) then
          begin
            var TargetKeyPath := TargetBasePath;
            if CurrentRelPath <> '' then
              TargetKeyPath := TargetBasePath + '\' + CurrentRelPath;
            CopyRegistryValue(SourceReg, TargetReg, FullSourcePath, TargetKeyPath, ValueName);
          end;
        end;

        // Recurse into subkeys
        for var SubKey in SubKeys do
        begin
          var SubRelPath := CurrentRelPath;
          if SubRelPath <> '' then
            SubRelPath := SubRelPath + '\' + SubKey
          else
            SubRelPath := SubKey;

          SyncKeyRecursive(SourceReg, TargetReg, SourceBasePath, TargetBasePath,
              SubRelPath, EntriesToSync);
        end;
      finally
        ValueNames.Free;
      end;
    finally
      SubKeys.Free;
    end;
  end;

begin
  if ProductId = DefaultIDEName then exit;

  var SourceReg := TRegistry.Create;
  try
    SourceReg.RootKey := HKEY_CURRENT_USER;

    // Read the list of registry entries to sync from settings
    if not SourceReg.OpenKeyReadOnly(RegistryKeys.SettingsPath(ProductId)) then exit;
    var EntriesToSync := SourceReg.ReadMultiString(RegistrySettings.RegistryEntriesToSync);
    BDSVariables := TBDSVariables.Create(SourceReg.ReadString(RegistrySettings.SmartSetupWorkingFolder));
    SourceReg.CloseKey;

    if Length(EntriesToSync) = 0 then exit;

    var SourcePath := RegistryKeys.EmbarcaderoEntry(DefaultIDEName, Version);
    var TargetPath := RegistryKeys.EmbarcaderoEntry(ProductId, Version);

    var TargetReg := TRegistry.Create;
    try
      TargetReg.RootKey := HKEY_CURRENT_USER;
      SyncKeyRecursive(SourceReg, TargetReg, SourcePath, TargetPath, '',
        EntriesToSync);
    finally
      TargetReg.Free;
    end;
  finally
    SourceReg.Free;
  end;
end;

class function TBDSLauncher.SyncPath(const ProductId: string): string;
begin
  // Get current PATH
  var CurrentPath := GetEnvironmentVariable('PATH');
  Result := CurrentPath;

  if ProductId = DefaultIDEName then exit;

  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKeyReadOnly(RegistryKeys.SettingsPath(ProductId)) then exit;
    var PathEntriesToSync := Reg.ReadMultiString(RegistrySettings.PathEntriesToSync);
    BDSVariables := TBDSVariables.Create(Reg.ReadString(RegistrySettings.SmartSetupWorkingFolder));
    Reg.CloseKey;

    if Length(PathEntriesToSync) = 0 then exit;

    // Split PATH into individual entries
    var PathEntries := CurrentPath.Split([';']);
    var FilteredPaths: TArray<string> := nil;

    // Filter PATH entries based on include/exclude patterns
    for var PathEntry in PathEntries do
    begin
      var TrimmedEntry := PathEntry.Trim;
      if TrimmedEntry = '' then continue;

      if IsIncluded(TrimmedEntry, PathEntriesToSync) then
        FilteredPaths := FilteredPaths + [TrimmedEntry];
    end;

    Result := string.Join(';', FilteredPaths);
  finally
    Reg.Free;
  end;
end;

class procedure TBDSLauncher.Launch(const ProductId, Version, ExtraBDSParams: string);

  function BuildEnvironmentBlock(const NewPath: string): TBytes;
  begin
    var EnvStrings := TList<string>.Create;
    try
      // Get current environment
      var P0 := GetEnvironmentStrings;
      var P1 := P0;
      try
        while P1^ <> #0 do
        begin
          var EnvVar:= StrPas(P1);
          UniqueString(EnvVar);
          // Replace PATH with our modified version
          if EnvVar.ToUpper.StartsWith('PATH=') then
            EnvStrings.Add('PATH=' + NewPath)
          else
            EnvStrings.Add(EnvVar);
          Inc(P1, Length(EnvVar) + 1);
        end;
      finally
        FreeEnvironmentStrings(P0);
      end;

      // Build double-null terminated block
      var EnvBlock := '';
      for var I := 0 to EnvStrings.Count - 1 do
        EnvBlock := EnvBlock + EnvStrings[I] + #0;
      EnvBlock := EnvBlock + #0;

      // Convert to bytes (Unicode)
      SetLength(Result, Length(EnvBlock) * SizeOf(Char));
      Move(EnvBlock[1], Result[0], Length(Result));
    finally
      EnvStrings.Free;
    end;
  end;

begin
  SyncRegistry(ProductId, Version);

  // Read IDE bitness from settings
  var Bitness := TIDEBitness.Bit32;
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(RegistryKeys.SettingsPath(ProductId)) then
    begin
      if Reg.ValueExists(RegistrySettings.IDEBitness) then
        Bitness := TIDEBitness(Reg.ReadInteger(RegistrySettings.IDEBitness));
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;

  var BDS := FindBDS(ProductId, Version, Bitness);
  if BDS = '' then BDS := FindBDS(DefaultIDEName, Version, Bitness);
  if BDS = '' then
  begin
    ShowError('There is no BDS installed for configuration "' + ProductId + '" , version "' + Version + '"' );
    exit;
  end;
  if not TFile.Exists(BDS) then
  begin
    ShowError('Can''t find the file "' + BDS + '"');
    exit;
  end;

  var BDSParams := '';
  if ProductId <> DefaultIDEName then BDSParams := BDSParams + '"/r' + RegistryKeys.IDEEntry(ProductId) + '" ';
  BDSParams := BDSParams + ExtraBDSParams;

  var NewPath := SyncPath(ProductId);
  var CommandLine := '"' + BDS + '" ' + BDSParams;

  var StartupInfo: TStartupInfo;
  var ProcessInfo: TProcessInformation;
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_SHOWNORMAL;
  ZeroMemory(@ProcessInfo, SizeOf(ProcessInfo));

  var EnvBlock := BuildEnvironmentBlock(NewPath);

  if CreateProcess(nil, PChar(CommandLine), nil, nil, False,
    CREATE_UNICODE_ENVIRONMENT, @EnvBlock[0], nil, StartupInfo, ProcessInfo) then
  begin
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end
  else
    ShowError('Failed to launch BDS: ' + SysErrorMessage(GetLastError));
end;

end.
