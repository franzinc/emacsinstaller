# Repackage the FSF Windows binaries in a convenient installer.
# Also offer the option at install time to integrate with our
# Emacs-Lisp interface.

VERS = 25.2
XVERS := $(shell echo $(VERS) | sed 's/[.]//g')

# Starting with Emacs 25.2, this is how the directory should be created:
#  $ mkdir emacs-25.2
#  $ cd emacs-25.2
#  $ unzip ../emacs-25.2-i686.zip
#  $ unzip ../emacs-25-i686-deps.zip
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
