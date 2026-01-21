unit Form.Build;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Theme.Manager, Model.Entry, Vcl.StdCtrls,
  Vcl.ComCtrls, System.Win.TaskbarCore, Vcl.Taskbar, Vcl.ExtCtrls;

type
  TFormBuild = class(TForm)
    MemoLog: TMemo;
    ProgressBar: TProgressBar;
    Taskbar: TTaskbar;
    LabelProgress: TLabel;
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    btnLog: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnLogClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    [volatile] IsCanceled: boolean;
    Finished: boolean;
  private
    FEntry: TEntry;
    Building: Boolean;
    procedure SetProgress(Progress: integer);
    function GetExtraConfig(const Entries: TArray<string>): string;
    function GetProgress(const s: string): integer;
  public
    procedure SetIDE(const aEntry: TEntry);
  end;

implementation
uses Util.Screen, Deget.CommandLine, System.Threading;

{$R *.dfm}

function TFormBuild.GetProgress(const s: string): integer;
begin
  var P := s.LastIndexOf('%]') + 1;
  if P >= 4 then
  begin
    if TryStrToInt(Trim(Copy(s, P - 3, 3)), Result) then exit;
  end;
  Result := -1;
end;

procedure TFormBuild.SetProgress(Progress: integer);
begin
  if Progress < 0 then exit;
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

procedure TFormBuild.btnCancelClick(Sender: TObject);
begin
 IsCanceled := true;
end;

procedure TFormBuild.btnLogClick(Sender: TObject);
begin
  ExecuteCommand('"' + FEntry.SmartSetupLocation +  '" log-view', FEntry.SmartSetupWorkingFolder);
end;

function TFormBuild.GetExtraConfig(const Entries: TArray<string>): string;
begin
  Result := '';
  for var Entry in Entries do if Entry.Trim <> '' then Result := Result + ' -add-config:"' + Entry.Trim() + '"';

end;

procedure TFormBuild.FormActivate(Sender: TObject);
begin
  if Building then exit;
  TThemeManager.UpdateControl(Self);
  Building := true;
  btnOk.Enabled := false;
  btnCancel.Visible := true;
  btnLog.Visible := false;
  IsCanceled := false;
  Finished := false;
  SetProgress(0);
  ProgressBar.State := TProgressBarState.pbsNormal;

  var Task := TTask.Run(procedure
  begin
    var ExitCode := TCommandLine.ExecuteEx('"' + FEntry.SmartSetupLocation +  '" update' + GetExtraConfig(FEntry.TmsBuildFiles),
                   FEntry.SmartSetupWorkingFolder,
                   procedure (const s: string)
                   begin
                     TThread.Queue(nil,
                     procedure
                     begin
                       MemoLog.Text := MemoLog.Text + s;
                       SendMessage(MemoLog.Handle, EM_LINESCROLL, 0, MemoLog.Lines.Count);
                       SetProgress(GetProgress(s));
                     end);
                   end,
                   nil, function: boolean
                   begin
                     Result := IsCanceled;
                   end);
    TThread.Queue(nil,
    procedure
    begin
      SetProgress(100);
      if ExitCode <> 0 then ProgressBar.State := TProgressBarState.pbsError;

      btnOk.Enabled := true;
      btnCancel.Visible := false;
      btnLog.Visible := true;
      Finished := true;
      if IsCanceled or (ExitCode = 0) then Close;

    end);
  end);
end;

procedure TFormBuild.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := Finished;
  IsCanceled := true;
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
