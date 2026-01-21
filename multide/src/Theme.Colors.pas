unit Theme.Colors;

//Delphi currently can't access the UISettings Interface, so we will have to use the registry.
//See https://gist.github.com/AveYo/80fc6677b9f34939e44364880fbf3768
interface
uses Sysutils, Classes, UITypes;
{$SCOPEDENUMS ON}
type
  TThemeStyle = (Automatic, Light, Dark);

  TThemeColors = record
  private
    FSystemUsesLightTheme: boolean;
    FBackColor: TColor;
    FTextColor: TColor;
    FAltBackColor: TColor;
    FAltTextColor: TColor;

    function GlobalSystemUsesLightTheme: boolean;
    function StartMenuAltTextColor: TColor;
    function StartMenuBackColor: TColor;
    function StartMenuTextColor: TColor;
    function StartMenuAltBackColor: TColor;
  public
    constructor Create(const ThemeStyle: TThemeStyle);

    property SystemUsesLightTheme: boolean read FSystemUsesLightTheme;
    property BackColor: TColor read FBackColor;
    property TextColor: TColor read FTextColor;
    property AltBackColor: TColor read FAltBackColor;
    property AltTextColor: TColor read FAltTextColor;

    function GetBackColor(const UseAlt: boolean): TColor;
    function GetTextColor(const UseAlt: boolean): TColor;
    function GetWindowsTheme: string;

  end;

implementation
uses Windows, Registry, UIConsts;
const EmptyColor = TColor(-1);

function LightenOrDarken(const Color: TColor; const AddPercent: double): TColor;
begin
  var RGB := TColorRec.ColorToRGB(Color);
  var AlphaColor := TAlphaColors.Alpha;
  TAlphaColorRec(AlphaColor).B := (RGB shr 16) and $FF;
  TAlphaColorRec(AlphaColor).G := (RGB shr 8) and $FF;
  TAlphaColorRec(AlphaColor).R := (RGB shr 0) and $FF;
  var H, S, L: single;
  RGBtoHSL(AlphaColor, H, S, L);
  var NewL := L + AddPercent;
  if NewL > 1 then NewL := 1;
  if NewL < 0 then NewL := 0;

  var NewColor := HSLtoRGB(H, S, NewL);
  Result := AlphaColorToColor(NewColor);
end;

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

function TThemeColors.GlobalSystemUsesLightTheme: boolean;
begin
  //default to light if key doesn't exist.
  Result := ReadInteger('SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize', 'SystemUsesLightTheme') <> 0;

end;

function TThemeColors.StartMenuBackColor: TColor;
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
  if SystemUsesLightTheme then Result := $F2F2F2 else Result := $242424;

end;

function TThemeColors.StartMenuTextColor: TColor;
begin
  var Back := TColors.ColorToRGB(StartMenuBackColor);
  var hsp := 0.299 * GetRValue(Back) * GetRValue(Back) + 0.587 * GetGValue(Back) * GetGValue(Back) + 0.114 * GetBValue(Back) * GetBValue(Back);
  if (hsp > 127.5 * 127.5) then exit(TColors.Black);
  Result := TColors.White;
end;

const LightOffset = 0.1;
function TThemeColors.StartMenuAltBackColor: TColor;
begin
  if SystemUsesLightTheme then Result := LightenOrDarken(StartMenuBackColor, LightOffset) else Result := LightenOrDarken(StartMenuBackColor, -LightOffset);
end;

function TThemeColors.StartMenuAltTextColor: TColor;
begin
  if SystemUsesLightTheme then Result := LightenOrDarken(StartMenuTextColor, -LightOffset) else Result := LightenOrDarken(StartMenuTextColor, LightOffset);
end;
{ TThemeColors }

constructor TThemeColors.Create(const ThemeStyle: TThemeStyle);
begin
  case ThemeStyle of
    TThemeStyle.Automatic: FSystemUsesLightTheme := GlobalSystemUsesLightTheme;
    TThemeStyle.Light: FSystemUsesLightTheme := true;
    TThemeStyle.Dark: FSystemUsesLightTheme := false;
  end;

  FBackColor := StartMenuBackColor;
  FTextColor := StartMenuTextColor;
  FAltBackColor := StartMenuAltBackColor;
  FAltTextColor := StartMenuAltTextColor;
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

function TThemeColors.GetWindowsTheme: string;
begin
  if not SystemUsesLightTheme then exit('DarkMode_Explorer');
  exit('Explorer');

end;

end.
