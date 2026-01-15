unit Model.GlobalSettingsWriter;
interface
uses Classes, SysUtils, Model.GlobalSettings, Model.Persistence, Theme.Colors, Global.Config;

type
  TModelGlobalSettingsWriter = record
  private
    class function GetItemSize(const s: TItemSize): string; static;
    class function GetThemeStyle(const s: TThemeStyle): string; static;
  public
    class procedure Save(const Entry: TGlobalSettings); static;
  end;

implementation
uses Windows, Registry;

{ TModelGlobalSettingsWriter }

class function TModelGlobalSettingsWriter.GetThemeStyle(const s: TThemeStyle): string;
begin
  case s of
    TThemeStyle.Light: exit('light');
    TThemeStyle.Dark: exit('dark');
  end;
  exit('auto');
end;

class function TModelGlobalSettingsWriter.GetItemSize(const s: TItemSize): string;
begin
  case s of
    TItemSize.Small: exit('small');
    TItemSize.Big: exit('big');
  end;
  exit('medium');
end;

class procedure TModelGlobalSettingsWriter.Save(const Entry: TGlobalSettings);
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKey(RegistryKeys.RootMultide, true) then
    begin
      raise Exception.Create('Cannot open registry key: ' + RegistryKeys.RootMultide);
    end;
    Reg.WriteString(RegistryGlobalSettings.ThemeStyle, GetThemeStyle(Entry.ThemeStyle));
    Reg.WriteString(RegistryGlobalSettings.ItemSize, GetItemSize(Entry.ItemSize));

  finally
    Reg.Free;
  end;

end;

end.
