unit Model.GlobalSettings;

interface
uses Global.Config, Theme.Colors;

type
  TGlobalSettings = class
  private
    FThemeStyle: TThemeStyle;
    FItemSize: TItemSize;
  public
    property ThemeStyle: TThemeStyle read FThemeStyle write FThemeStyle;
    property ItemSize: TItemSize read FItemSize write FItemSize;
  end;

implementation

end.
