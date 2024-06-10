unit Launcher.BDS;

interface
uses Classes, SysUtils;

type
  TBDSLauncher = record
  private
    class function FindBDS(const RegistryKey, Version: string): string; static;
    class procedure ShowError(const msg: string); static;
  public
    class procedure Launch(const RegistryKey, Version, ExtraBDSParams: string); static;
  end;

implementation
uses Forms, ShellApi, Windows, Registry, Global.Config, IOUtils, Dialogs;

{ TBDSLauncher }

class procedure TBDSLauncher.ShowError(const msg: string);
begin
  MessageBox(0, PCHAR(msg), 'MultIDE', MB_OK or MB_ICONERROR);
end;

class function TBDSLauncher.FindBDS(const RegistryKey, Version: string): string;
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if not Reg.OpenKeyReadOnly(RegistryKeys.Embarcadero + '\' + RegistryKey + '\' + Version) then exit('');
    Result := Reg.GetDataAsString('App');
  finally
    Reg.Free;
  end;

end;

class procedure TBDSLauncher.Launch(const RegistryKey, Version, ExtraBDSParams: string);
begin
  //todo: Update the registry first.

  var BDS := FindBDS(RegistryKey, Version);
  if BDS = '' then
  begin
    ShowError('There is no BDS installed at "' + RegistryKey + '" , version "' + Version + '"' );
    exit;
  end;
  if not TFile.Exists(BDS) then
  begin
    ShowError('Can''t find the file "' + BDS + '"');
    exit;
  end;

  var BDSParams := '"/r' + RegistryKey + '" ' + ExtraBDSParams;

  //SetEnvironment to change path. see https://stackoverflow.com/questions/17100920/whether-shellexecute-will-share-environment-variable-with-launching-process
  //or use shellexecuteex.
  ShellExecute(0, nil, PCHAR(BDS), PCHAR(BDSParams), '', SW_SHOWNORMAL);
end;

end.
