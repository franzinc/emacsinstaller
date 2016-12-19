# Repackage the FSF Windows binaries in a convenient installer.
# Also offer the option at install time to integrate with our
# Emacs-Lisp interface.

VERS = 25.1
XVERS := $(shell echo $(VERS) | sed 's/[.]//g')

# Starting with Emacs 25.1, this is how the directory should be created:
#  $ mkdir emacs-25.1
#  $ cd emacs-25.1
#  $ unzip ../emacs-25.1-2-i686-w64-mingw32.zip
#  $ unzip ../emacs-25-i686-deps.zip
# For reasons unknown the file
#   emacs-25.1-2-i686-w64-mingw32.zip
# is a lot bigger than the previous version
#   emacs-25.1-i686-w64-mingw32.zip
# was was created a couple of months before.  I unpacked both directories
# and looked at the differences, and there were only a couple of small
# files added in the new version.
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
