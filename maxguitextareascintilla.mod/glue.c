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

#include "Scintilla.h"
#include "SciLexer.h"

#include "blitz.h"

#ifdef WIN32
#define scintilla_send_message SendMessage
typedef HWND SCI_HANDLE;
#else
#include <gtk/gtk.h>
#include "ScintillaWidget.h"
typedef ScintillaObject * SCI_HANDLE;
#endif

#define TEXTFORMAT_BOLD 1
#define TEXTFORMAT_ITALIC 2
#define TEXTFORMAT_UNDERLINE 4
#define SCE_B_COMMENTREM 19

#ifdef BMX_NG
	void maxgui_maxguitextareascintilla_common_TSCNotification__update(BBObject *, int, int, int);
#else
	void _maxgui_maxguitextareascintilla_TSCNotification__update(BBObject *, int, int, int);
#endif

BBString * bmx_mgta_scintilla_gettext(SCI_HANDLE sci) {
	int len = scintilla_send_message(sci, SCI_GETLENGTH, 0, 0);
	
	char * buffer = malloc(len + 1);
	
	scintilla_send_message(sci, SCI_GETTEXT, len, (sptr_t)buffer);
	
	BBString * s = bbStringFromUTF8String(buffer);
	
	free(buffer);

	return s;
}

void bmx_mgta_scintilla_settext(SCI_HANDLE sci, BBString * text) {
	char * t = bbStringToUTF8String(text);

	scintilla_send_message(sci, SCI_SETTEXT, 0, (sptr_t)t);
	
	bbMemFree(t);
}

void bmx_mgta_scintilla_setfont(SCI_HANDLE sci, BBString * name, int size) {
	int style;

	char * n = bbStringToUTF8String(name);

	/* make sure all the styles are changed */
	for (style = 0; style < STYLE_MAX; style++) {
		scintilla_send_message(sci, SCI_STYLESETFONT, style, (sptr_t)n);
		scintilla_send_message(sci, SCI_STYLESETSIZE, style, size);
	}
	
	bbMemFree(n);
}

void bmx_mgta_scintilla_setlinedigits(SCI_HANDLE sci, int * digits, int show) {

	if (!show) {
		*digits = 0;
		scintilla_send_message(sci, SCI_SETMARGINWIDTHN, 0, 0);
		return;
	}
	
	int lines = scintilla_send_message(sci, SCI_GETLINECOUNT, 0, 0);
	int newDigits = (lines < 10 ? 1 : (lines < 100 ? 2 :   
		(lines < 1000 ? 3 : (lines < 10000 ? 4 :   
		(lines < 100000 ? 5 : (lines < 1000000 ? 6 :   
		(lines < 10000000 ? 7 : (lines < 100000000 ? 8 :  
		(lines < 1000000000 ? 9 : 10)))))))));

	if (*digits != newDigits) {
		*digits = newDigits;

		int i;
		int len = newDigits + 1;
		char * buf = malloc(len + 1);
		buf[0] = '_';
		buf[len] = 0;
		for (i = 1; i < len; i++) {
			buf[i] = '9';
		}
		
		/* set the linenumber margin width */
		int textWidth = scintilla_send_message(sci, SCI_TEXTWIDTH, STYLE_LINENUMBER, (sptr_t)buf) + 4;
		scintilla_send_message(sci, SCI_SETMARGINWIDTHN, 0, textWidth);
		
		free(buf);
	}
}

int bmx_mgta_scintilla_textwidth(SCI_HANDLE sci, BBString * text) {
	char * t = bbStringToUTF8String(text);
	int textWidth = scintilla_send_message(sci, SCI_TEXTWIDTH, STYLE_LINENUMBER, (sptr_t)t);
	bbMemFree(t);

	return textWidth;
}

