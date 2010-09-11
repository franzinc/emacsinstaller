; $Id: install.nsi,v 1.3 2008/06/27 04:30:20 layer Exp $

!define ACLREGKEY "Software\Franz Inc.\Allegro Common Lisp"
!define REGKEY    "Software\Franz Inc.\Gnu Emacs Installer"
!define GNUREGKEY "Software\GNU\Emacs"
!define VERBOSE_PROD "Gnu Emacs ${VERS}"
!define SHORT_PROD "Gnu Emacs"

!include "StrFunc.nsh"
# Declare used Functions from StrFunc
${StrRep}

SetCompressor /SOLID /FINAL lzma

Name "${VERBOSE_PROD}"

; The installer program that will be created
OutFile "${EXENAME}"

; The default installation directory
InstallDir "$PROGRAMFILES\${VERBOSE_PROD}"

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "${REGKEY}" "Install_Dir"

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "-${VERBOSE_PROD}"

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath "$INSTDIR"

  File /r "${EMACSDIR}\*"

  ; Write the installation path into the registry
  WriteRegStr HKLM "${REGKEY}" "Install_Dir" "$INSTDIR"

!define UNINSTMAIN "Software\Microsoft\Windows\CurrentVersion\Uninstall"
!define UNINSTKEY "${UNINSTMAIN}\${SHORT_PROD}"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "${UNINSTKEY}" "DisplayName" "${VERBOSE_PROD}"
  WriteRegStr HKLM "${UNINSTKEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "${UNINSTKEY}" "NoModify" 1
  WriteRegDWORD HKLM "${UNINSTKEY}" "NoRepair" 1
  WriteUninstaller "uninstall.exe"

  ; Pass the directory so the user is not asked any questions.
  ; Boy, that is one funky way to get a " into a string...
  ExecWait "$INSTDIR\bin\addpm.exe $\"$PROGRAMFILES\${VERBOSE_PROD}$\""

SectionEnd

; Optional section (can be disabled by the user)
  var homevar
  var test
  var edited_eli_p
  var eli_init_file
  var eli_handle
  var eli_text
  var allegro_dir

Function FindAclHomeDir

; setup stack of registry locations to check for Allegro directory
; based on ACLREGKEY. bug19652
; pairs: push 'name'
;        push 'sub_key'

;; for some reason the key name changed partway through 8.1

Push "InstallationDirectory"
Push "" ; 8.0

Push "InstallationDirectory"
Push "8.1 Student Edition"

Push "Install_Dir"
Push "8.1 Free Express Edition"

Push "InstallationDirectory"
Push "8.1"

Push "Install_Dir"
Push "8.2 Student Edition"

Push "Install_Dir"
Push "8.2 Free Express Edition"

Push "Install_Dir"
Push "8.2"

StrCpy $0 14 ; set to the number of pushes above.

loop:
  Pop $1
  Pop $2
  IntOp $0 $0 - 2
  IfErrors pop_error
  ; MessageBox MB_OK|MB_ICONSTOP "Popped '$1' '$2'. Looking it up in registry."
  StrCpy $1 "${ACLREGKEY}\$1"
  ReadRegStr $3 HKLM $1 $2
  ClearErrors
  ; MessageBox MB_OK|MB_ICONSTOP "registry result: '$3'"
  StrLen $test $3
  IntCmp $test 0 0 0 cleanup    ; match found.
  IntCmp $0 0 done              ; searched all locations
  goto loop
pop_error:
  ; MessageBox MB_OK|MB_ICONSTOP "Got an error while popping."
cleanup: ; pop remaining items off the stack
  ; MessageBox MB_OK|MB_ICONSTOP "cleaning up remaining items on stack. i='$0'"
  IntCmp $0 0 done
  Pop $2
  IntOp $0 $0 - 1
  goto cleanup
done:
  ClearErrors
  ; MessageBox MB_OK|MB_ICONSTOP "final result: '$3'"
  push $3
FunctionEnd


