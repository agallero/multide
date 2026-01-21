unit Model.DelphiVersions;

interface
type
  TDelphiVersion = record
  public
    Name: string;
    Version: string;

    constructor Create(const aName, aVersion: string);
  end;

  TDelphiVersionList = TArray<TDelphiVersion>;

implementation
{ TDelphiVersion }

constructor TDelphiVersion.Create(const aName, aVersion: string);
begin
  Name := aName;
  Version := aVersion;
end;

end.
