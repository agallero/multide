unit Model.Entry;

interface
uses Classes, SysUtils, Generics.Collections;
type
tdelphiversion =(delphi12);

TEntry = class
  private
    FId: string;
    FIcon: string;
    FDelphiVersion: TDelphiVersion;
    FOtherVersions: TArray<TDelphiVersion>;
    FTmsBuildFiles: TArray<string>;
    FSmartSetupLocation: string;
  public
    property Id: string read FId write FId;
    property DelphiVersion: TDelphiVersion read FDelphiVersion;
    property Icon: string read FIcon write FIcon;
    property OtherVersions: TArray<TDelphiVersion> read FOtherVersions;
    property TmsBuildFiles: TArray<string> read FTmsBuildFiles write FTmsBuildFiles;
    property SmartSetupLocation: string read FSmartSetupLocation write FSmartSetupLocation;

    constructor Create(const aId: string; const aIcon: string);
end;

TEntryList = TObjectList<TEntry>;

implementation

{ TEntry }

constructor TEntry.Create(const aId: string; const aIcon: string);
begin
  FId := aId;
  FIcon := aIcon;
end;

end.
