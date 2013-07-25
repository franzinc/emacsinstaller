# Repackage the FSF Windows binaries in a convenient installer.
# Also offer the option at install time to integrate with our
# Emacs-Lisp inteface.

VERS = 24.3
XVERS := $(shell echo $(VERS) | sed 's/[.]//g')

EMACSDIR = ../emacs-dist/emacs-$(VERS)

EXE = emacs$(XVERS).exe

NSIS_ARGS = /V1 /DVERS=$(VERS) /DEMACSDIR=$(EMACSDIR) /DEXENAME=$(EXE) 
ifdef LISPBOX
NSIS_ARGS += /DLISPBOX=$(LISPBOX)
endif

MAKENSIS = "/c/Program Files (x86)/NSIS/makensis.exe" $(NSIS_ARGS)

default: $(EXE)

$(EXE): FORCE
	$(MAKENSIS) install.nsi

clean: FORCE
	rm -f $(EXE)

FORCE:
