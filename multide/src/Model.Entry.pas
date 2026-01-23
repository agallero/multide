unit Model.Entry;

interface
uses Classes, SysUtils, Generics.Collections, Model.DelphiVersions;
type
  TIDEBitness = (Bit32, Bit64);

TEntry = class
  private
    FId: string;
    FIcon: string;
    FDelphiVersion: TDelphiVersion;
    FTmsBuildFiles: TArray<string>;
    FSmartSetupLocation: string;
    FSmartSetupWorkingFolder: string;
    FExtraParameters: string;
    FRegistryEntriesToSync: TArray<string>;
    FPathEntriesToSync: TArray<string>;
    FIDEBitness: TIDEBitness;
  public
    property Id: string read FId write FId;
    property Icon: string read FIcon write FIcon;
    property DelphiVersion: TDelphiVersion read FDelphiVersion write FDelphiVersion;
    property TmsBuildFiles: TArray<string> read FTmsBuildFiles write FTmsBuildFiles;
    property SmartSetupLocation: string read FSmartSetupLocation write FSmartSetupLocation;
    property SmartSetupWorkingFolder: string read FSmartSetupWorkingFolder write FSmartSetupWorkingFolder;
    property ExtraParameters: string read FExtraParameters write FExtraParameters;
    property RegistryEntriesToSync: TArray<string> read FRegistryEntriesToSync write FRegistryEntriesToSync;
    property PathEntriesToSync: TArray<string> read FPathEntriesToSync write FPathEntriesToSync;
    property IDEBitness: TIDEBitness read FIDEBitness write FIDEBitness;

    constructor Create(const aId: string);
    class function Clone(const aId: string; const aCopyFrom: TEntry): TEntry; static;
end;

TEntryList = class(TObjectList<TEntry>)
  public
  function ValidateId(const aId: string; const aEntryIndex: integer): string;
  function TryGet(const Index: integer): TEntry;
end;

implementation
uses Model.Persistence;

{ TEntry }

class function TEntry.Clone(const aId: string; const aCopyFrom: TEntry): TEntry;
begin
  Result := TEntry.Create(aId);
  if aCopyFrom = nil then exit;
  Result.FIcon := aCopyFrom.FIcon;
  Result.FDelphiVersion := aCopyFrom.FDelphiVersion;
  Result.FTmsBuildFiles :=  Copy(aCopyFrom.FTmsBuildFiles);
  Result.FSmartSetupLocation := aCopyFrom.FSmartSetupLocation;
  Result.FSmartSetupWorkingFolder := aCopyFrom.FSmartSetupWorkingFolder;
  Result.FExtraParameters := aCopyFrom.FExtraParameters;
  Result.FRegistryEntriesToSync := Copy(aCopyFrom.FRegistryEntriesToSync);
  Result.FPathEntriesToSync := Copy(aCopyFrom.FPathEntriesToSync);
  Result.FIDEBitness := aCopyFrom.FIDEBitness;
end;

constructor TEntry.Create(const aId: string);
begin
  FId := aId;
end;

{ TEntryList }

function TEntryList.TryGet(const Index: integer): TEntry;
begin
  if (Index < 0) or (Index >= Count) then exit(nil);
  Result := Self[Index];
end;

function TEntryList.ValidateId(const aId: string; const aEntryIndex: integer): string;
begin
  Result := '';
  if aEntryIndex = 0 then
  begin
    if aId <> DefaultIDEName then exit('Cannot rename the default ide name.');
    exit;
  end;


  if aId = '' then exit('Cannot be empty.');

  //registry accepts 255, but that's the maximum length of the full path.
  //After this registry entry, there will be subentries that will make it longer.
  if aId.Length + RegistryKeys.EmbarcaderoRoot.Length > 100 then exit('Name is too long.');
  for var c in aId do if (ord(c) < 32) or (c='\') then exit('It has invalid characters.');

  for var i := 0 to Count - 1 do
  begin
    if i = aEntryIndex then continue;
    if SameText(Self[i].Id, aId) then exit('This name already exists.');
  end;
end;

end.
