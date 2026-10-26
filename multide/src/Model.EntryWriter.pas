unit Model.EntryWriter;

interface
uses Classes, SysUtils, Model.Entry, Model.Persistence;

type
  TModelEntryWriter = record
  public
    class procedure RenameEntry(const OldEntryId, NewEntryId: string); static;
    class procedure SaveAll(const EntryList: TEntryList); static;
    class procedure SaveEntry(const Entry: TEntry; const Position: integer); static;
    class procedure RemoveBut(const EntryList: TEntryList); static;
  end;

implementation
uses Windows, Registry, System.Generics.Collections, System.Generics.Defaults;

function RegRenameKey(hKey: HKEY; lpSubKeyName, lpNewKeyName: LPCWSTR): LONG; stdcall;
  external 'Advapi32.dll' name 'RegRenameKey';

procedure RenameRegistryKeyAPI(const AHive: HKEY; const AParentKeyPath, AOldKeyName, ANewKeyName: string);
var
  ParentKeyHandle: HKEY;
  ResultCode: LONG;
begin
  var ParentKeyPath := AParentKeyPath;
  if ParentKeyPath.StartsWith('\') then ParentKeyPath := ParentKeyPath.Substring(1);

  // Open the parent key where the subkey resides
  ResultCode := RegOpenKeyExW(AHive, PWideChar(ParentKeyPath), 0, KEY_WRITE, ParentKeyHandle);
  if ResultCode <> ERROR_SUCCESS then
    raise ERegistryException.Create('Failed to open parent registry key ' + ParentKeyPath +'. Error code: ' + IntToStr(ResultCode));

  try
    // Execute the native rename command
    ResultCode := RegRenameKey(ParentKeyHandle, PWideChar(AOldKeyName), PWideChar(ANewKeyName));
    if ResultCode <> ERROR_SUCCESS then
      raise ERegistryException.Create('Failed to rename registry key ' + AOldKeyName +' into ' + ANewKeyName + '. Error code: ' + IntToStr(ResultCode));
  finally
    RegCloseKey(ParentKeyHandle);
  end;
end;

{ TModelEntryWriter }

class procedure TModelEntryWriter.RenameEntry(const OldEntryId, NewEntryId: string);
begin
  if SameText(OldEntryId, NewEntryId) then
  begin
    // Registry key names are case-insensitive, so a case-only rename goes through a temporary name.
    var TempId := NewEntryId + '.' + TGUID.NewGuid.ToString;
    RenameRegistryKeyAPI(HKEY_CURRENT_USER, RegistryKeys.RootMultide, OldEntryId, TempId);
    RenameRegistryKeyAPI(HKEY_CURRENT_USER, RegistryKeys.RootMultide, TempId, NewEntryId);
    exit;
  end;

  RenameRegistryKeyAPI(HKEY_CURRENT_USER, RegistryKeys.RootMultide, OldEntryId, NewEntryId);
end;

class procedure TModelEntryWriter.RemoveBut(const EntryList: TEntryList);
begin
  var Entries := THashSet<string>.Create(TIStringComparer.Ordinal);
  try
    for var Entry in EntryList do Entries.Add(Entry.Id);

    var Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;

      if not Reg.OpenKeyReadOnly(RegistryKeys.RootMultide) then exit;
      var List := TStringList.Create;
      try
        Reg.GetKeyNames(List);
        for var Id in List do
        begin
          if not Entries.Contains(Id) then Reg.DeleteKey(Id);
        end;
      finally
        List.Free;
      end;
    finally
      Reg.Free;
    end;
  finally
    Entries.Free;
  end;
end;

class procedure TModelEntryWriter.SaveAll(const EntryList: TEntryList);
begin
  var Position := -1;
  for var Entry in EntryList do
  begin
    inc(Position);
    SaveEntry(Entry, Position);
  end;
end;

class procedure TModelEntryWriter.SaveEntry(const Entry: TEntry; const Position: integer);
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKey(RegistryKeys.SettingsPath(Entry.Id), true) then
    begin
      raise Exception.Create('Cannot open registry key: ' + RegistryKeys.SettingsPath(Entry.Id));
    end;
    Reg.WriteInteger(RegistrySettings.Position, Position);
    Reg.WriteString(RegistrySettings.Icon, Entry.Icon);
    Reg.WriteString(RegistrySettings.DelphiVersionName, Entry.DelphiVersion.Name);
    Reg.WriteString(RegistrySettings.DelphiVersionVersion, Entry.DelphiVersion.Version);
    Reg.WriteString(RegistrySettings.SmartSetupLocation, Entry.SmartSetupLocation);
    Reg.WriteString(RegistrySettings.SmartSetupWorkingFolder, Entry.SmartSetupWorkingFolder);
    Reg.WriteMultiString(RegistrySettings.TmsBuildFiles, Entry.TmsBuildFiles);
    Reg.WriteString(RegistrySettings.ExtraParameters, Entry.ExtraParameters);
    Reg.WriteMultiString(RegistrySettings.RegistryEntriesToSync, Entry.RegistryEntriesToSync);
    Reg.WriteMultiString(RegistrySettings.PathEntriesToSync, Entry.PathEntriesToSync);
    Reg.WriteInteger(RegistrySettings.IDEBitness, Ord(Entry.IDEBitness));
    Reg.WriteInteger(RegistrySettings.IDEDpi, Ord(Entry.IDEDpi));

  finally
    Reg.Free;
  end;
end;

end.
