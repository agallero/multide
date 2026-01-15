unit Form.GlobalConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Theme.Manager, Theme.Colors, Util.Screen,
  Vcl.StdCtrls, Vcl.ExtCtrls, Model.GlobalSettings, Global.Config,
  Vcl.ControlList, Vcl.VirtualImage, Vcl.BaseImageCollection,
  Vcl.ImageCollection, System.ImageList, Vcl.ImgList,
  Vcl.VirtualImageList, Model.Entry, Form.AddConfig, Form.Config;

type
  TApplyGlobalSettings = procedure of object;

  TFormGlobalConfig = class(TForm)
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    rbItemSize: TRadioGroup;
    rbLightMode: TRadioGroup;
    IDEList: TControlList;
    IDECaption: TLabel;
    btnDelete: TControlListButton;
    btnConfig: TControlListButton;
    ButtonVirtualImages: TVirtualImageList;
    ButtonImages: TImageCollection;
    btnDown: TControlListButton;
    btnUp: TControlListButton;
    btnAddConfiguration: TButton;
    btnExport: TButton;
    btnImport: TButton;
    procedure FormCreate(Sender: TObject);
    procedure rbLightModeClick(Sender: TObject);
    procedure rbItemSizeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure IDEListBeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnAddConfigurationClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
  private
    Entries: TEntryList;
    GlobalSettings: TGlobalSettings;
    ApplyGlobalSettings: TApplyGlobalSettings;
    FFormAddConfig: TFormAddConfig;
    FFormConfig: TFormConfig;

    procedure Save;
    function FormAddConfig: TFormAddConfig;
    function FormConfig: TFormConfig;

  public
    procedure Initialize(const aEntries: TEntryList; const aGlobalSettings: TGlobalSettings; const aApplyGlobalSettings: TApplyGlobalSettings);
    procedure UpdateControls;
  end;

implementation
uses Model.GlobalSettingsReader, Model.GlobalSettingsWriter,
     Model.EntryReader, Model.EntryWriter, Shortcut.Manager;

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

procedure TFormGlobalConfig.rbItemSizeClick(Sender: TObject);
begin
  case rbItemSize.ItemIndex of
    0: GlobalSettings.ItemSize := TItemSize.Small;
    1: GlobalSettings.ItemSize := TItemSize.Medium;
    2: GlobalSettings.ItemSize := TItemSize.Big;
  end;
  if Assigned(ApplyGlobalSettings) then ApplyGlobalSettings;
end;

procedure TFormGlobalConfig.rbLightModeClick(Sender: TObject);
begin
  case rbLightMode.ItemIndex of
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
    TThemeStyle.Light: rbLightMode.ItemIndex := 1;
    TThemeStyle.Dark: rbLightMode.ItemIndex := 2;
    else rbLightMode.ItemIndex := 0;
  end;

  case GlobalSettings.ItemSize of
    TItemSize.Small: rbItemSize.ItemIndex := 0;
    TItemSize.Big: rbItemSize.ItemIndex := 2;
    else rbItemSize.ItemIndex := 1;
  end;
  IDEList.ItemCount := Entries.Count;
end;

end.