int bmx_mgta_scintilla_charfrombyte(SCI_HANDLE sci, int pos, int startPos) {
	int i;
	int characterOffset = 0;
	int length = pos - startPos;

	if (length <= 0) {
		return 0;
	}

	struct Sci_TextRange range;
	range.chrg.cpMin = startPos;
	range.chrg.cpMax = pos;
	
	range.lpstrText = malloc(length + 1);
	
	int len = scintilla_send_message(sci, SCI_GETTEXTRANGE, 0, (sptr_t)(&range));

	for (i = 0; i < length; i++) {
		char c = range.lpstrText[i];
		if ((c & 0xc0) != 0x80) {
				characterOffset++;
		}
	}
	free(range.lpstrText);

	return characterOffset;
}

void bmx_mgta_scintilla_startendfromchar(SCI_HANDLE sci, int pos, int length, int * startPos, int * endPos) {
	// all
	if (length == -1) {
		*startPos = 0;
		*endPos = scintilla_send_message(sci, SCI_GETLENGTH, 0, 0);
		return;
	}

	int startLine = scintilla_send_message(sci, SCI_LINEFROMINDEXPOSITION, pos, SC_LINECHARACTERINDEX_UTF16);
	int startLinePos = scintilla_send_message(sci, SCI_INDEXPOSITIONFROMLINE, startLine, SC_LINECHARACTERINDEX_UTF16);

	int actualStartLinePos = scintilla_send_message(sci, SCI_POSITIONFROMLINE, startLine, 0);
	*startPos = scintilla_send_message(sci, SCI_POSITIONRELATIVECODEUNITS, actualStartLinePos, pos - startLinePos);
	
	if (length) {
		*endPos = scintilla_send_message(sci, SCI_POSITIONRELATIVECODEUNITS, *startPos, length);
		if (*endPos == 0) {
			*endPos = scintilla_send_message(sci, SCI_GETLENGTH, 0, 0);
		}
	} else {
		*endPos = *startPos;
	}
}

int bmx_mgta_scintilla_positionfromline(SCI_HANDLE sci, int line, int valueInBytes) {
	if (valueInBytes){
		return scintilla_send_message(sci, SCI_POSITIONFROMLINE, line, 0);
	} else {
		return scintilla_send_message(sci, SCI_INDEXPOSITIONFROMLINE, line, SC_LINECHARACTERINDEX_UTF16);
	}
}

void bmx_mgta_scintilla_setselectionstart(SCI_HANDLE sci, int pos) {
	scintilla_send_message(sci, SCI_SETSELECTIONSTART, pos, 0);
}

void bmx_mgta_scintilla_setselectionend(SCI_HANDLE sci, int pos) {
	scintilla_send_message(sci, SCI_SETSELECTIONEND, pos, 0);
}

void bmx_mgta_scintilla_scrollcaret(SCI_HANDLE sci) {
	scintilla_send_message(sci, SCI_SCROLLCARET, 0, 0);
}

void bmx_mgta_scintilla_setsel(SCI_HANDLE sci, int startPos, int endPos) {
	scintilla_send_message(sci, SCI_SETSEL, startPos, endPos);
}

void bmx_mgta_scintilla_replacesel(SCI_HANDLE sci, const char * text) {
	scintilla_send_message(sci, SCI_REPLACESEL, 0, (sptr_t)text);
}

void bmx_mgta_scintilla_stylesetback(SCI_HANDLE sci, int col) {
	int style;
	
	for (style = 0; style < 33; style++) {
		scintilla_send_message(sci, SCI_STYLESETBACK, style, col);
	}
}

void bmx_mgta_scintilla_stylesetfore(SCI_HANDLE sci, int style, int color) {
	scintilla_send_message(sci, SCI_STYLESETFORE, style, color);
}

void bmx_mgta_scintilla_stylesetitalic(SCI_HANDLE sci, int style, int value) {
	scintilla_send_message(sci, SCI_STYLESETITALIC, style, value);
}

