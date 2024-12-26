unit Model.Entry;

interface
uses Classes, SysUtils, Generics.Collections;
type
  tdelphiversion =(delphi11, delphi12);
const
  DelphiVersionName: Array[TDelphiVersion] of string = ('Delphi 11', 'Delphi 12');

type
TEntry = class
  private
    FId: string;
    FIcon: string;
    FDelphiVersion: TDelphiVersion;
    FOtherVersions: TArray<TDelphiVersion>;
    FTmsBuildFiles: TArray<string>;
    FSmartSetupLocation: string;
    FExtraParameters: string;
  public
    property Id: string read FId write FId;
    property Icon: string read FIcon write FIcon;
    property DelphiVersion: TDelphiVersion read FDelphiVersion;
    property OtherVersions: TArray<TDelphiVersion> read FOtherVersions;
    property TmsBuildFiles: TArray<string> read FTmsBuildFiles write FTmsBuildFiles;
    property SmartSetupLocation: string read FSmartSetupLocation write FSmartSetupLocation;
    property ExtraParamters: string read FExtraParameters write FExtraParameters;

    constructor Create(const aId: string; const aIcon: string);
end;

TEntryList = TObjectList<TEntry>;

implementation

{ TEntry }

constructor TEntry.Create(const aId: string; const aIcon: string);
begin
  FId := aId;
  FIcon := aIcon;
  FDelphiVersion := tdelphiversion.delphi12;
end;

end.
