unit Model.EntryReader;

interface
uses Model.Entry, Model.Persistence, Registry, Model.DelphiVersions;

type
  TModelEntryReader = record
  private
    class function GetPosition(const Reg: TRegistry; const Id: string): integer; static;
  public
    class procedure EnsureDefaults(const Entry: TEntry); static;
    class procedure Load(const Entries: TEntryList); static;
    class procedure LoadFromRegistry(const Entry: TEntry); static;
  end;

implementation
uses SysUtils, Classes, Windows, Global.Config, Generics.Defaults, Generics.Collections, Math;
type
  TSortedEntry = record
  public
    Position: integer;
    Id: string;
    class function CompareEntries(const a, b: TSortedEntry): Integer; static;
  end;

{ TModelEntryReader }

class function TModelEntryReader.GetPosition(const Reg: TRegistry; const Id: string): integer;
begin
  Result := 0;
  if not Reg.OpenKeyReadOnly(RegistryKeys.SettingsPath(Id)) then exit;
  if not Reg.ValueExists(RegistrySettings.Position) then exit;

  Result := Reg.ReadInteger(RegistrySettings.Position);
end;

class procedure TModelEntryReader.Load(const Entries: TEntryList);
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    Entries.Add(TEntry.Create(DefaultIdeName));
    LoadFromRegistry(Entries.Last);

    if not Reg.OpenKeyReadOnly(RegistryKeys.RootMultide) then exit;
    var List := TStringList.Create;
    try
      Reg.GetKeyNames(List);
      var SortedEntries: TArray<TSortedEntry> := nil;
      SetLength(SortedEntries, List.Count);
      for var i := 0 to List.Count - 1 do
      begin
        SortedEntries[i].Id := List[i];
        SortedEntries[i].Position := GetPosition(Reg, List[i]);
      end;

      TArray.Sort<TSortedEntry>(SortedEntries, TComparer<TSortedEntry>.Construct(TSortedEntry.CompareEntries));


      for var Sorted in SortedEntries do
      begin
        if Sorted.Id <> DefaultIDEName then
        begin
          Entries.Add(TEntry.Create(Sorted.Id));
          LoadFromRegistry(Entries.Last);
        end;
      end;
    finally
      List.Free;
    end;

  finally
    Reg.Free;
  end;
end;

class procedure TModelEntryReader.EnsureDefaults(const Entry: TEntry);
begin
  if Entry.Icon = '' then Entry.Icon := Config.IDEImagePath('parthenon.png');
end;

class procedure TModelEntryReader.LoadFromRegistry(const Entry: TEntry);
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKeyReadOnly(RegistryKeys.SettingsPath(Entry.Id)) then
    begin
      EnsureDefaults(Entry);
      exit;
    end;
    Entry.Icon := Reg.ReadString(RegistrySettings.Icon);
    Entry.DelphiVersion := TDelphiVersion.Create(
      Reg.ReadString(RegistrySettings.DelphiVersionName),
      Reg.ReadString(RegistrySettings.DelphiVersionVersion));
    Entry.SmartSetupLocation := Reg.ReadString(RegistrySettings.SmartSetupLocation);
    Entry.SmartSetupWorkingFolder := Reg.ReadString(RegistrySettings.SmartSetupWorkingFolder);
    Entry.TmsBuildFiles := Reg.ReadMultiString(RegistrySettings.TmsBuildFiles);
    Entry.ExtraParameters:= Reg.ReadString(RegistrySettings.ExtraParameters);
    Entry.RegistryEntriesToSync := Reg.ReadMultiString(RegistrySettings.RegistryEntriesToSync);
    Entry.PathEntriesToSync := Reg.ReadMultiString(RegistrySettings.PathEntriesToSync);
    if Reg.ValueExists(RegistrySettings.IDEBitness) then
      Entry.IDEBitness := TIDEBitness(Reg.ReadInteger(RegistrySettings.IDEBitness))
    else
      Entry.IDEBitness := TIDEBitness.Bit32;

    EnsureDefaults(Entry);
  finally
    Reg.Free;
  end;
end;

{ TSortedEntry }


{ TSortedEntry }

class function TSortedEntry.CompareEntries(const a, b: TSortedEntry): Integer;
begin
  Result := CompareValue(a.Position, b.Position);
end;

end.
