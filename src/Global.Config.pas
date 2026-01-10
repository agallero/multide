unit Global.Config;
{$SCOPEDENUMS ON}
interface
type
  TItemSize = (Small, Medium, Big);

type
  Config = record
  public
    class function IDEImagePath(const FileName: string): string; static;
    class function ShortcutsImagePath(const FileName: string): string; static;
end;

implementation
uses IOUtils, SysUtils;

{ Config }

class function Config.ShortcutsImagePath(const FileName: string): string;
begin
  Result := TPath.Combine('ide-shortcuts', FileName);
  if not TFile.Exists(Result) then Result := '';
end;

class function Config.IDEImagePath(const FileName: string): string;
begin
  Result := TPath.Combine('ide-icons', FileName);
  if not TFile.Exists(Result) then Result := '';
end;

end.
