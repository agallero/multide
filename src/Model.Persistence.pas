unit Model.Persistence;

interface
type

  RegistryKeys = record
  private
    const
      MultideKeyFolder = 'multide';
  public
    const
      EmbarcaderoRoot = '\Software\Embarcadero';
    class function RootMultide: string; static;
    class function SettingsPath(const Id: string): string; static;
    class function EmbarcaderoEntry(const Id, Version: string): string; static;
    class function IDEEntry(const Id: string): string; static;
  end;

  RegistrySettings = record
  public
    const
      Icon = 'Icon';
      Position = 'Position';
      DelphiVersionName = 'DelphiVersionName';
      DelphiVersionVersion = 'DelphiVersionVersion';
      SmartSetupLocation = 'SmartSetupLocation';
      SmartSetupWorkingFolder = 'SmartSetupWorkingFolder';
      TmsBuildFiles = 'TmsBuildFiles';
      ExtraParameters = 'ExtraParameters';
  end;

  RegistryGlobalSettings = record
  public
    const
      ThemeStyle = 'ThemeStyle';
      ItemSize = 'ItemSize';
  end;


const
  DefaultIDEName = 'Default';


implementation

{ RegistryKeys }

class function RegistryKeys.EmbarcaderoEntry(const Id, Version: string): string;
begin
  var RelPath: string;
  if Id = DefaultIDEName then RelPath := 'BDS'
  else RelPath := MultideKeyFolder + '\' + Id;

  Result := EmbarcaderoRoot + '\' + RelPath + '\' + Version;

end;

class function RegistryKeys.SettingsPath(const Id: string): string;
begin
  Result := RootMultide + '\' + Id;
end;

class function RegistryKeys.IDEEntry(const Id: string): string;
begin
  if Id = DefaultIDEName then exit('')
  else Result := MultideKeyFolder + '\' + Id;
end;

class function RegistryKeys.RootMultide: string;
begin
  Result := EmbarcaderoRoot + '\' + MultideKeyFolder;
end;

end.
