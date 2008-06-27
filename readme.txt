$Id: readme.txt,v 1.3 2008/06/27 04:30:20 layer Exp $

How to build your own emacs installer.  The instructions below assume
that `makefile' and `install.nsi' have been downloaded and in the
current working directory.

1. Download and Install NSIS v 2.x from http://nsis.sourceforge.net

2. Download the Emacs version of choice from

      http://ftp.gnu.org/pub/gnu/emacs/windows/

   For the current version I downloaded emacs-22.2-bin-i386.zip

3. Extract the Emacs binaries into the current directory.  This should
   create an `emacs-22.2' subdirectory.

   (If you have downloaded a different version of emacs, modify the
   VERS variable in the `makefile'.)

4. Type "make" to build the installer.
   This requires GNU make from www.cygwin.com to be installed.