Section "Allegro Emacs-Lisp Interface setup"

  ; MessageBox MB_OK|MB_ICONSTOP "Starting ACL Check."

  ;; check for Allegro installation first.
  ;; check in each supported registry location. bug19652
  Call FindACLHomeDir
  Pop $allegro_dir

  ; MessageBox MB_OK|MB_ICONSTOP "ACL dir is '$allegro_dir'"

  StrLen $test $allegro_dir
  IntCmp $test 0 end_eli_section

determine_homedir:
  ; Check for existing .emacs file.
  ; if HOME is set, look for .emacs there, else look in 'C:\'

  ReadEnvStr $homevar "HOME"

  ; MessageBox MB_OK|MB_ICONSTOP "HOME dir is '$homevar'"

  StrLen $test $homevar
  IntCmp $test 0 eli_default
  ; need to check for trailing slash here. annoying.
  StrCpy $eli_init_file "$homevar\.emacs"
  goto check_for_eli

eli_default:
  StrCpy $eli_init_file "C:\.emacs"

check_for_eli:
  ;; prompt for modify/create .emacs file.
  IfFileExists "$homevar\.emacs" prompt_to_append prompt_to_create

prompt_to_append:
  MessageBox MB_YESNO|MB_ICONQUESTION \
	"Would you like us to modify $eli_init_file to include sample \
	code for loading the Allegro Emacs-Lisp interface?" \
	/SD IDNO \
	IDNO end_eli_section

  ; append to eli file.
  FileOpen $eli_handle $eli_init_file "a"
  FileSeek $eli_handle 0 END
  FileWriteByte $eli_handle "13"
  FileWriteByte $eli_handle "10"
  goto write_to_eli

prompt_to_create:
  MessageBox MB_YESNO|MB_ICONQUESTION \
	"Would you like to create $eli_init_file with sample code \
	for loading the Allegro Emacs-Lisp interface?" \
	/SD IDNO \
	IDNO end_eli_section

  ; create eli file.
  FileOpen $eli_handle $eli_init_file "w"

write_to_eli:
  IntOp $edited_eli_p 1 + 0
  FileWrite $eli_handle \
	"; This is sample code for starting and specifying defaults to the"
  FileWriteByte $eli_handle "13"
  FileWriteByte $eli_handle "10"
  FileWrite $eli_handle \
	"; Emacs-Lisp interface. Uncomment this code if you want the ELI"
  FileWriteByte $eli_handle "13"
  FileWriteByte $eli_handle "10"
  FileWrite $eli_handle \
	"; to load automatically when you start emacs."
  FileWriteByte $eli_handle "13"
  FileWriteByte $eli_handle "10"
  ${StrRep} $eli_text '; (push "$allegro_dir/eli" load-path)' '\' '/'
  FileWrite $eli_handle $eli_text
  FileWriteByte $eli_handle "13"
  FileWriteByte $eli_handle "10"
  FileWrite $eli_handle '; (load "fi-site-init.el")'
  FileWriteByte $eli_handle "13"
  FileWriteByte $eli_handle "10"
  FileWrite $eli_handle ';'
  FileWriteByte $eli_handle "13"
  FileWriteByte $eli_handle "10"
  ${StrRep} $eli_text \
	'; (setq fi:common-lisp-image-name "$allegro_dir/mlisp.exe")' \
	'\' '/'
  FileWrite $eli_handle $eli_text
  FileWriteByte $eli_handle "13"
  FileWriteByte $eli_handle "10"
  ${StrRep} $eli_text \
	'; (setq fi:common-lisp-image-file "$allegro_dir/mlisp.dxl")' \
	'\' '/'
  FileWrite $eli_handle $eli_text
  FileWriteByte $eli_handle "13"
  FileWriteByte $eli_handle "10"
  ${StrRep} $eli_text '; (setq fi:common-lisp-directory "$allegro_dir")' \
	'\' '/'
  FileWrite $eli_handle $eli_text
  FileWriteByte $eli_handle "13"
  FileWriteByte $eli_handle "10"
  FileClose $eli_handle

end_eli_section:

SectionEnd

Section "Start Menu Shortcuts"

  SetShellVarContext all
!define SMDIR "$SMPROGRAMS\${SHORT_PROD}"

  CreateDirectory "${SMDIR}"
  CreateShortCut "${SMDIR}\Uninstall.lnk" "$INSTDIR\uninstall.exe"

SectionEnd

