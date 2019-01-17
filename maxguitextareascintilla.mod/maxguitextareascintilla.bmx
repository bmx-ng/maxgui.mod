' Copyright (c) 2014-2018 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
'
SuperStrict

Rem
bbdoc: Scintilla-based MaxGUI TextArea gadget.
End Rem
Module MaxGUI.MaxGUITextAreaScintilla

ModuleInfo "Version: 1.00"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: (c) 2014-2018 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

'
' Notes :
'   commented out EM_SETSEL handler section in ScintillaWin.cxx - it was causing all the text to highlight whenever the gadget came into focus.
'
'   Added LINK_LEXER(lmBlitzMax); to Catalogue.cxx

ModuleInfo "CC_OPTS: -fexceptions"

?Linux

ModuleInfo "CC_OPTS: -DGTK"
ModuleInfo "CC_OPTS: -std=c++11"

' glib
ModuleInfo "CC_OPTS: -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/lib/i386-linux-gnu/glib-2.0/include -I/usr/lib/x86_64-linux-gnu/glib-2.0/include -I/usr/lib/arm-linux-gnueabihf/glib-2.0/include -I/usr/lib64/glib-2.0/include"
' gtk
ModuleInfo "CC_OPTS: -I/usr/include/gtk-3.0  -I/usr/lib/i386-linux-gnu/gtk-3.0/include"
' cairo
ModuleInfo "CC_OPTS: -I/usr/include/cairo"
' pango
ModuleInfo "CC_OPTS: -I/usr/include/pango-1.0"
' gdk
ModuleInfo "CC_OPTS: -I/usr/include/gdk-pixbuf-2.0"
' atk
ModuleInfo "CC_OPTS: -I/usr/include/atk-1.0"
' OpenSuse wayland includes
ModulesInfo "CC_OPTS: -I/usr/include/wayland"

?linuxarm
' glib
ModuleInfo "CC_OPTS: -I/usr/lib/arm-linux-gnueabihf/glib-2.0/include"
' gtk
ModuleInfo "CC_OPTS: -I/usr/lib/arm-linux-gnueabihf/gtk-3.0/include"

?linux
ModuleInfo "CPP_OPTS: -std=c++11 -DSCI_NAMESPACE -DSCI_LEXER"
ModuleInfo "CC_OPTS: -DSCI_NAMESPACE -DSCI_LEXER"

Import "linuxgtk.bmx"

?macos

ModuleInfo "CPP_OPTS: -std=c++11 -DSCI_NAMESPACE -DSCI_LEXER"
ModuleInfo "CC_OPTS: -DSCI_NAMESPACE -DSCI_LEXER"

'Import "macos.bmx"

?win32

ModuleInfo "CC_OPTS: -std=c++11 -DSCI_NAMESPACE -DSCI_LEXER -DSTATIC_BUILD"

Import "win32.bmx"

?
