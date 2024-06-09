unit Form.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts, Math,
  Vcl.StdCtrls, System.Win.TaskbarCore, Vcl.Taskbar, Vcl.ComCtrls,
  Vcl.ControlList, Vcl.VirtualImage, Model.Entry, Vcl.BaseImageCollection,
  Vcl.ImageCollection, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList,
  Form.Config, Form.Message, Vcl.Menus, Vcl.ExtCtrls, Form.Build, Util.Screen, Global.Config;

type
  TFormMain = class(TForm)
    ApplicationEvents: TApplicationEvents;
    WinTaskbar: TTaskbar;
    IDEList: TControlList;
    IDEImage: TVirtualImage;
    IDECaption: TLabel;
    btnUpdateComponents: TControlListButton;
    btnConfig: TControlListButton;
    IDEImages: TImageCollection;
    ButtonImages: TImageCollection;
    ButtonVirtualImages: TVirtualImageList;
    IDEVersion: TControlListButton;
    PopupVersions: TPopupMenu;
    AppPopupMenu: TPopupMenu;
    btnSmall: TMenuItem;
    btnMedium: TMenuItem;
    btnBig: TMenuItem;
    N1: TMenuItem;
    GlobalConfigButton: TMenuItem;
    PopConfig: TPopupMenu;
    btnConfigurationFor: TMenuItem;
    btnGlobalConfiguration: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure ApplicationEventsDeactivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure IDEListBeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure IDEListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnConfigClick(Sender: TObject);
    procedure btnUpdateComponentsClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure IDEVersionClick(Sender: TObject);
    procedure DelphiVersionsClick(Sender: TObject);
    procedure DelphiVersionsEdit(Sender: TObject);
    procedure BtnGlobalConfigClick(Sender: TObject);
    procedure IDEListItemClick(Sender: TObject);
    procedure btnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnSmallClick(Sender: TObject);
    procedure btnMediumClick(Sender: TObject);
    procedure btnBigClick(Sender: TObject);
    procedure btnConfigurationForClick(Sender: TObject);
  private
    Entries: TEntryList;
    InModalDialog: boolean;
    FFormConfig: TFormConfig;
    FFormBuild: TFormBuild;
    ControlClicked: boolean;
    ItemSize: TItemSize;


    procedure LoadIDEs;
    procedure LoadIDEIcons;
    procedure RunSelected;
    function FormConfig: TFormConfig;
    function FormBuild: TFormBuild;
    procedure ShowLocalConfig(const Card: TConfigCard);
    procedure ShowMessage(const aCaption, aText: string);
    procedure FillVersionsMenu(const Menu: TPopupMenu);
    procedure ShowCaptions;
    procedure DoBuild;
    procedure DoAllConfig;
    procedure DoLocalConfig;
    procedure DoGlobalConfig;
    procedure SetItemSize(const ItemSize: TItemSize);
    function ItemIndexWrong: boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation
uses Theme.Manager, Model.Reader, IOUtils, Generics.Defaults,
     Generics.Collections, Launcher.Shortcuts;

{$R *.dfm}

