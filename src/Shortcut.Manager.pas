unit Shortcut.Manager;

interface
uses Model.Entry, Generics.Collections;
type
  TShortcutManager = record
    class procedure Remove(const EntryId: string); static;
    class procedure RemoveBut(const EntryList: TEntryList); static;
    class procedure CreateAll(const EntryList: TEntryList); static;
    class procedure Create(const Entry: TEntry); static;
  end;

implementation
uses Classes, SysUtils, Shortcut.Creator, ICO.Creator, Global.Config, IOUtils;

{ TShortcutManager }

class procedure TShortcutManager.Create(const Entry: TEntry);
var
  IconPath: string;
begin
  if SameText(TPath.GetExtension(Entry.Icon), '.ico') then
  begin
    IconPath := TPath.GetFullPath(Entry.Icon);
  end else
  begin
    IconPath := Config.IDEIconPath(Entry.Id + '.ico');
    TDirectory.CreateDirectory(TPath.GetDirectoryName(IconPath));
    TIcoCreator.Convert(TPath.GetFullPath(Entry.Icon), IconPath);
  end;

  var ShortcutLocation := TPath.GetFullPath(Config.ShortcutsImagePath(Entry.Id + '.lnk'));
  TDirectory.CreateDirectory(TPath.GetDirectoryName(ShortcutLocation));
  TShortcutCreator.Create(ShortcutLocation,
     ParamStr(0), '"' + Entry.Id + '" "' + Entry.DelphiVersion.Version + '"', '', Entry.Id, IconPath);
end;

class procedure TShortcutManager.CreateAll(const EntryList: TEntryList);
begin
  for var Entry in EntryList do Create(Entry);

end;

class procedure TShortcutManager.Remove(const EntryId: string);
begin
  var ShortcutLocation := TPath.GetFullPath(Config.ShortcutsImagePath(EntryId + '.lnk'));
  DeleteFile(ShortcutLocation);
  var IcoLocation := TPath.GetFullPath(Config.IDEIconPath(EntryId + '.ico'));
  DeleteFile( IcoLocation);

end;

class procedure TShortcutManager.RemoveBut(const EntryList: TEntryList);
begin
  var Entries := THashSet<string>.Create;
  try
    for var Entry in EntryList do Entries.Add(Entry.Id);
    var IcoFolder := TPath.GetFullPath(Config.IDEIconPath(''));
    if not TDirectory.Exists(IcoFolder) then exit;
    
    var ExistingIcons := TDirectory.GetFiles(IcoFolder, '*.ico');
    for var Icon in ExistingIcons do
    begin
      if Entries.Contains(TPath.GetFileNameWithoutExtension(Icon)) then continue;
      DeleteFile(Icon);
    end;
    var ExistingShortcuts := TDirectory.GetFiles(TPath.GetFullPath(Config.ShortcutsImagePath('')), '*.lnk');
    for var Shortcut in ExistingShortcuts do
    begin
      if Entries.Contains(TPath.GetFileNameWithoutExtension(Shortcut)) then continue;
      DeleteFile(Shortcut);
    end;


  finally
    Entries.Free;
  end;
end;

end.
