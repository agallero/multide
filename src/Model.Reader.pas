unit Model.Reader;

interface
uses Model.Entry;

type
  TModelReader = record
  public
    class procedure Load(const Entries: TEntryList); static;
  end;

implementation
uses SysUtils, Classes, Windows, Registry, Global.Config;

const
  MultideKeyFolder = 'multide';

{ TModelReader }

class procedure TModelReader.Load(const Entries: TEntryList);
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    Entries.Add(TEntry.Create('Default', Config.IDEImagePath( 'parthenon.png')));

    if not Reg.OpenKeyReadOnly(RegistryKeys.Embarcadero + '\' + MultideKeyFolder) then exit;
    var List := TStringList.Create;
    try
      reg.GetKeyNames(List);
      for var Id in List do
      begin
        var ImageName := 'parthenon.png';
//var ImageName := 'delphi-corp.png';
        var f := Random(5);
        if f = 1 then ImageName := 'helmet-bw.png';
        if f = 3 then ImageName := 'helmet.png';
        //if f = 2 then ImageName := 'columns.png';
        if f = 4 then ImageName := 'bank.png';


        Entries.Add(TEntry.Create(Id, Config.IDEImagePath(ImageName)));
      end;
    finally
      List.Free;
    end;

  finally
    Reg.Free;
  end;
end;

end.
