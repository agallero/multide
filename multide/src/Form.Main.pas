unit Form.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts, Math,
  Vcl.StdCtrls, System.Win.TaskbarCore, Vcl.Taskbar, Vcl.ComCtrls,
  Vcl.ControlList, Vcl.VirtualImage, Model.Entry, Vcl.BaseImageCollection,
  Vcl.ImageCollection, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList,
  Form.Config, Form.GlobalConfig, Form.Message, Vcl.Menus, Vcl.ExtCtrls, Form.Build, Util.Screen, Global.Config,
  Vcl.Buttons, Model.GlobalSettings;

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
    AppPopupMenu: TPopupMenu;
    btnSmall: TMenuItem;
    btnMedium: TMenuItem;
    btnBig: TMenuItem;
    N1: TMenuItem;
    GlobalConfigButton: TMenuItem;
    PanelFooter: TPanel;
    btnGlobalConfig: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure ApplicationEventsDeactivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure IDEListBeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure IDEListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnUpdateComponentsClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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
    procedure ButtonGlobalConfigClick(Sender: TObject);
    procedure IDEVersionClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
  private
    Entries: TEntryList;
    InModalDialog: boolean;
    FFormConfig: TFormConfig;
    FFormGlobalConfig: TFormGlobalConfig;
    FFormBuild: TFormBuild;
    ControlClicked: boolean;
    GlobalSettings: TGlobalSettings;
    ShowingCaptions: boolean;


    procedure ApplyGlobalSettings;
    procedure LoadIDEs;
    procedure LoadIDEIcons;
    procedure RunSelected;
    function FormConfig: TFormConfig;
    function FormGlobalConfig: TFormGlobalConfig;
    function FormBuild: TFormBuild;
    procedure ShowLocalConfig(const Card: TConfigCard);
    procedure ShowGlobalConfig;
    procedure ShowMessage(const aCaption, aText: string);
    procedure ShowCaptions;
    procedure DoBuild;
    procedure DoLocalConfig;
    procedure DoGlobalConfig;
    procedure SetItemSize(const aItemSize: TItemSize);
    function ItemIndexWrong: boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation
uses Theme.Manager, Model.EntryReader, Model.EntryWriter, IOUtils, Generics.Defaults,
     Generics.Collections, Launcher.Shortcuts,
     Model.DelphiVersions, Model.DelphiVersionsReader,
     Model.GlobalSettingsReader, Model.GlobalSettingsWriter;

{$R *.dfm}

procedure TFormMain.ApplicationEventsDeactivate(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.LoadIDEs;
begin
  Entries.Clear;
  TModelEntryReader.Load(Entries);
  IDEList.ItemCount := Entries.Count;
  IDEList.Invalidate;
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
        var MissingStream := TResourceStream.Create(HInstance, 'MISSING_IMAGE', RT_RCDATA);
        try
          IDEImages.Add(IconName, MissingStream);
        finally
          MissingStream.Free;
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

function TFormMain.FormGlobalConfig: TFormGlobalConfig;
begin
  if FFormGlobalConfig = nil then
  begin
    FFormGlobalConfig := TFormGlobalConfig.Create(Self);
    FFormGlobalConfig.Initialize(Entries, GlobalSettings, ApplyGlobalSettings);
  end;
  Result := FFormGlobalConfig;
end;

procedure TFormMain.SetItemSize(const aItemSize: TItemSize);
begin
  GlobalSettings.ItemSize := aItemSize;
  case aItemSize of
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
        PanelFooter.Height := ScaleValue(20);
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
        PanelFooter.Height := ScaleValue(30);
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
        PanelFooter.Height := ScaleValue(30);
      end;

  end;
  TScreenUtil.PutInPosition(Self, PanelFooter.Height, IDEList.ItemHeight, IDEList.ItemCount);
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  GlobalSettings := TGlobalSettings.Create;
  TModelGlobalSettingsReader.Read(GlobalSettings);

  Entries := TEntryList.Create;
  LoadIDEs;
  SetItemSize(GlobalSettings.ItemSize);

  TScreenUtil.PutInPosition(Self, PanelFooter.Height, IDEList.ItemHeight, IDEList.ItemCount);
  TThemeManager.SetTheme(GlobalSettings.ThemeStyle);
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
  GlobalSettings.Free;
end;

procedure TFormMain.ShowCaptions;
begin
  if btnUpdateComponents.Caption <> '' then exit;
  btnUpdateComponents.Caption := '(&B)uild';
  btnUpdateComponents.Width := 160;
  btnConfig.Caption := '(&C)onfig';
  btnConfig.Width := 160;
  IDECaption.Width := IDECaption.Width - 80;
  btnGlobalConfig.Width := 240;
  btnGlobalConfig.Caption := '(&G)lobal Config';
  ShowingCaptions := true;
end;

procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then close;
  ShowCaptions; //if the user is using the keys, we will show them a way to press the buttons.
  if Char(Key) = 'B' then DoBuild;
  if Char(Key) = 'C' then DoLocalConfig;
  if Char(Key) = 'G' then DoGlobalConfig;
  if CharInSet(Char(Key), ['1'..'9']) then
  begin
    var Index := Key - ord('1');
    if (Index < IDEList.ItemCount) then
    begin
      IDEList.ItemIndex := Index;
      RunSelected;
    end;
  end;
end;

procedure TFormMain.IDEListBeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
  ARect: TRect; AState: TOwnerDrawState);
