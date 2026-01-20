unit Form.Config;
{$SCOPEDENUMS ON}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPanels, Vcl.ControlList, Vcl.VirtualImage,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Model.Entry, System.ImageList,
  Vcl.ImgList, Vcl.ExtDlgs, JPEG, Vcl.Imaging.pngimage, Vcl.VirtualImageList,
  Model.DelphiVersions, Model.DelphiVersionsReader;

type
  TConfigCard = (Default, General, IDEVersions, SmartSetup);
  TFormConfig = class(TForm)
    CardPanelOptions: TCardPanel;
    CardSmartSetup: TCard;
    edSmartSetupLocation: TLabeledEdit;
    CardGeneral: TCard;
    Splitter1: TSplitter;
    Tabs: TControlList;
    TabsText: TLabel;
    TabsImage: TVirtualImage;
    Images: TImageCollection;
    CardSync: TCard;
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    Panel2: TPanel;
    edConfigName: TLabeledEdit;
    CardIDEVersions: TCard;
    LabelConfFiles: TLabel;
    MemoConfFiles: TMemo;
    LabelIcon: TLabel;
    IdeImage: TImage;
    EmptyImageList: TImageList;
    Shape1: TShape;
    OpenPictureDialog: TOpenPictureDialog;
    edImageFilename: TLabeledEdit;
    AdditionalImageSelect: TButton;
    UIImageList: TVirtualImageList;
    UIImageCollection: TImageCollection;
    cbIDEToLaunch: TComboBox;
    LabelDefaultIDEVersions: TLabel;
    edExtraParams: TLabeledEdit;
    btnBDSInfo: TButton;
    btnChooseSmartSetup: TButton;
    OpenSmartSetupDialog: TFileOpenDialog;
    edSmartSetupWorkingFolder: TLabeledEdit;
    btnWorkingFolder: TButton;
    ChooseWorkingFolderDialog: TFileOpenDialog;
    lblPath: TLabel;
    MemoPath: TMemo;
    Splitter2: TSplitter;
    lblRegistry: TLabel;
    MemoRegistry: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure TabsBeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure TabsItemClick(Sender: TObject);
    procedure ImageContainerClick(Sender: TObject);
    procedure btnBDSInfoClick(Sender: TObject);
    procedure btnChooseSmartSetupClick(Sender: TObject);
    procedure btnWorkingFolderClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    FEntryList: TEntryList;
    FEntryIndex: integer;
    FEntry: TEntry;
    FDelphiVersions: TDelphiVersionList;
    function ValidateConfName(const ConfName: string): string;
    procedure Save;
  public
    procedure SelectCard(const Card: TConfigCard);
    procedure SetIDE(const aEntryList: TEntryList; const aEntryIndex: integer);
  end;

implementation
uses Theme.Manager, Global.Config, Character, Form.Message, IOUtils, Util.Screen,
     ShellAPI, Model.Persistence, Model.EntryWriter, Model.EntryReader, Shortcut.Manager;

{$R *.dfm}

procedure TFormConfig.TabsBeforeDrawItem(AIndex: Integer;
  ACanvas: TCanvas; ARect: TRect; AState: TOwnerDrawState);
begin
  if AIndex < 0 then exit;
  
  TabsImage.ImageIndex := AIndex;
  TabsText.Caption := CardPanelOptions.Cards[AIndex].Caption;
end;

procedure TFormConfig.TabsItemClick(Sender: TObject);
begin
  if Tabs.ItemIndex < 0 then exit;
  CardPanelOptions.ActiveCardIndex := Tabs.ItemIndex;
end;

function TFormConfig.ValidateConfName(const ConfName: string): string;
begin
  Result := FEntryList.ValidateId(ConfName, FEntryIndex);
end;

procedure TFormConfig.btnBDSInfoClick(Sender: TObject);
begin
  ShellExecute(0, '', 'https://docwiki.embarcadero.com/RADStudio/en/IDE_Command_Line_Switches_and_Options', nil, '', SW_SHOWNORMAL);
end;

