unit Launcher.Shortcuts;

interface
uses SysUtils, Global.Config, Model.Entry;

type
  TShorcutLauncher = record
  private
    //class procedure ShowError(const msg: string); static;
  public
    class procedure Launch(const Entry: TEntry); static;
  end;

implementation
uses Windows, ShellApi, IOUtils;

{ TShorcutLauncher }

class procedure TShorcutLauncher.Launch(const Entry: TEntry);
begin
  var ShortcutFile := Config.ShortcutsImagePath(Entry.Id + '.lnk');
  if not TFile.Exists(ShortcutFile) then raise Exception.Create('Cannot launch the configuration. Verify there is a RAD studio version selected.');


  ShellExecute(0, nil, PCHAR(ShortcutFile), '', '', SW_SHOWNORMAL);
end;

end.
