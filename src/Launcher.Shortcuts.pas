unit Launcher.Shortcuts;

interface
uses Global.Config, Model.Entry;

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

  ShellExecute(0, nil, PCHAR(TPath.GetFullPath(Config.ShortcutsImagePath(Entry.Id + '.lnk'))), '', '', SW_SHOWNORMAL);
end;

end.