procedure TFormConfig.btnChooseSmartSetupClick(Sender: TObject);
begin
  try
    OpenSmartSetupDialog.FileName := TPath.GetFullPath(edSmartSetupLocation.Text);
    OpenSmartSetupDialog.DefaultFolder := TPath.GetDirectoryName(TPath.GetFullPath(edSmartSetupLocation.Text));
  except

  end;
  if not OpenSmartSetupDialog.Execute(Self.Handle) then
  begin
    exit;
  end;
  if (OpenSmartSetupDialog.FileName = '') or not TFile.Exists(OpenSmartSetupDialog.FileName) then
    raise Exception.Create('Cannot find the file "' + OpenSmartSetupDialog.FileName + '"');
  edSmartSetupLocation.Text := OpenSmartSetupDialog.FileName;
end;

procedure TFormConfig.btnWorkingFolderClick(Sender: TObject);
begin
  try
    ChooseWorkingFolderDialog.DefaultFolder := TPath.GetFullPath(edSmartSetupWorkingFolder.Text);
  except

  end;
  if not ChooseWorkingFolderDialog.Execute(Self.Handle) then
  begin
    exit;
  end;
  if (ChooseWorkingFolderDialog.FileName = '') or not TDirectory.Exists(ChooseWorkingFolderDialog.FileName) then
    raise Exception.Create('Cannot find the folder "' + ChooseWorkingFolderDialog.FileName + '"');
  edSmartSetupWorkingFolder.Text := ChooseWorkingFolderDialog.FileName;

end;

procedure TFormConfig.Save;
begin
  var ConfName := Trim(edConfigName.Text);
  var Error := ValidateConfName(ConfName);
  if Error <> '' then
  begin
    TFormMessage.Show('Error in the configuration name', 'The configuration name "' + ConfName + '" is not valid. ' + Error, false);
    SelectCard(TConfigCard.General);
    edConfigName.SetFocus;
    ModalResult := mrNone;
    exit;
  end;

  var IconFileName := edImageFilename.Text;
  try
    var RelativeFileName := ExtractRelativePath(TPath.GetFullPath(Application.ExeName), edImageFilename.Text);
    if not RelativeFileName.Contains('..') then IconFileName := RelativeFileName;
  except
  end;

  FEntry.Icon := IconFileName;

  FEntry.SmartSetupLocation := edSmartSetupLocation.Text;
  FEntry.SmartSetupWorkingFolder := edSmartSetupWorkingFolder.Text;
  FEntry.TmsBuildFiles := MemoConfFiles.Lines.ToStringArray;
  FEntry.ExtraParameters := edExtraParams.Text;
  FEntry.PathEntriesToSync := MemoPath.Lines.ToStringArray;
  FEntry.RegistryEntriesToSync := MemoRegistry.Lines.ToStringArray;
  if (cbIDEToLaunch.ItemIndex >= 0) and (cbIDEToLaunch.ItemIndex < Length(FDelphiVersions)) then FEntry.DelphiVersion := FDelphiVersions[cbIDEToLaunch.ItemIndex];

  if ConfName <> FEntry.Id then
  begin
    TModelEntryWriter.RemoveEntry(FEntry.Id);
    TShortcutManager.Remove(FEntry.Id);
    FEntry.Id := ConfName;
  end;


  TModelEntryWriter.SaveEntry(FEntry, FEntryIndex);
  TShortcutManager.Create(FEntry);
end;

procedure TFormConfig.FormActivate(Sender: TObject);
begin
  TThemeManager.UpdateControl(Self);
end;

procedure TFormConfig.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrOk then Save
  else TModelEntryReader.LoadFromRegistry(FEntry);
end;

procedure TFormConfig.FormCreate(Sender: TObject);
begin
  TThemeManager.UpdateControl(Self);
  TScreenUtil.PutInPosition(Self);

  Tabs.ItemCount := CardPanelOptions.CardCount;
  Tabs.ItemIndex := 0;
  CardPanelOptions.ActiveCardIndex := 0;
end;


