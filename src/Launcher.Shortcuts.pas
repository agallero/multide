unit Launcher.Shortcuts;

interface
uses Global.Config;

type
  TShorcutLauncher = record
  private
    //class procedure ShowError(const msg: string); static;
  public
    class procedure Launch(const Id: string); static;
  end;

implementation
uses Windows, ShellApi, IOUtils;

{ TShorcutLauncher }

class procedure TShorcutLauncher.Launch(const Id: string);
begin
  ShellExecute(0, nil, PCHAR(TPath.GetFullPath(Config.ShortcutsImagePath(Id + '.lnk'))), '', '', SW_SHOWNORMAL);
end;

end.
