unit Form.Build;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Theme.Manager, Model.Entry, Vcl.StdCtrls,
  Vcl.ComCtrls, System.Win.TaskbarCore, Vcl.Taskbar;

type
  TFormBuild = class(TForm)
    MemoLog: TMemo;
    ProgressBar: TProgressBar;
    Taskbar: TTaskbar;
    LabelProgress: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    FEntry: TEntry;
    Building: Boolean;
    procedure SetProgress(Progress: integer);
  public
    procedure SetIDE(const aEntry: TEntry);
  end;

implementation
uses Util.Screen;

{$R *.dfm}

procedure TFormBuild.SetProgress(Progress: integer);
begin
  if Progress < 0 then Progress := 0;
  if Progress > 100 then Progress := 100;

  ProgressBar.Position := Progress;
  var ProgressStr := IntToStr(Progress) + '%';
  LabelProgress.Caption := ProgressStr;
  Taskbar.ProgressState := TTaskBarProgressState.Normal;
  Taskbar.ProgressValue := Progress;
  var UpdateStr := 'Updating';
  if Progress = 100 then UpdateStr := 'Updated';
  
  Caption := ProgressStr + ' - ' + UpdateStr + ' ' + FEntry.Id + '...';
end;

procedure TFormBuild.FormActivate(Sender: TObject);
begin
  if Building then exit;
  Building := true;
  for var i :=1 to 100 do
    begin
      Application.ProcessMessages;
      sleep(100);
      SetProgress(i);
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
