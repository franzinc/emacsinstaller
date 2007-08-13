# $Id: makefile,v 1.3 2007/08/13 23:29:07 layer Exp $

VERS = 21.3
XVERS := $(shell echo $(VERS) | sed 's/[.]//g')

EMACSDIR = emacs-$(VERS)
EXE = emacs$(XVERS).exe

NSIS_ARGS = /V1 /DVERS=$(VERS) /DEMACSDIR=$(EMACSDIR) /DEXENAME=$(EXE) 
ifdef LISPBOX
NSIS_ARGS += /DLISPBOX=$(LISPBOX)
endif

MAKENSIS = "/c/Program Files/NSIS/makensis.exe" $(NSIS_ARGS)

default: FORCE
	@echo "There is no default make rule."
	@echo "Use either \"make installer\" for the emacs installer or"
	@echo "\"make lispbox\" for the emacs used in Lisp in a box."
	@exit 1

installer: $(EXE)

lispbox: FORCE
	@$(MAKE) -s LISPBOX=lispbox installer

$(EXE): FORCE
	$(MAKENSIS) install.nsi

clean: FORCE
	rm -f $(EXE)

FORCE:
