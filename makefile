# $Id: makefile,v 1.4 2007/08/14 18:12:26 layer Exp $

VERS = 22.1
XVERS := $(shell echo $(VERS) | sed 's/[.]//g')

EMACSDIR = D:/emacs-dist/emacs-$(VERS)
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