procedure TFormMain.ApplicationEventsDeactivate(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.LoadIDEs;
begin
  TModelReader.Load(Entries);
  IDEList.ItemCount := Entries.Count;
end;

procedure TFormMain.LoadIDEIcons;
begin
  IDEImages.Images.Clear;
  var AlreadyLoaded := THashSet<string>.Create(TIStringComparer.Ordinal);
  for var Entry in Entries do
  begin
    var IconName := TPath.GetFileName(Entry.Icon);
    if AlreadyLoaded.Contains(IconName) then continue;
    AlreadyLoaded.Add(IconName);
    if IconName <> '' then
    begin
      var ExistingImages := IDEImages.Images.Count;
      try
        IDEImages.Add(IconName, Entry.Icon);
      except
        //Nothing, we couldn't load the image. But it could have loaded something invalid anyway.
        if ExistingImages < IDEImages.Images.Count then
        begin
          IDEImages.Delete(IDEImages.Images.Count - 1);
        end;
      end;
    end;
  end;

end;


procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not InModalDialog;
end;

function TFormMain.FormBuild: TFormBuild;
begin
  if FFormBuild = nil then FFormBuild := TFormBuild.Create(Self);
  Result := FFormBuild;
end;

function TFormMain.FormConfig: TFormConfig;
begin
  if FFormConfig = nil then FFormConfig := TFormConfig.Create(Self);
  Result := FFormConfig;
end;

procedure TFormMain.SetItemSize(const ItemSize: TItemSize);
begin
  case ItemSize of
    TItemSize.Small:
      begin
        IDEList.ItemHeight := ScaleValue(30);
        IDEImage.Width := ScaleValue(25);
        IDEImage.Height := ScaleValue(25);
        IDEImage.Margins.Top := ScaleValue(4);
        IDEImage.Margins.Bottom := ScaleValue(4);
        IDECaption.Font.Height := ScaleValue(-14);
        IDECaption.Top := ScaleValue(6);
        IDECaption.Left := ScaleValue(40);
        IDEVersion.Visible := false;
      end;

    TItemSize.Medium:
      begin
        IDEList.ItemHeight := ScaleValue(56);
        IDEImage.Width := ScaleValue(50);
        IDEImage.Height := ScaleValue(50);
        IDEImage.Margins.Top := ScaleValue(8);
        IDEImage.Margins.Bottom := ScaleValue(8);
        IDECaption.Font.Height := ScaleValue(19);
        IDECaption.Top := ScaleValue(8);
        IDECaption.Left := ScaleValue(90);
        IDEVersion.Visible := true;
        IDEVersion.Left := ScaleValue(90);
        IDEVersion.Top := ScaleValue(24);
      end;
    TItemSize.Big:
      begin
        IDEList.ItemHeight := ScaleValue(80);
        IDEImage.Width := ScaleValue(64);
        IDEImage.Height := ScaleValue(64);
        IDEImage.Margins.Top := ScaleValue(12);
        IDEImage.Margins.Bottom := ScaleValue(12);
        IDECaption.Font.Height := ScaleValue(-22);
        IDECaption.Top := ScaleValue(13);
        IDECaption.Left := ScaleValue(106);
        IDEVersion.Visible := true;
        IDEVersion.Left := ScaleValue(106);
        IDEVersion.Top := ScaleValue(30);
      end;

  end;

end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Entries := TEntryList.Create;
  LoadIDEs;
  ItemSize := TItemSize.Medium;
  SetItemSize(ItemSize);

  TScreenUtil.PutInPosition(Self, IDEList.ItemHeight, IDEList.ItemCount);
  TThemeManager.UpdateControl(Self);
  SetWindowLong(handle, GWL_EXSTYLE,
     GetWindowLong( application.handle, GWL_EXSTYLE )
     or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW and not WS_CAPTION);
  LoadIDEIcons;

end;

procedure TFormMain.FormDeactivate(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  Entries.Free;
end;

procedure TFormMain.ShowCaptions;
begin
  if btnUpdateComponents.Caption <> '' then exit;
  btnUpdateComponents.Caption := '(&B)uild';
  btnUpdateComponents.Width := 160;
  btnConfig.Caption := '(&C)onfig';
  btnConfig.Width := 160;
  IDECaption.Width := IDECaption.Width - 80;
end;

procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then close;
  ShowCaptions; //if the user is using the keys, we will show them a way to press the buttons.
  if Char(Key) = 'B' then DoBuild;
  if Char(Key) = 'C' then DoAllConfig;
  if Char(Key) = 'G' then DoGlobalConfig;
end;

procedure TFormMain.IDEListBeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
  ARect: TRect; AState: TOwnerDrawState);
begin
  if (AIndex < 0) or (AIndex >= Entries.Count) then exit;
  IDECaption.Caption := Entries[AIndex].Id;
  IDEImage.ImageName := TPath.GetFileName(Entries[AIndex].Icon);
  IDEVersion.Caption := 'Delphi 12';//Entries[AIndex].DelphiVersion';
  IDEVersion.Width := ACanvas.TextWidth(IDEVersion.Caption);
end;

procedure TFormMain.IDEListItemClick(Sender: TObject);
begin
  if not ControlClicked then RunSelected;
end;

function TFormMain.ItemIndexWrong: boolean;
begin
  Result := (IDEList.ItemIndex < 0) or (IDEList.ItemIndex >= Entries.Count);
end;

procedure TFormMain.RunSelected;
begin
  if ItemIndexWrong then exit;

  var Entry := Entries[IDEList.ItemIndex];
  TShorcutLauncher.Launch(Entry.Id);
  Close;

end;

procedure TFormMain.IDEListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then RunSelected;

end;

procedure TFormMain.FillVersionsMenu(const Menu: TPopupMenu);
begin
  Menu.Items.Clear;
  for var i := 1 to Random (12) do
  begin
    Menu.Items.Add(TMenuItem.Create(Menu));
    var MenuItem := Menu.Items[Menu.Items.Count - 1];
    MenuItem.Caption := 'Delphi ' + IntToStr(i);
    MenuItem.Tag := i; //delphiversion here.
    MenuItem.OnClick := DelphiVersionsClick;
  end;

  Menu.Items.Add(TMenuItem.Create(Menu));
  var MenuItem := Menu.Items[Menu.Items.Count - 1];
  MenuItem.Caption := '-';
  MenuItem.OnClick := DelphiVersionsEdit;

  Menu.Items.Add(TMenuItem.Create(Menu));
  MenuItem := Menu.Items[Menu.Items.Count - 1];
  MenuItem.Caption := 'Edit...';
  MenuItem.OnClick := DelphiVersionsEdit;

end;

procedure TFormMain.IDEVersionClick(Sender: TObject);
begin
  var Menu := (Sender as TControlListButton).PopupMenu;
  FillVersionsMenu(Menu);
  Menu.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TFormMain.ShowLocalConfig(const Card: TConfigCard);
begin
  if ItemIndexWrong then exit;

  InModalDialog := true;
  try
    FormConfig.SelectCard(Card);
    FormConfig.SetIDE(Entries[IDEList.ItemIndex]);
    var OriginalIcon := Entries[IDEList.ItemIndex].Icon;
    FormConfig.ShowModal;
    if OriginalIcon <> Entries[IDEList.ItemIndex].Icon then LoadIDEIcons;

  finally
    InModalDialog := false;
  end;
end;

procedure TFormMain.ShowMessage(const aCaption, aText: string);
begin
  InModalDialog := true;
  try
    TFormMessage.Show(aCaption, aText, true);
  finally
    InModalDialog := false;
  end;
end;

procedure TFormMain.DoLocalConfig;
begin
  ShowLocalConfig(TConfigCard.Default);
end;


procedure TFormMain.btnConfigClick(Sender: TObject);
begin
  DoAllConfig;
end;

procedure TFormMain.DoGlobalConfig;
begin
  //ShowConfig(TConfigCard.Default);
end;


procedure TFormMain.BtnGlobalConfigClick(Sender: TObject);
begin
  //Globalconfig will be donde from local config, to keep the main UI clean.
  //it shuold have a dark mode selector, a config selector.(+/- IDE configurations)
  DoGlobalConfig;
end;

procedure TFormMain.DoAllConfig;
begin
  if ItemIndexWrong then
  begin
    btnConfigurationFor.Caption := '-';
  end
  else
  begin
    //Caption can't start with C because we already pressed C in WmKeyDown, so
    //This will be selected by default. We could always use "C&onfiguration' so
    //The key is o instead of C. But C for config, and then C for local config doesn't work.
    btnConfigurationfor.Caption := 'Local Configuration for ' +  Entries[IDEList.ItemIndex].Id;
  end;
  PopConfig.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TFormMain.DoBuild;
begin
  if ItemIndexWrong then exit;

  if (Entries[IDEList.ItemIndex].TmsBuildFiles = nil) or (Entries[IDEList.ItemIndex].SmartSetupLocation.Trim = '') then
  begin
    ShowMessage('Missing configuration', 'Smart Setup is not configured for this IDE. To compile the components, you need to configure it first');
    ShowLocalConfig(TConfigCard.SmartSetup);
    exit;
  end;

  InModalDialog := true;
  try
    FormBuild.SetIDE(Entries[IDEList.ItemIndex]);
    FormBuild.ShowModal;
  finally
    InModalDialog := false;
  end;

end;

procedure TFormMain.btnUpdateComponentsClick(Sender: TObject);
begin
  DoBuild;
end;

procedure TFormMain.btnConfigurationForClick(Sender: TObject);
begin
  DoLocalConfig;
end;

procedure TFormMain.btnSmallClick(Sender: TObject);
begin
  ItemSize := TItemSize.Small;
  SetItemSize(ItemSize);
  TScreenUtil.PutInPosition(Self, IDEList.ItemHeight, IDEList.ItemCount);
end;

procedure TFormMain.btnMediumClick(Sender: TObject);
begin
  ItemSize := TItemSize.Medium;
  SetItemSize(ItemSize);
  TScreenUtil.PutInPosition(Self, IDEList.ItemHeight, IDEList.ItemCount);
end;

procedure TFormMain.btnBigClick(Sender: TObject);
begin
  ItemSize := TItemSize.Big;
  SetItemSize(ItemSize);
  TScreenUtil.PutInPosition(Self, IDEList.ItemHeight, IDEList.ItemCount);
end;

procedure TFormMain.btnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ControlClicked := true;
end;

procedure TFormMain.btnMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ControlClicked := false;
end;

procedure TFormMain.DelphiVersionsClick(Sender: TObject);
begin
 ShowMessage((Sender as TMenuItem).Caption, '');
end;

procedure TFormMain.DelphiVersionsEdit(Sender: TObject);
begin
  ShowLocalConfig(TConfigCard.IDEVersions);

end;

end.
