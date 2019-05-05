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
Strict

?linux
Import "-lgmodule-2.0"
?macos
?win32
Import "-lImm32"
?

Import "source.bmx"

Extern
?linux
	Function g_signal_cbsci:Int(gtkwidget:Byte Ptr, name:Byte Ptr, callback(widget:Byte Ptr, id:Int,notification:Byte Ptr,gadget:Object),gadget:Object,destroyhandler(data:Byte Ptr,user: Byte Ptr),flag:Int) = "g_signal_connect_data"
	Function scintilla_new:Byte Ptr()

	Function bmx_mgta_scintilla_getsci:Byte Ptr(handle:Byte Ptr, id:Int)
?win32
	Function bmx_mgta_scintilla_getsci:Byte Ptr(parent:Byte Ptr)
?

	Function bmx_mgta_scintilla_gettext:String(handle:Byte Ptr)
	Function bmx_mgta_scintilla_settext(handle:Byte Ptr, Text:String)
	Function bmx_mgta_scintilla_setfont(handle:Byte Ptr, name:String, size:Int)
	Function bmx_mgta_scintilla_positionfromline:Int(handle:Byte Ptr, line:Int, valueInBytes:Int)
	Function bmx_mgta_scintilla_setselectionstart(handle:Byte Ptr, pos:Int)
	Function bmx_mgta_scintilla_setselectionend(handle:Byte Ptr, pos:Int)
	Function bmx_mgta_scintilla_scrollcaret(handle:Byte Ptr)
	Function bmx_mgta_scintilla_setsel(handle:Byte Ptr, startPos:Int, endPos:Int)
	Function bmx_mgta_scintilla_replacesel(handle:Byte Ptr, Text:Byte Ptr)
	Function bmx_mgta_scintilla_stylesetback(handle:Byte Ptr, col:Int)
	Function bmx_mgta_scintilla_stylesetfore(handle:Byte Ptr, style:Int, color:Int)
	Function bmx_mgta_scintilla_stylesetitalic(handle:Byte Ptr, style:Int, value:Int)
	Function bmx_mgta_scintilla_stylesetbold(handle:Byte Ptr, style:Int, value:Int)
	Function bmx_mgta_scintilla_stylesetunderline(handle:Byte Ptr, style:Int, value:Int)
	Function bmx_mgta_scintilla_startstyling(handle:Byte Ptr, startPos:Int)
	Function bmx_mgta_scintilla_setstyling(handle:Byte Ptr, realLength:Int, style:Int)
	Function bmx_mgta_scintilla_gettextrange:String(handle:Byte Ptr, startPos:Int, endPos:Int)
	Function bmx_mgta_scintilla_getlinecount:Int(handle:Byte Ptr)
	Function bmx_mgta_scintilla_getlength:Int(handle:Byte Ptr)
	Function bmx_mgta_scintilla_getcurrentpos:Int(handle:Byte Ptr)
	Function bmx_mgta_scintilla_getcurrentline:Int(handle:Byte Ptr)
	Function bmx_mgta_scintilla_settabwidth(handle:Byte Ptr, tabs:Int)
	Function bmx_mgta_scintilla_settargetstart(handle:Byte Ptr, pos:Int)
	Function bmx_mgta_scintilla_settargetend(handle:Byte Ptr, pos:Int)
	Function bmx_mgta_scintilla_replacetarget(handle:Byte Ptr, Text:Byte Ptr)
	Function bmx_mgta_scintilla_cut(handle:Byte Ptr)
	Function bmx_mgta_scintilla_copy(handle:Byte Ptr)
	Function bmx_mgta_scintilla_paste(handle:Byte Ptr)
	Function bmx_mgta_scintilla_linefromposition:Int(handle:Byte Ptr, index:Int)
	Function bmx_mgta_scintilla_appendtext(handle:Byte Ptr, Text:String)
	Function bmx_mgta_scintilla_scrolltoend(handle:Byte Ptr)
	Function bmx_mgta_scintilla_getselectionlength:Int(handle:Byte Ptr, units:Int)
	Function bmx_mgta_scintilla_addtext(handle:Byte Ptr, Text:Byte Ptr)
	Function bmx_mgta_scintilla_textwidth:Int(handle:Byte Ptr, Text:String)
	Function bmx_mgta_scintilla_setlinedigits(handle:Byte Ptr, lineDigits:Int Ptr, show:Int)
	Function bmx_mgta_scintilla_setmarginleft(handle:Byte Ptr, leftmargin:Int)
	Function bmx_mgta_scintilla_setcaretwidth(handle:Byte Ptr, width:Int)
	Function bmx_mgta_scintilla_setcaretcolor(handle:Byte Ptr, r:Int, g:Int, b:Int)
	Function bmx_mgta_scintilla_startendfromchar(handle:Byte Ptr, pos:Int, length:Int, startPos:Int Var, endPos:Int Var)
	Function bmx_mgta_scintilla_setcaretlinevisible(handle:Byte Ptr, enable:int)
	Function bmx_mgta_scintilla_getcaretlinevisible:Int(handle:Byte Ptr)
	Function bmx_mgta_scintilla_setcaretlineback:Int(handle:Byte Ptr, r:Int, g:Int, b:Int)
	Function bmx_mgta_scintilla_getcaretlineback:Int(handle:Byte Ptr)

	Function bmx_mgta_scintilla_notifcation_update(obj:Object, handle:Byte Ptr)
	
	Function bmx_mgta_scintilla_enableundoredo(handle:Byte Ptr, enable:Int)
	Function bmx_mgta_scintilla_undoredoenabled:Int(handle:Byte Ptr)
	Function bmx_mgta_scintilla_undo(handle:Byte Ptr)
	Function bmx_mgta_scintilla_redo(handle:Byte Ptr)
	Function bmx_mgta_scintilla_canundo:Int(handle:Byte Ptr)
	Function bmx_mgta_scintilla_canredo:Int(handle:Byte Ptr)
	Function bmx_mgta_scintilla_clearundoredo(handle:Byte Ptr)

	Function bmx_mgta_scintilla_sethighlightlanguage(handle:Byte Ptr, lang:String)
	Function bmx_mgta_scintilla_sethighlightkeywords(handle:Byte Ptr, index:Int, keywords:String)
	Function bmx_mgta_scintilla_sethighlightstyle(handle:Byte Ptr, style:Int, flags:Int, color:Int)
	Function bmx_mgta_scintilla_highlight(handle:Byte Ptr)
	Function bmx_mgta_scintilla_clearhighlightstyles(handle:Byte Ptr, back:Int, fore:Int)

	Function bmx_mgta_scintilla_setlinenumberbackcolor(handle:Byte Ptr, color:Int)
	Function bmx_mgta_scintilla_setlinenumberforecolor(handle:Byte Ptr, color:Int)
