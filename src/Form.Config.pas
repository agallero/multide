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
    Button3: TButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure TabsBeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure TabsItemClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure ImageContainerClick(Sender: TObject);
    procedure btnBDSInfoClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FEntryList: TEntryList;
    FEntryIndex: integer;
    FEntry: TEntry;
    FDelphiVersions: TDelphiVersionList;
    function ValidateConfName(const ConfName: string): string;
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
  Result := '';
  if FEntryIndex = 0 then
  begin
    if ConfName <> DefaultIDEName then exit('Cannot rename the default ide name.');
    exit;
  end;

  if ConfName = '' then exit('Cannot be empty.');

  //registry accepts 255, but that's the maximum length of the full path.
  //After this registry entry, there will be subentries that will make it longer.
  if ConfName.Length + RegistryKeys.EmbarcaderoRoot.Length > 100 then exit('Name is too long.');
  for var c in ConfName do if (ord(c) < 32) or (c='\') then exit('It has invalid characters.');

  for var i := 0 to FEntryList.Count - 1 do
  begin
    if i = FEntryIndex then continue;
    if SameText(FEntryList[i].Id, ConfName) then exit('This name already exists.');
  end;
end;

procedure TFormConfig.btnBDSInfoClick(Sender: TObject);
begin
  ShellExecute(0, '', 'https://docwiki.embarcadero.com/RADStudio/en/IDE_Command_Line_Switches_and_Options', nil, '', SW_SHOWNORMAL);
end;

procedure TFormConfig.btnCancelClick(Sender: TObject);
begin
  TModelEntryReader.LoadFromRegistry(FEntry);
end;

procedure TFormConfig.btnOkClick(Sender: TObject);
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

  if ConfName <> FEntry.Id then
  begin
    FEntry.Id := ConfName;
    //rename registry key and my docs.
  end;

  var IconFileName := edImageFilename.Text;
  try
    var RelativeFileName := ExtractRelativePath(TPath.GetFullPath(Application.ExeName), edImageFilename.Text);
    if not RelativeFileName.Contains('..') then IconFileName := RelativeFileName;
  except
  end;

  FEntry.Icon := IconFileName;

  FEntry.TmsBuildFiles := MemoConfFiles.Lines.ToStringArray;
  FEntry.SmartSetupLocation := edSmartSetupLocation.Text;
  FEntry.ExtraParamters := edExtraParams.Text;
  if (cbIDEToLaunch.ItemIndex >= 0) and (cbIDEToLaunch.ItemIndex < Length(FDelphiVersions)) then FEntry.DelphiVersion := FDelphiVersions[cbIDEToLaunch.ItemIndex];
  TModelEntryWriter.Save(FEntry);
  TShortcutManager.Create(FEntry);
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
  MemoConfFiles.Text := '';
  MemoConfFiles.Lines.AddStrings(FEntry.TmsBuildFiles);
  edExtraParams.Text := FEntry.ExtraParamters;

  FDelphiVersions := TModelDelphiVersionsReader.Read;
  cbIDEToLaunch.Items.Clear;
  for var DelphiVersion in FDelphiVersions do
  begin
    cbIDEToLaunch.Items.Add(DelphiVersion.Name);
    if DelphiVersion.Version = FEntry.DelphiVersion.Version then cbIDEToLaunch.ItemIndex := cbIDEToLaunch.Items.Count - 1;

  end;


end;

end.
