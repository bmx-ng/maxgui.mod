/*
 Copyright (c) 2014-2020 Bruce A Henderson
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
*/

#include <gtk/gtk.h>
#include "Scintilla.h"
#include "SciLexer.h"
#include "ScintillaWidget.h"

#include "blitz.h"

ScintillaObject * bmx_mgta_scintilla_getsci(void * editor, int id) {
	ScintillaObject * obj = SCINTILLA(editor);
	scintilla_set_id(obj, id);

	scintilla_send_message(obj, SCI_SETCODEPAGE, SC_CP_UTF8, 0);
	scintilla_send_message(obj, SCI_ALLOCATELINECHARACTERINDEX, SC_LINECHARACTERINDEX_UTF16 , 0);
	scintilla_send_message(obj, SCI_SETSCROLLWIDTH, 1 , 0);
	scintilla_send_message(obj, SCI_SETSCROLLWIDTHTRACKING, 1 , 0);

	return obj;
}
