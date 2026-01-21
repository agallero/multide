unit Shortcut.Creator;

interface
type
TShortcutCreator = record
public
  class procedure Create(const Location, Target, Arguments, WorkingDir, Description, IconPath: string; const IconIndex: integer = 0); static;
end;

implementation
uses Windows,
  ActiveX,
  SysUtils,
  ShlObj,
  ComObj;


{ TShortcutCreator }

class procedure TShortcutCreator.Create(const Location, Target, Arguments, WorkingDir, Description, IconPath: string; const IconIndex: integer = 0);
begin
  CoInitialize(nil);
  try
    var ShellLink := CreateComObject(CLSID_ShellLink) as IShellLink;

    ShellLink.SetPath(PChar(Target));

    if Arguments <> '' then
      ShellLink.SetArguments(PChar(Arguments));

    if WorkingDir <> '' then
      ShellLink.SetWorkingDirectory(PChar(WorkingDir));

    if Description <> '' then
      ShellLink.SetDescription(PChar(Description));

    if IconPath <> '' then
      ShellLink.SetIconLocation(PChar(IconPath), IconIndex);

    var PersistFile := ShellLink as IPersistFile;
    PersistFile.Save(PWideChar(WideString(Location)), True);
  finally
    CoUninitialize;
  end;
end;

end.
