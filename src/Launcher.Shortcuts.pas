unit Launcher.Shortcuts;

interface
type
  TShorcutLauncher = record
  private
    //class procedure ShowError(const msg: string); static;
  public
    class procedure Launch(const Id: string); static;
  end;

implementation
uses Windows, ShellApi;

{ TShorcutLauncher }

class procedure TShorcutLauncher.Launch(const Id: string);
begin

end;

end.
