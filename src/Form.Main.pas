unit Form.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts, Math,
  Vcl.StdCtrls, System.Win.TaskbarCore, Vcl.Taskbar, Vcl.ComCtrls,
  Vcl.ControlList, Vcl.VirtualImage, Model.Entry, Vcl.BaseImageCollection,
  Vcl.ImageCollection, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList,
  Form.Config, Form.Message, Vcl.Menus, Vcl.ExtCtrls, Form.Build, Util.Screen;

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
  private
    Entries: TEntryList;
    InModalDialog: boolean;
    FFormConfig: TFormConfig;
    FFormBuild: TFormBuild;
    ControlClicked: boolean;

    procedure LoadIDEs;
    procedure LoadIDEIcons;
    procedure RunSelected;
    function FormConfig: TFormConfig;
    function FormBuild: TFormBuild;
    procedure ShowConfig(const Card: TConfigCard);
    procedure ShowMessage(const aCaption, aText: string);
    procedure FillVersionsMenu(const Menu: TPopupMenu);
    procedure ShowCaptions;
    procedure DoBuild;
    procedure DoConfig;
    procedure DoGlobalConfig;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation
uses Theme.Manager, Model.Reader, IOUtils, Generics.Defaults,
     Generics.Collections, Global.Config;

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

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Entries := TEntryList.Create;
  LoadIDEs;
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
  if Char(Key) = 'C' then DoConfig;
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

procedure TFormMain.RunSelected;
begin
 // ShowMessage(inttostr(IDEList.ItemIndex));
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

procedure TFormMain.ShowConfig(const Card: TConfigCard);
begin
  if (IDEList.ItemIndex < 0) or (IDEList.ItemIndex >= Entries.Count) then exit;

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

procedure TFormMain.DoConfig;
begin
  ShowConfig(TConfigCard.Default);
end;

procedure TFormMain.btnConfigClick(Sender: TObject);
begin
  DoConfig;
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

procedure TFormMain.DoBuild;
begin
  if (IDEList.ItemIndex < 0) or (IDEList.ItemIndex >= Entries.Count) then exit;

  if (Entries[IDEList.ItemIndex].TmsBuildFiles = nil) or (Entries[IDEList.ItemIndex].SmartSetupLocation.Trim = '') then
  begin
    ShowMessage('Missing configuration', 'Smart Setup is not configured for this IDE. To compile the components, you need to configure it first');
    ShowConfig(TConfigCard.SmartSetup);
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
  ShowConfig(TConfigCard.IDEVersions);

end;

end.