End Extern

Type TSCNotification
	Field code:Int
	Field modificationType:Int
	Field updated:Int
	
	Function _update(n:TSCNotification, code:Int, modificationType:Int, updated:Int) { nomangle }
		n.code = code
		n.modificationType = modificationType
		n.updated = updated
	End Function
End Type


Const SCN_STYLENEEDED:Int = 2000
Const SCN_CHARADDED:Int = 2001
Const SCN_SAVEPOINTREACHED:Int = 2002
Const SCN_SAVEPOINTLEFT:Int = 2003
Const SCN_MODIFYATTEMPTRO:Int = 2004
Const SCN_KEY:Int = 2005
Const SCN_DOUBLECLICK:Int = 2006
Const SCN_UPDATEUI:Int = 2007
Const SCN_MODIFIED:Int = 2008
Const SCN_MACRORECORD:Int = 2009
Const SCN_MARGINCLICK:Int = 2010
Const SCN_NEEDSHOWN:Int = 2011
Const SCN_PAINTED:Int = 2013
Const SCN_USERLISTSELECTION:Int = 2014
Const SCN_URIDROPPED:Int = 2015
Const SCN_DWELLSTART:Int = 2016
Const SCN_DWELLEND:Int = 2017
Const SCN_ZOOM:Int = 2018
Const SCN_HOTSPOTCLICK:Int = 2019
Const SCN_HOTSPOTDOUBLECLICK:Int = 2020
Const SCN_CALLTIPCLICK:Int = 2021
Const SCN_AUTOCSELECTION:Int = 2022
Const SCN_INDICATORCLICK:Int = 2023
Const SCN_INDICATORRELEASE:Int = 2024
Const SCN_AUTOCCANCELLED:Int = 2025
Const SCN_AUTOCCHARDELETED:Int = 2026
Const SCN_HOTSPOTRELEASECLICK:Int = 2027
Const SCN_FOCUSIN:Int = 2028
Const SCN_FOCUSOUT:Int = 2029

Const SC_MOD_INSERTTEXT:Int = $1
Const SC_MOD_DELETETEXT:Int = $2
Const SC_MOD_CHANGESTYLE:Int = $4
Const SC_MOD_CHANGEFOLD:Int = $8
Const SC_PERFORMED_USER:Int = $10
Const SC_PERFORMED_UNDO:Int = $20
Const SC_PERFORMED_REDO:Int = $40
Const SC_MULTISTEPUNDOREDO:Int = $80
Const SC_LASTSTEPINUNDOREDO:Int = $100
Const SC_MOD_CHANGEMARKER:Int = $200
Const SC_MOD_BEFOREINSERT:Int = $400
Const SC_MOD_BEFOREDELETE:Int = $800
Const SC_MULTILINEUNDOREDO:Int = $1000
Const SC_STARTACTION:Int = $2000
Const SC_MOD_CHANGEINDICATOR:Int = $4000
Const SC_MOD_CHANGELINESTATE:Int = $8000
Const SC_MOD_CHANGEMARGIN:Int = $10000
Const SC_MOD_CHANGEANNOTATION:Int = $20000
Const SC_MOD_CONTAINER:Int = $40000
Const SC_MOD_LEXERSTATE:Int = $80000
Const SC_MODEVENTMASKALL:Int = $FFFFF
Const SC_UPDATE_CONTENT:Int = $1
Const SC_UPDATE_SELECTION:Int = $2
Const SC_UPDATE_V_SCROLL:Int = $4
Const SC_UPDATE_H_SCROLL:Int = $8
