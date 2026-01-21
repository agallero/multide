unit Form.GlobalConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Theme.Manager, Theme.Colors, Util.Screen,
  Vcl.StdCtrls, Vcl.ExtCtrls, Model.GlobalSettings, Global.Config,
  Vcl.ControlList, Vcl.VirtualImage, Vcl.BaseImageCollection,
  Vcl.ImageCollection, System.ImageList, Vcl.ImgList,
  Vcl.VirtualImageList, Model.Entry, Form.AddConfig, Form.Config,
  System.JSON, System.IOUtils, Generics.Collections;

type
  TApplyGlobalSettings = procedure of object;

  TFormGlobalConfig = class(TForm)
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    ButtonVirtualImages: TVirtualImageList;
    ButtonImages: TImageCollection;
    Panel2: TPanel;
    Panel3: TPanel;
    btnExport: TButton;
    btnImport: TButton;
    cbItemSize: TComboBox;
    cbLightMode: TComboBox;
    lblItemSize: TLabel;
    lblLightMode: TLabel;
    IDEList: TControlList;
    IDECaption: TLabel;
    btnAddConfiguration: TButton;
    btnDown: TControlListButton;
    btnUp: TControlListButton;
    btnDelete: TControlListButton;
    btnConfig: TControlListButton;

    procedure FormCreate(Sender: TObject);
    procedure cbLightModeChange(Sender: TObject);
    procedure cbItemSizeChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure IDEListBeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnAddConfigurationClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
  private
    Entries: TEntryList;
    GlobalSettings: TGlobalSettings;
    ApplyGlobalSettings: TApplyGlobalSettings;
    FFormAddConfig: TFormAddConfig;
    FFormConfig: TFormConfig;
    ConfigOpenDialog: TOpenDialog;
    ConfigSaveDialog: TSaveDialog;


    procedure Save;
    function FormAddConfig: TFormAddConfig;
    function FormConfig: TFormConfig;
    function EntriesToJSON: TJSONObject;
    procedure JSONToEntries(const JSON: TJSONObject);

  public
    procedure Initialize(const aEntries: TEntryList; const aGlobalSettings: TGlobalSettings; const aApplyGlobalSettings: TApplyGlobalSettings);
    procedure UpdateControls;
  end;

implementation
uses Model.GlobalSettingsReader, Model.GlobalSettingsWriter,
     Model.EntryReader, Model.EntryWriter, Shortcut.Manager, Model.DelphiVersions;

{$R *.dfm}

procedure TFormGlobalConfig.IDEListBeforeDrawItem(AIndex: Integer;
  ACanvas: TCanvas; ARect: TRect; AState: TOwnerDrawState);
begin
  if (AIndex < 0) or (AIndex >= Entries.Count) then exit;
  var Id := Entries[AIndex].Id;
  IDECaption.Caption := Id;
  btnDelete.Enabled := AIndex <> 0;
  btnUp.Enabled := AIndex > 1;
  btnDown.Enabled := (AIndex <> 0) and (AIndex <> Entries.Count - 1)
end;

procedure TFormGlobalConfig.Initialize(const aEntries: TEntryList;
  const aGlobalSettings: TGlobalSettings; const aApplyGlobalSettings: TApplyGlobalSettings);
begin
  Entries := aEntries;
  GlobalSettings := aGlobalSettings;
  ApplyGlobalSettings := aApplyGlobalSettings;
  IDEList.ItemCount := aEntries.Count;
end;

procedure TFormGlobalConfig.btnAddConfigurationClick(Sender: TObject);
begin
  FormAddConfig.Initialize(Entries);
  if FormAddConfig.ShowModal = mrOk then
  begin
    Entries.Add(TEntry.Clone(FormAddConfig.ConfigName, Entries.TryGet(FormAddConfig.CopyFrom - 1)));
    TModelEntryReader.EnsureDefaults(Entries.Last);

    IDEList.ItemCount := Entries.Count;
    IDEList.Invalidate;
  end;
end;

procedure TFormGlobalConfig.btnConfigClick(Sender: TObject);
begin
  if (IDEList.ItemIndex < 0) or (IDEList.ItemIndex >= Entries.Count) then exit;
  FormConfig.SetIDE(Entries, IDEList.ItemIndex);
  var OriginalIcon := Entries[IDEList.ItemIndex].Icon;
  FormConfig.ShowModal;
end;

procedure TFormGlobalConfig.btnDeleteClick(Sender: TObject);
begin
  if (IDEList.ItemIndex < 1) or (IDEList.ItemIndex >= Entries.Count) then exit;
  Entries.Delete(IDEList.ItemIndex);
  IDEList.ItemCount := IDEList.ItemCount - 1;
end;

procedure TFormGlobalConfig.btnDownClick(Sender: TObject);
begin
  if (IDEList.ItemIndex < 0) or (IDEList.ItemIndex >= Entries.Count - 1) then exit;
  Entries.Move(IDEList.ItemIndex, IDEList.ItemIndex + 1);
  IDEList.Invalidate;
end;

procedure TFormGlobalConfig.btnUpClick(Sender: TObject);
begin
  if (IDEList.ItemIndex < 1) or (IDEList.ItemIndex >= Entries.Count) then exit;
  Entries.Move(IDEList.ItemIndex, IDEList.ItemIndex - 1);
  IDEList.Invalidate;
end;

procedure TFormGlobalConfig.FormActivate(Sender: TObject);
begin
  TThemeManager.UpdateControl(Self);
end;

function TFormGlobalConfig.FormAddConfig: TFormAddConfig;
begin
  if FFormAddConfig = nil then
  begin
    FFormAddConfig := TFormAddConfig.Create(Self);
  end;
  Result := FFormAddConfig;

end;

procedure TFormGlobalConfig.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult = mrOk then Save
  else
  begin
    TModelGlobalSettingsReader.Read(GlobalSettings);
    if Assigned(ApplyGlobalSettings) then ApplyGlobalSettings;
  end;
end;

function TFormGlobalConfig.FormConfig: TFormConfig;
begin
  if FFormConfig = nil then FFormConfig := TFormConfig.Create(Self);
  Result := FFormConfig;
end;

procedure TFormGlobalConfig.FormCreate(Sender: TObject);
begin
  TThemeManager.UpdateControl(Self);
  TScreenUtil.PutInPosition(Self);
end;

procedure TFormGlobalConfig.cbItemSizeChange(Sender: TObject);
begin
  case cbItemSize.ItemIndex of
    0: GlobalSettings.ItemSize := TItemSize.Small;
    1: GlobalSettings.ItemSize := TItemSize.Medium;
    2: GlobalSettings.ItemSize := TItemSize.Big;
  end;
  if Assigned(ApplyGlobalSettings) then ApplyGlobalSettings;
end;

procedure TFormGlobalConfig.cbLightModeChange(Sender: TObject);
begin
  case cbLightMode.ItemIndex of
    0: GlobalSettings.ThemeStyle := TThemeStyle.Automatic;
    1: GlobalSettings.ThemeStyle := TThemeStyle.Light;
    2: GlobalSettings.ThemeStyle := TThemeStyle.Dark;
  end;
  if Assigned(ApplyGlobalSettings) then ApplyGlobalSettings;
  TThemeManager.UpdateControl(Self);
end;

procedure TFormGlobalConfig.Save;
begin
  TModelGlobalSettingsWriter.Save(GlobalSettings);
  TModelEntryWriter.SaveAll(Entries);
  TShortcutManager.RemoveBut(Entries);
  TShortcutManager.CreateAll(Entries);
end;

procedure TFormGlobalConfig.UpdateControls;
begin
  case GlobalSettings.ThemeStyle of
    TThemeStyle.Light: cbLightMode.ItemIndex := 1;
    TThemeStyle.Dark: cbLightMode.ItemIndex := 2;
    else cbLightMode.ItemIndex := 0;
  end;

  case GlobalSettings.ItemSize of
    TItemSize.Small: cbItemSize.ItemIndex := 0;
    TItemSize.Big: cbItemSize.ItemIndex := 2;
    else cbItemSize.ItemIndex := 1;
  end;
  IDEList.ItemCount := Entries.Count;
end;

function TFormGlobalConfig.EntriesToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;

  // Global settings
  var SettingsObj := TJSONObject.Create;
  case GlobalSettings.ThemeStyle of
    TThemeStyle.Light: SettingsObj.AddPair('themeStyle', 'Light');
    TThemeStyle.Dark: SettingsObj.AddPair('themeStyle', 'Dark');
    else SettingsObj.AddPair('themeStyle', 'Automatic');
  end;
  case GlobalSettings.ItemSize of
    TItemSize.Small: SettingsObj.AddPair('itemSize', 'Small');
    TItemSize.Big: SettingsObj.AddPair('itemSize', 'Big');
    else SettingsObj.AddPair('itemSize', 'Medium');
  end;
  Result.AddPair('globalSettings', SettingsObj);

  // Entries
  var EntriesArr := TJSONArray.Create;
  for var Entry in Entries do
  begin
    var EntryObj := TJSONObject.Create;
    EntryObj.AddPair('id', Entry.Id);
    EntryObj.AddPair('icon', Entry.Icon);

    var DelphiObj := TJSONObject.Create;
    DelphiObj.AddPair('name', Entry.DelphiVersion.Name);
    DelphiObj.AddPair('version', Entry.DelphiVersion.Version);
    EntryObj.AddPair('delphiVersion', DelphiObj);

    var BuildFilesArr := TJSONArray.Create;
    for var BuildFile in Entry.TmsBuildFiles do
      BuildFilesArr.Add(BuildFile);
    EntryObj.AddPair('tmsBuildFiles', BuildFilesArr);

    EntryObj.AddPair('smartSetupLocation', Entry.SmartSetupLocation);
    EntryObj.AddPair('smartSetupWorkingFolder', Entry.SmartSetupWorkingFolder);
    EntryObj.AddPair('extraParameters', Entry.ExtraParameters);

    var RegistryEntriesToSyncArr := TJSONArray.Create;
    for var Key in Entry.RegistryEntriesToSync do
      RegistryEntriesToSyncArr.Add(Key);
    EntryObj.AddPair('registryEntriesToSync', RegistryEntriesToSyncArr);

    var PathEntriesToSyncArr := TJSONArray.Create;
    for var Key in Entry.PathEntriesToSync do
      PathEntriesToSyncArr.Add(Key);
    EntryObj.AddPair('pathEntriesToSync', PathEntriesToSyncArr);

    EntriesArr.Add(EntryObj);
  end;
  Result.AddPair('entries', EntriesArr);
end;

procedure TFormGlobalConfig.JSONToEntries(const JSON: TJSONObject);
begin
  // Import global settings
  var SettingsObj := JSON.GetValue<TJSONObject>('globalSettings');
  if SettingsObj <> nil then
  begin
    var ThemeStr := SettingsObj.GetValue<string>('themeStyle', 'Automatic');
    if SameText(ThemeStr, 'Light') then GlobalSettings.ThemeStyle := TThemeStyle.Light
    else if SameText(ThemeStr, 'Dark') then GlobalSettings.ThemeStyle := TThemeStyle.Dark
    else GlobalSettings.ThemeStyle := TThemeStyle.Automatic;

    var SizeStr := SettingsObj.GetValue<string>('itemSize', 'Medium');
    if SameText(SizeStr, 'Small') then GlobalSettings.ItemSize := TItemSize.Small
    else if SameText(SizeStr, 'Big') then GlobalSettings.ItemSize := TItemSize.Big
    else GlobalSettings.ItemSize := TItemSize.Medium;
  end;

  // Import entries
  var EntriesArr := JSON.GetValue<TJSONArray>('entries');
  if EntriesArr = nil then exit;

  // Clear all entries except Default (index 0), then clear Default's settings
  while Entries.Count > 1 do
    Entries.Delete(Entries.Count - 1);

  for var i := 0 to EntriesArr.Count - 1 do
  begin
    var EntryObj := EntriesArr.Items[i] as TJSONObject;
    var EntryId := EntryObj.GetValue<string>('id', '');
    if EntryId = '' then continue;

    var Entry: TEntry;
    if (i = 0) and (Entries.Count > 0) then
    begin
      // Update the Default entry
      Entry := Entries[0];
    end
    else
    begin
      Entry := TEntry.Create(EntryId);
      Entries.Add(Entry);
    end;

    Entry.Icon := EntryObj.GetValue<string>('icon', '');

    var DelphiObj := EntryObj.GetValue<TJSONObject>('delphiVersion');
    if DelphiObj <> nil then
    begin
      var DelphiVer: TDelphiVersion;
      DelphiVer.Name := DelphiObj.GetValue<string>('name', '');
      DelphiVer.Version := DelphiObj.GetValue<string>('version', '');
      Entry.DelphiVersion := DelphiVer;
    end;

    var BuildFilesArr := EntryObj.GetValue<TJSONArray>('tmsBuildFiles');
    if BuildFilesArr <> nil then
    begin
      var BuildFiles: TArray<string>;
      SetLength(BuildFiles, BuildFilesArr.Count);
      for var j := 0 to BuildFilesArr.Count - 1 do
        BuildFiles[j] := BuildFilesArr.Items[j].Value;
      Entry.TmsBuildFiles := BuildFiles;
    end;

    Entry.SmartSetupLocation := EntryObj.GetValue<string>('smartSetupLocation', '');
    Entry.SmartSetupWorkingFolder := EntryObj.GetValue<string>('smartSetupWorkingFolder', '');
    Entry.ExtraParameters := EntryObj.GetValue<string>('extraParameters', '');

    var RegistryEntriesToSyncArr := EntryObj.GetValue<TJSONArray>('registryEntriesToSync');
    if RegistryEntriesToSyncArr <> nil then
    begin
      var Keys: TArray<string>;
      SetLength(Keys, RegistryEntriesToSyncArr.Count);
      for var j := 0 to RegistryEntriesToSyncArr.Count - 1 do
        Keys[j] := RegistryEntriesToSyncArr.Items[j].Value;
      Entry.RegistryEntriesToSync := Keys;
    end;

    var PathEntriesToSyncArr := EntryObj.GetValue<TJSONArray>('pathEntriesToSync');
    if PathEntriesToSyncArr <> nil then
    begin
      var Keys: TArray<string>;
      SetLength(Keys, PathEntriesToSyncArr.Count);
      for var j := 0 to PathEntriesToSyncArr.Count - 1 do
        Keys[j] := PathEntriesToSyncArr.Items[j].Value;
      Entry.PathEntriesToSync := Keys;
    end;
  end;
end;

procedure TFormGlobalConfig.btnExportClick(Sender: TObject);
begin
  if ConfigSaveDialog = nil then
  begin
    ConfigSaveDialog := TSaveDialog.Create(Self);
    ConfigSaveDialog.Title := 'Export Configurations';
    ConfigSaveDialog.Filter := 'JSON Files (*.json)|*.json|All Files (*.*)|*.*';
    ConfigSaveDialog.DefaultExt := 'json';
    ConfigSaveDialog.FileName := 'multide-config.json';
    ConfigSaveDialog.Options := ConfigSaveDialog.Options + [ofOverwritePrompt];
  end;

  if ConfigSaveDialog.Execute then
  begin
    var JSON := EntriesToJSON;
    try
      TFile.WriteAllText(ConfigSaveDialog.FileName, JSON.Format, TEncoding.UTF8);
    finally
      JSON.Free;
    end;
  end;
end;

procedure TFormGlobalConfig.btnImportClick(Sender: TObject);
begin
  if ConfigOpenDialog = nil then
  begin
    ConfigOpenDialog := TOpenDialog.Create(Self);
    ConfigOpenDialog.Title := 'Import Configurations';
    ConfigOpenDialog.Filter := 'JSON Files (*.json)|*.json|All Files (*.*)|*.*';
    ConfigOpenDialog.DefaultExt := 'json';
  end;

  if ConfigOpenDialog.Execute then
  begin
    try
      var Content := TFile.ReadAllText(ConfigOpenDialog.FileName, TEncoding.UTF8);
      var JSON := TJSONObject.ParseJSONValue(Content) as TJSONObject;
      if JSON = nil then
      begin
        ShowMessage('Invalid configuration file.');
        exit;
      end;

      try
        JSONToEntries(JSON);
        UpdateControls;
        if Assigned(ApplyGlobalSettings) then ApplyGlobalSettings;
        TThemeManager.UpdateControl(Self);
      finally
        JSON.Free;
      end;
    except
      on E: Exception do
        ShowMessage('Error importing configuration: ' + E.Message);
    end;
  end;
end;

end.
