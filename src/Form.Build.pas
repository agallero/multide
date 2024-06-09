unit Form.Build;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Theme.Manager, Model.Entry, Vcl.StdCtrls;

type
  TFormBuild = class(TForm)
    MemoLog: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    FEntry: TEntry;
  public
    procedure SetIDE(const aEntry: TEntry);
  end;

implementation

{$R *.dfm}

procedure TFormBuild.FormCreate(Sender: TObject);
begin
  TThemeManager.UpdateControl(Self);
end;

procedure TFormBuild.SetIDE(const aEntry: TEntry);
begin
  FEntry := aEntry;
  Caption := 'Updating ' + FEntry.Id + '...';
  MemoLog.Text := '';
end;

end.
