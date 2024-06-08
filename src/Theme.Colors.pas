unit Theme.Colors;

//Delphi currently can't access the UISettings Interface, so we will have to use the registry.
//See https://gist.github.com/AveYo/80fc6677b9f34939e44364880fbf3768
interface
uses Sysutils, Classes, UITypes;

type
  TThemeColors = record
    private
      FSystemUsesLightTheme: boolean;
      FBackColor: TColor;
      FTextColor: TColor;
      FAltBackColor: TColor;
      FAltTextColor: TColor;
    public
      constructor Create(const UseTheme: boolean);

      property SystemUsesLightTheme: boolean read FSystemUsesLightTheme;
      property BackColor: TColor read FBackColor;
      property TextColor: TColor read FTextColor;
      property AltBackColor: TColor read FAltBackColor;
      property AltTextColor: TColor read FAltTextColor;

      function GetBackColor(const UseAlt: boolean): TColor;
      function GetTextColor(const UseAlt: boolean): TColor;

  end;

implementation
uses Windows, Registry;
const EmptyColor = TColor(-1);

function ReadInteger(const Key, Value: string): Integer;
begin
  Result := -1;
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(Key) and Reg.ValueExists(Value)
      then exit(Reg.ReadInteger(Value));
  finally
    Reg.Free;
  end;

end;

function GlobalSystemUsesLightTheme: boolean;
begin
  //default to light if key doesn't exist.
  Result := ReadInteger('SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize', 'SystemUsesLightTheme') <> 0;

end;

function StartMenuBackColor: TColor;
begin
  var UseAccentColorInStartMenuInt := ReadInteger('SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize', 'ColorPrevalence');
  if UseAccentColorInStartMenuInt = -1 then exit(EmptyColor);
  var UseAccentColorInStartMenu := UseAccentColorInStartMenuInt = 1;
  if UseAccentColorInStartMenu then
  begin
    Result := TColor(ReadInteger('Software\Microsoft\Windows\CurrentVersion\Explorer\Accent',
          'StartColorMenu') and $FFFFFF);
    exit;
  end;


  //This is in my machine, not sure on how to read those values.
  if GlobalSystemUsesLightTheme then Result := $F2F2F2 else Result := $242424;

end;

function StartMenuTextColor: TColor;
begin
  var Back := TColors.ColorToRGB(StartMenuBackColor);
  var hsp := 0.299 * GetRValue(Back) * GetRValue(Back) + 0.587 * GetGValue(Back) * GetGValue(Back) + 0.114 * GetBValue(Back) * GetBValue(Back);
  if (hsp > 127.5 * 127.5) then exit(TColors.Black);
  Result := TColors.White;
end;

function StartMenuAltBackColor: TColor;
begin
  if GlobalSystemUsesLightTheme then Result := $FFFFFF else Result := 0;

end;
function StartMenuAltTextColor: TColor;
begin
  if GlobalSystemUsesLightTheme then Result := 0 else Result := $FFFFFF;
end;
{ TThemeColors }

constructor TThemeColors.Create(const UseTheme: boolean);
begin
  if UseTheme then
  begin
    FSystemUsesLightTheme := GlobalSystemUsesLightTheme;
    FBackColor := StartMenuBackColor;
    FTextColor := StartMenuTextColor;
    FAltBackColor := StartMenuAltBackColor;
    FAltTextColor := StartMenuAltTextColor;
  end
  else
  begin
    FSystemUsesLightTheme := true;
    FBackColor := -1;
    FTextColor := -1;
    FAltBackColor := -1;
    FAltTextColor := -1;
  end;


end;

function TThemeColors.GetBackColor(const UseAlt: boolean): TColor;
begin
  if UseAlt then exit(AltBackColor);
  Result := BackColor;
end;

function TThemeColors.GetTextColor(const UseAlt: boolean): TColor;
begin
  if UseAlt then exit(AltTextColor);
  Result := TextColor;
end;

end.
