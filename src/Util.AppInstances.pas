unit Util.AppInstances;

interface
function AppIsAlreadyRunning(): boolean;

implementation
uses Windows, SysUtils;

function AppIsAlreadyRunning(): boolean;
begin
  Result := false;

  {$IFDEF MSWINDOWS}
  //"Global\text" instead of "text" is to look into all users. Here we just want for the current user
  if CreateMutex(nil, True, PChar('multide-FC170FF8-DD64-422F-B2F0-3BD042AF135E')) = 0 then
    RaiseLastOSError;

  var LastError := GetLastError;
  if LastError = ERROR_ALREADY_EXISTS then
    Exit(true);
  {$ENDIF}
end;

end.