procedure TFormConfig.ImageContainerClick(Sender: TObject);
begin
  try
    OpenPictureDialog.FileName := TPath.GetFullPath(FEntry.Icon);
    OpenPictureDialog.InitialDir := TPath.GetDirectoryName(TPath.GetFullPath(FEntry.Icon));
  except

  end;
  if not OpenPictureDialog.Execute(Self.Handle) then
  begin
    exit;
  end;
  if (OpenPictureDialog.FileName = '') or not TFile.Exists(OpenPictureDialog.FileName) then
    raise Exception.Create('Cannot find the file "' + OpenPictureDialog.FileName + '"');
  edImageFilename.Text := OpenPictureDialog.FileName;
  IdeImage.Picture.LoadFromFile(edImageFilename.Text);
end;

procedure TFormConfig.SelectCard(const Card: TConfigCard);
begin
  case Card of
    TConfigCard.Default: ;
    TConfigCard.General:
      begin
        CardPanelOptions.ActiveCard := CardGeneral;
        Tabs.Selected[CardGeneral.CardIndex] := true;
      end;
    TConfigCard.IDEVersions:
      begin
        CardPanelOptions.ActiveCard := CardIDEVersions;
        Tabs.Selected[CardIDEVersions.CardIndex] := true;
      end;
    TConfigCard.SmartSetup:
      begin
        CardPanelOptions.ActiveCard := CardSmartSetup;
        Tabs.Selected[CardSmartSetup.CardIndex] := true;
      end;
  end;
end;

procedure TFormConfig.SetIDE(const aEntryList: TEntryList; const aEntryIndex: integer);
begin
  FEntryList := aEntryList;
  FEntryIndex := aEntryIndex;
  FEntry := aEntryList[aEntryIndex];
  Caption := 'Multide configuration for ' + FEntry.Id;
  edConfigName.Text := FEntry.Id;
  try
    if FEntry.Icon.Trim <> '' then IdeImage.Picture.LoadFromFile(FEntry.Icon)
    else IdeImage.Picture := nil;
  except
    IdeImage.Picture := nil;
    ShowMessage('Error loading ' + FEntry.Icon);
  end;

  if FEntry.Icon <> '' then edImageFilename.Text := TPath.GetFullPath(FEntry.Icon) else edImageFilename.Text := '';

  edSmartSetupLocation.Text := FEntry.SmartSetupLocation;
  edSmartSetupWorkingFolder.Text := FEntry.SmartSetupWorkingFolder;
  MemoConfFiles.Text := '';
  MemoConfFiles.Lines.AddStrings(FEntry.TmsBuildFiles);
  edExtraParams.Text := FEntry.ExtraParameters;

  var IsDefault := aEntryIndex = 0;
  MemoPath.Enabled := not IsDefault;
  MemoRegistry.Enabled := not IsDefault;

  MemoPath.Text := '';
  if IsDefault then MemoPath.Text := 'Cannot sync the default configuration'
  else
  begin
    if (FEntry.PathEntriesToSync = nil) then
    begin
      MemoPath.Lines.AddStrings([
        '# lines starting with # are comments',
        '# Start with + or - to include or exclude the path',
        '# You can use wildcards to match parts of the paths',
        '# use $(SmartSetup) variable to pass the SmartSetup path',
        '+$(SmartSetup)\*']);
    end else
    begin
      MemoPath.Lines.AddStrings(FEntry.PathEntriesToSync);
    end;
  end;

  MemoRegistry.Text := '';
  if IsDefault then MemoRegistry.Text := 'Cannot sync the default configuration'
  else
  begin
    if (FEntry.RegistryEntriesToSync = nil) then
    begin
      MemoRegistry.Lines.AddStrings([
        '# lines starting with # are comments',
        '# Start with + or - to include or exclude the registry path',
        '# +Known Packages\$(BDSBIN)\*'
      ]);
    end else
    begin
      MemoRegistry.Lines.AddStrings(FEntry.RegistryEntriesToSync);
    end;
  end;

  FDelphiVersions := TModelDelphiVersionsReader.Read;
  cbIDEToLaunch.Items.Clear;
  for var DelphiVersion in FDelphiVersions do
  begin
    cbIDEToLaunch.Items.Add(DelphiVersion.Name);
    if DelphiVersion.Version = FEntry.DelphiVersion.Version then cbIDEToLaunch.ItemIndex := cbIDEToLaunch.Items.Count - 1;

  end;


end;

end.
