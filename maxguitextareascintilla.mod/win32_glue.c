
#include "Scintilla.h"
#include "SciLexer.h"

#include "blitz.h"

#define scintilla_send_message SendMessage

#ifdef BMX_NG
	void maxgui_maxguitextareascintilla_common_TSCNotification__update(BBObject *, int, int, int);
#else
	void _maxgui_maxguitextareascintilla_TSCNotification__update(BBObject *, int, int, int);
#endif

static int _registered;

HWND bmx_mgta_scintilla_getsci(HWND parent) {

	if (!_registered) {
		_registered = 1;
		Scintilla_RegisterClasses(GetModuleHandleA(NULL));
	}
	
	HWND obj = CreateWindowEx( WS_EX_CLIENTEDGE, "Scintilla", "", WS_CHILD|WS_TABSTOP|WS_CLIPSIBLINGS, 0, 0, 100, 100, parent, 0, GetModuleHandleA(NULL), "");

	scintilla_send_message(obj, SCI_SETCODEPAGE, SC_CP_UTF8, 0);
	scintilla_send_message(obj, SCI_SETMODEVENTMASK , SC_MODEVENTMASKALL, 0);
	scintilla_send_message(obj, SCI_SETEOLMODE, SC_EOL_LF, 0); // the default of CRLF results in double LFs for some reason, which breaks (at least) maxide

	return obj;
}

BBString * bmx_mgta_scintilla_gettext(HWND sci) {
	int len = scintilla_send_message(sci, SCI_GETLENGTH, 0, 0);
	
	char * buffer = malloc(len + 1);
	
	scintilla_send_message(sci, SCI_GETTEXT, len, buffer);
	
	BBString * s = bbStringFromUTF8String(buffer);
	
	free(buffer);

	return s;
}

void bmx_mgta_scintilla_settext(HWND sci, BBString * text) {
	char * t = bbStringToUTF8String(text);

	scintilla_send_message(sci, SCI_SETTEXT, 0, t);
	
	bbMemFree(t);
}

void bmx_mgta_scintilla_setfont(HWND sci, BBString * name, int size) {
	int style;

	char * n = bbStringToUTF8String(name);

	/* make sure all the styles are changed */
	for (style = 0; style < STYLE_MAX; style++) {
		scintilla_send_message(sci, SCI_STYLESETFONT, style, n);
		scintilla_send_message(sci, SCI_STYLESETSIZE, style, size);
	}
	
	bbMemFree(n);
}

void bmx_mgta_scintilla_setlinedigits(HWND sci, int * digits) {

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
		int textWidth = scintilla_send_message(sci, SCI_TEXTWIDTH, STYLE_LINENUMBER, buf) + 4;
		scintilla_send_message(sci, SCI_SETMARGINWIDTHN, 0, textWidth);
		
		free(buf);
	}
}

int bmx_mgta_scintilla_textwidth(HWND sci, BBString * text) {
	char * t = bbStringToUTF8String(text);
	int textWidth = scintilla_send_message(sci, SCI_TEXTWIDTH, STYLE_LINENUMBER, t);
	bbMemFree(t);

	return textWidth;
}

int bmx_mgta_scintilla_charfrombyte(HWND sci, int pos, int startPos) {
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
	
	int len = scintilla_send_message(sci, SCI_GETTEXTRANGE, 0, &range);

	for (i = 0; i < length; i++) {
		char c = range.lpstrText[i];
		if ((c & 0xc0) != 0x80) {
				characterOffset++;
		}
	}
	free(range.lpstrText);

	return characterOffset;
}

/* startBytePos is a known byte offset for startCharPos */
int bmx_mgta_scintilla_bytefromchar(HWND sci, int charLength, int startBytePos, int startCharPos) {
	int i;
	int characterOffset = startBytePos;

	int characters = charLength;
	if (!characters) {
		return startBytePos;
	}

	int endBytePos = scintilla_send_message(sci, SCI_GETLENGTH, 0, 0);

	if (characters == -1) {
		return endBytePos;
	}

	int length = endBytePos - startBytePos + 1;

	struct Sci_TextRange range;
	range.chrg.cpMin = startBytePos;
	range.chrg.cpMax = endBytePos;
	
	range.lpstrText = malloc(length);
	
	int len = scintilla_send_message(sci, SCI_GETTEXTRANGE, 0, &range);

	for (i = 0; i < len; i++) {
		char c = range.lpstrText[i];
		if ((c & 0xc0) != 0x80) {
				if (! --characters) {
					break;
				}
		}
	}
	free(range.lpstrText);

	return startBytePos + i + 1;
}

int bmx_mgta_scintilla_positionfromline(HWND sci, int line, int valueInBytes) {
	int bytePos = scintilla_send_message(sci, SCI_POSITIONFROMLINE, line, 0);
	return (valueInBytes) ? bytePos : bmx_mgta_scintilla_charfrombyte(sci, bytePos, 0);
}

void bmx_mgta_scintilla_setselectionstart(HWND sci, int pos) {
	scintilla_send_message(sci, SCI_SETSELECTIONSTART, pos, 0);
}

void bmx_mgta_scintilla_setselectionend(HWND sci, int pos) {
	scintilla_send_message(sci, SCI_SETSELECTIONEND, pos, 0);
}

void bmx_mgta_scintilla_scrollcaret(HWND sci) {
	scintilla_send_message(sci, SCI_SCROLLCARET, 0, 0);
}

void bmx_mgta_scintilla_setsel(HWND sci, int startPos, int endPos) {
	scintilla_send_message(sci, SCI_SETSEL, startPos, endPos);
}

void bmx_mgta_scintilla_replacesel(HWND sci, const char * text) {
	scintilla_send_message(sci, SCI_REPLACESEL, 0, text);
}

void bmx_mgta_scintilla_stylesetback(HWND sci, int col) {
	int style;
	
	for (style = 0; style < 33; style++) {
		scintilla_send_message(sci, SCI_STYLESETBACK, style, col);
	}
}

void bmx_mgta_scintilla_stylesetfore(HWND sci, int style, int color) {
	scintilla_send_message(sci, SCI_STYLESETFORE, style, color);
}

void bmx_mgta_scintilla_stylesetitalic(HWND sci, int style, int value) {
	scintilla_send_message(sci, SCI_STYLESETITALIC, style, value);
}

void bmx_mgta_scintilla_stylesetbold(HWND sci, int style, int value) {
	scintilla_send_message(sci, SCI_STYLESETBOLD, style, value);
}

void bmx_mgta_scintilla_stylesetunderline(HWND sci, int style, int value) {
	scintilla_send_message(sci, SCI_STYLESETUNDERLINE, style, value);
}

void bmx_mgta_scintilla_startstyling(HWND sci, int startPos) {
	scintilla_send_message(sci, SCI_STARTSTYLING, startPos, 0x1f);
}

void bmx_mgta_scintilla_setstyling(HWND sci, int realLength, int style) {
	if (realLength == -1) {
		realLength = scintilla_send_message(sci, SCI_GETLENGTH, 0, 0);
	}
	scintilla_send_message(sci, SCI_SETSTYLING, realLength, style);
}

BBString * bmx_mgta_scintilla_gettextrange(HWND sci, int startPos, int endPos) {
	if (endPos == -1) {
		endPos = scintilla_send_message(sci, SCI_GETLENGTH, 0, 0);
	}

	struct Sci_TextRange range;
	range.chrg.cpMin = startPos;
	range.chrg.cpMax = endPos;
	
	range.lpstrText = malloc(endPos - startPos + 1);
	
	int len = scintilla_send_message(sci, SCI_GETTEXTRANGE, 0, &range);
	
	BBString * s = bbStringFromUTF8String(range.lpstrText);
	free(range.lpstrText);
	return s;
}

int bmx_mgta_scintilla_getlinecount(HWND sci) {
	return scintilla_send_message(sci, SCI_GETLINECOUNT, 0, 0);
}

int bmx_mgta_scintilla_getlength(HWND sci) {
	return scintilla_send_message(sci, SCI_GETLENGTH, 0, 0);
}

int bmx_mgta_scintilla_getcurrentpos(HWND sci) {
	int bytePos = scintilla_send_message(sci, SCI_GETSELECTIONSTART, 0, 0);
	return bmx_mgta_scintilla_charfrombyte(sci, bytePos, 0);
}

int bmx_mgta_scintilla_getcurrentline(HWND sci) {
	return scintilla_send_message(sci, SCI_LINEFROMPOSITION, scintilla_send_message(sci, SCI_GETSELECTIONSTART, 0, 0), 0);
}

