unit Model.DelphiVersionsReader;

interface
uses Model.DelphiVersions, Model.Persistence;

type
  TModelDelphiVersionsReader = record
  private
    class function GetName(const Version: string): string; static;
  public
    class function Read: TDelphiVersionList; static;
  end;

implementation
uses Windows, Registry, SysUtils, Classes;

{ TModelDelphiVersionsReader }

class function TModelDelphiVersionsReader.GetName(
  const Version: string): string;
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKeyReadOnly(RegistryKeys.EmbarcaderoRoot + '\BDS\' + Version + '\Personalities') then exit('unknown');
    Result := Reg.ReadString('');
  finally
    Reg.Free;
  end;

end;

class function TModelDelphiVersionsReader.Read: TDelphiVersionList;
begin
  Result := nil;
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKeyReadOnly(RegistryKeys.EmbarcaderoRoot + '\BDS') then exit;
    var List := TStringList.Create;
    try
      Reg.GetKeyNames(List);
      for var Version in List do
      begin
        Result := Result + [TDelphiVersion.Create(GetName(Version), Version)];
      end;
    finally
      List.Free;
    end;

  finally
    Reg.Free;
  end;

end;

end.
