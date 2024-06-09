unit Global.Config;
{$SCOPEDENUMS ON}
interface
type
  TItemSize = (Small, Medium, Big);

  RegistryKeys = record
    public
      const Embarcadero = 'Software\Embarcadero';
  end;

type
  Config = record
  public
    class function IDEImagePath(const FileName: string): string; static;
end;

implementation
uses IOUtils, SysUtils;

{ Config }

class function Config.IDEImagePath(const FileName: string): string;
begin
  Result := TPath.Combine('ide-icons', FileName);
  if not TFile.Exists(Result) then Result := '';
end;

end.
