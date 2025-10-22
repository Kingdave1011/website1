; Space Shooter V2 - NSIS Installer Script
; Created by NEXO GAMES

;--------------------------------
; Includes

!include "MUI2.nsh"
!include "FileFunc.nsh"

;--------------------------------
; General Settings

; Name and file
Name "Space Shooter V2"
OutFile "SpaceShooter_Setup.exe"
Unicode True

; Default installation folder
InstallDir "$LOCALAPPDATA\Space Shooter V2"

; Get installation folder from registry if available
InstallDirRegKey HKCU "Software\NEXO GAMES\Space Shooter V2" ""

; Request application privileges
RequestExecutionLevel user

;--------------------------------
; Interface Settings

!define MUI_ABORTWARNING

; Custom Graphics
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install-colorful.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall-colorful.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\nsis3-branding.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\nsis3-branding.bmp"

;--------------------------------
; Pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
!insertmacro MUI_PAGE_DIRECTORY

; Components page for user choices
!insertmacro MUI_PAGE_COMPONENTS

!insertmacro MUI_PAGE_INSTFILES

; Custom finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\Space Shooter V2.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch Space Shooter V2"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
; Languages

!insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Version Information

VIProductVersion "1.0.0.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "Space Shooter V2"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "NEXO GAMES"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "© 2025 NEXO GAMES"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "Space Shooter V2 Installer"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "1.0.0.0"

;--------------------------------
; Installer Sections

Section "!Space Shooter V2 (Required)" SecCore
  SectionIn RO  ; Read-only, always installed
  
  SetOutPath "$INSTDIR"
  
  ; Copy main files
  File "SpaceShooterWindows\Space Shooter V2.exe"
  File "SpaceShooterWindows\Space Shooter V2.pck"
  File "SpaceShooterWindows\README.txt"
  
  ; Copy sounds folder if it exists
  SetOutPath "$INSTDIR\sounds"
  File /nonfatal /r "SpaceShooterWindows\sounds\*.*"
  
  SetOutPath "$INSTDIR"
  
  ; Store installation folder
  WriteRegStr HKCU "Software\NEXO GAMES\Space Shooter V2" "" $INSTDIR
  
  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  
  ; Add to Add/Remove Programs
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SpaceShooterV2" \
                   "DisplayName" "Space Shooter V2"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SpaceShooterV2" \
                   "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SpaceShooterV2" \
                   "DisplayIcon" "$INSTDIR\Space Shooter V2.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SpaceShooterV2" \
                   "Publisher" "NEXO GAMES"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SpaceShooterV2" \
                   "DisplayVersion" "1.0"
  
  ; Calculate and store installation size
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SpaceShooterV2" \
                     "EstimatedSize" "$0"
SectionEnd

Section "Start Menu Shortcuts" SecStartMenu
  CreateDirectory "$SMPROGRAMS\Space Shooter V2"
  CreateShortcut "$SMPROGRAMS\Space Shooter V2\Space Shooter V2.lnk" "$INSTDIR\Space Shooter V2.exe" "" "$INSTDIR\Space Shooter V2.exe" 0
  CreateShortcut "$SMPROGRAMS\Space Shooter V2\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
SectionEnd

Section "Desktop Shortcut" SecDesktop
  CreateShortcut "$DESKTOP\Space Shooter V2.lnk" "$INSTDIR\Space Shooter V2.exe" "" "$INSTDIR\Space Shooter V2.exe" 0
SectionEnd

;--------------------------------
; Section Descriptions

LangString DESC_SecCore ${LANG_ENGLISH} "Main game files (required)"
LangString DESC_SecStartMenu ${LANG_ENGLISH} "Add shortcuts to the Start Menu"
LangString DESC_SecDesktop ${LANG_ENGLISH} "Add a shortcut to the Desktop"

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} $(DESC_SecCore)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecStartMenu} $(DESC_SecStartMenu)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} $(DESC_SecDesktop)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Uninstaller Section

Section "Uninstall"
  ; Remove files
  Delete "$INSTDIR\Space Shooter V2.exe"
  Delete "$INSTDIR\Space Shooter V2.pck"
  Delete "$INSTDIR\*.dll"
  Delete "$INSTDIR\README.txt"
  Delete "$INSTDIR\Uninstall.exe"
  
  ; Remove sounds folder
  RMDir /r "$INSTDIR\sounds"
  
  ; Remove shortcuts (if they exist)
  Delete "$SMPROGRAMS\Space Shooter V2\*.*"
  RMDir "$SMPROGRAMS\Space Shooter V2"
  Delete "$DESKTOP\Space Shooter V2.lnk"
  
  ; Remove installation directory
  RMDir "$INSTDIR"
  
  ; Remove registry keys
  DeleteRegKey HKCU "Software\NEXO GAMES\Space Shooter V2"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SpaceShooterV2"
SectionEnd

;--------------------------------
; Custom Functions

Function .onInstSuccess
  MessageBox MB_OK "Space Shooter V2 has been successfully installed!$\r$\n$\r$\nControls:$\r$\n• Arrow Keys/WASD - Move ship$\r$\n• Space/Click - Shoot$\r$\n• ESC - Pause menu$\r$\n$\r$\nThank you for installing!$\r$\nCreated by NEXO GAMES"
FunctionEnd
