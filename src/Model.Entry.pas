unit Model.Entry;

interface
uses Classes, SysUtils, Generics.Collections, Model.DelphiVersions;
type
TEntry = class
  private
    FId: string;
    FIcon: string;
    FDelphiVersion: TDelphiVersion;
    FTmsBuildFiles: TArray<string>;
    FSmartSetupLocation: string;
    FExtraParameters: string;
  public
    property Id: string read FId write FId;
    property Icon: string read FIcon write FIcon;
    property DelphiVersion: TDelphiVersion read FDelphiVersion write FDelphiVersion;
    property TmsBuildFiles: TArray<string> read FTmsBuildFiles write FTmsBuildFiles;
    property SmartSetupLocation: string read FSmartSetupLocation write FSmartSetupLocation;
    property ExtraParamters: string read FExtraParameters write FExtraParameters;

    constructor Create(const aId: string);
end;

TEntryList = TObjectList<TEntry>;

implementation

{ TEntry }

constructor TEntry.Create(const aId: string);
begin
  FId := aId;
end;

end.
