Unicode true

# Add current directory to plugin path
!addplugindir .\

# Architecture detection
!include x64.nsh

# Include LogicLib (http://nsis.sourceforge.net/LogicLib)
!include 'LogicLib.nsh'

# Include ZipDLL plugin (http://nsis.sourceforge.net/ZipDLL_plug-in)
!include 'ZipDLL.nsh'

# Include Locate plugin (http://nsis.sourceforge.net/Locate_plugin)
!include 'locate.nsh'

# Include MoveFileFolder plugin (http://nsis.sourceforge.net/MoveFileFolder)
!include 'FileFunc.nsh'
!insertmacro Locate
Var /GLOBAL switch_overwrite
!include 'MoveFileFolder.nsh'

# Enable CRC
CRCCheck on

# Require admin privledges when UAC is on
RequestExecutionLevel admin

!define APPNAME "Mist"
!define GROUPNAME "Ethereum"
!define HELPURL "https://github.com/ethereum/mist/releases/issues"
!define UPDATEURL "https://github.com/ethereum/mist/releases"
!define ABOUTURL "https://ethereum.org"
!define /date NOW "%Y%m%d"

## These must be integers and can be set on the command line by NSIS with "/DMAJORVERSION=0 /DMINORVERSION=8 /DBUILDVERSION=7"
#!define VERSIONMAJOR 0
#!define VERSIONMINOR 8
#!define VERSIONBUILD 7

# Define some script globals
Name "${GROUPNAME} ${APPNAME}"
Icon "..\dist_mist\build\icon.ico"
OutFile "..\dist_mist\release\mist-installer-${VERSIONMAJOR}-${VERSIONMINOR}-${VERSIONBUILD}.exe"
var FILEDIR
var DATADIR
var NODEDATADIR
var ARCHDIR
var SHORTCUTDIR
var DESKTOPDIR

# Check for administrative rights
!macro VerifyUserIsAdmin
UserInfo::GetAccountType
pop $0
${If} $0 != "admin"
        messageBox mb_iconstop $(msgAdminRequired)
        setErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
        quit
${EndIf}
!macroend

# Create a shared function function for setting environment variables
!macro ENVFUNC un
  Function ${un}setenv

    SetShellVarContext current
    StrCpy $DATADIR "$APPDATA\${APPNAME}"
    StrCpy $NODEDATADIR "$APPDATA\Ethereum"
    StrCpy $SHORTCUTDIR "$SMPROGRAMS\${APPNAME}"
    StrCpy $DESKTOPDIR "$DESKTOP"

    ${If} ${RunningX64}
      StrCpy $FILEDIR "$PROGRAMFILES64\${APPNAME}"
      StrCpy $ARCHDIR "win-unpacked"
    ${Else}
      StrCpy $FILEDIR "$PROGRAMFILES32\${APPNAME}"
      StrCpy $ARCHDIR "win-ia32-unpacked"
    ${Endif}

    SetShellVarContext all

  FunctionEnd
!macroend

!insertmacro ENVFUNC ""
!insertmacro ENVFUNC "un."


# Include translations for NSIS default strings
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
#LoadLanguageFile "${NSISDIR}\Contrib\Language files\Czech.nlf"
#LoadLanguageFile "${NSISDIR}\Contrib\Language files\Dutch.nlf"
#LoadLanguageFile "${NSISDIR}\Contrib\Language files\French.nlf"
#LoadLanguageFile "${NSISDIR}\Contrib\Language files\German.nlf"
#LoadLanguageFile "${NSISDIR}\Contrib\Language files\Korean.nlf"
#LoadLanguageFile "${NSISDIR}\Contrib\Language files\Russian.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\Spanish.nlf"
#LoadLanguageFile "${NSISDIR}\Contrib\Language files\Swedish.nlf"
#LoadLanguageFile "${NSISDIR}\Contrib\Language files\TradChinese.nlf"
#LoadLanguageFile "${NSISDIR}\Contrib\Language files\SimpChinese.nlf"
#LoadLanguageFile "${NSISDIR}\Contrib\Language files\Slovak.nlf"

# Include translations for custom strings
!include LangEnglish.nsh
!include LangSpanish.nsh

# Language selection dialog
Function selectlang
  Push ""
  Push ${LANG_ENGLISH}
  Push English
  #Push ${LANG_CZECH}
  #Push čeština‎
  #Push ${LANG_DUTCH}
  #Push Nederlands
  #Push ${LANG_FRENCH}
  #Push Français
  #Push ${LANG_GERMAN}
  #Push Deutsche
  #Push ${LANG_KOREAN}
  #Push 한국어
  #Push ${LANG_RUSSIAN}
  #Push Русский
  Push ${LANG_SPANISH}
  Push Español
  #Push ${LANG_SWEDISH}
  #Push Svenska
  #Push ${LANG_TRADCHINESE}
  #Push "正體字"
  #Push ${LANG_SIMPCHINESE}
  #Push "简化字"
  #Push ${LANG_SLOVAK}
  #Push Slovenčina
  Push A ; A means auto count languages
         ; for the auto count to work the first empty push (Push "") must remain
  LangDLL::LangDialog "Language Selection" "Choose a language"

  Pop $LANGUAGE
  StrCmp $LANGUAGE "cancel" 0 +2
    Abort
FunctionEnd

function .onInit
  !insertmacro VerifyUserIsAdmin
  call setenv
  call selectlang
functionEnd

# The license page. Can use .txt or .rtf data
PageEx license
  LicenseData ..\LICENSE
PageExEnd

# Components is a good place to allow the user to select optional software to install
# For example, it could be used to allow the user to select which node they want installed and then download it
#Page components

# Select the location to install the main program files
PageEx directory
  DirVar $FILEDIR
PageExEnd

## Select the location for Mist's data directory
#PageEx directory
#  DirText $(msgDatadir)
#  DirVar $DATADIR
#PageExEnd

# Select the location for the node's data directory
PageEx directory
  DirText $(msgNodeDatadir)
  DirVar $NODEDATADIR
PageExEnd

# Installation
Page instfiles

# Uninstaller confirmation page. Useful to remind the user what data (if any) will remain, for example chaindata or keystore
UninstPage uninstConfirm

# Uninstallation section
UninstPage instfiles

# Show details by default
ShowInstDetails show
ShowUninstDetails show

# Mist installer instructions
Section Mist MIST_IDX
    StrCpy $switch_overwrite 1

    # set the installation directory as the destination for the following actions
    SetOutPath $TEMP
    # include both architecture zip files
    file "..\dist_mist\release\${APPNAME}-win64-${VERSIONMAJOR}-${VERSIONMINOR}-${VERSIONBUILD}.zip"
    file "..\dist_mist\release\${APPNAME}-win32-${VERSIONMAJOR}-${VERSIONMINOR}-${VERSIONBUILD}.zip"
    file "..\dist_mist\build\icon.ico"

    # Extract the zip file from TEMP to the user's selected installation directory
    ${If} ${RunningX64}
      ZipDLL::extractALL "$TEMP\${APPNAME}-win64-${VERSIONMAJOR}-${VERSIONMINOR}-${VERSIONBUILD}.zip" "$FILEDIR"
      StrCpy $ARCHDIR "win-unpacked"
    ${Else}
      ZipDLL::extractALL "$TEMP\${APPNAME}-win32-${VERSIONMAJOR}-${VERSIONMINOR}-${VERSIONBUILD}.zip" "$FILEDIR"
      StrCpy $ARCHDIR "win-ia32-unpacked"
    ${Endif}
    
    # Move files out of subfolder
    !insertmacro MoveFolder "$FILEDIR\$ARCHDIR" "$FILEDIR" "*.*"
    # Copy icon from installer (not included in zip)
    !insertmacro MoveFile "$TEMP\icon.ico" "$FILEDIR\logo.ico"
 
    # create the uninstaller
    WriteUninstaller "$FILEDIR\uninstall.exe"
 
    # create shortcuts with flags in the start menu programs directory
    createDirectory "$SHORTCUTDIR"
    createShortCut "$SHORTCUTDIR\${APPNAME}.lnk" "$FILEDIR\${APPNAME}.exe" '--node-datadir="$NODEDATADIR"' "$FILEDIR\${APPNAME}.exe" 0

    # create desktop shortcut
    createShortCut "$DESKTOPDIR\${APPNAME}.lnk" "$FILEDIR\${APPNAME}.exe" '--node-datadir="$NODEDATADIR"' "$FILEDIR\${APPNAME}.exe" 0

    # create a shortcut for the program uninstaller
    CreateShortCut "$SHORTCUTDIR\Uninstall.lnk" "$FILEDIR\uninstall.exe"

    ## Firewall - add rules
    #SimpleFC::AdvAddRule "Geth incoming peers (TCP:30303)" ""  6 1 1 2147483647 1 "$DATADIR\binaries\Geth\unpacked\geth.exe" "" "" "Ethereum" 30303 "" "" ""
    #SimpleFC::AdvAddRule "Geth outgoing peers (TCP:30303)" ""  6 2 1 2147483647 1 "$DATADIR\binaries\Geth\unpacked\geth.exe" "" "" "Ethereum" "" 30303 "" ""
    #SimpleFC::AdvAddRule "Geth UDP discovery (UDP:30303)" "" 17 2 1 2147483647 1 "$DATADIR\binaries\Geth\unpacked\geth.exe" "" "" "Ethereum" "" 30303 "" ""

    # write registry strings for uninstallation
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "DisplayName" "${GROUPNAME} ${APPNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "UninstallString" '"$FILEDIR\uninstall.exe"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "InstallLocation" '"$FILEDIR"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "InstallDate" "${NOW}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "DisplayIcon" '"$FILEDIR\logo.ico"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "Publisher" "${GROUPNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "HelpLink" '"${HELPURL}"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "URLUpdateInfo" '"${UPDATEURL}"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "URLInfoAbout" '"${ABOUTURL}"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "DisplayVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "VersionMajor" ${VERSIONMAJOR}
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "VersionMinor" ${VERSIONMINOR}
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "NoRepair" 1
    # calculate and store installation size
    Call GetInstalledSize
    Pop $0
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "EstimatedSize" "$0"

    # write registry strings for current user options
    WriteRegStr HKCU "Software\${GROUPNAME} ${APPNAME}" "DATADIR" "$DATADIR"
    WriteRegStr HKCU "Software\${GROUPNAME} ${APPNAME}" "NODEDATADIR" "$NODEDATADIR"
    WriteRegStr HKCU "Software\${GROUPNAME} ${APPNAME}" "DESKTOPDIR" "$DESKTOPDIR"

    # Clean up temporary files
    Delete "$TEMP\${APPNAME}-win32-${VERSIONMAJOR}-${VERSIONMINOR}-${VERSIONBUILD}.zip"
    Delete "$TEMP\${APPNAME}-win64-${VERSIONMAJOR}-${VERSIONMINOR}-${VERSIONBUILD}.zip"