begin
  if (AIndex < 0) or (AIndex >= Entries.Count) then exit;
  var Id := Entries[AIndex].Id;
  if ShowingCaptions and (AIndex < 9) then Id := '(' + IntToStr(AIndex + 1) + ') ' + Id;

  IDECaption.Caption := Id;
  IDEImage.ImageName := TPath.GetFileName(Entries[AIndex].Icon);
  IDEVersion.Caption := Entries[AIndex].DelphiVersion.Name;
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
  TShorcutLauncher.Launch(Entry);
  Close;

end;

procedure TFormMain.IDEListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then RunSelected;

end;

procedure TFormMain.IDEVersionClick(Sender: TObject);
begin
  //ShowLocalConfig(TConfigCard.IDEVersions);
  RunSelected;
end;

procedure TFormMain.ShowLocalConfig(const Card: TConfigCard);
begin
  if ItemIndexWrong then exit;
  if InModalDialog then exit;

  InModalDialog := true;
  try
    FormConfig.SelectCard(Card);
    FormConfig.SetIDE(Entries, IDEList.ItemIndex);
    var OriginalIcon := Entries[IDEList.ItemIndex].Icon;
    FormConfig.ShowModal;
    if OriginalIcon <> Entries[IDEList.ItemIndex].Icon then LoadIDEIcons;

  finally
    InModalDialog := false;
  end;
end;

procedure TFormMain.ShowGlobalConfig;
begin
  if InModalDialog then exit;

  InModalDialog := true;
  try
    FormGlobalConfig.UpdateControls;
    FormGlobalConfig.ShowModal;
    LoadIDEs;
    LoadIDEIcons;

    TScreenUtil.PutInPosition(Self, PanelFooter.Height, IDEList.ItemHeight, IDEList.ItemCount);
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


procedure TFormMain.DoGlobalConfig;
begin
  ShowGlobalConfig;
end;


procedure TFormMain.BtnGlobalConfigClick(Sender: TObject);
begin
  //Globalconfig will be donde from local config, to keep the main UI clean.
  //it should have a dark mode selector, a config selector.(+/- IDE configurations)
  DoGlobalConfig;
end;

procedure TFormMain.DoBuild;
begin
  if ItemIndexWrong then exit;

  if (Entries[IDEList.ItemIndex].SmartSetupWorkingFolder.Trim = '') or (Entries[IDEList.ItemIndex].SmartSetupLocation.Trim = '') then
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

procedure TFormMain.ButtonGlobalConfigClick(Sender: TObject);
begin
  DoGlobalConfig;
end;

procedure TFormMain.btnConfigClick(Sender: TObject);
begin
  DoLocalConfig;
end;

procedure TFormMain.btnConfigurationForClick(Sender: TObject);
begin
  DoLocalConfig;
end;

procedure TFormMain.btnSmallClick(Sender: TObject);
begin
  SetItemSize(TItemSize.Small);
  TModelGlobalSettingsWriter.Save(GlobalSettings);
end;

procedure TFormMain.btnMediumClick(Sender: TObject);
begin
  SetItemSize(TItemSize.Medium);
  TModelGlobalSettingsWriter.Save(GlobalSettings);
end;

procedure TFormMain.btnBigClick(Sender: TObject);
begin
  SetItemSize(TItemSize.Big);
  TModelGlobalSettingsWriter.Save(GlobalSettings);
end;

procedure TFormMain.ApplyGlobalSettings;
begin
  SetItemSize(GlobalSettings.ItemSize);
  TThemeManager.SetTheme(GlobalSettings.ThemeStyle);
  TThemeManager.UpdateControl(Self);
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

end.
