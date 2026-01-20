unit Util.AppInstances;

interface
function AppIsAlreadyRunning(): boolean;
procedure FocusExistingInstance(const AppWindowClass, AppWindowTitle: string);

implementation
uses Windows, SysUtils;

function FindExistingWindow(const AppWindowClass, AppWindowTitle: string): HWND;
begin
  Result := FindWindow(PChar(AppWindowClass), PChar(AppWindowTitle));
end;

procedure FocusExistingInstance(const AppWindowClass, AppWindowTitle: string);
var
  Wnd: HWND;
begin
  Wnd := FindExistingWindow(AppWindowClass, AppWindowTitle);
  if Wnd <> 0 then
  begin
    if IsIconic(Wnd) then
      ShowWindow(Wnd, SW_RESTORE);
    SetForegroundWindow(Wnd);
  end;
end;

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
