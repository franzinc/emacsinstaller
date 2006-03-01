# $Id: makefile,v 1.1.1.1 2006/03/01 07:05:05 layer Exp $

VERS = 21.3

EMACSDIR = emacs-$(VERS)
EXE = emacs$(VERS).exe

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
