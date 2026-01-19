unit Model.EntryWriter;

interface
uses Classes, SysUtils, Model.Entry, Model.Persistence;

type
  TModelEntryWriter = record
  private
    class procedure RemoveExistingEntries; static;
  public
    class procedure RemoveEntry(const EntryId: string); static;
    class procedure SaveAll(const EntryList: TEntryList); static;
    class procedure SaveEntry(const Entry: TEntry; const Position: integer); static;
  end;

implementation
uses Windows, Registry;

{ TModelEntryWriter }

class procedure TModelEntryWriter.RemoveEntry(const EntryId: string);
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.DeleteKey(RegistryKeys.SettingsPath(EntryId))
      then raise Exception.Create('Cannot delete entry ' + RegistryKeys.SettingsPath(EntryId));
  finally
    Reg.Free;
  end;

end;

class procedure TModelEntryWriter.RemoveExistingEntries;
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKeyReadOnly(RegistryKeys.RootMultide) then exit;
    var List := TStringList.Create;
    try
      Reg.GetKeyNames(List);
      for var Id in List do
      begin
        Reg.DeleteKey(Id);
      end;
    finally
      List.Free;
    end;
  finally
    Reg.Free;
  end;
end;

class procedure TModelEntryWriter.SaveAll(const EntryList: TEntryList);
begin
  RemoveExistingEntries;
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

  finally
    Reg.Free;
  end;
end;

end.
