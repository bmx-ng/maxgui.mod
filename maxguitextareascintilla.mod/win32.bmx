' Copyright (c) 2014-2019 Bruce A Henderson
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

Import MaxGUI.Win32MaxGUIEx

Import "common.bmx"

Rem
bbdoc: 
End Rem
Type TWindowsScintillaTextArea Extends TWindowsTextArea

	'Field _hwnd:Byte Ptr
	'Field sciId:Int
	
	Field styleMap:TMap = New TMap
	Field styles:Int[] = New Int[31]
	Field styleIndex:Int = 0
	
	Field lastStyleValue:Int = -1
	Field lastStyle:Int

	Global sci_id_count:Int = 0
	
	Field ignoreChange:Int
	Field tabPixelWidth:Int
	
	Field lineDigits:Int
	
	Field showLineNumbers:Int = True
	
	' holder for the latest notification
	' keep one in the type rather than locally in the callback function so we don't have to create a new object for every notification
	Field notification:TSCNotification = New TSCNotification

	Method Create:TWindowsGadget(group:TGadget, style:Int, txt:String)

		Local parent:Byte Ptr=group.query(QUERY_HWND_CLIENT)

		Local hwnd:Byte Ptr = bmx_mgta_scintilla_getsci(parent)
		
		Register GADGET_TEXTAREA,hwnd

		SetShape(0, 0, ClientWidth(group), ClientHeight(group))
		SetShow(True)
		Sensitize()
		
		Return Self
	End Method

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
			Local event:TEvent
		Select msg
			'Case WM_MOUSEWHEEL
			'	If (Long(wp)&MK_CONTROL) Then SendMessageW _hwnd, EM_SETZOOM, 0, 0
			Case WM_KEYDOWN
				If eventfilter<>Null
					event=CreateEvent(EVENT_KEYDOWN,Self,Int(wp),keymods())
					If Not eventfilter(event,context) Return True
				EndIf
				
			Case WM_KILLFOCUS
				PostGuiEvent EVENT_GADGETLOSTFOCUS

			Case WM_CHAR
				Local mods:Int = keymods()
				If (mods & MODIFIER_CONTROL And Not (mods & MODIFIER_OPTION)) Then
					Return 1
				End If
				If eventfilter<>Null
					event=CreateEvent(EVENT_KEYCHAR,Self,Int(wp),mods)
					If Not eventfilter(event,context) Return True
				EndIf

		End Select
		
		Return Super.WndProc(hwnd,msg,wp,lp)
		
	EndMethod

	Method OnNotify(wp:WParam,lp:LParam)
		Local nmhdrPtr:Byte Ptr
		Local event:TEvent
		
		Super.OnNotify(wp,lp)	'Tooltip
		
		bmx_mgta_scintilla_notifcation_update(notification, Byte Ptr(lp))

		Select notification.code
			Case SCN_UPDATEUI
				If notification.updated & SC_UPDATE_SELECTION Then
					PostGuiEvent(EVENT_GADGETSELECT, Self)
				End If
			Case SCN_MODIFIED
				If notification.modificationType & (SC_MOD_INSERTTEXT | SC_MOD_DELETETEXT) Then
					If Not ignoreChange Then
						PostGuiEvent(EVENT_GADGETSELECT, Self)
						PostGuiEvent(EVENT_GADGETACTION, Self)
					End If
					ignoreChange = False
					
					bmx_mgta_scintilla_setlinedigits(_hwnd, Varptr lineDigits, showLineNumbers)
				End If
		End Select

	End Method

	Method GetText:String()
		Return bmx_mgta_scintilla_gettext(_hwnd)
	End Method

	Rem
	bbdoc: Sets the text.
	End Rem
	Method SetText(txt:String)
		bmx_mgta_scintilla_settext(_hwnd, txt)
	End Method

	Method SetFont(font:TGuiFont)
		If font = Null Then
			Return
		End If

		_font = TWindowsFont(font)

		bmx_mgta_scintilla_setfont(_hwnd, font.name, font.size)
		
		' set the margin size for line numbers
		bmx_mgta_scintilla_setlinedigits(_hwnd, Varptr lineDigits, showLineNumbers)
		
		SetTabs()
	End Method

	Rem
	bbdoc: Set the text area selection
	End Rem
	Method SetSelection(pos:Int, length:Int, units:Int)
		'ignoreChange = True
		Local startPos:Int
		Local endPos:Int

		If length = 0 Then
			If units = TEXTAREA_LINES Then
				startPos = bmx_mgta_scintilla_positionfromline(_hwnd, pos, True)
				endPos = startPos
			Else
				bmx_mgta_scintilla_startendfromchar(_hwnd, pos, length, startPos, endPos)
			End If
		Else
			If units = TEXTAREA_LINES Then
				startPos = bmx_mgta_scintilla_positionfromline(_hwnd, pos, True)
				endPos = bmx_mgta_scintilla_positionfromline(_hwnd, pos + length, True)
			Else ' must be TEXTAREA_CHARS
				bmx_mgta_scintilla_startendfromchar(_hwnd, pos, length, startPos, endPos)
			End If
		End If

		bmx_mgta_scintilla_setsel(_hwnd, startPos, endPos)


		PostGuiEvent(EVENT_GADGETSELECT, Self)

		' scroll to the start of the selection
		'bmx_mgta_scintilla_scrollcaret(_hwnd)

	End Method

	Method GetSelectionLength:Int(units:Int)
		Return bmx_mgta_scintilla_getselectionlength(_hwnd, units)
	End Method

	Method SetMargins(leftmargin:Int)
		bmx_mgta_scintilla_setmarginleft(_hwnd, leftmargin)
	End Method

	Method CharX:Int(char:Int)
		' TODO
	EndMethod

	Method CharY:Int(char:Int)
		' TODO
	EndMethod

	Method AddText(Text:String)
		ignoreChange = True

		bmx_mgta_scintilla_appendtext(_hwnd, Text)
		bmx_mgta_scintilla_scrolltoend(_hwnd)
	End Method

	Method ReplaceText(pos:Int, length:Int, Text:String, units:Int)
		ignoreChange = True
		If length = TEXTAREA_ALL Then
			SetText(Text)
		Else
			Local startPos:Int
			Local endPos:Int
	
			If units = TEXTAREA_LINES Then
				startPos = bmx_mgta_scintilla_positionfromline(_hwnd, pos, True)
				endPos = bmx_mgta_scintilla_positionfromline(_hwnd, pos + length, True)
			Else ' must be TEXTAREA_CHARS
				bmx_mgta_scintilla_startendfromchar(_hwnd, pos, length, startPos, endPos)
			End If

			bmx_mgta_scintilla_settargetstart(_hwnd, startPos)
			bmx_mgta_scintilla_settargetend(_hwnd, endPos)
	
			' insert new text
			Local textPtr:Byte Ptr = Text.ToUTF8String()
			bmx_mgta_scintilla_replacetarget(_hwnd, textPtr)
			MemFree(textPtr)
		End If
	End Method

	Method SetColor(r:Int, g:Int, b:Int)
		bmx_mgta_scintilla_stylesetback(_hwnd, r | g Shl 8 | b Shl 16)
	End Method

	Method SetTextColor(r:Int, g:Int, b:Int)
		' set style 0 color (should be main text style)
		bmx_mgta_scintilla_stylesetfore(_hwnd, 0, r | g Shl 8 | b Shl 16)
	End Method

	Method SetStyle(r:Int, g:Int, b:Int, flags:Int, pos:Int, length:Int, units:Int)
		' Build a style string
		Local s:Int = r Shl 24 | g Shl 16 | b Shl 8 | (flags & $ff)
		Local style:Int = lastStyle

		If s <> lastStyleValue Then
		
			Local styleText:String = String(s)
	
			Local st:String = String(styleMap.ValueForKey(styleText))
			If Not st Then

				' is there already an entry for this one?
				If styles[styleIndex] Then
					' remove it from the map
					styleMap.Remove(String(styles[styleIndex]))
				End If
				
				styles[styleIndex] = s
				
				styleMap.Insert(styleText, Chr(styleIndex + 65))
				style = styleIndex
				
				styleIndex :+ 1
				If styleIndex > 31 Then
					styleIndex = 0
				End If

				' create the styling
				bmx_mgta_scintilla_stylesetfore(_hwnd, style, r | g Shl 8 | b Shl 16)
	
				If flags & TEXTFORMAT_ITALIC Then
					bmx_mgta_scintilla_stylesetitalic(_hwnd, style, True)
				Else
					bmx_mgta_scintilla_stylesetitalic(_hwnd, style, False)
				End If
	
				If flags & TEXTFORMAT_BOLD Then
					bmx_mgta_scintilla_stylesetbold(_hwnd, style, True)
				Else
					bmx_mgta_scintilla_stylesetbold(_hwnd, style, False)
				End If
	
				If flags & TEXTFORMAT_UNDERLINE Then
					bmx_mgta_scintilla_stylesetunderline(_hwnd, style, True)
				Else
					bmx_mgta_scintilla_stylesetunderline(_hwnd, style, False)
				End If
				
			Else
				style = Asc(st) - 65
			End If
			
			lastStyle = style
			lastStyleValue = s

		End If
		
		applyStyle(pos, length, units, style)
		
	End Method
	
	Method applyStyle(pos:Int, length:Int, units:Int, style:Int)
		Local startPos:Int
		Local realLength:Int

		If units = TEXTAREA_LINES Then
			startPos = bmx_mgta_scintilla_positionfromline(_hwnd, pos, True)
			realLength = bmx_mgta_scintilla_positionfromline(_hwnd, pos + length, True) - startPos
		Else ' must be TEXTAREA_CHARS
			Local endPos:Int
			bmx_mgta_scintilla_startendfromchar(_hwnd, pos, length, startPos, endPos)
			realLength = endPos - startPos
		End If

		bmx_mgta_scintilla_startstyling(_hwnd, startPos)
		bmx_mgta_scintilla_setstyling(_hwnd, realLength, style)

	End Method

	Method AreaText:String(pos:Int, length:Int, units:Int)
		Local startPos:Int
		Local endPos:Int

		If units = TEXTAREA_LINES Then
			startPos = bmx_mgta_scintilla_positionfromline(_hwnd, pos, True)
			endPos = bmx_mgta_scintilla_positionfromline(_hwnd, pos + length, True)
		Else ' must be TEXTAREA_CHARS
			bmx_mgta_scintilla_startendfromchar(_hwnd, pos, length, startPos, endPos)
		End If
		
		Return bmx_mgta_scintilla_gettextrange(_hwnd, startPos, endPos)
	End Method

	Method AreaLen:Int(units:Int)
		If units = TEXTAREA_LINES Then
			Return bmx_mgta_scintilla_getlinecount(_hwnd)
		Else
			Return bmx_mgta_scintilla_getlength(_hwnd)
		End If
	End Method

	Method GetCursorPos:Int(units:Int)
		If units = TEXTAREA_LINES Then
			Return bmx_mgta_scintilla_getcurrentline(_hwnd)
		Else
			Return bmx_mgta_scintilla_getcurrentpos(_hwnd)
		End If
	End Method

	Method SetTabs(tabWidth:Int = -1)
		If tabWidth >= 0 Then
			tabPixelWidth = tabWidth
		Else
			tabWidth = tabPixelWidth
		End If

		' convert from pixels to characters
		If _font Then
			tabWidth = tabWidth / _font.CharWidth(32)
		Else
			tabWidth = 4
		End If

		bmx_mgta_scintilla_settabwidth(_hwnd, tabWidth)

	End Method

	Method Activate(cmd:Int)
		Super.Activate(cmd)

		Select cmd
			Case ACTIVATE_CUT
				bmx_mgta_scintilla_cut(_hwnd)

			Case ACTIVATE_COPY
				bmx_mgta_scintilla_copy(_hwnd)

			Case ACTIVATE_PASTE
				bmx_mgta_scintilla_paste(_hwnd)

		End Select
	End Method

	Method CharAt:Int(line:Int)
		Return bmx_mgta_scintilla_positionfromline(_hwnd, line, False)
	End Method

	Method LineAt:Int(index:Int)
		Return bmx_mgta_scintilla_linefromposition(_hwnd, index)
	End Method

	Method SetCaretWidth(width:Int)
		bmx_mgta_scintilla_setcaretwidth(_hwnd, width)
	End Method
	
	Method SetCaretColor(r:Int, g:Int, b:Int)
		bmx_mgta_scintilla_setcaretcolor(_hwnd, r, g, b)
	End Method

	Method Class()
		Return GADGET_TEXTAREA
	EndMethod

	Method HasUndoRedo:Int()
		Return True
	End Method

	Method EnableUndoRedo(enable:Int)
		bmx_mgta_scintilla_enableundoredo(_hwnd, enable)
	End Method

	Method UndoRedoEnabled:Int()
		Return bmx_mgta_scintilla_undoredoenabled(_hwnd)
	End Method

	Method Undo()
		bmx_mgta_scintilla_undo(_hwnd)
	End Method

	Method Redo()
		bmx_mgta_scintilla_redo(_hwnd)
	End Method

	Method CanUndo:Int()
		Return bmx_mgta_scintilla_canundo(_hwnd)
	End Method

	Method CanRedo:Int()
		Return bmx_mgta_scintilla_canredo(_hwnd)
	End Method

	Method ClearUndoRedo()
		bmx_mgta_scintilla_clearundoredo(_hwnd)
	End Method

	Method HasHighlighting:Int()
		Return True
	End Method

	Method SetHighlightLanguage(lang:String)
		bmx_mgta_scintilla_sethighlightlanguage(_hwnd, lang)
	End Method

	Method SetHighlightKeywords(index:Int, keywords:String)
		bmx_mgta_scintilla_sethighlightkeywords(_hwnd, index, keywords)
	End Method

	Method SetHighlightStyle(index:Int, flags:Int, red:Int, green:Int, blue:Int)
		bmx_mgta_scintilla_sethighlightstyle(_hwnd, index, flags, red | green Shl 8 | blue Shl 16)
	End Method

	Method HighLight()
		bmx_mgta_scintilla_highlight(_hwnd)
	End Method

	Method ClearHighlightStyles(br:Int, bg:Int, bb:Int, fr:Int, fg:Int, fb:Int)
		bmx_mgta_scintilla_clearhighlightstyles(_hwnd, br | bg Shl 8 | bb Shl 16, fr | fg Shl 8 | fb Shl 16)
	End Method

	Method HasLineNumbers:Int()
		Return True
	End Method

	Method SetLineNumberBackColor(r:Int, g:Int, b:Int)
		bmx_mgta_scintilla_setlinenumberbackcolor(_hwnd, r | g Shl 8 | b Shl 16)
	End Method

	Method SetLineNumberForeColor(r:Int, g:Int, b:Int)
		bmx_mgta_scintilla_setlinenumberforecolor(_hwnd, r | g Shl 8 | b Shl 16)
	End Method

	Method SetLineNumberEnable(enabled:Int)
		showLineNumbers = enabled
		bmx_mgta_scintilla_setlinedigits(_hwnd, Varptr lineDigits, showLineNumbers)
	End Method
	
	Method SetCaretLineVisible(enabled:Int)
		bmx_mgta_scintilla_setcaretlinevisible(_hwnd, enabled)
	End Method

	Method GetCaretLineVisible:Int()
		Return bmx_mgta_scintilla_getcaretlinevisible(_hwnd)
	End Method

	Method SetCaretLineBackgroundColor(r:Int, g:Int, b:Int, a:Int)
		bmx_mgta_scintilla_setcaretlineback(_hwnd, r, g, b, a)
	End Method

	Method GetCaretLineBackgroundColor:Int()
		Return bmx_mgta_scintilla_getcaretlineback(_hwnd)
	End Method
	
	Method HasCharEventSupressionFixup:Int()
		Return True
	End Method

	Method HasBlockIndent:Int()
		Return True
	End Method

	Method BeginUndoAction()
		bmx_mgta_scintilla_beginundoaction(_hwnd)
	End Method
	
	Method EndUndoAction()
		bmx_mgta_scintilla_endundoaction(_hwnd)
	End Method

	Method HasBracketMatching:Int()
		Return True
	End Method
	
	Method SetBracketMatchingColor(r:Int, g:Int, b:Int, flags:Int)
		bmx_mgta_scintilla_setbracketmatchingcolor(_hwnd, r, g, b, flags)
	End Method
	
	Method MatchBrackets()
		bmx_mgta_scintilla_matchbrackets(_hwnd)
	End Method

End Type


' scintilla text area driver
Type TWindowsScintillaTextAreaDriver Extends TWindowsTextAreaDriver
	Function CreateTextArea:TWindowsGadget(group:TGadget, style:Int, Text:String)
		Return New TWindowsScintillaTextArea.Create(group, style, Text)
	End Function
End Type

windowsmaxguiex_textarea = New TWindowsScintillaTextAreaDriver

Private 
Function KeyMods()
	Local mods
	If GetKeyState(VK_SHIFT)&$8000 mods:|MODIFIER_SHIFT
	If GetKeyState(VK_CONTROL)&$8000 mods:|MODIFIER_CONTROL
	If GetKeyState(VK_MENU)&$8000 mods:|MODIFIER_OPTION
	If GetKeyState(VK_LWIN)&$8000 Or GetKeyState(VK_RWIN)&$8000 mods:|MODIFIER_SYSTEM
	Return mods
EndFunction
