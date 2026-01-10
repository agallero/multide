unit Shortcut.Manager;

interface
uses Model.Entry;
type
  TShortcutManager = record
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

end.