void bmx_mgta_scintilla_stylesetbold(SCI_HANDLE sci, int style, int value) {
	scintilla_send_message(sci, SCI_STYLESETBOLD, style, value);
}

void bmx_mgta_scintilla_stylesetunderline(SCI_HANDLE sci, int style, int value) {
	scintilla_send_message(sci, SCI_STYLESETUNDERLINE, style, value);
}

void bmx_mgta_scintilla_startstyling(SCI_HANDLE sci, int startPos) {
	scintilla_send_message(sci, SCI_STARTSTYLING, startPos, 0x1f);
}

void bmx_mgta_scintilla_setstyling(SCI_HANDLE sci, int realLength, int style) {
	if (realLength == -1) {
		realLength = scintilla_send_message(sci, SCI_GETLENGTH, 0, 0);
	}
	scintilla_send_message(sci, SCI_SETSTYLING, realLength, style);
}

BBString * bmx_mgta_scintilla_gettextrange(SCI_HANDLE sci, int startPos, int endPos) {
	if (endPos == -1) {
		endPos = scintilla_send_message(sci, SCI_GETLENGTH, 0, 0);
	}

	struct Sci_TextRange range;
	range.chrg.cpMin = startPos;
	range.chrg.cpMax = endPos;
	
	range.lpstrText = malloc(endPos - startPos + 1);
	
	int len = scintilla_send_message(sci, SCI_GETTEXTRANGE, 0, (sptr_t)(&range));
	
	BBString * s = bbStringFromUTF8String(range.lpstrText);
	free(range.lpstrText);
	return s;
}

int bmx_mgta_scintilla_getlinecount(SCI_HANDLE sci) {
	return scintilla_send_message(sci, SCI_GETLINECOUNT, 0, 0);
}

int bmx_mgta_scintilla_getlength(SCI_HANDLE sci) {
	return scintilla_send_message(sci, SCI_GETLENGTH, 0, 0);
}

int bmx_mgta_scintilla_getcurrentline(SCI_HANDLE sci) {
	return scintilla_send_message(sci, SCI_LINEFROMPOSITION, scintilla_send_message(sci, SCI_GETSELECTIONSTART, 0, 0), 0);
}

int bmx_mgta_scintilla_getcurrentpos(SCI_HANDLE sci) {
	int line = bmx_mgta_scintilla_getcurrentline(sci);
	int startPos = scintilla_send_message(sci, SCI_POSITIONFROMLINE, line, 0);
	int endPos = scintilla_send_message(sci, SCI_GETSELECTIONSTART, 0, 0);

	return scintilla_send_message(sci, SCI_INDEXPOSITIONFROMLINE, line, SC_LINECHARACTERINDEX_UTF16) + scintilla_send_message(sci, SCI_COUNTCODEUNITS, startPos, endPos);
}

void bmx_mgta_scintilla_settabwidth(SCI_HANDLE sci, int tabs) {
	scintilla_send_message(sci, SCI_SETTABWIDTH, tabs, 0);
}

void bmx_mgta_scintilla_settargetstart(SCI_HANDLE sci, int pos) {
	scintilla_send_message(sci, SCI_SETTARGETSTART, pos, 0);
}

void bmx_mgta_scintilla_settargetend(SCI_HANDLE sci, int pos) {
	scintilla_send_message(sci, SCI_SETTARGETEND, pos, 0);
}

void bmx_mgta_scintilla_replacetarget(SCI_HANDLE sci, const char * text) {
	scintilla_send_message(sci, SCI_REPLACETARGET, -1, (sptr_t)text);
}

void bmx_mgta_scintilla_cut(SCI_HANDLE sci) {
	scintilla_send_message(sci, SCI_CUT, 0, 0);
}

void bmx_mgta_scintilla_copy(SCI_HANDLE sci) {
	scintilla_send_message(sci, SCI_COPY, 0, 0);
}