Section "Run Emacs after install"

  MessageBox MB_YESNO|MB_ICONQUESTION|MB_TOPMOST \
	"Would you like to start Emacs now?" \
	/SD IDNO \
	IDNO norun

  IntCmp $edited_eli_p 0 open_without_initfile
  Exec '"$INSTDIR\bin\runemacs.exe" "$eli_init_file"'
  goto norun
open_without_initfile:
  Exec '"$INSTDIR\bin\runemacs.exe "'

norun:

SectionEnd

;------------------------------------------------------------------------------

; Author: Lilla (lilla@earthlink.net) 2003-06-13
; function IsUserAdmin uses plugin \NSIS\PlusgIns\UserInfo.dll
; This function is based upon code in \NSIS\Contrib\UserInfo\UserInfo.nsi
; This function was tested under NSIS 2 beta 4 (latest CVS as of this writing).
;
; Usage:
;   Call IsUserAdmin
;   Pop $R0   ; at this point $R0 is "true" or "false"
;
Function IsUserAdmin
Push $R0
Push $R1
Push $R2

ClearErrors
UserInfo::GetName
IfErrors Win9x
Pop $R1
UserInfo::GetAccountType
Pop $R2

StrCmp $R2 "Admin" 0 Continue
; Observation: I get here when running Win98SE. (Lilla)
; The functions UserInfo.dll looks for are there on Win98 too, 
; but just don't work. So UserInfo.dll, knowing that admin isn't required
; on Win98, returns admin anyway. (per kichik)
StrCpy $R0 "true"
Goto Done

Continue:
; You should still check for an empty string because the functions
; UserInfo.dll looks for may not be present on Windows 95. (per kichik)
StrCmp $R2 "" Win9x
StrCpy $R0 "false"
Goto Done

Win9x:
; we don't work on win9x...
StrCpy $R0 "false"

Done:

Pop $R2
Pop $R1
Exch $R0
FunctionEnd

;------------------------------------------------------------------------------

; IsWin9x
;
; Base on GetWindowsVersion from
;     http://nsis.sourceforge.net/wiki/Get_Windows_version
;
; Based on Yazno's function, http://yazno.tripod.com/powerpimpit/
; Updated by Joost Verburg
;
; Returns on top of stack
;
; Windows Version (95, 98, ME, NT x.x, 2000, XP, 2003)
; or
; '' (Unknown Windows Version)
;
; Usage:
;   Call IsWin9x
;   Pop $R0
;   ; at this point $R0 is "true" or "false"
 
Function IsWin9x

Push $R0
Push $R1

ClearErrors

ReadRegStr $R0 HKLM \
"SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion

IfErrors 0 lbl_winnt

; we are not NT
StrCpy $R0 "true"
Goto lbl_done

lbl_winnt:

StrCpy $R0 "false"

lbl_done:

Pop $R1
Exch $R0
 
FunctionEnd

;------------------------------------------------------------------------------

Function .onInit

  Call IsWin9x
  Pop $R0   ; at this point $R0 is "true" or "false"
  StrCmp $R0 "true" 0 IsWinNT
     MessageBox MB_OK \
        'The NetInstaller does not work on Windows 9x.'
     Abort
 IsWinNT:

  Call IsUserAdmin
  Pop $R0   ; at this point $R0 is "true" or "false"
  StrCmp $R0 "false" 0 IsAdmin
     MessageBox MB_OK \
        'You must be a member of the Administrators group to run installer.'
     Abort
 IsAdmin:

  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "AllegroEmacsInstallerMutex") i .r1 ?e'
  Pop $R0
 
  StrCmp $R0 0 +3
    MessageBox MB_OK|MB_ICONEXCLAMATION \
	'The NetInstaller is already running.'
    Abort

FunctionEnd

;--------------------------------

; Uninstaller

Section "-Un.Uninstall"
  
  SetShellVarContext all

  DeleteRegKey HKLM "${UNINSTKEY}"
  DeleteRegKey HKLM "${REGKEY}"
  DeleteRegKey HKLM "${GNUREGKEY}"

  RMDir /r /REBOOTOK "$INSTDIR"
  RMDir /r /REBOOTOK "${SMDIR}"

SectionEnd
