# $Id: makefile,v 1.7 2008/10/23 03:23:33 layer Exp $

AT_FRANZ := $(shell if test -d /d/emacs-dist; then echo yes; else echo no; fi)

VERS = 22.3
XVERS := $(shell echo $(VERS) | sed 's/[.]//g')

ifeq ($(AT_FRANZ),yes)
EMACSDIR = D:/emacs-dist/emacs-$(VERS)
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
