; Space Shooter V2 - Inno Setup Installer Script
; Created by NEXO GAMES

#define MyAppName "Space Shooter V2"
#define MyAppVersion "1.0"
#define MyAppPublisher "NEXO GAMES"
#define MyAppURL "https://nexogames.com"
#define MyAppExeName "Space Shooter V2.exe"

[Setup]
; App identification
AppId={{A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

; Installation directories
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes

; Output settings
OutputDir=.
OutputBaseFilename=SpaceShooter_Setup
Compression=lzma2/max
SolidCompression=yes

; UI settings
WizardStyle=modern
SetupIconFile=SpaceShooterWindows\Space Shooter V2.exe

; Privileges
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

; Architecture
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Main executable
Source: "SpaceShooterWindows\Space Shooter V2.exe"; DestDir: "{app}"; Flags: ignoreversion
; Data file
Source: "SpaceShooterWindows\Space Shooter V2.pck"; DestDir: "{app}"; Flags: ignoreversion
; Additional files
Source: "SpaceShooterWindows\*.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "SpaceShooterWindows\README.txt"; DestDir: "{app}"; Flags: ignoreversion
; Sounds folder
Source: "SpaceShooterWindows\sounds\*"; DestDir: "{app}\sounds"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Start Menu shortcut
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
; Desktop shortcut
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; Option to launch game after installation
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpFinished then
  begin
    WizardForm.FinishedLabel.Caption := 
      'Space Shooter V2 has been successfully installed!' + #13#10 + #13#10 +
      'Controls:' + #13#10 +
      '• Arrow Keys/WASD - Move ship' + #13#10 +
      '• Space/Click - Shoot' + #13#10 +
      '• ESC - Pause menu' + #13#10 + #13#10 +
      'Thank you for installing Space Shooter V2!' + #13#10 +
      'Created by NEXO GAMES';
  end;
end;
