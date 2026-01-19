unit Launcher.BDS;

interface
uses Classes, SysUtils;

type
  TBDSLauncher = record
  private
    class function FindBDS(const ProductId, Version: string): string; static;
    class procedure ShowError(const msg: string); static;
    class procedure SyncRegistry(const ProductId, Version: string); static;
  public
    class procedure Launch(const ProductId, Version, ExtraBDSParams: string); static;
  end;

implementation
uses Forms, ShellApi, Windows, Registry, Global.Config, IOUtils, Dialogs, Model.Persistence, Masks;

{ TBDSLauncher }

class procedure TBDSLauncher.ShowError(const msg: string);
begin
  MessageBox(0, PCHAR(msg), 'MultIDE', MB_OK or MB_ICONERROR);
end;

class function TBDSLauncher.FindBDS(const ProductId, Version: string): string;
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKeyReadOnly(RegistryKeys.EmbarcaderoEntry(ProductId, Version)) then exit('');
    Result := Reg.ReadString('App');
  finally
    Reg.Free;
  end;

end;

function IsIncluded(const RelativePath: string;
  const EntriesToSync: TArray<string>): Boolean;
begin
  Result := False;
  for var Entry in EntriesToSync do
  begin
    var Mask := Entry.Trim;
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

class procedure TBDSLauncher.Launch(const ProductId, Version, ExtraBDSParams: string);
begin
  SyncRegistry(ProductId, Version);

  var BDS := FindBDS(ProductId, Version);
  if BDS = '' then BDS := FindBDS(DefaultIDEName, Version);
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

  //todo: change windows path
  //SetEnvironment to change path. see https://stackoverflow.com/questions/17100920/whether-shellexecute-will-share-environment-variable-with-launching-process
  //or use shellexecuteex.
  ShellExecute(0, nil, PCHAR(BDS), PCHAR(BDSParams), '', SW_SHOWNORMAL);
end;

end.
