# Repackage the FSF Windows binaries in a convenient installer.
# Also offer the option at install time to integrate with our
# Emacs-Lisp inteface.

AT_FRANZ := $(shell if test -d /c/emacs-dist; then echo yes; else echo no; fi)

VERS = 23.3
XVERS := $(shell echo $(VERS) | sed 's/[.]//g')

ifeq ($(AT_FRANZ),yes)
EMACSDIR = C:/emacs-dist/emacs-$(VERS)
else
EMACSDIR = emacs-$(VERS)
endif

EXE = emacs$(XVERS).exe

NSIS_ARGS = /V1 /DVERS=$(VERS) /DEMACSDIR=$(EMACSDIR) /DEXENAME=$(EXE) 
ifdef LISPBOX
NSIS_ARGS += /DLISPBOX=$(LISPBOX)
endif

MAKENSIS = "/c/Program Files/NSIS/makensis.exe" $(NSIS_ARGS)

default: $(EXE)

$(EXE): FORCE
	$(MAKENSIS) install.nsi

clean: FORCE
	rm -f $(EXE)

FORCE:
