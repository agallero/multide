program multide;

{$R 'MultIDE.Resources.res' 'src\MultIDE.Resources.rc'}

uses
  Vcl.Forms,
  Form.Main in 'src\Form.Main.pas' {FormMain},
  Theme.Colors in 'src\Theme.Colors.pas',
  Model.Entry in 'src\Model.Entry.pas',
  Model.EntryReader in 'src\Model.EntryReader.pas',
  Global.Config in 'src\Global.Config.pas',
  Form.Config in 'src\Form.Config.pas' {FormConfig},
  Theme.Manager in 'src\Theme.Manager.pas',
  Form.Message in 'src\Form.Message.pas' {FormMessage},
  Util.AppInstances in 'src\Util.AppInstances.pas',
  ICO.Creator in 'src\ICO.Creator.pas',
  Form.Build in 'src\Form.Build.pas' {FormBuild},
  Util.Screen in 'src\Util.Screen.pas',
  Launcher.BDS in 'src\Launcher.BDS.pas',
  Launcher.Shortcuts in 'src\Launcher.Shortcuts.pas',
  Form.GlobalConfig in 'src\Form.GlobalConfig.pas' {FormGlobalConfig},
  Model.EntryWriter in 'src\Model.EntryWriter.pas',
  Model.Persistence in 'src\Model.Persistence.pas',
  Model.DelphiVersions in 'src\Model.DelphiVersions.pas',
  Model.DelphiVersionsReader in 'src\Model.DelphiVersionsReader.pas',
  Shortcut.Creator in 'src\Shortcut.Creator.pas',
  Shortcut.Manager in 'src\Shortcut.Manager.pas',
  Deget.CommandLine in 'src\Deget.CommandLine.pas',
  Model.GlobalSettings in 'src\Model.GlobalSettings.pas',
  Model.GlobalSettingsReader in 'src\Model.GlobalSettingsReader.pas',
  Model.GlobalSettingsWriter in 'src\Model.GlobalSettingsWriter.pas',
  Form.AddConfig in 'src\Form.AddConfig.pas' {FormAddConfig};

{$R *.res}

function ConcatParams(const Start: integer): string;
begin
  Result := '';
  for var i := Start to ParamCount do
  begin
    Result := Result + ' "' + ParamStr(i) + '"';
  end;

end;

const
  FormMainCaption = 'Select IDE';
begin
  if ParamCount > 1 then
  begin
    TBDSLauncher.Launch(ParamStr(1), ParamStr(2), ConcatParams(3));
    exit;
  end;
  if AppIsAlreadyRunning then
  begin
    FocusExistingInstance(TFormMain.ClassName, FormMainCaption);
    exit;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'MultIDE';
  Application.CreateForm(TFormMain, FormMain);
  FormMain.Caption := FormMainCaption;
  Application.Run;
end.
