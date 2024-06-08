unit Form.Config;
{$SCOPEDENUMS ON}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPanels, Vcl.ControlList, Vcl.VirtualImage,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Model.Entry, System.ImageList,
  Vcl.ImgList, Vcl.ExtDlgs, JPEG, Vcl.Imaging.pngimage, Vcl.VirtualImageList;

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
    cbDefaultIDEVersion: TComboBox;
    LabelDefaultIDEVersions: TLabel;
    LabelIDESupported: TLabel;
    lbIDEs: TListBox;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure TabsBeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure TabsItemClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure ImageContainerClick(Sender: TObject);
  private
    FEntry: TEntry;
    function ValidateConfName(const ConfName: string): string;
    { Private declarations }
  public
    procedure SelectCard(const Card: TConfigCard);
    procedure SetIDE(const aEntry: TEntry);
    { Public declarations }
  end;

implementation
uses Theme.Manager, Global.Config, Character, Form.Message, IOUtils;

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
  if ConfName = '' then exit('Cannot be empty.');
  //registry accepts 255, but that's the maximum length of the full path.
  //After this registry entry, there will be subentries that will make it longer.
  if ConfName.Length + RegistryKeys.Embarcadero.Length > 100 then exit('Name is too long.');
  for var c in ConfName do if (ord(c) < 32) or (c='\') then exit('It has invalid characters');
end;

procedure TFormConfig.btnOkClick(Sender: TObject);
begin
  var ConfName := Trim(edConfigName.Text);
  var Error := ValidateConfName(ConfName);
  if Error <> '' then
  begin
    TFormMessage.Show('Error in the configuration name', 'The configuration name "' + ConfName + '" is not valid.' + Error, false);
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

  FEntry.Icon := edImageFilename.Text;

  FEntry.TmsBuildFiles := MemoConfFiles.Lines.ToStringArray;
  FEntry.SmartSetupLocation := edSmartSetupLocation.Text;
end;

procedure TFormConfig.FormCreate(Sender: TObject);
begin
  TThemeManager.UpdateControl(Self);
  Tabs.ItemCount := CardPanelOptions.CardCount;
  Tabs.ItemIndex := 0;
  CardPanelOptions.ActiveCardIndex := 0;

end;


procedure TFormConfig.ImageContainerClick(Sender: TObject);
begin
  if not OpenPictureDialog.Execute then exit;
  if (OpenPictureDialog.FileName = '') or not TFile.Exists(OpenPictureDialog.FileName) then
    raise Exception.Create('Cannot find the file "' + OpenPictureDialog.FileName + '"');
  edImageFilename.Text := OpenPictureDialog.FileName;
  IdeImage.Picture.LoadFromFile(edImageFilename.Text);
  Self.SetFocus;

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

procedure TFormConfig.SetIDE(const aEntry: TEntry);
begin
  FEntry := aEntry;
  Caption := 'Multide configuration for ' + FEntry.Id;
  edConfigName.Text := FEntry.Id;
  try
    if FEntry.Icon.Trim <> '' then IdeImage.Picture.LoadFromFile(FEntry.Icon)
    else IdeImage.Picture := nil;
  except
    IdeImage.Picture := nil;
    ShowMessage('Error loading ' + FEntry.Icon);
  end;
  edImageFilename.Text := FEntry.Icon;

  edSmartSetupLocation.Text := FEntry.SmartSetupLocation;
  MemoConfFiles.Text := '';
  MemoConfFiles.Lines.AddStrings(FEntry.TmsBuildFiles);

end;

end.
