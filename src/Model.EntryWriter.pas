unit Model.EntryWriter;

interface
uses Classes, SysUtils, Model.Entry, Model.Persistence;

type
  TModelEntryWriter = record
  public
    class procedure Save(const Entry: TEntry); static;
  end;

implementation
uses Windows, Registry;

{ TModelEntryWriter }

class procedure TModelEntryWriter.Save(const Entry: TEntry);
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKey(RegistryKeys.SettingsPath(Entry.Id), true) then
    begin
      raise Exception.Create('Cannot open registry key: ' + RegistryKeys.SettingsPath(Entry.Id));
    end;
    Reg.WriteString(RegistrySettings.Icon, Entry.Icon);
    Reg.WriteString(RegistrySettings.DelphiVersionName, Entry.DelphiVersion.Name);
    Reg.WriteString(RegistrySettings.DelphiVersionVersion, Entry.DelphiVersion.Version);
    Reg.WriteString(RegistrySettings.SmartSetupLocation, Entry.SmartSetupLocation);
    Reg.WriteString(RegistrySettings.ExtraParamters, Entry.ExtraParamters);

  finally
    Reg.Free;
  end;
end;

end.
