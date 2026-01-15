unit Model.GlobalSettingsReader;

interface
uses Model.GlobalSettings, Model.Persistence, Theme.Colors, Global.Config;

type
  TModelGlobalSettingsReader = record
  private
    class function GetThemeStyle(const s: string): TThemeStyle; static;
    class function GetItemSize(const s: string): TItemSize; static;
  public
    class procedure Read(const Entry: TGlobalSettings); static;
  end;

implementation
uses Windows, Registry, SysUtils, Classes;

{ TModelGlobalSettingsReader }

class function TModelGlobalSettingsReader.GetThemeStyle(const s: string): TThemeStyle;
begin
  if s = 'light' then exit(TThemeStyle.Light);
  if s = 'dark' then exit(TThemeStyle.Dark);
  exit (TThemeStyle.Automatic);
end;

class function TModelGlobalSettingsReader.GetItemSize(const s: string): TItemSize;
begin
  if s = 'small' then exit(TItemSize.Small);
  if s = 'big' then exit(TItemSize.Big);
  exit(TItemSize.Medium);
end;

class procedure TModelGlobalSettingsReader.Read(const Entry: TGlobalSettings);
begin
  Entry.ThemeStyle := TThemeStyle.Automatic;
  Entry.ItemSize := TItemSize.Medium;

  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKeyReadOnly(RegistryKeys.RootMultide) then
    begin
      exit;
    end;
    Entry.ThemeStyle := GetThemeStyle(Reg.ReadString(RegistryGlobalSettings.ThemeStyle));
    Entry.ItemSize := GetItemSize(Reg.ReadString(RegistryGlobalSettings.ItemSize));
  finally
    Reg.Free;
  end;

end;

end.
