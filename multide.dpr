program multide;

uses
  Vcl.Forms,
  Form.Main in 'src\Form.Main.pas' {FormMain},
  Theme.Colors in 'src\Theme.Colors.pas',
  Model.Entry in 'src\Model.Entry.pas',
  Model.Reader in 'src\Model.Reader.pas',
  Global.Config in 'src\Global.Config.pas',
  Form.Config in 'src\Form.Config.pas' {FormConfig},
  Theme.Manager in 'src\Theme.Manager.pas',
  Form.Message in 'src\Form.Message.pas' {FormMessage},
  Util.AppInstances in 'src\Util.AppInstances.pas',
  ICO.Creator in 'src\ICO.Creator.pas';

{$R *.res}

begin
  if AppIsAlreadyRunning then exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'MultIDE';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
