#define MyAppName "QueryAI"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Freedom Reflection, LLC"
#define MyAppURL "freedomreflection@gmail.com"
#define MyAppExeName "frontend.exe"
#define MyBackendExeName "sql_assistant_backend.exe"

[Setup]
AppId={{B8F62C1A-45F4-4763-B490-DCE47CEBF7C1}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=Output
OutputBaseFilename=queryai_setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Frontend executable and ALL dependencies
Source: "..\frontend\build\windows\runner\Release\frontend.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\frontend\build\windows\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\frontend\build\windows\runner\Release\app_links_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\frontend\build\windows\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\frontend\build\windows\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; Backend executable
Source: "..\backend\dist\sql_assistant_backend.exe"; DestDir: "{app}"; Flags: ignoreversion
; Config file
Source: "config.json"; DestDir: "{app}"; Flags: ignoreversion
; Launcher script
Source: "launcher.bat"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\launcher.bat"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\launcher.bat"; IconFilename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\launcher.bat"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
var
  BackendPID: Integer;

procedure StopBackend;
var
  ResultCode: Integer;
begin
  Exec('taskkill.exe', '/F /IM {#MyBackendExeName}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    SaveStringToFile(ExpandConstant('{app}\launcher.bat'), 
      '@echo off' + #13#10 +
      'echo Starting QueryAI...' + #13#10 +
      'cd /d "%~dp0"' + #13#10 +
      'echo Starting backend service...' + #13#10 +
      'start /B "" "{#MyBackendExeName}"' + #13#10 +
      'echo Initializing...' + #13#10 +
      'timeout /t 2 /nobreak > nul' + #13#10 +
      'echo Launching application...' + #13#10 +
      'start "" "{#MyAppExeName}"' + #13#10 +
      'exit', False);
  end;
end;

procedure DeinitializeSetup();
begin
  StopBackend;
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  try
    // Kill any existing instances of the backend
    StopBackend;
  except
    // Ignore errors if the process is not running
  end;
end;