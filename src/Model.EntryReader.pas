unit Model.EntryReader;

interface
uses Model.Entry, Model.Persistence, Registry, Model.DelphiVersions;

type
  TModelEntryReader = record
  private
    class procedure EnsureDefaults(const Entry: TEntry); static;
  public
    class procedure Load(const Entries: TEntryList); static;
    class procedure LoadFromRegistry(const Entry: TEntry); static;
  end;

implementation
uses SysUtils, Classes, Windows, Global.Config;

{ TModelEntryReader }

class procedure TModelEntryReader.Load(const Entries: TEntryList);
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    Entries.Add(TEntry.Create(DefaultIdeName));
    LoadFromRegistry(Entries.Last);

    if not Reg.OpenKeyReadOnly(RegistryKeys.RootMultide) then exit;
    var List := TStringList.Create;
    try
      Reg.GetKeyNames(List);
      for var Id in List do
      begin
        if Id <> DefaultIDEName then
        begin
          Entries.Add(TEntry.Create(Id));
          LoadFromRegistry(Entries.Last);
        end;
      end;
    finally
      List.Free;
    end;

  finally
    Reg.Free;
  end;
end;

class procedure TModelEntryReader.EnsureDefaults(const Entry: TEntry);
begin
  if Entry.Icon = '' then Entry.Icon := Config.IDEImagePath('parthenon.png');
end;

class procedure TModelEntryReader.LoadFromRegistry(const Entry: TEntry);
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKeyReadOnly(RegistryKeys.SettingsPath(Entry.Id)) then
    begin
      EnsureDefaults(Entry);
      exit;
    end;
    Entry.Icon := Reg.GetDataAsString(RegistrySettings.Icon);
    Entry.DelphiVersion := TDelphiVersion.Create(
      Reg.GetDataAsString(RegistrySettings.DelphiVersionName),
      Reg.GetDataAsString(RegistrySettings.DelphiVersionVersion));
    Entry.SmartSetupLocation := Reg.GetDataAsString(RegistrySettings.SmartSetupLocation);
    Entry.ExtraParamters:= Reg.GetDataAsString(RegistrySettings.ExtraParamters);

    EnsureDefaults(Entry);
  finally
    Reg.Free;
  end;
end;

end.