void bmx_mgta_scintilla_paste(SCI_HANDLE sci) {
	scintilla_send_message(sci, SCI_PASTE, 0, 0);
}

int bmx_mgta_scintilla_linefromposition(SCI_HANDLE sci, int pos) {
	return scintilla_send_message(sci, SCI_LINEFROMINDEXPOSITION, pos, SC_LINECHARACTERINDEX_UTF16);
}

void bmx_mgta_scintilla_appendtext(SCI_HANDLE sci, BBString * text) {
	char * s = bbStringToUTF8String(text);
	scintilla_send_message(sci, SCI_APPENDTEXT, strlen(s), (sptr_t)s);
	bbMemFree(s);
}

void bmx_mgta_scintilla_scrolltoend(SCI_HANDLE sci) {
	scintilla_send_message(sci, SCI_GOTOPOS, scintilla_send_message(sci, SCI_GETLENGTH, 0, 0), 0);
}

int bmx_mgta_scintilla_getselectionlength(SCI_HANDLE sci, int units) {
	if (units == 2) {
		/* lines */
		int startPos = scintilla_send_message(sci, SCI_LINEFROMPOSITION, scintilla_send_message(sci, SCI_GETSELECTIONSTART, 0, 0), 0);
		int endPos = scintilla_send_message(sci, SCI_LINEFROMPOSITION, scintilla_send_message(sci, SCI_GETSELECTIONEND, 0, 0) - 1, 0);
		return (endPos - startPos) + 1;
	} else {
		/* chars */
		int startPos = scintilla_send_message(sci, SCI_GETSELECTIONSTART, 0, 0);
		int endPos = scintilla_send_message(sci, SCI_GETSELECTIONEND, 0, 0);
		int length = scintilla_send_message(sci, SCI_COUNTCODEUNITS, startPos, endPos);
		return length;
	}
}

void bmx_mgta_scintilla_notifcation_update(BBObject * obj, struct SCNotification * notification) {
#ifdef BMX_NG
	maxgui_maxguitextareascintilla_common_TSCNotification__update(obj, notification->nmhdr.code, notification->modificationType, notification->updated);
#else
	_maxgui_maxguitextareascintilla_TSCNotification__update(obj, notification->nmhdr.code, notification->modificationType, notification->updated);
#endif
}

void bmx_mgta_scintilla_setmarginleft(SCI_HANDLE sci, int leftmargin) {
	scintilla_send_message(sci, SCI_SETMARGINLEFT, 0, leftmargin);
}

void bmx_mgta_scintilla_setcaretlinevisible(SCI_HANDLE sci, int enable) {
	scintilla_send_message(sci, SCI_SETCARETLINEVISIBLE, enable, 0);
}

int bmx_mgta_scintilla_getcaretlinevisible(SCI_HANDLE sci) {
	return scintilla_send_message(sci, SCI_GETCARETLINEVISIBLE, 0, 0);
}

void bmx_mgta_scintilla_setcaretlineback(SCI_HANDLE sci, int r, int g, int b, int alpha) {
	scintilla_send_message(sci, SCI_SETCARETLINEBACK, r | (g << 8) | (b << 16), 0);
	scintilla_send_message(sci, SCI_SETCARETLINEBACKALPHA, alpha, 0);
}

int bmx_mgta_scintilla_getcaretlineback(SCI_HANDLE sci) {
	return scintilla_send_message(sci, SCI_GETCARETLINEBACK, 0, 0);
}

void bmx_mgta_scintilla_setcaretwidth(SCI_HANDLE sci, int width) {
	scintilla_send_message(sci, SCI_SETCARETWIDTH, width, 0);
}

void bmx_mgta_scintilla_setcaretcolor(SCI_HANDLE sci, int r, int g, int b) {
	scintilla_send_message(sci, SCI_SETCARETFORE, r | (g << 8) | (b << 16), 0);
}