void bmx_mgta_scintilla_settabwidth(HWND sci, int tabs) {
	scintilla_send_message(sci, SCI_SETTABWIDTH, tabs, 0);
}

void bmx_mgta_scintilla_settargetstart(HWND sci, int pos) {
	scintilla_send_message(sci, SCI_SETTARGETSTART, pos, 0);
}

void bmx_mgta_scintilla_settargetend(HWND sci, int pos) {
	scintilla_send_message(sci, SCI_SETTARGETEND, pos, 0);
}

void bmx_mgta_scintilla_replacetarget(HWND sci, const char * text) {
	scintilla_send_message(sci, SCI_REPLACETARGET, -1, text);
}

void bmx_mgta_scintilla_cut(HWND sci) {
	scintilla_send_message(sci, SCI_CUT, 0, 0);
}

void bmx_mgta_scintilla_copy(HWND sci) {
	scintilla_send_message(sci, SCI_COPY, 0, 0);
}

void bmx_mgta_scintilla_paste(HWND sci) {
	scintilla_send_message(sci, SCI_PASTE, 0, 0);
}

int bmx_mgta_scintilla_linefromposition(HWND sci, int pos) {
	return scintilla_send_message(sci, SCI_LINEFROMPOSITION, pos, 0);
}

void bmx_mgta_scintilla_appendtext(HWND sci, BBString * text) {
	char * s = bbStringToUTF8String(text);
	scintilla_send_message(sci, SCI_APPENDTEXT, strlen(s), s);
	bbMemFree(s);
}

void bmx_mgta_scintilla_scrolltoend(HWND sci) {
	scintilla_send_message(sci, SCI_GOTOPOS, scintilla_send_message(sci, SCI_GETLENGTH, 0, 0), 0);
}

int bmx_mgta_scintilla_getselectionlength(HWND sci, int units) {
	if (units == 2) {
		/* lines */
		int startPos = scintilla_send_message(sci, SCI_LINEFROMPOSITION, scintilla_send_message(sci, SCI_GETSELECTIONSTART, 0, 0), 0);
		int endPos = scintilla_send_message(sci, SCI_LINEFROMPOSITION, scintilla_send_message(sci, SCI_GETSELECTIONEND, 0, 0), 0);
		return endPos - startPos;
	} else {
		/* chars */
		int startPos = bmx_mgta_scintilla_charfrombyte(sci, scintilla_send_message(sci, SCI_GETSELECTIONSTART, 0, 0), 0);
		int length = bmx_mgta_scintilla_charfrombyte(sci, scintilla_send_message(sci, SCI_GETSELECTIONEND, 0, 0), startPos);
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

void bmx_mgta_scintilla_setmarginleft(HWND sci, int leftmargin) {
	scintilla_send_message(sci, SCI_SETMARGINLEFT, 0, leftmargin);
}

void bmx_mgta_scintilla_setcaretwidth(HWND sci, int width) {
	scintilla_send_message(sci, SCI_SETCARETWIDTH, width, 0);
}

void bmx_mgta_scintilla_setcaretcolor(HWND sci, int r, int g, int b) {
	scintilla_send_message(sci, SCI_SETCARETFORE, r | (g << 8) | (b << 16), 0);
}

void bmx_mgta_scintilla_enableundoredo(HWND sci, int enable) {
	scintilla_send_message(sci, SCI_SETUNDOCOLLECTION, enable, 0);
}

int bmx_mgta_scintilla_undoredoenabled(HWND sci) {
	return scintilla_send_message(sci, SCI_GETUNDOCOLLECTION, 0, 0);
}

void bmx_mgta_scintilla_undo(HWND sci) {
	scintilla_send_message(sci, SCI_UNDO, 0, 0);
}

void bmx_mgta_scintilla_redo(HWND sci) {
	scintilla_send_message(sci, SCI_REDO, 0, 0);
}

int bmx_mgta_scintilla_canundo(HWND sci) {
	return scintilla_send_message(sci, SCI_CANUNDO, 0, 0);
}

int bmx_mgta_scintilla_canredo(HWND sci) {
	return scintilla_send_message(sci, SCI_CANREDO, 0, 0);
}

void bmx_mgta_scintilla_clearundoredo(HWND sci) {
	scintilla_send_message(sci, SCI_EMPTYUNDOBUFFER, 0, 0);
}