SectionEnd

Function .onInstSuccess
  ExecShell "open" "$SHORTCUTDIR"
FunctionEnd

function un.onInit
  call un.setenv
  !insertmacro VerifyUserIsAdmin
functionEnd
 
# uninstaller section start
Section "uninstall"
    # get user settings from registry
    ClearErrors
    ReadRegStr $0  HKCU "Software\${GROUPNAME} ${APPNAME}" 'DATADIR'
    ReadRegStr $1  HKCU "Software\${GROUPNAME} ${APPNAME}" 'NODEDATADIR'
    ReadRegStr $2  HKCU "Software\${GROUPNAME} ${APPNAME}" 'DESKTOPDIR'

    IfErrors 0 +2
    MessageBox MB_ICONEXCLAMATION|MB_OK $(msgRegError)

    StrCpy $DATADIR $0
    StrCpy $NODEDATADIR $1
    StrCpy $DESKTOPDIR $2

    # remove the link from the start menu
    rmDir /r "$SHORTCUTDIR"

    # remove desktop shortcut
    Delete "$DESKTOPDIR\${APPNAME}.lnk"

    # remove files from installation directory
    rmDir /r /REBOOTOK "$FILEDIR"

    ## Firewall - remove rules (if exists)
    #SimpleFC::AdvRemoveRule "Geth incoming peers (TCP:30303)"
    #SimpleFC::AdvRemoveRule "Geth outgoing peers (TCP:30303)"
    #SimpleFC::AdvRemoveRule "Geth UDP discovery (UDP:30303)"

    # delete registry strings
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}"
    DeleteRegKey HKCU "Software\${GROUPNAME} ${APPNAME}"
SectionEnd

Function un.onUnInstSuccess
  MessageBox MB_OK $(msgLeftover)
  ExecShell "open" "$DATADIR"
  ExecShell "open" "$NODEDATADIR"
FunctionEnd


# Return on top of stack the total size (as DWORD) of the selected/installed sections.
Var GetInstalledSize.total
Function GetInstalledSize
  StrCpy $GetInstalledSize.total 0

  ${if} ${SectionIsSelected} ${MIST_IDX}
    ${locate::GetSize} "$FILEDIR" "/S=Kb" $0 $1 $2
    # TODO check for return of -1 for error
    IntOp $GetInstalledSize.total $GetInstalledSize.total + $0
  ${endif}

  IntFmt $GetInstalledSize.total "0x%08X" $GetInstalledSize.total
  Push $GetInstalledSize.total
FunctionEnd