void bmx_mgta_scintilla_enableundoredo(SCI_HANDLE sci, int enable) {
	scintilla_send_message(sci, SCI_SETUNDOCOLLECTION, enable, 0);
}

int bmx_mgta_scintilla_undoredoenabled(SCI_HANDLE sci) {
	return scintilla_send_message(sci, SCI_GETUNDOCOLLECTION, 0, 0);
}

void bmx_mgta_scintilla_undo(SCI_HANDLE sci) {
	scintilla_send_message(sci, SCI_UNDO, 0, 0);
}

void bmx_mgta_scintilla_redo(SCI_HANDLE sci) {
	scintilla_send_message(sci, SCI_REDO, 0, 0);
}

int bmx_mgta_scintilla_canundo(SCI_HANDLE sci) {
	return scintilla_send_message(sci, SCI_CANUNDO, 0, 0);
}

int bmx_mgta_scintilla_canredo(SCI_HANDLE sci) {
	return scintilla_send_message(sci, SCI_CANREDO, 0, 0);
}

void bmx_mgta_scintilla_clearundoredo(SCI_HANDLE sci) {
	scintilla_send_message(sci, SCI_EMPTYUNDOBUFFER, 0, 0);
}

void bmx_mgta_scintilla_sethighlightlanguage(SCI_HANDLE sci, BBString * lang) {
	char * t = (lang != &bbEmptyString) ? bbStringToUTF8String(lang) : 0;

	if (t) {
		scintilla_send_message(sci, SCI_SETLEXERLANGUAGE, 0, (sptr_t)t);
		bbMemFree(t);
	} else {
		scintilla_send_message(sci, SCI_SETLEXER, SCLEX_NULL, 0);
	}
}

void bmx_mgta_scintilla_sethighlightkeywords(SCI_HANDLE sci, int index, BBString * keywords) {
	char * t = (keywords != &bbEmptyString) ? bbStringToUTF8String(keywords) : 0;
	
	scintilla_send_message(sci, SCI_SETKEYWORDS, index, (sptr_t)(t != NULL ? t : ""));

	if (t) bbMemFree(t);
}

void bmx_mgta_scintilla_sethighlightstyle(SCI_HANDLE sci, int style, int flags, int color) {

	int lang = scintilla_send_message(sci, SCI_GETLEXER, 0, 0);

	if (style == 0) {
		scintilla_send_message(sci, SCI_STYLESETFORE, style, color);
	} else {

		switch (lang) {
			case 222:
				switch (style) {
					case 1:
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_B_COMMENT, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_B_COMMENTREM, color);
						break;
					case 2:
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_B_STRING, color);
						break;
					case 3:
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_B_KEYWORD, color);
						break;
					case 4:
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_B_NUMBER, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_B_HEXNUMBER, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_B_BINNUMBER, color);
						break;
				}
				break;
			case SCLEX_CPP:
				switch (style) {
					case 1:
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_C_COMMENT, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_C_COMMENTLINE, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_C_COMMENTDOC, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_C_COMMENTLINEDOC, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_C_PREPROCESSORCOMMENT, color);
						break;
					case 2:
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_C_STRING, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_C_CHARACTER, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_C_PREPROCESSOR, color);
						break;
					case 3:
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_C_WORD, color);
						break;
					case 4:
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_C_NUMBER, color);
						break;
				}
				break;
			case SCLEX_HTML:
				break;
			case SCLEX_XML:
				break;
			case SCLEX_LUA:
				switch (style) {
					case 1:
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_LUA_COMMENT, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_LUA_COMMENTLINE, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_LUA_COMMENTDOC, color);
						break;
					case 2:
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_LUA_STRING, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_LUA_CHARACTER, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_LUA_LITERALSTRING, color);
						break;
					case 3:
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_LUA_WORD, color);
						break;
					case 4:
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_LUA_NUMBER, color);
						scintilla_send_message(sci, SCI_STYLESETFORE, SCE_B_HEXNUMBER, color);
						break;
				}
				break;
		}
	}

	if (flags & TEXTFORMAT_BOLD) {
		scintilla_send_message(sci, SCI_STYLESETBOLD, style, 1);
	}

	if (flags & TEXTFORMAT_ITALIC) {
		scintilla_send_message(sci, SCI_STYLESETITALIC, style, 1);
	}

	if (flags & TEXTFORMAT_UNDERLINE) {
		scintilla_send_message(sci, SCI_STYLESETUNDERLINE, style, 1);
	}
}

