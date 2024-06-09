unit Form.Build;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Theme.Manager, Model.Entry, Vcl.StdCtrls;

type
  TFormBuild = class(TForm)
    MemoLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    FEntry: TEntry;
    Building: Boolean;
  public
    procedure SetIDE(const aEntry: TEntry);
  end;

implementation
uses Util.Screen;

{$R *.dfm}

procedure TFormBuild.FormActivate(Sender: TObject);
begin
  if Building then exit;
  Building := true;
  for var i :=1 to 100 do
    begin
      Application.ProcessMessages;
      sleep(100);
      MemoLog.Lines.Add(inttostr(i));
    end;
end;

procedure TFormBuild.FormCreate(Sender: TObject);
begin
  TThemeManager.UpdateControl(Self);
  TScreenUtil.PutInPosition(Self);


end;

procedure TFormBuild.SetIDE(const aEntry: TEntry);
begin
  FEntry := aEntry;
  Caption := 'Updating ' + FEntry.Id + '...';
  MemoLog.Text := '';
  Building := false;
end;

end.
