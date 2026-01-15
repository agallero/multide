unit Form.AddConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Theme.Manager, Util.Screen,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, Model.Entry, Form.Message;

type
  TFormAddConfig = class(TForm)
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    edConfigName: TLabeledEdit;
    csCopyFrom: TComboBox;
    lblCopyFrom: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FEntryList: TEntryList;
  public
    procedure Initialize(const aEntryList: TEntryList);
    function ConfigName: string;
    function CopyFrom: integer;
  end;
implementation

{$R *.dfm}

function TFormAddConfig.ConfigName: string;
begin
  Result := Trim(edConfigName.Text);
end;

function TFormAddConfig.CopyFrom: integer;
begin
  Result := csCopyFrom.ItemIndex;
end;

procedure TFormAddConfig.FormActivate(Sender: TObject);
begin
  TThemeManager.UpdateControl(Self);
end;

procedure TFormAddConfig.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
  if ModalResult <> mrOk then exit;
  var Error := FEntryList.ValidateId(ConfigName, FEntryList.Count);
  if Error <> '' then
  begin
    TFormMessage.Show('Error', Error, true);
    CanClose := false;
  end;
end;

procedure TFormAddConfig.FormCreate(Sender: TObject);
begin
  TThemeManager.UpdateControl(Self);
  TScreenUtil.PutInPosition(Self);
end;

procedure TFormAddConfig.Initialize(const aEntryList: TEntryList);
begin
  FEntryList := aEntryList;
  csCopyFrom.Items.Clear;
  csCopyFrom.Items.Add('--None--');
  for var s in aEntryList do csCopyFrom.AddItem(s.Id, nil);
  csCopyFrom.ItemIndex := 0;
end;

end.