void bmx_mgta_scintilla_highlight(SCI_HANDLE sci) {
	scintilla_send_message(sci, SCI_COLOURISE, 0, -1);
}

void bmx_mgta_scintilla_clearhighlightstyles(SCI_HANDLE sci, int backcolor, int forecolor) {
	scintilla_send_message(sci, SCI_STYLERESETDEFAULT, 0, 0);
	scintilla_send_message(sci, SCI_STYLESETBACK, STYLE_DEFAULT, backcolor);
	scintilla_send_message(sci, SCI_STYLESETFORE, STYLE_DEFAULT, forecolor);
	scintilla_send_message(sci, SCI_STYLECLEARALL, 0, 0);
}

void bmx_mgta_scintilla_setlinenumberbackcolor(SCI_HANDLE sci, int color) {
	scintilla_send_message(sci, SCI_STYLESETBACK, STYLE_LINENUMBER, color);
}

void bmx_mgta_scintilla_setlinenumberforecolor(SCI_HANDLE sci, int color) {
	scintilla_send_message(sci, SCI_STYLESETFORE, STYLE_LINENUMBER, color);
}

void bmx_mgta_scintilla_beginundoaction(SCI_HANDLE sci) {
	scintilla_send_message(sci, SCI_BEGINUNDOACTION, 0, 0);
}

void bmx_mgta_scintilla_endundoaction(SCI_HANDLE sci) {
	scintilla_send_message(sci, SCI_ENDUNDOACTION, 0, 0);
}

void bmx_mgta_scintilla_setbracketmatchingcolor(SCI_HANDLE sci, int r, int g, int b, int flags) {
	scintilla_send_message(sci, SCI_STYLESETFORE, STYLE_BRACELIGHT, r | (g << 8) | (b << 16));

	scintilla_send_message(sci, SCI_STYLESETBOLD, STYLE_BRACELIGHT, 0);
	scintilla_send_message(sci, SCI_STYLESETITALIC, STYLE_BRACELIGHT, 0);
	scintilla_send_message(sci, SCI_STYLESETUNDERLINE, STYLE_BRACELIGHT, 0);

	if (flags & TEXTFORMAT_BOLD) {
		scintilla_send_message(sci, SCI_STYLESETBOLD, STYLE_BRACELIGHT, 1);
	}

	if (flags & TEXTFORMAT_ITALIC) {
		scintilla_send_message(sci, SCI_STYLESETITALIC, STYLE_BRACELIGHT, 1);
	}

	if (flags & TEXTFORMAT_UNDERLINE) {
		scintilla_send_message(sci, SCI_STYLESETUNDERLINE, STYLE_BRACELIGHT, 1);
	}
}

void bmx_mgta_scintilla_matchbrackets(SCI_HANDLE sci) {
	int pos = scintilla_send_message(sci, SCI_GETCURRENTPOS, 0, 0);
	int endPos = scintilla_send_message(sci, SCI_BRACEMATCH, pos, 0);
	if (endPos != -1) {
		scintilla_send_message(sci, SCI_BRACEHIGHLIGHT, pos, endPos);
	} else {
		scintilla_send_message(sci, SCI_BRACEBADLIGHT, -1, 0);
	}
}

void bmx_mgta_scintilla_resetscrollwidth(SCI_HANDLE sci) {
	scintilla_send_message(sci, SCI_SETSCROLLWIDTH, 1 , 0);
}
