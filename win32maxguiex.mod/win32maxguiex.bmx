Strict

Rem
bbdoc: MaxGUI Drivers/Win32MaxGUIEx
End Rem
Module MaxGUI.Win32MaxGUIEx

ModuleInfo "Version: 0.80"
ModuleInfo "Author: Simon Armstrong, Seb Hollington, Bruce A Henderson"
ModuleInfo "License: zlib/libpng"

ModuleInfo "History: 0.80"
ModuleInfo "History: Rebuilt to support Windows 64-bit."

?Win32

ModuleInfo "CC_OPTS: -include ~qwindows.h~q -include ~qcommctrl.h~q"

Import MaxGUI.MaxGUI
Import brl.systemdefault
Import brl.retro
Import "tom.bmx"
Import "common.bmx"


maxgui_driver = New TWindowsGUIDriver

Type TWindowsGUIDriver Extends TMaxGUIDriver

	Global GadgetMap:TPtrMap
	Global GDIDesktop:TWindowsDesktop
	Global GDIFont:TWindowsFont
	Global ClassAtom
	Global ClassAtom2
	Global KBMessageHook:Byte Ptr,MouseMessageHook:Byte Ptr

	Global windowtheme:Short Ptr
	Global _cursor:Byte Ptr, _commoncontrolversion[]
	Global _explorerstyle = False
	Global _activeWindow:TWindowsWindow = Null

	Global _customcolors[] = 	[$FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, ..
						 $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF ]

	Global _hwndTooltips:Byte Ptr

	Global intDontReleaseCapture% = False	'See WM_CAPTURECHANGED

	Method New()

		'Initialize libraries
		OleInitialize(Null)
		Local icc:TINITCOMMONCONTROLSEX = New TINITCOMMONCONTROLSEX
		'icc.dwSize = SizeOf(icc)
		icc.SetdwICC(ICC_WIN95_CLASSES|ICC_USEREX_CLASSES)'|ICC_COOL_CLASSES'|ICC_DATE_CLASSES
		InitCommonControlsEx icc.controlPtr

		'Initialize Global Variables
		GDIFont=TWindowsFont.DefaultFont()
		GadgetMap=New TPtrMap
		GDIDesktop=New TWindowsDesktop

		'Set-up Message Hooks
		KBMessageHook=SetWindowsHookExW(WH_KEYBOARD,KeyboardProc,GetModuleHandleW(Null),GetCurrentThreadId())
		MouseMessageHook=SetWindowsHookExW(WH_MOUSE,MouseProc,GetModuleHandleW(Null),GetCurrentThreadId())

		'Gadget Tooltips
		_hwndTooltips = CreateWindowExW( 0,"tooltips_class32","",WS_POPUP|TTS_ALWAYSTIP,0,0,0,0,GDIDesktop._hwnd,Null,GetModuleHandleW(Null),Null )
		SendMessageW( _hwndTooltips, TTM_SETMAXTIPWIDTH, 0, 300)
		SetWindowPos( _hwndTooltips, Byte Ptr(HWND_TOPMOST), 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE )

	EndMethod

	Method Delete()
		DestroyWindow( _hwndTooltips );_hwndTooltips = 0
		UnhookWindowsHookEx MouseMessageHook
		UnhookWindowsHookEx KBMessageHook
	EndMethod

	Method UserName$()
		Return getenv_("username")
	End Method

	Method ComputerName$()
		Return getenv_("userdomain")
	End Method

	Method CreateGadget:TGadget(class,Text$,x,y,w,h,group:TGadget,style)

		Select class
			Case GADGET_WINDOW
				If Not group group=GDIDesktop
		End Select

		Local gadget:TGadget = GadgetInstanceFromClass(class,group,style,Text)

		Select class
			Case GADGET_DESKTOP, GADGET_MENUITEM, GADGET_NODE
				Return gadget
		End Select

		If LocalizationMode() & LOCALIZATION_OVERRIDE Then
			LocalizeGadget(gadget,Text,"")
		Else
			gadget.SetText(Text)
		EndIf

		If group Then gadget._SetParent group
		If class <> GADGET_TOOLBAR Then gadget.SetShape(x,y,w,h)

		'v0.51: Gadgets are now only shown when they have been sized, and the text set.
		If TWindowsGadget(gadget) Then
			If Not TWindowsWindow(gadget)
				gadget.SetFont(GDIFont)
				If TWindowsGadget(group) Then
					TWindowsGadget(gadget)._forceDisable = Not( TWindowsGadget(group)._enabled And Not TWindowsGadget(group)._forceDisable )
					gadget.SetEnabled(Not (gadget.State()&STATE_DISABLED))
				EndIf
				gadget.SetShow(True)
			ElseIf Not (style & WINDOW_HIDDEN) Then
				gadget.SetShow(True)
			EndIf
		EndIf

		If TWindowsGadget(gadget) Then TWindowsGadget(gadget).Sensitize()

		Return gadget
	EndMethod

	Method GadgetInstanceFromClass:TGadget(class, group:TGadget, style = 0, Text$ = "")

		Local gadget:TGadget

		Select class
			Case GADGET_DESKTOP
				gadget=GDIDesktop
			Case GADGET_MENUITEM
				gadget=New TWindowsMenu.Create(group,style,Text)
			Case GADGET_WINDOW
				gadget=New TWindowsWindow.Create(group,style)
			Case GADGET_BUTTON
				gadget=New TWindowsButton.Create(group,style)
			Case GADGET_TEXTFIELD
				gadget=New TWindowsTextField.Create(group,style,Text)
			Case GADGET_TEXTAREA
				' no custom text area? use the default
				If Not windowsmaxguiex_textarea Then
					windowsmaxguiex_textarea = New TWindowsDefaultTextAreaDriver
				End If
				gadget = windowsmaxguiex_textarea.CreateTextArea(group,style,Text)
			Case GADGET_COMBOBOX
				gadget=New TWindowsComboBox.Create(group,style,Text)
			Case GADGET_LISTBOX
				gadget=New TWindowsListBox.Create(group,style)
			Case GADGET_TOOLBAR
				gadget=New TWindowsToolBar.Create(group,style,Text)
			Case GADGET_TABBER
				gadget=New TWindowsTabber.Create(group,style)
			Case GADGET_NODE
				gadget=New TWindowsTreeNode.Create(group,style,Text)
			Case GADGET_TREEVIEW
				gadget=New TWindowsTreeView.Create(group,style)
			Case GADGET_LABEL
				gadget=New TWindowsLabel.Create(group,style)
			Case GADGET_SLIDER
				gadget=New TWindowsSlider.Create(group,style)
			Case GADGET_PROGBAR
				gadget=New TWindowsProgressBar.Create(group,style)
			Case GADGET_PANEL
				gadget=New TWindowsPanel.Create(group,style)
			Case GADGET_CANVAS
				gadget=New TWindowsPanel.Create(group,style|PANEL_CANVAS|PANEL_ACTIVE)
			Case GADGET_HTMLVIEW
				gadget=New TWindowsHTMLView.Create(group,style)
		End Select

		Return gadget

	EndMethod

	Method ActiveGadget:TGadget()
		Local tmpHwnd:Byte Ptr = GetFocus(), tmpGadget:TGadget
		While tmpHwnd
		 	tmpGadget = GadgetFromHwnd( tmpHwnd )
			If tmpGadget Then Exit
			tmpHwnd = GetParent_(tmpHwnd)
		Wend
		Return tmpGadget
	EndMethod

	Method RequestColor(red,green,blue)
		Local cc:TChooseColor = New TChooseColor.Create(GetActiveHwnd(), (red)|(green Shl 8)|(blue Shl 16), _customcolors)
		Local hwnd:Byte Ptr = GetFocus()
		Local n:Int = cc.ChooseColor()
		SetFocus(hwnd)
		If Not n Return 0
		Local rgbResult:Int = cc.rgbResult()
		n = ((rgbResult Shr 16)&$ff) | (rgbResult&$ff00) | ((rgbResult Shl 16)&$ff0000)
		Return n|$ff000000
	EndMethod

	Method LookupColor( colorindex:Int, red:Byte Var, green:Byte Var, blue:Byte Var )

		Select colorindex
			Case GUICOLOR_WINDOWBG
				colorindex = COLOR_BTNFACE
			Case GUICOLOR_GADGETBG
				colorindex = COLOR_WINDOW
			Case GUICOLOR_GADGETFG
				colorindex = COLOR_WINDOWTEXT
			Case GUICOLOR_LINKFG
				colorindex = COLOR_HOTLIGHT
			Case GUICOLOR_SELECTIONBG
				colorindex = COLOR_HIGHLIGHT
			Default
				Return Super.LookupColor( colorindex, red, green, blue )
		EndSelect

		Local tmpColor:Int = GetSysColor( colorindex )
		red = tmpColor & $FF
		green = (tmpColor Shr 8) & $FF
		blue = (tmpColor Shr 16) & $FF

		Return True

	EndMethod

	Method LoadFont:TGuiFont(name$,size,flags)
		Return New TWindowsFont.Load(name,Double(size),flags)
	EndMethod

	Method LoadFontWithDouble:TGuiFont(name$,size:Double,flags)
		Return New TWindowsFont.Load(name,size,flags)
	EndMethod

	Method LibraryFont:TGuiFont( pFontType% = GUIFONT_SYSTEM, pFontSize:Double = 0, pFontStyle% = FONT_NORMAL )
		If pFontType = GUIFONT_SYSTEM Then Return TWindowsFont.DefaultFont( pFontSize, pFontStyle ) Else Return Super.LibraryFont( pFontType, pFontSize, pFontStyle )
	EndMethod

	Method RequestFont:TGuiFont(font:TGuiFont)
		Return TWindowsFont.Request(font)
	EndMethod

	Method SetPointer(shape)
		Global winptrs[]=[0,32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650,32651]
		If shape<1 Or shape>14 Then
			_cursor = LoadCursorW( Null,Short Ptr( IDC_ARROW ) )
		Else
			_cursor=LoadCursorW(Null,Short Ptr(winptrs[shape]))
		End If
		SetCursor(_cursor)
		If TWindowsTextArea._oldCursor Then TWindowsTextArea._oldCursor = _cursor
		If shape = 0 Then _cursor = 0
	EndMethod

	Method LoadIconStrip:TIconStrip(source:Object)
		Return TWindowsIconStrip.Create(source)
	EndMethod


	'Low-level Win32 interface

	Function RegisterHwnd(hwnd:Byte Ptr,gadget:TWindowsGadget)
		GadgetMap.Insert hwnd,gadget
	EndFunction

	Function RemoveHwnd(hwnd:Byte Ptr)
		GadgetMap.Remove hwnd
	EndFunction

	Function GadgetFromHwnd:TWindowsGadget(hwnd:Byte Ptr) nodebug
		Return TWindowsGadget(GadgetMap.ValueForKey(hwnd))
	EndFunction

	Function ClassWndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam) "win32"
		Local owner:TWindowsGadget
		Local res
		Local nmhdrPtr:Byte Ptr

		'?Debug And Win32
		'Print TWindowsDebug.ReverseLookupMsg(msg) + ", hwnd: " + hwnd + ", wp: " + wp + ", lp: " + lp
		'?Win32

		Select msg

			Case WM_MENUCHAR

				If HotKeyEventFromWp(wp & $FF) Then
					Return (MNC_CLOSE Shl 16)
				Else
					Return (MNC_IGNORE Shl 16)
				EndIf

			Case WM_SIZE

				owner = GadgetFromHwnd(hwnd)
				If owner And Not TWindowsWindow(owner) Then
					If hwnd = owner.Query(QUERY_HWND) Then owner.RethinkClient()
					If hwnd = owner.Query(QUERY_HWND_CLIENT) Then owner.LayoutKids()
				EndIf

			Case WM_CTLCOLORSTATIC, WM_CTLCOLOREDIT, WM_CTLCOLORBTN

				owner=GadgetFromHwnd(Byte Ptr lp)

				Select True

					Case TWindowsLabel(owner) <> Null

						SetBkMode(Byte Ptr wp, TRANSPARENT)
						If owner.FgColor() > -1 Then SetTextColor_(Byte Ptr wp, owner.FgColor())
						Return owner.CreateControlBrush( owner._hwnd, Byte Ptr wp )

					Case TWindowsPanel(owner) <> Null

						If TWindowsPanel(owner)._type = TWindowsPanel.PANELGROUP Then

							SetBkMode(Byte Ptr wp, TRANSPARENT)
							If owner.FgColor() > -1 Then SetTextColor_(Byte Ptr wp, owner.FgColor())
							Return owner.CreateControlBrush( Byte Ptr lp, Byte Ptr wp )

						EndIf

					Case TWindowsTextField(owner) <> Null, TWindowsComboBox(owner) <> Null

						If owner.FgColor() > -1 Then SetTextColor_(Byte Ptr wp, owner.FgColor())
						If owner.BgBrush() Then SetBkColor(Byte Ptr wp, owner.BgColor());Return owner.BgBrush()

					Case TWindowsButton(owner) <> Null, TWindowsSlider(owner) <> Null

						SetBkMode(Byte Ptr wp, TRANSPARENT)
						If owner.FgColor() > -1 Then SetTextColor_(Byte Ptr wp, owner.FgColor())
						Return owner.CreateControlBrush( owner._hwnd, Byte Ptr wp )

				EndSelect

				owner = Null

			Case WM_COMMAND,WM_HSCROLL,WM_VSCROLL
				If lp Then
					owner=GadgetFromHwnd(Byte Ptr lp)
					'Fix for tab control's up/down arrow.
					If Not owner Then owner = GadgetFromHwnd(GetParent_(Byte Ptr lp))
				Else
					owner=GadgetFromHwnd(hwnd)		'Fixed for menu events
				EndIf

				If Not owner Then owner = GadgetFromHwnd(hwnd)

				If owner Then
					res=owner.OnCommand(msg,ULong(wp))
					If Not res And owner._proc And owner._hwnd = hwnd Return CallWindowProcW(owner._proc,hwnd,msg,wp,lp)
					Return res
				Else
					Return DefWindowProcW( hwnd,msg,wp,lp )
				EndIf

			Case WM_NOTIFY
				'Gadget tooltips
				nmhdrPtr=lp
				owner=GadgetFromHwnd(bmx_win32_NMHDR_hwndFrom(nmhdrPtr))
				If owner Then
					Select bmx_win32_NMHDR_code(nmhdrPtr)
						Case TTN_GETDISPINFOW
							If owner._wstrTooltip Then bmx_win32_NMTTDISPINFOW_SetlpszText(nmhdrPtr, owner._wstrTooltip)
					EndSelect
					Return owner.OnNotify(wp,lp)
				EndIf

			Case WM_SETCURSOR

				If _cursor Then
					SetCursor(_cursor)
					Return 1
				EndIf

			Case WM_ACTIVATEAPP, WM_ACTIVATE

				SystemEmitOSEvent(hwnd,msg,wp,lp,Null)

			Case WM_DRAWITEM

				Local tmpDrawItemStruct:DRAWITEMSTRUCT = DRAWITEMSTRUCT._create(Byte Ptr lp)
				'MemCopy tmpDrawItemStruct, Byte Ptr lp, SizeOf(tmpDrawItemStruct)

				owner = GadgetFromHwnd(tmpDrawItemStruct.hwndItem())
				If owner And owner.OnDrawItem( tmpDrawItemStruct ) Then Return True

				owner = Null

			'Allow BRL.System to handle mouse/key events on sensitive gadgets.

			Case WM_CAPTURECHANGED

				'For preventing problem where controls which called SetCapture() internally
				'had their capture prematurely released by the ReleaseCapture() call in BRL.System.
				intDontReleaseCapture = False
				'If SetCapture() is called again after BRL.System's call (when the new
				'capture hwnd [lp] = old hwnd [hwnd]) then we dont want to call ReleaseCapture() in BRL.System
				'when WM_MOUSEBUTTONUP is received by the system hook TWindowsGUIDriver.MouseProc().
				If (Byte Ptr lp = hwnd) And (Not intEmitOSEvent) Then intDontReleaseCapture = True

			Default

				'Added preliminary check to avoid searching for a gadget in GadgetMap un-necessarily.
				If (msg = WM_MOUSEWHEEL) Or (msg = WM_MOUSELEAVE) Or (msg>=WM_KEYFIRST And msg<=WM_KEYLAST) Then
					owner=GadgetFromHwnd(hwnd)
					If owner Then
						Select msg
							Case WM_MOUSELEAVE, WM_MOUSEWHEEL
								If (owner.sensitivity&SENSITIZE_MOUSE) Then SystemEmitOSEvent hwnd,msg,wp,lp,owner
							Case WM_KEYDOWN, WM_KEYUP, WM_SYSKEYDOWN, WM_SYSKEYUP, WM_CHAR, WM_SYSCHAR
								If (owner.sensitivity&SENSITIZE_KEYS) And Not GadgetDisabled(owner) Then
									SystemEmitOSEvent hwnd,msg,wp,lp,owner
								EndIf
								If (msg<>WM_CHAR And msg<>WM_SYSCHAR) And HotKeyEventFromWp(wp) Then Return 1
						EndSelect
					EndIf
				EndIf

		EndSelect

		If Not owner Then owner=GadgetFromHwnd(hwnd)
		If owner Return owner.WndProc(hwnd,msg,wp,lp)

		Return DefWindowProcW( hwnd,msg,wp,lp )

	EndFunction

	Function KeyboardProc:Byte Ptr( code, wp:WParam, lp:LParam) "win32" nodebug
		Local ev:TEvent, hwnd:Byte Ptr, tmpClassName:Short[16], mods:Int, key:Int = wp
		If code>=0 Then
			'Removed: http://www.blitzbasic.com/Community/posts.php?topic=72737
'			Rem
			If wp = $D Then	'$D: VK_RETURN
				hwnd = GetFocus()
				If hwnd And GetClassNameW(hwnd,tmpClassName,tmpClassName.length) And String.FromWString(tmpClassName).ToUpper() = "EDIT" Then
					SetFocus(GetParent_(hwnd))
				EndIf
			EndIf
'			EndRem

			ev = HotkeyEventFromWp(wp)
			If ev
				'Hot-key events shouldn't be emitted if the source gadget is disabled
				If Not(TGadget(ev.source) And GadgetDisabled(TGadget(ev.source))) Then
					If Not (lp & $80000000:UInt) Then
						EmitEvent ev
						If ev.mods Then Return 1	'Key press events never reach active panels etc. if we return 1
					EndIf
				EndIf
			EndIf
		EndIf
		Return CallNextHookEx( KBMessageHook,code,wp,lp )
	EndFunction

	Function HotkeyEventFromWp:TEvent(wp:WParam)
		Local key = wp, mods = KeyMods()
		Select wp
			Case VK_SHIFT, $A0, $A1
				If (wp=VK_SHIFT) Then key = KEY_LSHIFT
				mods:&~MODIFIER_SHIFT
			Case VK_CONTROL, $A2, $A3
				If (wp=VK_CONTROL) Then key = KEY_LCONTROL
				mods:&~MODIFIER_CONTROL
			Case VK_MENU, $A4, $A5
				If (wp=VK_MENU) Then key = KEY_LALT
				mods:&~MODIFIER_ALT
			Case VK_LWIN, VK_RWIN
				mods:&~MODIFIER_SYSTEM
		EndSelect
		Return HotKeyEvent( key,mods,GetForegroundWindow() )
	EndFunction

	Global intButtonStates%[4]

	Function MouseProc:Byte Ptr( code,wp:WParam,lp:LParam) "win32" nodebug

		If code>=0 And wp >= WM_MOUSEFIRST And wp <= WM_MOUSELAST Then 'Not needed as MouseProc only receives mouse messages!!!

			Global mh:MOUSEHOOKSTRUCT = New MOUSEHOOKSTRUCT
			mh.hookPtr = lp
			Local w:WParam, l:LParam, data
			Local hwnd:Byte Ptr = mh.hwnd(), msg:UInt = wp, owner:TWindowsGadget
			Local point:Int[] = [mh.x(), mh.y()]

			Select msg
				Case WM_LBUTTONDOWN, WM_LBUTTONDBLCLK
					data = MOUSE_LEFT
					msg = WM_LBUTTONDOWN
					intButtonStates[MOUSE_LEFT] = True
				Case WM_LBUTTONUP
					data = MOUSE_LEFT
					intButtonStates[MOUSE_LEFT] = False
				Case WM_RBUTTONDOWN, WM_RBUTTONDBLCLK
					data = MOUSE_RIGHT
					msg = WM_RBUTTONDOWN
					intButtonStates[MOUSE_RIGHT] = True
				Case WM_RBUTTONUP
					data = MOUSE_RIGHT
					intButtonStates[MOUSE_RIGHT] = False
				Case WM_MBUTTONDOWN, WM_MBUTTONDBLCLK
					data = MOUSE_MIDDLE
					msg = WM_MBUTTONDOWN
					intButtonStates[MOUSE_MIDDLE] = True
				Case WM_MBUTTONUP
					data = MOUSE_MIDDLE
					intButtonStates[MOUSE_MIDDLE] = False
			EndSelect

			owner = GadgetFromHwnd(hwnd)
			If owner And ScreenToClient( hwnd, point ) Then

				If data And (Not intButtonStates[data]) And TGadget.dragGadget[data-1] Then
					PostGuiEvent EVENT_GADGETDROP, owner, data, KeyMods(), point[0], point[1], TGadget.dragGadget[data-1]
					TGadget.dragGadget[data-1] = Null
				EndIf

				If (owner.sensitivity&SENSITIZE_MOUSE) Then

					'Fake wp parameter to pass onto bbSystemEmitOSEvent
					If intButtonStates[MOUSE_LEFT] Then w:|MK_LBUTTON
					If intButtonStates[MOUSE_MIDDLE] Then w:|MK_MBUTTON
					If intButtonStates[MOUSE_RIGHT] Then w:|MK_RBUTTON
					If GetKeyState(VK_SHIFT)&$8000 Then w:|MK_SHIFT
					If GetKeyState(VK_CONTROL)&$8000 Then w:|MK_CONTROL

					l = (Short(point[1]) Shl 16) | Short(point[0])
					'Sort and determine whether to emit the event
					Select msg
						Case WM_MOUSEMOVE
							If (owner._oldcursorlp<>l) Then
								owner._oldcursorlp=l
								SystemEmitOSEvent hwnd,msg,w,l,owner
							EndIf
						Case WM_LBUTTONUP, WM_RBUTTONUP, WM_MBUTTONUP
							If intDontReleaseCapture Then
								PostGuiEvent EVENT_MOUSEUP, owner, data
							Else
								SystemEmitOSEvent hwnd,msg,w,l,owner
							EndIf
						Case WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN
							SystemEmitOSEvent hwnd,msg,w,l,owner
					EndSelect

				EndIf
			EndIf
		EndIf
		Return CallNextHookEx( MouseMessageHook,code,wp,lp )
	EndFunction

	Global intEmitOSEvent

	Function SystemEmitOSEvent( hwnd:Byte Ptr, msg:UInt, wp:WParam, lp:LParam, owner:TGadget )
		intEmitOSEvent:+1
		If owner Then
			While owner.source
				owner = owner.source
			Wend
		EndIf
		bbSystemEmitOSEvent( hwnd, msg, wp, lp, owner )
		intEmitOSEvent:-1
		Return 0
	EndFunction

	Function CheckCommonControlVersion()	'Returns True if supports alpha/themes etc. or False if not.
		If Not _commoncontrolversion Then
			Local libComCtl:Byte Ptr = LoadLibraryW("comctl32.dll")
			Local GetCommonControlVersion( pDllVersionInfo:Byte Ptr ) "win32" = GetProcAddress(libComCtl, "DllGetVersion")
			If GetCommonControlVersion Then
				Local tmpDllVersion:DLLVERSIONINFO2 = New DLLVERSIONINFO2
				GetCommonControlVersion( tmpDllVersion.infoPtr )
				_commoncontrolversion = [tmpDllVersion.dwMajorVersion(),tmpDllVersion.dwMinorVersion(),tmpDLLVersion.dwBuildNumber()]
			EndIf
			GetCommonControlVersion = Null
			FreeLibrary( libComCtl )
		EndIf
		If _commoncontrolversion And _commoncontrolversion[0] >= 6 Then
			If (_commoncontrolversion[0] > 6) Or (_commoncontrolversion[1] > 0) Then Return 2 Else Return 1
		EndIf
	EndFunction

	Function GetThemeHandle:Byte Ptr(hwnd:Byte Ptr, pClass$ = "WINDOW")
		If CheckCommonControlVersion() Then Return OpenThemeData(hwnd, pClass)
	EndFunction

	Function CloseThemeHandle(hTheme:Byte Ptr)
		Return CloseThemeData(hTheme)
	EndFunction

	Function CreateExplorerStyleGadgets( pDisable = False )
		_explorerstyle = (pDisable <> True)
	EndFunction


	Function GetActiveHwnd:Byte Ptr()
		If _activeWindow Then Return _activeWindow._hwnd Else Return GetActiveWindow()
	EndFunction


	Function ClassName$()
		Global _name$
		Global _wc:WNDCLASSW
		Global _icon:Byte Ptr

		If Not _name
			_name="BLITZMAX_WINDOW_CLASS"
			_icon=bbAppIcon(GetModuleHandleW(Null))
			_wc=New WNDCLASSW
			_wc.Setstyle(CS_OWNDC|CS_HREDRAW|CS_VREDRAW)
			_wc.SetlpfnWndProc(ClassWndProc)
			_wc.SethInstance(GetModuleHandleW(Null))
			_wc.SethIcon(_icon)
			_wc.SethCursor(LoadCursorW( Null,Short Ptr( IDC_ARROW ) ))
			_wc.SethbrBackground(COLOR_BTNSHADOW)
			'_wc.lpszMenuName=Null
			Local n:Short Ptr = _name.ToWString()
			_wc.SetlpszClassName(n)
			_wc.SetcbWndExtra(DLGWINDOWEXTRA)
			ClassAtom=RegisterClassW(_wc.classPtr)
			MemFree(n)
		EndIf
		Return _name
	EndFunction

	Function DialogClassName$()
		Global _dname$
		Global _dc:WNDCLASSW

		If Not _dname
			_dname="BLITZMAX_DIALOG_CLASS"
			_dc=New WNDCLASSW
			_dc.Setstyle(CS_OWNDC|CS_HREDRAW|CS_VREDRAW)
			_dc.SetlpfnWndProc(ClassWndProc)
			_dc.SethInstance(GetModuleHandleW(Null))
			_dc.SethCursor(LoadCursorW( Null,Short Ptr( IDC_ARROW ) ))
			_dc.SethbrBackground(COLOR_BTNSHADOW)
			'_dc.lpszMenuName=Null
			Local n:Short Ptr = _dname.ToWString()
			_dc.SetlpszClassName(_dname.ToWString())
			_dc.SetcbWndExtra(DLGWINDOWEXTRA)
			ClassAtom2=RegisterClassW(_dc.classPtr)
			MemFree(n)
		EndIf
		Return _dname
	EndFunction

End Type



Type TChooseColor

	Field colorPtr:Byte Ptr

	Method Create:TChooseColor(parent:Byte Ptr, rgb:Int, customColors:Int Ptr, flags:Int = CC_RGBINIT|CC_FULLOPEN|CC_ANYCOLOR)
		colorPtr = bmx_win32maxgui_choosecolor_new(parent, rgb, customColors, flags)
		Return Self
	End Method

	Method ChooseColor:Int()
		Return bmx_win32maxgui_choosecolor_ChooseColor(colorPtr)
	End Method

	Method rgbResult:Int()
		Return bmx_win32maxgui_choosecolor_rgbResult(colorPtr)
	End Method

	Method Delete()
		If colorPtr Then
			bmx_win32maxgui_choosecolor_free(colorPtr)
			colorPtr = Null
		End If
	End Method

End Type




Type TWindowsIconStrip Extends TIconStrip

	Field	_blanks[]
	Field	_imagelist:Byte Ptr

	Function DetectNotBlank(pixmap:TPixmap,xx,n)
		Local c = pixmap.ReadPixel(xx,0), y
		For Local x=0 Until n
			For y=0 Until n
				If pixmap.ReadPixel(xx+x,y)<>c Return True
			Next
		Next
	EndFunction

	Method IsBlankIcon(n)
		Return _blanks[n]
	EndMethod

	Function RemoveMask(pixmap:TPixmap)
		If pixmap.format<>( PF_RGBA8888 ) And pixmap.format<>( PF_BGRA8888 ) Return
		Local w = pixmap.width, h = pixmap.height, y, c
		For Local x=0 Until w
			For y=0 Until h
				c=pixmap.ReadPixel(x,y)
				If c>=0 pixmap.WritePixel x,y,-1
			Next
		Next
	EndFunction

	Function BuildImageList:Byte Ptr(pixmap:TPixmap)

		Local bitmap:Byte Ptr,imagelist:Byte Ptr,sz,mask:Byte Ptr
		sz=pixmap.height

		If TWindowsGUIDriver.CheckCommonControlVersion() And (Pixmap.format=PF_RGBA8888 Or pixmap.format=PF_BGRA8888)
			imagelist=ImageList_Create(sz,sz,ILC_COLOR32,0,1)
			If imagelist
				bitmap=TWindowsGraphic.BitmapFromPixmap(pixmap, True)
				ImageList_Add(imagelist,bitmap,Null)
			EndIf
		EndIf
		If imagelist=0
			bitmap=TWindowsGraphic.BitmapFromPixmap(pixmap, False)
			mask=TWindowsGraphic.BitmapMaskFromPixmap(pixmap)
			imagelist=ImageList_Create(sz,sz,ILC_COLOR24|ILC_MASK,0,1)
			ImageList_Add(imagelist,bitmap,mask)
			DeleteObject(mask)
		EndIf
		DeleteObject(bitmap)
		Return imagelist
	EndFunction

	Function Create:TWindowsIconStrip(source:Object)
		Local	icons:TWindowsIconStrip
		Local	imagelist:Byte Ptr
		Local	n,i,sz
		Local	blanks[]

		'Get a 24-bit pixmap from source
		Local pix:TPixmap = TPixmap(source)
		If Not pix pix = LoadPixmap(source)
		If Not pix Return

		'Detect blank icons in the set
		sz=pix.height;If sz n=pix.width/sz

		If n=0 Return
		blanks=New Int[n]
		For i=0 Until n
			blanks[i]=Not DetectNotBlank(pix,i*sz,sz)
		Next

		'Build a Win32 Image-List
		imagelist=BuildImageList(pix)
		icons = New TWindowsIconStrip
		icons.pixmap = pix
		icons.count=n
		icons._blanks=blanks
		icons._imagelist=imagelist

		Return icons
	EndFunction

	Function CreateBlank:TWindowsIconStrip()
		Return Create(CreatePixmap(1,1,PF_BGR888))
	EndFunction

	Method Delete()
		If _imagelist Then
			ImageList_Destroy(_imagelist)
			_imagelist = 0
		EndIf
	EndMethod

EndType

Type TWindowsFont Extends TGuiFont

	Method Load:TWindowsFont(_name$,_size:Double,_style)

		If handle Then
			DeleteObject handle
			handle = 0
		End If

		Local cfweight = FW_NORMAL
		Local cfsize = -LogicalUnitsFromSize( _size )

		If _style & FONT_BOLD cfweight=FW_BOLD
		handle = CreateFontW( cfsize, 0,0,0,cfweight,..
			(_style & FONT_ITALIC) ,..
			(_style & FONT_UNDERLINE),..
			(_style & FONT_STRIKETHROUGH),..
			DEFAULT_CHARSET,..
			OUT_DEFAULT_PRECIS,..
			CLIP_DEFAULT_PRECIS,..
			CLEARTYPE_QUALITY|ANTIALIASED_QUALITY,..
			DEFAULT_PITCH|FF_DONTCARE,..
			_name.toWString())

		'Now lets test to see whether the right font was found

		name = NameFromHandle(handle)

		'If the font returned has a different name to that requested, let's try the symbol character set

		If name.ToLower() <> _name.ToLower() Then
			Local tmpSymbolHandle:Byte Ptr = CreateFontW( cfsize, 0,0,0,cfweight,..
							(_style & FONT_ITALIC) ,..
							(_style & FONT_UNDERLINE),..
							(_style & FONT_STRIKETHROUGH),..
							SYMBOL_CHARSET,..
							OUT_DEFAULT_PRECIS,..
							CLIP_DEFAULT_PRECIS,..
							CLEARTYPE_QUALITY|ANTIALIASED_QUALITY,..
							DEFAULT_PITCH|FF_DONTCARE,..
							_name.toWString())

			Local strSymbolName:String = NameFromHandle(tmpSymbolHandle)

			'If we now have a match, delete the first font returned and use the new symbol one.

			If strSymbolName.ToLower() = _name.ToLower() Then
				DeleteObject handle
				handle = tmpSymbolHandle
				name = strSymbolName
			Else
				DeleteObject tmpSymbolHandle
			EndIf

		EndIf

		size=_size
		style=_style

		Return Self

	EndMethod

	Method LoadFromLogFont:TWindowsFont( pLogFont:LOGFONTW, pStyle% = 0, pSize:Double = 0:Double )

		If pLogFont.lfWeight()>=FW_BOLD Then pStyle:| FONT_BOLD
		If pLogFont.lfItalic() Then pStyle:| FONT_ITALIC
		If pLogFont.lfUnderline() Then pStyle:| FONT_UNDERLINE
		If pLogFont.lfStrikeOut() Then pStyle:| FONT_STRIKETHROUGH

		style = pStyle

		If Not pSize Then pSize = SizeFromLogFont( pLogFont )

		size = pSize

		SetLogFontProperties( pLogFont, pStyle, pSize )

		name = String.FromWString( pLogFont.lfFaceName() )

		If handle Then DeleteObject handle
		handle = CreateFontIndirectW( pLogFont.fontPtr )

		Return Self

	EndMethod

	Method LoadFromHandle:TWindowsFont(hfont:Byte Ptr)

		Local tmpLogFont:LOGFONTW = New LOGFONTW
		GetObjectW( hfont, LOGFONTW.Size(), tmpLogFont.fontPtr )
		Return LoadFromLogFont( tmpLogFont )

	EndMethod

	Method CharWidth( charcode )
		Local hdc:Byte Ptr=GetDC(0)
		Local TFont:Byte Ptr=SelectObject( hdc,handle )

		Local width=8,widths[3]

		If GetCharABCWidthsW( hdc,UInt(charcode),UInt(charcode),widths )
			width=widths[0]+widths[1]+widths[2]
		Else If GetCharWidth32W( hdc,UInt(charcode),UInt(charcode),widths )
			width=widths[0]
		EndIf

		SelectObject hdc,TFont
		ReleaseDC Null,hdc

		Return width
	EndMethod

	Method GetMaxCharWidth()
		Local hdc:Byte Ptr=GetDC(0)
		Local TFont:Byte Ptr=SelectObject(hdc,handle)
		Local tm:TEXTMETRICW=New TEXTMETRICW
		GetTextMetricsW hdc,tm.metricPtr
		SelectObject(hdc,TFont)
		ReleaseDC(Null,hdc)
		Return tm.tmAveCharWidth()
	EndMethod

	Method Delete()
		If handle Then DeleteObject handle
	EndMethod

	Function Request:TWindowsFont(font:TGuiFont)

		Local lf:LOGFONTW = New LOGFONTW
		Local cf:CHOOSEFONTW = New CHOOSEFONTW

		'cf.lStructSize=SizeOf(cf)
		cf.SethwndOwner(TWindowsGUIDriver.GetActiveHwnd())
		cf.SetlpLogFont(lf.fontPtr)
		cf.SetFlags(CF_BOTH)

		If font
			Local p:Short Ptr = lf.lfFaceName()
			For Local i = 0 Until Min(font.name.length, 31)
				p[i]=font.name[i]
			Next
			SetLogFontProperties( lf, font.style, font.size )
			cf.SetFlags(cf.Flags()|CF_INITTOLOGFONTSTRUCT)
		EndIf

		Local hwnd:Byte Ptr = GetFocus()
		Local n = ChooseFontW_(cf.fontPtr)
		SetFocus(hwnd)
		If Not n Return

		Local style
		If cf.nFontType()&BOLD_FONTTYPE style:|FONT_BOLD
		If cf.nFontType()&ITALIC_FONTTYPE style:|FONT_ITALIC
		Return New TWindowsFont.LoadFromLogFont( lf, style, cf.iPointSize()/Double(10) )

	EndFunction

	Function DefaultFont:TWindowsFont( pFontSize:Double = 0, pFontStyle% = FONT_NORMAL )

		'Attempts to get hold of the Windows themed font (typically Tahoma on XP, Segeo UI on Vista)
		Local tmpNonClientMetrics:NONCLIENTMETRICSW = New NONCLIENTMETRICSW

		If SystemParametersInfoW( SPI_GETNONCLIENTMETRICS, tmpNonClientMetrics.Size(), tmpNonClientMetrics.metricsPtr, 0 ) Then
			Return New TWindowsFont.LoadFromLogFont( tmpNonClientMetrics.lfMessageFont(), pFontStyle, pFontSize )
		EndIf

		'If these functions, for whatever reason, fail, then the default GUI font is used (typically MS Sans Serif).
		'Note: A font size of '8' has has been hard-coded in as no reliable substitute can be found, however this may cause
		'text to appear too small in some languages/lacalizations.
		If pFontSize <= 0 Then pFontSize = 8
		Return New TWindowsFont.Load( "MS Shell Dlg", pFontSize, pFontStyle )

	EndFunction

	Function NameFromHandle:String( pFntHandle:Byte Ptr )

		Local hdc:Byte Ptr = GetDC(0), buffer:Short[512]
		Local TFont:Byte Ptr = SelectObject(hdc,pFntHandle)

		If Not GetTextFaceW(hdc,buffer.length,buffer) buffer[0] = 0

		SelectObject(hdc, TFont)
		ReleaseDC(Null,hdc)

		Return String.FromWString(buffer)

	EndFunction

	Function LogicalUnitsFromSize( pSize:Double )

		Local tmpDC:Byte Ptr = GetDC(0)
		Local tmpSize:Int = (pSize * GetDeviceCaps(tmpDC,LOGPIXELSY))/72 + 0.5
		ReleaseDC( Null, tmpDC )
		Return tmpSize

	EndFunction

	Function SizeFromLogFont:Double( pLogFont:LOGFONTW )

		Local tmpDC:Byte Ptr = GetDC(0)
		Local tmpSize:Double = (Abs(pLogFont.lfHeight()) * Double(72.0) )/GetDeviceCaps(tmpDC,LOGPIXELSY)
		ReleaseDC( Null, tmpDC )
		Return tmpSize

	EndFunction

	Function SetLogFontProperties( pLogFont:LOGFONTW, pFlags%, pSize:Double = 0:Double )

		If pFlags&FONT_BOLD Then pLogFont.SetlfWeight(FW_BOLD) Else pLogFont.SetlfWeight(FW_NORMAL)
		If pFlags&FONT_ITALIC Then pLogFont.SetlfItalic(True) Else pLogFont.SetlfItalic(False)
		If pFlags&FONT_UNDERLINE Then pLogFont.SetlfUnderline(True) Else pLogFont.SetlfUnderline(False)
		If pFlags&FONT_STRIKETHROUGH Then pLogFont.SetlfStrikeOut(True) Else pLogFont.SetlfStrikeOut(False)

		If pSize > 0 Then pLogFont.SetlfHeight(-LogicalUnitsFromSize( pSize ))

	EndFunction

EndType


Type TWindowsGadget Extends TGadget

	'Flag that determines whether gadgets should redraw when they are resized (see Rethink()).
	Global _resizeRedraw = True

	'Generic Unicode Strings to prevent memory-leak
	Global _wstrEmpty:Short Ptr = "".ToWString()
	Global _wstrSpace:Short Ptr = " ".ToWString()
	Global _wstrExplorer:Short Ptr = "Explorer".ToWString()

	'Important gadget fields that store OS control handles etc..

	Field _class, _hwnd:Byte Ptr, _hwndclient:Byte Ptr, _tooltips:Byte Ptr
	Field _proc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:Byte Ptr,lp:Byte Ptr) "win32"
	Field _hotkey:THotKey
	Field _oldcursorlp:Byte Ptr	'Should track events

	Field _sensitive% = False	'Determines whether gadgets should generate events.
						'Not to be confused with the sensitivity field of TGadget
						'which specifies which type of events are fired.

	'Aesthetics
	Field _bgbrush:Byte Ptr, _fgcolor = -1, _bgcolor = -1	'Background colour
	Field _hbrush:Byte Ptr, _hbitmap:Byte Ptr					'Background colour
	Field _bitmap:Byte Ptr							'Background bitmap
	Field _iconBitmap:Byte Ptr							'Icon bitmap
	Field _hTheme:Byte Ptr							'Open handle to XP Theme API (for use in button's WM_DRAWITEM etc.)
	Field _font:TWindowsFont					'Font (needs to be stored, otherwise it may be collected by GC)
	Field _wstrTooltip:Short Ptr, _toolAdded = False
	Field _clientX:Int, _clientY:Int, _enabled:Int = True, _forcedisable:Int = False


	Method Create:TWindowsGadget(group:TGadget, style, Text$="")	 Abstract

	Method SetColor(red,green,blue)
		If _bgbrush Then DeleteObject _bgbrush
		_bgcolor = (blue Shl 16) | (green Shl 8) | red
		_bgbrush=CreateSolidBrush(_bgcolor)
		RedrawGadget(Self)
	EndMethod

	Method RemoveColor()
		If _bgbrush Then DeleteObject _bgbrush
		_bgbrush=0
		RedrawGadget(Self)
	EndMethod

	Method FgColor()
		Return _fgcolor
	EndMethod

	Method BgColor()
		Return _bgcolor
	EndMethod

	Method BgBrush:Byte Ptr()
		Return _bgbrush
	EndMethod

	Method SetTextColor(r,g,b)
		_fgcolor = (b Shl 16) | (g Shl 8) | r
		RedrawGadget(Self)
	EndMethod

	Method Query:Byte Ptr(queryid)
		Select queryid
			Case QUERY_HWND
				Return _hwnd
			Case QUERY_HWND_CLIENT
				If _hwndclient Return _hwndclient
				Return _hwnd
		End Select
	EndMethod

	Method Register(class,hwnd:Byte Ptr,hwndclient:Byte Ptr=0,tips=False)
		_class=class
		_hwnd=hwnd
		_hwndclient=hwndclient
		TWindowsGUIDriver.RegisterHwnd(_hwnd,Self)
		If _hwndclient TWindowsGUIDriver.RegisterHwnd(_hwndclient,Self)
		Local atom=GetClassLongW(hwnd,GCW_ATOM)
		If atom<>TWindowsGUIDriver.ClassAtom And atom<>TWindowsGUIDriver.ClassAtom2 And Not _proc
			_proc=Byte Ptr(SetWindowLongPtrW(hwnd,GWL_WNDPROC,TWindowsGUIDriver.ClassWndProc))
		EndIf
		If tips Then SetupToolTips()
	EndMethod

	Method SetupToolTips()
		If _tooltips Then
			DestroyWindow _tooltips;TWindowsGUIDriver.RemoveHwnd(_tooltips);_tooltips = 0
		End If
		_tooltips = CreateWindowExW( 0,"tooltips_class32","",TTS_ALWAYSTIP,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,_hwnd,Null,GetModuleHandleW(Null),Null )
		SendMessageW _tooltips,TTM_SETMAXTIPWIDTH,0,300
		TWindowsGUIDriver.RegisterHwnd( _tooltips, Self )
	EndMethod

	Method isTabbable()
		Local style:Int = GetWindowLongW(_hwnd,GWL_STYLE)&(WS_TABSTOP|WS_CHILD)
		Return (style=(WS_TABSTOP|WS_CHILD))
	EndMethod

	Method isControl()
		Return (GetWindowLongW(_hwnd,GWL_STYLE)&(WS_CHILD)=WS_CHILD)
	EndMethod

	Method Activate(cmd)
		Select cmd
			Case ACTIVATE_FOCUS
				If isTabbable()
					DefDlgProcW GetParent_(_hwnd),WM_NEXTDLGCTL,WParam(_hwnd),1
					Return 1
				EndIf
				If SetFocus(_hwnd) Then
					Return True
				End If
			Case ACTIVATE_BACK
				Return SendMessageW(_hwnd,WM_NEXTDLGCTL,1,0)
			Case ACTIVATE_FORWARD
				Return SendMessageW(_hwnd,WM_NEXTDLGCTL,0,0)
			Case ACTIVATE_REDRAW
				RefreshLook()
				Return RedrawWindow( _hwnd, Null, Null, RDW_INVALIDATE | RDW_ERASE | RDW_FRAME | RDW_ALLCHILDREN )
		End Select
	EndMethod

	Method Rethink()
		QueueResize(_hwnd,xpos,ypos,width,height)
	EndMethod

	Method RethinkClient(forceRedraw:Int = False)
	EndMethod

	Method SetArea(x,y,w,h)
		SetRect(x,y,w,h)
		Rethink()
	EndMethod

	Method LayoutKids()

		StartResize()

		'Implemented hack to speed-up drawing considerably...
		Local tmpOldState = TWindowsGadget._resizeredraw
		TWindowsGadget._resizeredraw = False

		'Child windows are laid-out like normal...
		Super.LayoutKids()

		'Reposition all child gadgets together.
		EndResize()

		'If this control is the first parent who started the resizing, then redraw parent and all controls now.
		If tmpOldState Then
			If (Not kids.IsEmpty()) Then Activate(ACTIVATE_REDRAW)
			TWindowsGadget._resizeredraw = True
		EndIf

	EndMethod

	Method ClientWidth()
		Local Rect[] = [xpos,ypos,xpos+width,ypos+height]
		SendMessageW Query(QUERY_HWND), WM_NCCALCSIZE, False, LParam(Byte Ptr Rect)
		Return Rect[2]-Rect[0]-_clientX
	EndMethod

	Method ClientHeight()
		Local Rect[] = [xpos,ypos,xpos+width,ypos+height]
		SendMessageW Query(QUERY_HWND), WM_NCCALCSIZE, False, LParam(Byte Ptr Rect)
		Return Rect[3]-Rect[1]-_clientY
	EndMethod

	Method SetText(Text$)
		Desensitize()
		SetWindowTextW _hwnd, Text
		Sensitize()
	EndMethod

	Method GetText$()
		Local strText:Short[GetWindowTextLengthW(_hwnd)+1]		'Must include NULL terminator.
		GetWindowTextW _hwnd, strText, strText.length
		Return String.FromWString( strText )
	EndMethod

	Method SetFont(font:TGuiFont)
		If TWindowsFont(font) Then _font = TWindowsFont(font) Else _font = TWindowsGUIDriver.GDIFont
		SendMessageW _hwnd,WM_SETFONT,WParam(font.handle),1
	EndMethod

	Method SetShow(show)
		If show
			ShowWindow _hwnd,SW_SHOW
		Else
			'Requester fix - ShowWindow activates the last activated window when an active window is hidden, so if
			'a file requester/child gadget was the last window to be activated, then the program will lose focus as it is
			'trying to activate a non-existent window.
			If parent And HasDescendant(ActiveGadget()) Then ActivateGadget(parent)
			ShowWindow _hwnd,SW_HIDE
		EndIf
	EndMethod

	Method SetEnabled(enable)
		_enabled = enable
		enable = enable And Not _forceDisable
		If Not((EnableWindow(_hwnd,enable)<>0) ~ enable) Then
			For Local tmpGadget:TWindowsGadget = EachIn kids
				tmpGadget._forceDisable = Not enable
				If tmpGadget.isControl() Then tmpGadget.SetEnabled(tmpGadget._enabled)
			Next
		EndIf
	EndMethod

	Method SetTooltip( pTooltip$ )

		If _wstrTooltip Then
			MemFree _wstrTooltip
			_wstrTooltip = Null
		End If

		Local tmpToolInfo:TOOLINFOW = New TOOLINFOW
		'tmpToolInfo.cbSize = SizeOf(tmpToolInfo)
		tmpToolInfo.Sethwnd(GetParent_(_hwnd))
		tmpToolInfo.Sethinst(GetModuleHandleW(Null))
		tmpToolInfo.SetuID(_hwnd)

		If pTooltip Then
			_wstrTooltip = pTooltip.Replace("~r","").Replace("~n","~r~n").ToWString()

			tmpToolInfo.SetuFlags(TTF_IDISHWND|TTF_TRANSPARENT|TTF_SUBCLASS)
			tmpToolInfo.SetlpszText(_wstrTooltip)

			If Not _toolAdded Then
				_toolAdded = SendMessageW(TWindowsGUIDriver._hwndTooltips, TTM_ADDTOOLW, 0, LParam(tmpToolInfo.infoPtr))
			Else
				SendMessageW(TWindowsGUIDriver._hwndTooltips, TTM_UPDATETIPTEXTW, 0, LParam(tmpToolInfo.infoPtr))
			EndIf
		ElseIf _tooladded Then
			SendMessageW(TWindowsGUIDriver._hwndTooltips, TTM_DELTOOLW, 0, LParam(tmpToolInfo.infoPtr ))
			_toolAdded = 0
		EndIf

	EndMethod

	Method GetTooltip$()
		If _wstrTooltip Then Return String.FromWString(_wstrTooltip)
	EndMethod

	Method State()
		Local t, style = GetWindowLongW(_hwnd, GWL_STYLE)
		If Not (style&WS_VISIBLE) Then t:|STATE_HIDDEN
		If Not _enabled Then t:|STATE_DISABLED
		Return t
	EndMethod

	Method Free()
		If _tooltips Then DestroyWindow _tooltips;_tooltips=0
		SetTooltip("")	'Free any tooltip memory allocations
		If _hwnd Then DestroyWindow _hwnd;TWindowsGUIDriver.RemoveHwnd(_hwnd);_hwnd=0
		If _hwndclient Then TWindowsGUIDriver.RemoveHwnd(_hwndclient);_hwndclient=0
		FlushBrushes(False)
		If _hotKey Then RemoveHotKey(_hotKey);_hotKey = Null
		If _iconBitmap Then DeleteObject(_iconBitmap);_iconBitmap = 0
		If _bitmap Then DeleteObject(_bitmap);_bitmap = 0
		If _bgbrush Then DeleteObject(_bgbrush);_bgbrush = 0
		If _htheme Then TWindowsGUIDriver.CloseThemeHandle(_hTheme);_hTheme = 0
		_font = Null
		_SetParent Null
	EndMethod

	Method OnNotify(wp:WParam,lp:LParam)
	EndMethod

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
		Select msg
			Case WM_WINDOWPOSCHANGING
				FlushBrushes()
		EndSelect
		If _proc And _hwnd = hwnd Then
			Return CallWindowProcW(_proc,hwnd,msg,wp,lp)	 'fixed auto scrollbars
		EndIf
		Return DefWindowProcW( hwnd,msg,wp,lp )
	EndMethod

	Method OnCommand(msg,wp:ULong)
	EndMethod

	Method OnDrawItem( pDrawItemStruct:DRAWITEMSTRUCT )
	EndMethod

	Method SetHotKey(key,modifier)
		Local ev:TEvent = CreateEvent( EVENT_GADGETACTION,Self)
		If _hotKey Then
			RemoveHotKey(_hotKey)
			_hotKey = Null
		End If
		If key Then _hotkey=SetHotKeyEvent(key,modifier,ev,FindGadgetWindowHwnd(Self))
	EndMethod

	'Slow back-up code for mimicking transparency for PANEL_GROUPs and when
	'DrawThemeParentBackground() is not available (i.e. on Windows 9x/2000).
	Method CreateControlBrush:Byte Ptr( hWndControl:Byte Ptr, hdc:Byte Ptr = Null )

		Local xOffset, yOffset
		Local hwndWindow:Byte Ptr = GetParent_(hwndControl)
		Local rectWindow[4], rectControl[4], rectClient[4]

		If _hbrush Then Return _hbrush

		If BgBrush() Then
			If hdc Then SetBkColor(hdc, BgColor())
			Return BgBrush()
		EndIf

		Local tmpDC:Byte Ptr = GetDC( hwndWindow )

		'Fix required to offset background when controls are drawn with WS_EX_CLIENTEDGE (e.g. panel with PANEL_SUNKEN/PANEL_RAISED set)
		If GetWindowLongW(hwndWindow,GWL_EXSTYLE)&(WS_EX_CLIENTEDGE|WS_EX_WINDOWEDGE) Then
			xOffset = -GetSystemMetrics(SM_CXEDGE)
			yOffset = -GetSystemMetrics(SM_CYEDGE)
		EndIf

		GetClientRect( hwndControl, rectClient )
		GetWindowRect( hwndWindow, rectWindow )
		GetWindowRect( hwndControl, rectControl )

		Local x = rectControl[0]-rectWindow[0]
		Local y = rectControl[1]-rectWindow[1]
		Local w = rectControl[2]-rectControl[0]
		Local h = rectControl[3]-rectControl[1]

		Local dcBitmap:Byte Ptr = CreateCompatibleDC( tmpDC )
		Local bkgndBitmap:Byte Ptr = CreateCompatibleBitmap( tmpDC, rectWindow[2]-rectWindow[0], rectWindow[3]-rectWindow[1] )
		SelectObject( dcBitmap, bkgndBitmap )

		'InvalidateRect( hwndWindow, Null, False )
		SendMessageW hwndWindow, WM_ERASEBKGND, WParam(dcBitmap), 0

		Local bkgndClientBitmap:Byte Ptr = CreateCompatibleBitmap( tmpDC, w, h )
		Local dcClientBitmap:Byte Ptr = CreateCompatibleDC( tmpDC )
		SelectObject( dcClientBitmap, bkgndClientBitmap )

		BitBlt( dcClientBitmap, 0,0 , w, h, dcBitmap, x+xOffset, y+yOffset, ROP_SRCCOPY )

		DeleteObject( bkgndBitmap )
		DeleteDC( dcBitmap )
		DeleteDC( dcClientBitmap )

		_hbrush = CreatePatternBrush( bkgndClientBitmap )
		_hbitmap = bkgndClientBitmap

		ReleaseDC( hwndWindow, tmpDC )

		Return _hbrush

	EndMethod

	'Clears the parent background brushes.
	Method FlushBrushes(pRecurse:Int = True)
		Local tmpChanges:Int = 0
		If _hbrush Then
			DeleteObject( _hbrush )
			_hbrush = 0
			tmpChanges:|True
		EndIf
		If _hBitmap Then
			DeleteObject( _hBitmap )
			_hBitmap = 0
			tmpChanges:|True
		EndIf
		Return tmpChanges
	EndMethod

	'Method that returns a brush for drawing backgrounds.
	Method DrawBackground:Byte Ptr( hdc:Byte Ptr, hwnd:Byte Ptr )

		If BgBrush() Then SetBkColor(hdc, BgColor());Return BgBrush()

		Return DrawParentBackground( hdc, hwnd )

	EndMethod

	'Another method which mimics transparency on Windows Controls.
	Function DrawParentBackground:Byte Ptr( hdc:Byte Ptr, hwndControl:Byte Ptr, pForceHack = False )

		Local rectWindow[4], rectControl[4], rectClient[4]
		Local hwndWindow:Byte Ptr = GetParent_(hwndControl)

		GetClientRect( hwndControl, rectClient )
		GetClientRect( hwndWindow, rectWindow )
		GetWindowRect( hwndControl, rectControl )

		'Ensures that the the drawing context is returned in exactly the same state that it was passed.
		Local tmpSaveState = SaveDC( hdc )

		If Not pForceHack Then

			DrawThemeParentBackground(hwndControl,hdc,rectClient)

		Else 'Again, slow back-up code in case DrawThemeParentBackground() is not available.

			Local tmpDC:Byte Ptr
			Local xOffset, yOffset

			'Fix required to offset background when controls are drawn with WS_EX_CLIENTEDGE (e.g. panel with PANEL_BORDER set)
			If GetWindowLongW(hwndWindow,GWL_EXSTYLE)&WS_EX_CLIENTEDGE Then
				xOffset = -GetSystemMetrics(SM_CXEDGE)
				yOffset = -GetSystemMetrics(SM_CYEDGE)
			EndIf

			tmpDC = GetDC( hwndWindow )

			ScreenToClient( hwndWindow, rectControl )
			ScreenToClient( hwndWindow, Int Ptr (rectControl)+2 )

			Local x = rectControl[0]+rectClient[0]
			Local y = rectControl[1]+rectClient[1]
			Local w = rectClient[2]-rectClient[0]
			Local h = rectClient[3]-rectClient[1]

			Local bkgndBitmap:Byte Ptr = CreateCompatibleBitmap( tmpDC, rectWindow[2]-rectWindow[0], rectWindow[3]-rectWindow[1] )
			Local dcBitmap:Byte Ptr = CreateCompatibleDC( tmpDC )
			SelectObject( dcBitmap, bkgndBitmap )

			InvalidateRect( hwndWindow, Null, False )
			SendMessageW hwndWindow, WM_ERASEBKGND, WParam(dcBitmap), 0

			BitBlt( hdc, 0,0 , w, h, dcBitmap, x+xOffset, y+yOffset, ROP_SRCCOPY )

			DeleteObject( bkgndBitmap )
			DeleteDC( dcBitmap )
			ReleaseDC( hwndWindow, tmpDC )

		EndIf

		'Ensures that the the drawing context is returned in exactly the same state that it was passed.
		RestoreDC( hdc, tmpSaveState )

		Return GetStockObject( NULL_BRUSH )

	EndFunction

	Method Sensitize()
		_sensitive = True
	EndMethod

	Method DeSensitize()
		_sensitive = False
	EndMethod

	Method PostGuiEvent( pID%, pData%=0, pMods%=0, pX%=0, pY%=0, pExtra:Object = Null)

		Select True
			Case TWindowsListBox(Self) <> Null, TWindowsTabber(Self) <> Null, TWindowsToolbar(Self) <> Null, TWindowsCombobox(Self) <> Null
				If pData>-1 Then
					If (ItemFlags(pData) & GADGETITEM_TOGGLE) Then SelectItem(pData,2)
				EndIf
		End Select

		If _sensitive Then MaxGUI.MaxGUI.PostGuiEvent( pID, Self, pData, pMods, pX, pY, pExtra )

	EndMethod

	'Resize Methods

	Field hdwpStruct:Byte Ptr

	Method StartResize()
		If Not hdwpStruct Then
			Local tmpCount = kids.Count()
			If tmpCount Then hdwpStruct = BeginDeferWindowPos( tmpCount )
		EndIf
	EndMethod

	Method QueueResize( hwnd:Byte Ptr, xpos, ypos, width, height )
		If parent And GetParent_(hwnd) = parent.Query(QUERY_HWND_CLIENT) And TWindowsGadget(parent).hdwpStruct Then
			Local tmpFlags = SWP_NOOWNERZORDER | SWP_NOZORDER | SWP_NOACTIVATE' | SWP_NOCOPYBITS
			If Not _resizeRedraw Then tmpFlags:| SWP_NOREDRAW
			TWindowsGadget(parent).hdwpStruct = DeferWindowPos( TWindowsGadget(parent).hdwpStruct, hwnd, Null, xpos, ypos, width, height, UInt(tmpFlags) )
		Else
			MoveWindow( hwnd, xpos, ypos, width, height, _resizeRedraw )
			HasResized()
		EndIf
	EndMethod

	Method EndResize()
		If hdwpStruct Then
			EndDeferWindowPos( hdwpStruct );hdwpStruct = 0
			For Local tmpGadget:TWindowsGadget = EachIn kids
				Sensitize()
				tmpGadget.HasResized()
			Next
		EndIf
	EndMethod

	'Required for resizing columns in listboxes (has to be done outside WM_SIZE)
	Method HasResized()
	EndMethod

	'Required to ensure problematic controls are updated when parent aesthetics are changed:
	Method RefreshLook()
		FlushBrushes(False)
		For Local tmpGadget:TWindowsGadget = EachIn kids
			tmpGadget.RefreshLook()
		Next
	EndMethod

End Type

Type TWindowsDesktop Extends TWindowsGadget

	Method New()
		Local Rect[4]
		Local hwnd:Byte Ptr = GetDesktopWindow()
		Register(GADGET_DESKTOP,hwnd,Null,False)
		GetClientRect hwnd,Rect
		SetShape 0,0,Rect[2]-Rect[0],Rect[3]-Rect[1]
	EndMethod

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Return Self
	EndMethod

	Method SetTooltip( pTooltip$ )
		'Shouldn't have tool-tips.
	EndMethod

	Method Free()
		'Can't be free'd.
	EndMethod

	Method Class()
		Return GADGET_DESKTOP
	EndMethod

	Method ClientHeight()
		Local Rect[4]
		If SystemParametersInfoW( SPI_GETWORKAREA, 0, Rect, 0 )
			Return Rect[3]-Rect[1]
		Else
			Return Super.ClientHeight()
		EndIf
	EndMethod

	Method ClientWidth()
		Local Rect[4]
		If SystemParametersInfoW( SPI_GETWORKAREA, 0, Rect, 0 )
			Return Rect[2]-Rect[0]
		Else
			Return Super.ClientWidth()
		EndIf
	EndMethod

	Method ScaleFactor:Int()
		If GetDpiForMonitor Then
			Local hwnd:Byte Ptr = GetDesktopWindow()
			Local monitor:Byte Ptr = MonitorFromWindow(hwnd, 0)
			If monitor Then
				Local xdpi:UInt
				Local ydpi:UInt
				Local res:Byte Ptr = GetDpiForMonitor(monitor, 0, xdpi, ydpi)
				If xdpi > 96 Then
					Return 2
				End If
			End If
		End If
		Return 1
	End Method

EndType

Type TWindowsWindow Extends TWindowsGadget

	Field	_wstyle, _xstyle
	Field	_minwidth,_minheight,_maxwidth = -1,_maxheight = -1
	Field	_menu:TWindowsMenu
	Field	_hmenu:Byte Ptr
	Field	_status:Byte Ptr

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	hwnd:Byte Ptr, parent:Byte Ptr, client:Byte Ptr
		Local classname$ = TWindowsGUIDriver.ClassName()

		Self.style = style
		_wstyle=WS_CLIPSIBLINGS|WS_CLIPCHILDREN
		If group Then parent = group.Query(QUERY_HWND)

		If (style&WINDOW_TITLEBAR)
			_wstyle:|WS_OVERLAPPED|WS_SYSMENU
			If style&WINDOW_RESIZABLE _wstyle:|WS_MINIMIZEBOX|WS_MAXIMIZEBOX
			If group <> TWindowsGUIDriver.GDIDesktop And Not (style&WINDOW_TOOL) Then
				classname$ = TWindowsGUIDriver.DialogClassName()
				_xstyle:|WS_EX_DLGMODALFRAME
			EndIf
		Else
			_wstyle:|WS_POPUP
		EndIf

		If style&WINDOW_RESIZABLE Then _wstyle:|WS_SIZEBOX
		If style&WINDOW_MENU Then
			_hmenu=CreateMenu_()
			AppendMenuW( _hmenu,MF_STRING,Null,_wstrEmpty )
		End If
		If style&WINDOW_TOOL Then _xstyle:|WS_EX_TOOLWINDOW

		' Note: No WINDOW_HIDDEN case as gadgets are always created hidden to hide initial resize flicker.
		' TWindowsGUIDriver.CreateGadget() will later show window if WINDOW_HIDDEN is not specified.

		hwnd=CreateWindowExW(_xstyle,classname,"",_wstyle,0,0,0,0,parent,_hmenu,GetModuleHandleW(Null),Null)

		If style&WINDOW_STATUS
			_status=CreateWindowExW(0,"msctls_statusbar32","",WS_CHILD|WS_VISIBLE,0,0,0,0,hwnd,Null,GetModuleHandleW(Null),Null)
			SetWindowPos( _status, Byte Ptr(HWND_TOPMOST),0,0,0,0,SWP_NOACTIVATE|SWP_NOMOVE|SWP_NOOWNERZORDER|SWP_NOSIZE)
		EndIf

		client=CreateWindowExW(0,TWindowsGUIDriver.ClassName(),"",WS_CHILD|WS_VISIBLE|WS_CLIPCHILDREN|WS_CLIPSIBLINGS,0,0,0,0,hwnd,Null,GetModuleHandleW(Null),Null)

		Register GADGET_WINDOW,hwnd,client,False

		If style&WINDOW_ACCEPTFILES Then DragAcceptFiles _hwnd,True
		_wstyle = GetWindowLongW( hwnd, GWL_STYLE )

		Return Self
	EndMethod

	Method SetAlpha( alpha# )
		Local tmpStyle% = GetWindowLongW(_hwnd, GWL_EXSTYLE)
		If alpha = 1.0 Then
			SetLayeredWindowAttributes( _hwnd, 0, Byte(alpha*255), LWA_ALPHA)
			If (tmpStyle & WS_EX_LAYERED) Then SetWindowLongW(_hwnd, GWL_EXSTYLE, tmpStyle&~WS_EX_LAYERED)
		Else
			If Not (tmpStyle & WS_EX_LAYERED) Then SetWindowLongW(_hwnd, GWL_EXSTYLE, tmpStyle|WS_EX_LAYERED)
			SetLayeredWindowAttributes( _hwnd, 0, Byte(alpha*255), LWA_ALPHA)
		EndIf
		RedrawGadget(Self)
	EndMethod

	Method Rethink()
		Local dimensions[] = [xpos,ypos,width,height]
		ConvertToContainerDimensions( dimensions[0], dimensions[1], dimensions[2], dimensions[3] )
		MoveWindow _hwnd, dimensions[0], dimensions[1], dimensions[2], dimensions[3], True
		RethinkClient(True)
	EndMethod

	Method RethinkClient(forceRedraw:Int = False)
		If _hwndClient Then
			MoveWindow _hwndClient, _clientx,_clienty,ClientWidth(),ClientHeight(),forceRedraw
		EndIf
		LayoutKids()
	EndMethod


	Method ClientWidth()
		If (style & WINDOW_CLIENTCOORDS) Then Return width
		Local Rect:Int[4]
		GetClientRect _hwnd, Rect
		Return Max(Rect[2]-Rect[0]-_clientX,0)
	EndMethod

	Method ClientHeight()
		If (style & WINDOW_CLIENTCOORDS) Then Return height
		Local h:Int = height, Rect:Int[] = [0,0,width,height]
		Local menu:Int = _hMenu <> Null
		AdjustWindowRectEx(Rect,GetWindowLongW(_hwnd, GWL_STYLE),menu,GetWindowLongW(_hwnd, GWL_EXSTYLE))
		h:-(Rect[3]-Rect[1]+_clientY-height)
		If _status Then GetWindowRect _status,Rect;h:-(Rect[3]-Rect[1])
		Return Max(h,0)
	End Method

	Method Class()
		Return GADGET_WINDOW
	EndMethod

	Method State()
		Local t = Super.State()
		If IsIconic(_hwnd) t:|STATE_MINIMIZED
		If IsZoomed(_hwnd) t:|STATE_MAXIMIZED
		Return t
	EndMethod

	Method SetEnabled(enable)
		_enabled = enable
		EnableWindow(_hwnd,enable)
	EndMethod

	Method SetMinimumSize(w,h)
		'Set minimum size for current window style
		_minwidth=w;_minheight=h
		'Get window style
		Local tmpWStyle% = GetWindowLongW( _hwnd, GWL_STYLE )
		'Update size border
		If (_maxwidth = _minwidth And _maxheight = _minheight) Then tmpWStyle:&~WS_SIZEBOX ElseIf (style&WINDOW_RESIZABLE) Then tmpWStyle:|WS_SIZEBOX
		'Set new window style if necessary
		If tmpWStyle <> GetWindowLongW( _hwnd, GWL_STYLE ) Then
			SetWindowLongW( _hwnd, GWL_STYLE, tmpWStyle )
			Rethink()
			SetWindowPos( _hwnd, Null, 0, 0, 0, 0, SWP_DRAWFRAME|SWP_FRAMECHANGED|SWP_NOACTIVATE|SWP_NOMOVE|SWP_NOOWNERZORDER|SWP_NOZORDER|SWP_NOSIZE )
		EndIf
	EndMethod

	Method SetMaximumSize(w,h)
		'Set maximum size for current window style
		_maxwidth=w;_maxheight=h
		'Get window style
		Local tmpWStyle% = GetWindowLongW( _hwnd, GWL_STYLE )&~WS_MAXIMIZEBOX
		'Update size border
		If (_maxwidth = _minwidth And _maxheight = _minheight) Then tmpWStyle:&~WS_SIZEBOX ElseIf (style&WINDOW_RESIZABLE) Then tmpWStyle:|WS_SIZEBOX
		'Set new window style if necessary
		If tmpWStyle <> GetWindowLongW( _hwnd, GWL_STYLE ) Then
			SetWindowLongW( _hwnd, GWL_STYLE, tmpWStyle )
			Rethink()
			SetWindowPos( _hwnd, Null, 0, 0, 0, 0, SWP_DRAWFRAME|SWP_FRAMECHANGED|SWP_NOACTIVATE|SWP_NOMOVE|SWP_NOOWNERZORDER|SWP_NOZORDER|SWP_NOSIZE )
		EndIf
	EndMethod

	Method GetMenu:TGadget()
		If Not _menu Then
			_menu = New TWindowsMenu.Create(Null,0,"")
			_menu._setParent Self
		EndIf
		Return _menu
	EndMethod

	Method UpdateMenu()

		Local hmenu:Byte Ptr, oldMenu:Byte Ptr
		If _menu
			_menu.FreeKids
			_menu.Open
			hmenu=_menu._hmenu
		EndIf

		oldMenu = GetMenu_( _hwnd )
		SetMenu _hwnd,hmenu
		DrawMenuBar _hwnd
		DestroyMenu oldMenu

	EndMethod

	Field _statustext$

	Method GetStatusText$()
		If _status
			Return _statustext
		EndIf
	EndMethod

	Method SetStatusText(Text$)
		If _status
			_statustext = Text
			If (style&WINDOW_RESIZABLE) Then Text:+"     "	'Cludge for size handle obfuscation
			Local tmpWString:Short Ptr = Text.ToWString()
			SendMessageW _status,WM_SETTEXT,0,LParam(tmpWString)
			MemFree tmpWString
		EndIf
	EndMethod

	Field popupextra:Object

	Method PopupMenu(menu:TGadget,extra:Object)
		Local pt[2], wmenu:TWindowsMenu = TWindowsMenu(menu), tmpLink:TLink
		If wmenu

			GetCursorPos_ pt
			popupextra = extra
			wmenu.Open(True)

			Local hmenu:Int = TrackPopupMenu( wmenu._hmenu,TPM_LEFTALIGN|TPM_TOPALIGN|TPM_RETURNCMD|TPM_NONOTIFY,pt[0],pt[1],0,_hwnd,0 )
			If hmenu Then HandleMenuEvent( WM_COMMAND, ULong(hmenu))

			wmenu.Close()
			popupextra = Null

		EndIf
	EndMethod

	Function EnumChildProc(hwnd:Byte Ptr,lp:Byte Ptr) "win32"
		Local winfo:WINDOWINFO = New WINDOWINFO
		'winfo.cbSize=SizeOf winfo
		GetWindowInfo hwnd,winfo.infoPtr
		If winfo.dwStyle()&WS_TABSTOP
			_firsttab=hwnd
		Else
			EnumChildWindows hwnd,EnumChildProc,0
		EndIf
		If _firsttab Return 0
		Return 1
	EndFunction

	Global _firsttab:Byte Ptr

	Method Activate(cmd)
		Select cmd
			Case ACTIVATE_FOCUS
				_firsttab=0
				EnumChildWindows _hwnd,EnumChildProc,0
				If Not _firsttab _firsttab=_hwnd
				SetFocus _firsttab
			Case ACTIVATE_MINIMIZE
				ShowWindow _hwnd,SW_MINIMIZE
			Case ACTIVATE_MAXIMIZE
				ShowWindow _hwnd,SW_MAXIMIZE
			Case ACTIVATE_RESTORE
				ShowWindow _hwnd,SW_RESTORE
			Case ACTIVATE_REDRAW
				RefreshLook()
				Return RedrawWindow( _hwnd, Null, Null, RDW_INVALIDATE | RDW_UPDATENOW | RDW_ERASE | RDW_FRAME | RDW_ALLCHILDREN )
		End Select
	EndMethod

	Method OnCommand(msg,wp:ULong)
		If wp>100 Then HandleMenuEvent(msg,wp)
	EndMethod

	Method HandleMenuEvent( msg, wp:ULong )
		Local tmpMenuSource:TWindowsMenu = TWindowsMenu.GetMenuFromKey(Int(wp)), tmpMenuID
		If tmpMenuSource Then tmpMenuID = tmpMenuSource._tag

		Local tmpPopupExtra:Object = popupextra
		popupextra = Null

		MaxGUI.MaxGUI.PostGuiEvent EVENT_MENUACTION,tmpMenuSource,tmpMenuID,0,0,0,tmpPopupExtra

	EndMethod

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
		Local x,y,w,h
		Local move,size
		Local Rect[4]
		Local winrect[4]

		Select msg

			Case WM_ERASEBKGND
				If BgBrush() Then
					Local Rect[4]
					If Not GetUpdateRect( hwnd, Rect, False ) Then GetClipBox( Byte Ptr wp, Rect )
					FillRect( Byte Ptr wp, Rect, BgBrush() )
					Return 1
				EndIf

			Case WM_SIZE

				If (hwnd = _hwnd) And (wp <> SIZE_MINIMIZED) Then

					If _status Then SendMessageW _status,WM_SIZE,0,0

					If (style & WINDOW_CLIENTCOORDS) Then
						GetClientRect _hwnd,Rect
						w=Rect[2]
						h=Rect[3]
						If _hmenu Then
							AdjustWindowRectEx(Rect,GetWindowLongW(_hwnd, GWL_STYLE),True,GetWindowLongW(_hwnd, GWL_EXSTYLE))
						Else
							AdjustWindowRectEx(Rect,GetWindowLongW(_hwnd, GWL_STYLE),False,GetWindowLongW(_hwnd, GWL_EXSTYLE))
						End If
						x=-Rect[0]
						y=-Rect[1]
						GetWindowRect _hwnd,Rect
						x:+Rect[0]
						y:+Rect[1]
						If _status Then
							GetWindowRect _status,Rect
							h:-(Rect[3]-Rect[1])
						EndIf
						x:+_clientX;y:+_clientY
						w:-_clientX;h:-_clientY
					Else
						GetWindowRect(_hwnd,Rect)
						x=Rect[0];y=Rect[1]
						w=Rect[2]-Rect[0]
						h=Rect[3]-Rect[1]
					EndIf

					If x<>xpos Or y<>ypos Then move = True
					If w<>width Or h<>height Then size = True

					SetRect x,y,w,h

					If size Then RethinkClient()

					If move PostGuiEvent EVENT_WINDOWMOVE,0,0,x,y
					If size PostGuiEvent EVENT_WINDOWSIZE,0,0,w,h

				EndIf

			Case WM_MOVE
				If (hwnd = _hwnd) And Not (IsZoomed(hwnd) Or IsIconic(hwnd)) Then

					If (style & WINDOW_CLIENTCOORDS) Then
						GetClientRect _hwnd,Rect
						w=Rect[2]
						h=Rect[3]
						If _hmenu Then
							AdjustWindowRectEx(Rect,GetWindowLongW(_hwnd, GWL_STYLE),True,GetWindowLongW(_hwnd, GWL_EXSTYLE))
						Else
							AdjustWindowRectEx(Rect,GetWindowLongW(_hwnd, GWL_STYLE),False,GetWindowLongW(_hwnd, GWL_EXSTYLE))
						End If
						x=-Rect[0]
						y=-Rect[1]
						GetWindowRect _hwnd,Rect
						x:+Rect[0]+_clientX
						y:+Rect[1]+_clientY
					Else
						GetWindowRect(_hwnd,Rect)
						x=Rect[0];y=Rect[1]
						w=Rect[2]-Rect[0]
						h=Rect[3]-Rect[1]
					EndIf

					If x<>xpos Or y<>ypos Then
						SetRect x,y,width,height
						PostGuiEvent EVENT_WINDOWMOVE,0,0,x,y
					EndIf

				EndIf

			Case WM_GETMINMAXINFO
				If hwnd = _hwnd And lp Then

					Local minmax:MINMAXINFO = MINMAXINFO._create(Byte Ptr lp)
					Local tmpZero% = 0

					Local mw:Int = _minwidth
					Local mh:Int = _minheight

					ConvertToContainerDimensions(tmpZero,tmpZero,mw,mh)

					minmax.SetminTrackSizeX(mw)
					minmax.SetminTrackSizeY(mh)

					If (_maxwidth >= _minwidth) And (_maxheight >= _minheight) Then
						mw = _maxwidth
						mh = _maxheight
						ConvertToContainerDimensions(tmpZero,tmpZero,mw,mh)

						minmax.SetmaxTrackSizeX(mw)
						minmax.SetmaxTrackSizeY(mh)
					EndIf

				EndIf

			Case WM_ACTIVATE
				If (wp = WA_ACTIVE) Or (wp = WA_CLICKACTIVE) Then
					TWindowsGUIDriver._ActiveWindow = Self
					PostGuiEvent EVENT_WINDOWACTIVATE
				EndIf

			Case WM_COMMAND
				If wp>100 Then HandleMenuEvent(msg,ULong(wp))

			Case WM_CLOSE
				PostGuiEvent EVENT_WINDOWCLOSE
				Return 1

			Case WM_QUERYENDSESSION ' system shutdown or restart
				PostGuiEvent EVENT_APPTERMINATE
				Return 1

			Case WM_DROPFILES
				Local hdrop:Byte Ptr,pt[2],path$
				Local pbuffer:Short[MAX_PATH]
				Local i,n,l
				DragQueryPoint Byte Ptr wp,pt
				n=DragQueryFileW(Byte Ptr wp,$ffffffff:UInt,Null,0)
				For i=0 Until n
					l=DragQueryFileW(Byte Ptr wp,UInt(i),pbuffer,MAX_PATH)
					path=String.FromShorts(pbuffer,l)
					PostGuiEvent EVENT_WINDOWACCEPT,0,0,pt[0],pt[1],path
				Next
				DragFinish Byte Ptr wp
			Case WM_SYSCOMMAND
				' suppress F10 KEYMENU when window has no menu
				If wp = $F100 And Not (style&WINDOW_MENU) Then ' SC_KEYMENU
					Return 0
				End If
				
		End Select

		Return Super.WndProc(hwnd,msg,wp,lp)

	EndMethod

	Method DoLayout()
		'Don't do anything!
	EndMethod

	Method SetTooltip( pTooltip$ )
		'Windows shouldn't have tool-tips!
	EndMethod

	Method SetSensitivity(flags)
		'Problems with resizing/moving sensitive windows.
		Super.SetSensitivity(flags&~SENSITIZE_MOUSE)
		'Easy to create an active panel in client area as a work around.
	EndMethod

	Method SetPixmap(pPixmap:TPixmap, pFlags)
		If Not (pFlags & GADGETPIXMAP_ICON) Then Return False
		If _iconBitmap Then
			DestroyIcon(_iconBitmap)
			_iconBitmap = 0
		End If
		If pPixmap Then _iconBitmap = TWindowsGraphic.IconFromPixmap32( pPixmap )
		SendMessageW (_hwnd, WM_SETICON, 0, LParam(_iconBitmap))
		SendMessageW (_hwnd, WM_SETICON, 1, LParam(_iconBitmap))
		Return True
	EndMethod

	' Needed otherwise SetEnabled() locks if modal child window is opened and parent is disabled.
	Method isControl()
		Return False
	EndMethod

	Method ConvertToContainerDimensions%( pX Var, pY Var, pW Var , pH Var )

		If Not (style & WINDOW_CLIENTCOORDS) Then Return 0

		Local Rect[4], menu_:Byte Ptr = GetMenu_(_hwnd), menu

		If menu_ Then menu = True
		If _status Then
			GetWindowRect _status,Rect
			pH:+(Rect[3]-Rect[1])
		End If
		pW:+_clientX;pH:+_clientY;pX:-_clientX;pY:-_clientY

		Rect = [pX,pY,pX+pW,pY+pH]
		AdjustWindowRectEx Rect,GetWindowLongW(_hwnd, GWL_STYLE),menu,GetWindowLongW(_hwnd, GWL_EXSTYLE)

		pX = Rect[0];pY = Rect[1];pW = Rect[2]-Rect[0];pH = Rect[3]-Rect[1]

		Return 1

	EndMethod

	Method FlushBrushes(pRecurse:Int = True)
		Super.FlushBrushes()
		If Not pRecurse Then Return
		For Local tmpGadget:TWindowsGadget = EachIn kids
			tmpGadget.FlushBrushes()
		Next
	EndMethod

End Type

Type TButtonImageList
	Field buttonImageListPtr:Byte Ptr
	Field hasImageList:Int

	Method New()
		buttonImageListPtr = bmx_win32_BUTTON_IMAGELIST_new()
	End Method

	Method Delete()
		If buttonImageListPtr Then
			If hasImageList Then

			End If
			bmx_win32_BUTTON_IMAGELIST_free(buttonImageListPtr)
			buttonImageListPtr = Null
		End If
	End Method

	Method Sethiml(himl:Byte Ptr)
		bmx_win32_BUTTON_IMAGELIST_Sethiml(buttonImageListPtr, himl)
		hasImageList = True
	End Method

	Method SetuAlign(uAlign:UInt)
		bmx_win32_BUTTON_IMAGELIST_SetuAlign(buttonImageListPtr, uAlign)
	End Method

	Method himl:Byte Ptr()
		Return bmx_win32_BUTTON_IMAGELIST_himl(buttonImageListPtr)
	End Method

	Method Destroyhiml()
		ImageList_Destroy(himl())
		hasImageList = False
	End Method

End Type

Type TWindowsButton Extends TWindowsGadget

	'Field _buttonImageList[] = [-1,0,0,0,0,0]
	Field _buttonImageList:TButtonImageList = New TButtonImageList
	Field _strButtonText$, _mouseoverbutton

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	xstyle,wstyle,hotkey
		Local	hwnd:Byte Ptr,parent:Byte Ptr
		Self.style = style
		wstyle=WS_CHILD|WS_TABSTOP|WS_CLIPSIBLINGS|BS_MULTILINE
		Select style&7
			Case 0
				wstyle:|BS_PUSHBUTTON
				style = BUTTON_PUSH
			Case BUTTON_CHECKBOX
				wstyle:|BS_3STATE
				If (style&BUTTON_PUSH) Then wstyle:|BS_PUSHLIKE
			Case BUTTON_RADIO
				wstyle:|BS_AUTORADIOBUTTON
				If (style&BUTTON_PUSH) Then wstyle:|BS_PUSHLIKE
			Case BUTTON_OK
				wstyle:|BS_DEFPUSHBUTTON
				hotkey=IDOK
			Case BUTTON_CANCEL
				wstyle:|BS_PUSHBUTTON
				hotkey=IDCANCEL
		End Select
		parent=group.query(QUERY_HWND_CLIENT)
		hwnd=CreateWindowExW(xstyle,"BUTTON","",wstyle,0,0,0,0,parent,Byte Ptr(hotkey),GetModuleHandleW(Null),Null)
		Register GADGET_BUTTON,hwnd
		Return Self
	EndMethod

	Method SetTextColor(r,g,b)
		If Not (style&7) Then
			SetWindowLongW(_hwnd,GWL_STYLE,GetWindowLongW(_hwnd,GWL_STYLE)|BS_OWNERDRAW)
			If Not _hTheme Then _hTheme = TWindowsGUIDriver.GetThemeHandle( _hwnd, "Button" )
		ElseIf Not (style&BUTTON_PUSH) And ((style&7=BUTTON_CHECKBOX) Or (style&7=BUTTON_RADIO))
			SetWindowTheme(_hwnd,_wstrSpace,_wstrSpace)
		EndIf
		Super.SetTextColor(r,g,b)
	EndMethod

	Method SetColor(r,g,b)
		If Not (style&7) Then
			SetWindowLongW(_hwnd,GWL_STYLE,GetWindowLongW(_hwnd,GWL_STYLE)|BS_OWNERDRAW)
			If Not _hTheme Then _hTheme = TWindowsGUIDriver.GetThemeHandle( _hwnd, "Button" )
		EndIf
		Super.SetColor(r,g,b)
	EndMethod

	Method RemoveColor()
		If Not (style&7) Then
			SetWindowLongW(_hwnd,GWL_STYLE,GetWindowLongW(_hwnd,GWL_STYLE)&~BS_OWNERDRAW)
			_hTheme=0
		EndIf
		Super.RemoveColor()
	EndMethod

	Method State()
		Local t=Super.State()
		Select SendMessageW( _hwnd,BM_GETCHECK,0,0 )
			Case BST_CHECKED;t:|STATE_SELECTED
			Case BST_INDETERMINATE;t:|STATE_INDETERMINATE
		EndSelect
		Return t
	EndMethod

	Method SetSelected(bool)
		Local state:WParam = BST_UNCHECKED
		If bool Then
			If (style&7 = BUTTON_CHECKBOX) And (bool = CHECK_INDETERMINATE) Then
				state = BST_INDETERMINATE
			Else
				state = BST_CHECKED
			EndIf
		EndIf
		SendMessageW _hwnd,BM_SETCHECK,state,0
	EndMethod

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
		Select msg
			Case WM_THEMECHANGED
				If _hTheme Then
					TWindowsGUIDriver.CloseThemeHandle(_hTheme)
					_hTheme = TWindowsGUIDriver.GetThemeHandle(_hwnd,"BUTTON")
				EndIf
			Case WM_LBUTTONDBLCLK
				PostMessageW(_hwnd, WM_LBUTTONDOWN, wp, lp)
			Case WM_MOUSEMOVE
				If Not _mouseoverbutton Then
					_mouseoverbutton = True
					InvalidateRect(_hwnd,Null,False)

					Local tmpTrackMouseEvent:TRACKMOUSEEVENT = New TRACKMOUSEEVENT
					tmpTrackMouseEvent.SetdwFlags($2)
					tmpTrackMouseEvent.SethwndTrack(hwnd)

					_TrackMouseEvent( tmpTrackMouseEvent.eventPtr )
				EndIf
			Case WM_MOUSELEAVE
				If _mouseoverbutton Then
					_mouseoverbutton = False
					InvalidateRect(_hwnd,Null,False)
				EndIf
			Case WM_ERASEBKGND
				Return 1
		EndSelect

		Return Super.WndProc(hwnd,msg,wp,lp)

	EndMethod

	Method OnDrawItem(pDrawItemStruct:DRAWITEMSTRUCT)

		Local tmpDc:Byte Ptr = pDrawItemStruct.hDc(), txtWidth%, txtHeight%
		Local tmpDcState = SaveDC(tmpDC)

		' button state
		Local tmpIsPressed = (pDrawItemStruct.ItemState() & ODS_SELECTED)
		Local tmpIsFocused  = (pDrawItemStruct.ItemState() & ODS_FOCUS)
		Local tmpIsDisabled = (pDrawItemStruct.ItemState() & ODS_DISABLED)
		Local tmpDrawFocusRect = Not (pDrawItemStruct.ItemState() & ODS_NOFOCUSRECT)

		Local itemRect:Int Ptr = pDrawItemStruct.rcItem(), txtRect:Int[4], clientRect:Int[4]

		Local tmpBgMode = SetBkMode(tmpDc, TRANSPARENT)

		' Prepare draw... paint button background

		If _hTheme Then

			Local tmpState = PBS_NORMAL
			If tmpIsDisabled Then
				tmpState = PBS_DISABLED
			ElseIf tmpIsPressed Then
				tmpState = PBS_PRESSED
			ElseIf _mouseoverbutton Then
				tmpState = PBS_HOT
			ElseIf tmpIsFocused Then
				tmpState = PBS_DEFAULTED
			EndIf

			If IsThemeBackgroundPartiallyTransparent(_hTheme, BP_PUSHBUTTON, tmpState) Then
				DrawThemeParentBackground( _hwnd, tmpDc, itemRect )
			EndIf
			DrawThemeBackground(_hTheme, tmpDc, BP_PUSHBUTTON, tmpState, itemRect, Null)
			GetThemeBackgroundContentRect(_hTheme, tmpDc, BP_PUSHBUTTON, tmpState, itemRect, clientRect)

		Else

			clientRect = [itemRect[0], itemRect[1], itemRect[2], itemRect[3]]
			InflateRect(clientRect, -GetSystemMetrics(SM_CXEDGE), -GetSystemMetrics(SM_CYEDGE))

			If tmpIsFocused Then

				Local tmpBr:Byte Ptr = CreateSolidBrush($000000)
				FrameRect(tmpDc, itemRect , tmpBr)
				InflateRect(itemRect, -1, -1)
				DeleteObject(tmpBr)

			EndIf

			Local crColor
			If BgColor() < 0 Then crColor = GetSysColor(COLOR_BTNFACE) Else crColor = BgColor()

			Local brBackground:Byte Ptr = CreateSolidBrush(crColor)

			FillRect(tmpDc, itemRect, brBackground)

			DeleteObject(brBackground)

			' Draw pressed button
			If tmpIsPressed

				Local brBtnShadow:Byte Ptr = CreateSolidBrush(GetSysColor(COLOR_BTNSHADOW))
				FrameRect(tmpDc, itemRect, brBtnShadow)
				DeleteObject(brBtnShadow)

				OffsetRect( clientRect, 1, 1 )

			Else ' ...Else draw non pressed button

				Local tmpUState = DFCS_BUTTONPUSH
				If _mouseoverbutton Then tmpUState :| DFCS_HOT
				If tmpIsPressed Then tmpUState :| DFCS_PUSHED

				DrawFrameControl(tmpDc, itemRect, DFC_BUTTON, tmpUState)

			EndIf

		EndIf

		If BgColor() > -1 Then
			Local brBackground:Byte Ptr = CreateSolidBrush(BgColor())
			FillRect(tmpDc, clientRect, brBackground)
			DeleteObject(brBackground)
		EndIf

		txtRect = clientRect[..]

		clientRect[RECT_RIGHT]:-clientRect[RECT_LEFT]
		clientRect[RECT_BOTTOM]:-clientRect[RECT_TOP]

		' Read the button's title
		Local tmpText$ = Super.GetText()

		' Draw the icon
		'DrawTheIcon(GetDlgItem(hDlg, IDC_OWNERDRAW_BTN), &dc, bHasTitle, &lpDIS.rcItem, &captionRect, bIsPressed, bIsDisabled)

		' Write the button title (if any)
		If tmpText Then

			Local tmpFlags = DT_CENTER|DT_WORDBREAK

			DrawTextW( tmpDc, tmpText, -1, txtRect, DT_CALCRECT|tmpFlags )

			txtWidth = txtRect[RECT_RIGHT]-txtRect[RECT_LEFT]
			txtHeight = txtRect[RECT_BOTTOM]-txtRect[RECT_TOP]

			txtRect[RECT_LEFT] = clientRect[RECT_LEFT] + (clientRect[RECT_RIGHT] - txtWidth)/2
			txtRect[RECT_TOP] = clientRect[RECT_TOP] + (clientRect[RECT_BOTTOM] - txtHeight)/2
			txtRect[RECT_RIGHT] = txtRect[RECT_LEFT] + txtWidth
			txtRect[RECT_BOTTOM] = txtRect[RECT_TOP] + txtHeight

			Local tmpTextColor
			If tmpIsDisabled Then
				tmpTextColor = GetSysColor(COLOR_GRAYTEXT)
			Else
				If FgColor() < 0 Then tmpTextColor = GetSysColor(COLOR_BTNTEXT) Else tmpTextColor = FgColor()
			EndIf
			tmpTextColor = SetTextColor_(tmpDc,tmpTextColor)

			DrawTextW( tmpDc, tmpText, -1, txtRect, tmpFlags )

			SetTextColor_(tmpDc,tmpTextColor)

		EndIf

		RestoreDC(tmpDc,tmpDcState)

		' Draw the focus rect
		If tmpIsFocused And tmpDrawFocusRect Then
			Local focusRect:Int[4]
			CopyRect(focusRect, itemRect)
			InflateRect(focusRect, -3, -3)
			SetMapMode(tmpDc, MM_TEXT)
			DrawFocusRect(tmpDc, focusRect)
		EndIf

		Return True
	EndMethod

	Method OnCommand(msg,wp:ULong)

		Select wp Shr 16
			Case BN_CLICKED
				Select (style&7)
					Case BUTTON_CHECKBOX
						Select State()&STATE_INDETERMINATE
							Case 0, STATE_INDETERMINATE
								SetSelected(True)
							Case STATE_SELECTED
								SetSelected(False)
						EndSelect
				EndSelect

				PostGuiEvent EVENT_GADGETACTION,ButtonState(Self)

				'Fix so that tooltips reappear on Windows XP
				Local tmpTooltip$ = GetTooltip()
				If tmpTooltip Then SetTooltip("");SetTooltip(tmpTooltip)

		EndSelect
	EndMethod

	Method SetPixmap(pixmap:TPixmap,pFlags)

		Local tmpWindowStyle = GetWindowLongW(_hwnd,GWL_STYLE)

		If (pFlags & GADGETPIXMAP_ICON) And (((style&BUTTON_PUSH)=BUTTON_PUSH) Or (style = BUTTON_CANCEL)) Then

			'To remove an image from a button, a handle-list of -1 should be passed.
			If _buttonImageList.hasImageList Then _buttonImageList.Destroyhiml()
			If pixmap Then _buttonImageList.Sethiml(BuildImageList( pixmap ))

			If (pFlags & GADGETPIXMAP_NOTEXT) Then
				_buttonImageList.SetuAlign(BUTTON_IMAGELIST_ALIGN_CENTER)
			Else
				_buttonImageList.SetuAlign(BUTTON_IMAGELIST_ALIGN_LEFT)
			EndIf

			'If running Windows XP/Vista, let's use BCM_SETIMAGELIST

			If Not SendMessageW (_hwnd, BCM_SETIMAGELIST, 0, LParam(_buttonImageList.buttonImageListPtr)) Then
			'Otherwise, if this fails we should use BM_SETIMAGE.

				If _buttonImageList.hasImageList Then _buttonImageList.Destroyhiml()

				If _iconBitmap Then DeleteObject(_iconBitmap);_iconBitmap = 0
				If pixmap Then _iconBitmap = TWindowsGraphic.BitmapFromPixmap( pixmap, True )

				SendMessageW (_hwnd, BM_SETIMAGE, IMAGE_BITMAP, LParam(_iconBitmap))

			EndIf

			'Show the text if there isn't a pixmap or if we haven't specified GADGETPIXMAP_NOTEXT.
			If (Not pixmap) Or Not(pFlags & GADGETPIXMAP_NOTEXT) Then
				tmpWindowStyle:&(~BS_BITMAP)

				'Text isn't hidden on XP image buttons regardless of whether BS_BITMAP is set
				'so we have to hack this in - they must have fixed it on Vista though as it works fine there.

				Super.SetText( GetText() )
			Else
				tmpWindowStyle:|BS_BITMAP

				'Text isn't hidden on XP image buttons regardless of whether BS_BITMAP is set
				'so we have to hack this in - they must have fixed it on Vista though as it works fine there.

				Super.SetText( "" )
			EndIf

			SetWindowLongW _hwnd,GWL_STYLE,tmpWindowStyle

			InvalidateRect _hwnd, Null, False

			Return True

		EndIf

	EndMethod

	Method SetText(pText$)
		Local oldText$ = _strButtonText
		_strButtonText = pText
		If (Not _buttonImageList.hasImageList  And Not _iconBitmap) Or (oldText = Super.GetText()) Then Super.SetText(pText)
	EndMethod

	Method GetText$()
		Return _strButtonText
	EndMethod

	Method Free()
		If _buttonImageList.hasImageList Then _buttonImageList.Destroyhiml()
		If _iconBitmap Then DestroyIcon( _iconBitmap );_iconBitmap = 0
		_buttonImageList = Null
		Super.Free()
	EndMethod

	Function BuildImageList:Byte Ptr(pixmap:TPixmap)

		Local bitmap:Byte Ptr,imagelist:Byte Ptr,mask:Byte Ptr
		If TWindowsGUIDriver.CheckCommonControlVersion() And (Pixmap.format=PF_RGBA8888 Or pixmap.format=PF_BGRA8888)
			imagelist=ImageList_Create(pixmap.width,pixmap.height,ILC_COLOR32,0,1)
			If imagelist
				bitmap=TWindowsGraphic.BitmapFromPixmap(pixmap, True)
				ImageList_Add(imagelist,bitmap,Null)
			EndIf
		EndIf
		If imagelist=0
			bitmap=TWindowsGraphic.BitmapFromPixmap(pixmap, False)
			mask=TWindowsGraphic.BitmapMaskFromPixmap(pixmap)
			imagelist=ImageList_Create(pixmap.width,pixmap.height,ILC_COLOR24|ILC_MASK,0,1)
			ImageList_Add(imagelist,bitmap,mask)
			DeleteObject(mask)
		EndIf
		DeleteObject(bitmap)
		Return imagelist
	EndFunction

	Method Class()
		Return GADGET_BUTTON
	EndMethod

End Type

Type TWindowsMenu Extends TGadget
	Field	_hmenu:Byte Ptr
	Field	_pmenu:Byte Ptr
	Field	_item
	Field	_state
	Field	_tag
	Field	_hotkeycode
	Field	_modifier
	Field	_shortcut$
	Field	_hotkey:THotKey
	Field	_key:UInt = SetNewKey()
	Field _iconBitmap:Byte Ptr

	Global iteminfo:MENUITEMINFOW

	Global keymap:TIntMap=New TIntMap 'key,gadget
	Global keycount=100

	Method SetNewKey%()
		keycount:+1
		keymap.Insert( keycount, Self )
		Return keycount
	EndMethod

	Function GetMenuFromKey:TWindowsMenu(pKey%)
		Return TWindowsMenu(keymap.ValueForKey(pKey))
	EndFunction

	Method SetText(pText$)
		name = pText
	EndMethod

	Method GetText$()
		Return name
	EndMethod

	Method Free()
		Close
		_setparent Null
		keymap.Remove(_key)
		If _iconBitmap Then DeleteObject(_iconBitmap)
	EndMethod

	Method DoLayout()
		'Don't do anything!
	EndMethod

	Method State()
		Return _state
	EndMethod

	Method SetEnabled(enable)
		If enable
			If _pmenu EnableMenuItem(_pmenu,_item,MF_BYPOSITION|MF_ENABLED)
			_state:&~STATE_DISABLED
		Else
			If _pmenu EnableMenuItem(_pmenu,_item,MF_BYPOSITION|MF_GRAYED)
			_state:|STATE_DISABLED
		EndIf
	EndMethod

	Method SetSelected(bool)
		If bool
			If _pmenu CheckMenuItem(_pmenu,_item,MF_BYPOSITION|MF_CHECKED)
			_state:|STATE_SELECTED
		Else
			If _pmenu CheckMenuItem(_pmenu,_item,MF_BYPOSITION|MF_UNCHECKED)
			_state:&~STATE_SELECTED
		EndIf
	EndMethod

	Method SetHotKey(keycode,modifier)
		_hotkeycode=keycode
		_modifier=modifier

		Local	pre$, suf$, m$

		If LocalizationMode()&LOCALIZATION_ON Then
			pre="{{"
			suf="}}"
		EndIf

		If keycode>=KEY_0 And keycode<=KEY_9
			m$=Chr(keycode)
		ElseIf keycode>=KEY_A And keycode<=KEY_Z
			m$=Chr(keycode)
		ElseIf keycode>=KEY_F1 And keycode<=KEY_F12
			m$="F"+(keycode+1-KEY_F1)
		ElseIf keycode>=KEY_NUM0 And keycode<=KEY_NUM9
			m$="Num "+(keycode+1-KEY_NUM0)
		Else
			Select keycode
				Case KEY_BACKSPACE;m = pre+"Backspace"+suf
				Case KEY_TAB;m = pre+"Tab"+suf
				Case KEY_ESCAPE;m = pre+"Esc"+suf
				Case KEY_SPACE;m = pre+"Space"+suf
				Case KEY_ENTER;m = pre+"Enter"+suf
				Case KEY_PAGEUP;m = pre+"PageUp"+suf
				Case KEY_PAGEDOWN;m = pre+"PageDown"+suf
				Case KEY_END;m = pre+"End"+suf
				Case KEY_HOME;m = pre+"Home"+suf
				Case KEY_LEFT;m = pre+"Left"+suf
				Case KEY_RIGHT;m = pre+"Right"+suf
				Case KEY_UP;m = pre+"Up"+suf
				Case KEY_DOWN;m = pre+"Down"+suf
				Case KEY_INSERT;m = pre+"Insert"+suf
				Case KEY_DELETE;m = pre+"Delete"+suf
				Case KEY_TILDE;m = "~~"
				Case KEY_MINUS;m = "-"
				Case KEY_EQUALS;m = "="
				Case KEY_OPENBRACKET;m = "["
				Case KEY_CLOSEBRACKET;m = "]"
				Case KEY_BACKSLASH;m = "\"
				Case KEY_SEMICOLON;m = ";"
				Case KEY_QUOTES;m = "'"
				Case KEY_COMMA;m = ","
				Case KEY_PERIOD;m = "."
				Case KEY_SLASH;m = "/"
				Case KEY_NUMMULTIPLY;m = "Num *"
				Case KEY_NUMADD;m = "Num +"
				Case KEY_NUMSUBTRACT;m = "Num -"
				Case KEY_NUMDECIMAL;m = "Num ."
				Case KEY_NUMDIVIDE;m = "Num /"
			EndSelect
		EndIf

		If m
			If modifier&MODIFIER_SHIFT m$=pre+"Shift"+suf+"+"+m$
			If modifier&MODIFIER_CONTROL m$=pre+"Ctrl"+suf+"+"+m$
			If modifier&MODIFIER_ALT m$=pre+"Alt"+suf+"+"+m$
			m="~t"+m
		EndIf
		_shortcut$=LocalizeString(m)
		If Not iteminfo
			iteminfo=New MENUITEMINFOW
			'iteminfo.cbSize=SizeOf(iteminfo)
		EndIf
		iteminfo.SetfMask(MIIM_TYPE)
		iteminfo.SetdwTypeData((name+_shortcut).toWString())
		SetMenuItemInfoW _pmenu,_item,True,iteminfo.infoPtr

		MemFree iteminfo.dwTypeData()

		Local ev:TEvent=CreateEvent( EVENT_MENUACTION, Self,_tag)
		If _hotKey Then
			RemoveHotKey(_hotKey)
			_hotKey = Null
		End If
		If keycode Then _hotkey=SetHotKeyEvent(keycode,modifier,ev,FindGadgetWindowHwnd(Self))
	EndMethod

	Method Create:TWindowsMenu(group:TGadget,tag,Text$="")
		If Not iteminfo Then
			iteminfo=New MENUITEMINFOW
			'iteminfo.cbSize=SizeOf(iteminfo)
		EndIf
		name=Text
		_tag=tag
		Local window:TWindowsWindow = TWindowsWindow(group)
		If window group=window.GetMenu()
		_SetParent(group)
		If (LocalizationMode()&LOCALIZATION_OVERRIDE) Then
			LocalizeGadget(Self, name, "")
		EndIf
		Return Self
	EndMethod

	Method Open(popup=False)
		Local dad:TWindowsMenu	= TWindowsMenu(parent)

		If dad And Not popup
			_pmenu=dad._hmenu
			If Not _pmenu Throw "Parent doesn't have a handle - the desktop heap may have run out of memory!"
			_item=GetMenuItemCount(_pmenu)
			If name
				Local tmpWString:Short Ptr = (LocalizeString(name)+_shortcut).ToWString()
				AppendMenuW _pmenu,MF_STRING,_key,tmpWString
				MemFree tmpWString
			Else
				AppendMenuW _pmenu,MF_SEPARATOR,_key,Null
			EndIf
			If kids.count()
				_hmenu=CreateMenu_()
				Local tmpMenuInfo:MENUINFO = New MENUINFO

				tmpMenuInfo.SetfMask(MIM_APPLYTOSUBMENUS|MIM_STYLE)
				tmpMenuInfo.SetdwStyle(MNS_CHECKORBMP|MNS_MODELESS)
				SetMenuInfo(_hmenu, tmpMenuInfo.infoPtr)

				iteminfo.SetfMask(MIIM_SUBMENU)
				iteminfo.SethSubMenu(_hmenu)
				SetMenuItemInfoW _pmenu,_item,True,iteminfo.infoPtr
			EndIf

			If _state&STATE_DISABLED SetEnabled(False)
			If _state&STATE_SELECTED SetSelected(True)

			If _iconBitmap Then SetMenuItemBitmaps(_pMenu,_key,MF_BYCOMMAND,_iconBitmap,Null)
		Else
			If popup
				_hmenu=CreatePopupMenu()
			Else
				If kids _hmenu=CreateMenu_()
			EndIf
		EndIf

		For Local kid:TWindowsMenu = EachIn kids
			kid.Open
		Next

	EndMethod

	Method FreeKids()
		For Local kid:TWindowsMenu = EachIn kids
			kid.Close
		Next
	EndMethod

	Method Close()
		FreeKids()
		If _hmenu
			DestroyMenu _hmenu
			_hmenu=0
		EndIf
	EndMethod

	Method SetPixmap(pixmap:TPixmap,pFlags)
		If Not (pFlags & GADGETPIXMAP_ICON) Then Return
		If _iconBitmap Then DeleteObject(_iconBitmap);_iconBitmap = 0
		If pixmap Then
			pixmap = PixmapWindow(pixmap,0,0,Min(GetSystemMetrics(SM_CXMENUCHECK),PixmapWidth(pixmap)),Min(GetSystemMetrics(SM_CYMENUCHECK),PixmapHeight(pixmap)))
			If TWindowsGUIDriver.CheckCommonControlVersion() >= 2 Then
				_iconBitmap = TWindowsGraphic.PreMultipliedBitmapFromPixmap32( pixmap )
			Else
				Local tmpRGB = GetSysColor(COLOR_MENU)
				_iconBitmap = TWindowsGraphic.BitmapWithBackgroundFromPixmap32( pixmap, tmpRGB&$FF, (tmpRGB Shr 8) & $FF, (tmpRGB Shr 16) & $FF )
			EndIf
		EndIf

	EndMethod

	Method SetTooltip( pTooltip$ )
		'Menus shouldn't have tool-tips.
	EndMethod

	Method Class()
		Return GADGET_MENUITEM
	EndMethod

End Type

Type TWindowsListBox Extends TWindowsGadget

	Field _icons:TWindowsIconStrip
	Field _selected = -1

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	xstyle,wstyle,hotkey
		Local	hwnd:Byte Ptr,parent:Byte Ptr

		Self.style = style

		xstyle=WS_EX_CLIENTEDGE
		wstyle=WS_CHILD|WS_TABSTOP|LVS_REPORT|LVS_NOCOLUMNHEADER|LVS_SHOWSELALWAYS|LVS_SHAREIMAGELISTS
		wstyle:|WS_CLIPSIBLINGS

		If (style&LISTBOX_MULTISELECT<>LISTBOX_MULTISELECT) Then wstyle:|LVS_SINGLESEL

		parent=group.query(QUERY_HWND_CLIENT)
		hwnd=CreateWindowExW(xstyle,"SysListView32","",wstyle,0,0,20,20,parent,Byte Ptr(hotkey),GetModuleHandleW(Null),Null)

		Local column:LVCOLUMNW = New LVCOLUMNW
		SendMessageW hwnd,LVM_INSERTCOLUMNW,0,LParam(column.colPtr)

		SendMessageW hwnd,LVM_SETEXTENDEDLISTVIEWSTYLE,LVS_EX_FULLROWSELECT|LVS_EX_INFOTIP,LVS_EX_FULLROWSELECT|LVS_EX_INFOTIP

		If TWindowsGUIDriver.CheckCommonControlVersion() Then SendMessageW hwnd,LVM_SETEXTENDEDLISTVIEWSTYLE,LVS_EX_DOUBLEBUFFER,LVS_EX_DOUBLEBUFFER

		Register GADGET_LISTBOX,hwnd,Null,False	'Set to True for normal Tooltips

		If TWindowsGUIDriver._explorerstyle Then UseExplorerTheme()

		Return Self
	EndMethod

	Method SetColor(r,g,b)
		SendMessageW _hwnd,LVM_SETBKCOLOR ,0,(b Shl 16)|(g Shl 8)|r
		SendMessageW _hwnd,LVM_SETTEXTBKCOLOR ,0,(b Shl 16)|(g Shl 8)|r
	EndMethod

	Method RemoveColor()
		SendMessageW _hwnd,LVM_SETBKCOLOR ,1,0
		SendMessageW _hwnd,LVM_SETTEXTBKCOLOR ,1,0
	EndMethod

	Method SetTextColor(r,g,b)
		SendMessageW _hwnd,LVM_SETTEXTCOLOR,0,(b Shl 16)|(g Shl 8)|r
	EndMethod

	'Hack: When image lists are removed from listviews, the items don't
	'reposition themselves automatically. Hack involves first setting a tiny
	'blank image-list to update item size, before attempting to remove it.
	Method SetIconStrip(iconstrip:TIconStrip)
		Local imagelist:Byte Ptr
		If Not iconstrip Then
			_icons = TWindowsIconStrip.CreateBlank()
		Else
			_icons = TWindowsIconStrip(iconstrip)
		EndIf
		If _icons Then imagelist = _icons._imagelist

		SendMessageW _hwnd,LVM_SETIMAGELIST,LVSIL_SMALL,LParam(imagelist)
		If Not iconstrip Then
			SendMessageW _hwnd,LVM_SETIMAGELIST,LVSIL_SMALL,0
			_icons = Null
		EndIf
	EndMethod

	Method ClearListItems()
		_selected=-1
		DeSensitize()
		SendMessageW _hwnd,LVM_DELETEALLITEMS,0,0
		If Not IsSingleSelect() Then SelectionChanged()
		Sensitize()
	EndMethod

	Method InsertListItem(index,Text$,tip$,icon,tag:Object)
		Local it:LVITEMW = New LVITEMW
		it.Setmask(LVIF_TEXT|LVIF_DI_SETITEM)
		it.SetiItem(index)
		it.SetpszText(Text.toWString())

		If icon>=0 Then
			it.Setmask(it.mask()|LVIF_IMAGE)
			it.SetiImage(icon)
		EndIf

		Desensitize()
		SendMessageW _hwnd,LVM_INSERTITEMW,0,LParam(it.itemPtr)
		'SendMessageW _hwnd,LVM_SETCOLUMNWIDTH,0,Byte Ptr(-2)
		If Not IsSingleSelect() Then SelectionChanged()
		Sensitize()
		MemFree it.pszText()
		
		SendMessageW _hwnd,LVM_SETCOLUMNWIDTH,0,LVSCW_AUTOSIZE_USEHEADER
	EndMethod

	Method SetListItem(index,Text$,tip$,icon,tag:Object)
		Local tmpReselect
		If ListItemState(index) & STATE_SELECTED Then tmpReselect = True
		RemoveListItem index
		InsertListItem index,Text,tip,icon,tag
		If tmpReselect Then SetItemState(index,STATE_SELECTED)
	EndMethod

	Method RemoveListItem(index)
		Desensitize()
		If ListItemState(index) & STATE_SELECTED Then _selected = -1
		SendMessageW _hwnd,LVM_DELETEITEM,WParam(index),0
		SendMessageW _hwnd,LVM_SETCOLUMNWIDTH,0,-2
		If Not IsSingleSelect() Then SelectionChanged()
		Sensitize()
	EndMethod

	Method SetListItemState(index,state)
		Local it:LVITEMW = New LVITEMW
		it.Setmask(LVIF_STATE)
		it.SetiItem(index)
		If state&STATE_SELECTED
			it.Setstate(LVIS_SELECTED)
			If IsSingleSelect() Then _selected=index
		ElseIf _selected=index
			_selected=-1
		EndIf
		it.SetstateMask(LVIS_SELECTED)
		Desensitize()
		SendMessageW _hwnd,LVM_SETITEMSTATE,WParam(index),LParam(it.itemPtr)
		If it.state() Then SendMessageW _hwnd,LVM_ENSUREVISIBLE,WParam(index),False
		If Not IsSingleSelect() Then SelectionChanged()
		Sensitize()
	EndMethod

	Method ListItemState(index)
		Local state = SendMessageW(_hwnd,LVM_GETITEMSTATE,WParam(index),LVIS_SELECTED)
		If state&LVIS_SELECTED Return STATE_SELECTED
	EndMethod

	Method SetTooltip( pTooltip$ )
		'ToolTips should be set on an item-by-item basis instead.
	EndMethod

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
		Select msg
			Case WM_MAXGUILISTREFRESH
				Local index

				If IsSingleSelect() Then
					index=SendMessageW(_hwnd,LVM_GETNEXTITEM,WParam(-1),LVNI_SELECTED)
				Else
					index = SelectionChanged()
				EndIf
				If index <> _selected Then
					If IsSingleSelect() Then _selected = index
					Local item:TGadgetItem = New TGadgetItem
					If index>=0 And index<items.length item=items[index]
					PostGuiEvent EVENT_GADGETSELECT,index,0,0,0,item.extra
				EndIf

			'If we are using XP Common Controls or higher, then the listbox will be double-buffered
			'and so we don't need to clear the background (performance tweak).
			Case WM_ERASEBKGND
				If TWindowsGUIDriver.CheckCommonControlVersion() Then Return 1
		EndSelect
		Return Super.WndProc(hwnd,msg,wp,lp)
	EndMethod

	Method OnNotify(wp:WParam,lp:LParam)
		Local nmhdrPtr:Byte Ptr = lp
		Local index, code = bmx_win32_NMHDR_code(nmhdrPtr)
		Select code

			Case LVN_GETINFOTIPW
				Local tmpItemIndex = bmx_win32_NMLVGETINFOTIPW_iItem(nmhdrPtr)
				Local tmpMaxCharCount = bmx_win32_NMLVGETINFOTIPW_cchTextMax(nmhdrPtr)-1
				Local tmpTipOutput:Short Ptr = bmx_win32_NMLVGETINFOTIPW_pszText(nmhdrPtr)

				If tmpItemIndex < items.length Then

					Local tmpTipString$ = items[tmpItemIndex].tip
					If (items[tmpItemIndex].flags&GADGETITEM_LOCALIZED) Then tmpTipString = LocalizeString(tmpTipString)

					tmpTipString = tmpTipString[..Min(tmpTipString.length,tmpMaxCharCount)]

					Local tmpBufferMem:Short Ptr = tmpTipString.ToWString()
					MemCopy tmpTipOutput, tmpBufferMem, Size_T((tmpTipString.length+1) * 2)
					MemFree tmpBufferMem

				EndIf

			Case LVN_ITEMCHANGED
				'We need to postpone processing until after *all* item states have been updated by the OS.
				If Not(bmx_win32_NMLISTVIEW_uChanged(nmhdrPtr)&LVIF_STATE) Then Return
				PostMessageW( _hwnd, WM_MAXGUILISTREFRESH, 0, 0 )
			Case NM_DBLCLK
				index=bmx_win32_NMITEMACTIVATE_iItem(nmhdrPtr)
				Local item:TGadgetItem
				If index>=0 And index<items.length
					item=items[index]
					PostGuiEvent EVENT_GADGETACTION,index,0,0,0,item.extra
				EndIf
			Case NM_CLICK
				index=bmx_win32_NMITEMACTIVATE_iItem(nmhdrPtr)
				If index=-1 And _selected<>-1
					_selected=-1
					PostGuiEvent EVENT_GADGETSELECT,-1
				EndIf
			Case NM_RCLICK
				index=bmx_win32_NMITEMACTIVATE_iItem(nmhdrPtr)
				Local item:TGadgetItem
				If index>=0 And index<items.length
					item=items[index]
					PostGuiEvent EVENT_GADGETMENU,index,0,0,0,item.extra
				EndIf
			'Return true to tell the OS not to send individual LVN_DELETEITEM notifications for each and every item when clearing list.
			Case LVN_DELETEALLITEMS
				Return True
		End Select
	EndMethod

	Method IsSingleSelect()
		Return (style&LISTBOX_MULTISELECT<>LISTBOX_MULTISELECT)
	EndMethod

	Method Class()
		Return GADGET_LISTBOX
	EndMethod

	Method HasResized()
		SendMessageW _hwnd,LVM_SETCOLUMNWIDTH,0,-2
	EndMethod

	Method UseExplorerTheme()
		If TWindowsGUIDriver.CheckCommonControlVersion() Then SetWindowTheme( _hwnd, _wstrExplorer, Null )
	EndMethod

EndType

Type TWindowsTabber Extends TWindowsGadget

	Field _icons:TWindowsIconStrip
	Field _tabcount
	Field _blank:Short Ptr
	Field _selected = -1
	Field _tipbuffer:Short Ptr
	Field _hittest:TCHITTESTINFO

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	xstyle,wstyle,hotkey
		Local	hwnd:Byte Ptr,parent:Byte Ptr,client:Byte Ptr
		Self.style = style
		xstyle=WS_EX_CONTROLPARENT
		wstyle=WS_CHILD|TCS_HOTTRACK|WS_TABSTOP|TCS_FOCUSNEVER|WS_CLIPCHILDREN|WS_CLIPSIBLINGS
		parent=group.query(QUERY_HWND_CLIENT)
		hwnd=CreateWindowExW(xstyle,"SysTabControl32","",wstyle,0,0,0,0,parent,Byte Ptr(hotkey),GetModuleHandleW(Null),Null)
		client=CreateWindowExW(xstyle,TWindowsGUIDriver.ClassName(),"",WS_CHILD|WS_VISIBLE|WS_CLIPSIBLINGS|WS_CLIPCHILDREN,0,0,0,0,hwnd,Null,GetModuleHandleW(Null),Null )
		SendMessageW hwnd,TCM_INSERTITEMW,0,LParam(_wstrSpace)
		Register GADGET_TABBER,hwnd,client,True
		SendMessageW _hwnd,TCM_SETTOOLTIPS,WParam(_tooltips),0
		Return Self
	EndMethod

	Method SetIconStrip(iconstrip:TIconStrip)
		Local imagelist:Byte Ptr
		_icons=TWindowsIconStrip(iconstrip)
		If _icons Then imagelist = _icons._imagelist
		SendMessageW _hwnd,TCM_SETIMAGELIST,0,LParam(imagelist)
		RethinkClient()
	EndMethod

	Method ClientWidth()
		Local Rect[] = [0,0,width,height]
		SendMessageW _hwnd,TCM_ADJUSTRECT,False,LParam Byte Ptr Rect
		If Rect[2]>Rect[0] Then Return Rect[2]-Rect[0]
	EndMethod

	Method ClientHeight()
		Local Rect[] = [0,0,width,height]
		SendMessageW _hwnd,TCM_ADJUSTRECT,False,LParam Byte Ptr Rect
		If Rect[3]>Rect[1] Then Return Rect[3]-Rect[1]
	EndMethod

	Method ClearListItems()
		_tabcount=0
		_selected=-1
		Desensitize()
		SendMessageW _hwnd,TCM_DELETEALLITEMS, 0, 0
		Sensitize()
		RethinkClient()
	EndMethod

	Method InsertListItem(index,Text$,tip$,icon,tag:Object)
		If _tabcount=0 SendMessageW _hwnd,TCM_DELETEALLITEMS,0,0
		Local t:TCITEMW=New TCITEMW
		t.Setmask(TCIF_TEXT|TCIF_IMAGE)
		t.SetpszText(Text.toWString())
		t.SetiImage(icon)
		Desensitize()
		SendMessageW _hwnd,TCM_INSERTITEMW,WParam(index),LParam(t.itemPtr)
		Sensitize()
		MemFree t.pszText()
		_tabcount:+1
		RethinkClient()
	EndMethod

	Method SetListItem(index,Text$,tip$,icon,tag:Object)
		Local t:TCITEMW=New TCITEMW
		t.Setmask(TCIF_TEXT|TCIF_IMAGE)
		t.SetpszText(Text.toWString())
		t.SetiImage(icon)
		Desensitize()
		SendMessageW _hwnd,TCM_SETITEMW,WParam(index),LParam(t.itemPtr)
		Sensitize()
		MemFree t.pszText()
		RethinkClient()
	EndMethod

	Method RemoveListItem(index)
		Desensitize()
		SendMessageW _hwnd,TCM_DELETEITEM,WParam(index),0
		_tabcount:-1
		_selected=SendMessageW(_hwnd,TCM_GETCURSEL,0,0)
		If _tabcount=0 SendMessageW _hwnd,TCM_INSERTITEMW,0,LParam(_blank)
		Sensitize()
		RethinkClient()
	EndMethod

	Method SetListItemState(index,state)
		Desensitize()
		If state&STATE_SELECTED
			_selected=index
			SendMessageW _hwnd,TCM_SETCURSEL,WParam(index),0
		ElseIf _selected=index
			_selected=-1
		EndIf
		Sensitize()
	EndMethod

	Method ListItemState(index)
		Local state,Current
		Current=-1
		If _tabcount Current=SendMessageW(_hwnd,TCM_GETCURSEL,0,0)
		If Current=index state:|STATE_SELECTED
		Return state
	EndMethod

	Method OnNotify(wp:WParam,lp:LParam)
		Local nmhdrPtr:Byte Ptr	'hwnd,id,code
		Local index
		nmhdrPtr=lp
		Select bmx_win32_NMHDR_code(nmhdrPtr)

			Case TTN_GETDISPINFOW

				'Local hittest:TCHITTESTINFO = New TCHITTESTINFO
				If Not _hittest Then
					_hittest = New TCHITTESTINFO
				End If

				Local Rect[4]

				GetCursorPos_( _hittest.pt() );GetWindowRect( _hwnd, Rect )
				'TCHITTESTINFO = [TCHITTESTINFO[0]-Rect[0],TCHITTESTINFO[1]-Rect[1],0]
				_hittest.Setx(_hittest.x() - Rect[0])
				_hittest.Sety(_hittest.y() - Rect[1])
				_hittest.Setflags(0)

				Local tmpItem = SendMessageW( _hwnd, TCM_HITTEST, 0, LParam(_hittest.infoPtr))

				If (tmpItem > -1) And (tmpItem < items.length) Then
					Local tmpTooltip$ = items[tmpItem].tip
					If (items[tmpItem].flags&GADGETITEM_LOCALIZED) Then tmpTooltip = LocalizeString(tmpTooltip)
					SetTipBuffer( tmpTooltip )
					If tmpTooltip Then bmx_win32_NMTTDISPINFOW_SetlpszText(nmhdrPtr, _tipbuffer)
				EndIf

			Case TCN_SELCHANGE
				If _tabcount
					index=SendMessageW(_hwnd,TCM_GETCURSEL,0,0)
					If index<>_selected
						Local extra:Object
						If index>=0 And index<items.length
							extra=items[index].extra
						Else
							index=-1
						EndIf
						_selected=index

						PostGuiEvent EVENT_GADGETACTION,index,0,0,0,extra
					EndIf
				EndIf

			Case NM_RCLICK

				If Not _hittest Then
					_hittest = New TCHITTESTINFO
				End If
				Local Rect[4], extra:Object

				GetCursorPos_( _hittest.pt() );GetWindowRect( _hwnd, Rect )
				_hittest.Setx(_hittest.x() - Rect[0])
				_hittest.Sety(_hittest.y() - Rect[1])
				_hittest.Setflags(0)
'				TCHITTESTINFO = [TCHITTESTINFO[0]-Rect[0],TCHITTESTINFO[1]-Rect[1],0]

				Local index = SendMessageW( _hwnd, TCM_HITTEST, 0, LParam(_hittest.infoPtr))
				If (index < 0) Or (index >= items.length) Then
					index = -1
				Else
					extra = items[index].extra
				End If

				PostGuiEvent EVENT_GADGETMENU,index,0,_hittest.x(),_hittest.y(),extra

		EndSelect
	EndMethod

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
		Select msg
			Case WM_ERASEBKGND
				Select hwnd
					Case _hwndclient
						DrawParentBackground(Byte Ptr wp,hwnd)
						Return 1
				EndSelect
		End Select
		Return Super.WndProc(hwnd,msg,wp,lp)
	EndMethod

	Method RethinkClient(forceRedraw:Int = False)
		Local Rect[] = [0,0,width,height]
		SendMessageW _hwnd,TCM_ADJUSTRECT,False, LParam(Byte Ptr(Rect))
		MoveWindow _hwndclient,Rect[RECT_LEFT],Rect[RECT_TOP],Rect[RECT_RIGHT]-Rect[RECT_LEFT],Rect[RECT_BOTTOM]-Rect[RECT_TOP],forceRedraw
	EndMethod

	Method SetTipBuffer( pTip$ )
		If _tipbuffer Then MemFree _tipbuffer
		If pTip Then
			_tipbuffer = pTip.ToWString()
		Else
			_tipbuffer = Null
		End If
	EndMethod

	Method SetTooltip( pTooltip$ )
		'ToolTips should be set on an item-by-item basis instead.
	EndMethod

	Method Class()
		Return GADGET_TABBER
	EndMethod

EndType

Type TWindowsToolbar Extends TWindowsGadget
	Field _icons:TWindowsIconStrip
	Field _disabledIcons:TWindowsIconStrip

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	xstyle,wstyle,hotkey
		Local	hwnd:Byte Ptr,parent:Byte Ptr
		Self.style = style
		xstyle=TBSTYLE_EX_DOUBLEBUFFER|TBSTYLE_EX_HIDECLIPPEDBUTTONS
		wstyle=TBSTYLE_FLAT|WS_CHILD|WS_CLIPSIBLINGS|TBSTYLE_TRANSPARENT
		Self.parent = group
		parent=Self.parent.query(QUERY_HWND)
		hwnd=CreateWindowExW(xstyle,"ToolbarWindow32","",wstyle,0,0,0,0,parent,Byte Ptr(hotkey),GetModuleHandleW(Null),Null)
		DragAcceptFiles(hwnd,False)	'For some reason, toolbars may accept files by default!
		Register GADGET_TOOLBAR,hwnd,Null,True
		SendMessageW _hwnd,TB_SETTOOLTIPS,WParam(_tooltips),0
		Rethink()
		Return Self
	EndMethod

	Method SetIconStrip(iconstrip:TIconStrip)
		_icons=TWindowsIconStrip(iconstrip)
		SendMessageW _hwnd,TB_SETIMAGELIST,0,LParam(_icons._imagelist)
		SendMessageW _hwnd,TB_AUTOSIZE,0,0
		Rethink
	EndMethod

	'Windows adds a gray border around the icons when they are disabled which can look pretty odd.
	'Use this method to grayscale/fade-out a given pixmap and assign the contained icons
	'as disabled icons.
	Method CreateDisabledIconStrip:TIconStrip(pixmap:TPixmap, saturation:Float = 0.1, alpha:Float = 0.4)
		If Not pixmap Then Return
		'work on a copy to avoid manipulating the original pixmap data
		Local disabledPixmap:TPixmap = pixmap.copy()
		'grayscale and fadeout each pixel
		For Local x:Int = 0 Until pixmap.width
			For Local y:Int = 0 Until pixmap.height
				Local c:Int = pixmap.ReadPixel(x,y)
				Local a:Int = (c Shr 24) & $ff
				Local r:Int = (c Shr 16) & $ff
				Local g:Int = (c Shr 8) & $ff
				Local b:Int = c & $ff
				'convert to grayscale
				Local luminance:Float = Sqr(0.299 * r*r + 0.587 * g*g + 0.114 * b*b)
				r = Min(255, Max(0, luminance + (r - luminance) * saturation))
				g = Min(255, Max(0, luminance + (g - luminance) * saturation))
				b = Min(255, Max(0, luminance + (b - luminance) * saturation))
				disabledPixmap.WritePixel(x,y, Int(a * alpha) * $1000000 + r * $10000 + g * $100 + b)
			Next
		Next
		Return LoadIconStrip(disabledPixmap)
	EndMethod

	Method CreateAndSetDisabledIconStrip:TIconStrip(pixmap:TPixmap, saturation:Float = 0.1, alpha:Float = 0.4)
		SetDisabledIconStrip( CreateDisabledIconStrip(pixmap, saturation, alpha) )
	EndMethod

	Method SetDisabledIconStrip(iconstrip:TIconStrip)
		_disabledIcons = TWindowsIconStrip(iconstrip)
		If _disabledIcons
			SendMessageW _hwnd,TB_SETDISABLEDIMAGELIST,0,LParam(_disabledIcons._imagelist)
			SendMessageW _hwnd,TB_AUTOSIZE,0,0
		EndIf
		Rethink
	EndMethod

	Method SetShow(truefalse)
		Super.SetShow(truefalse)
		UpdateWindowClient()
	EndMethod

	Method Free()
		SetShow(False)
		Super.Free()
	EndMethod

	Method Rethink()

		Local tmpRect[4]
		GetWindowRect _hwnd,tmpRect
		SetRect(0,0,parent.ClientWidth(),(tmpRect[3]-tmpRect[1]))
		QueueResize _hwnd,xpos,ypos,width,height
		UpdateWindowClient()

	EndMethod

	Method UpdateWindowClient()
		Local tmpHeight:Int = height
		If (State()&STATE_HIDDEN) Then tmpHeight = 0
		If TWindowsGadget(parent)._clientY <> tmpHeight Then
			TWindowsGadget(parent)._clientY = tmpHeight
			parent.Rethink()
			TWindowsGadget(parent).RethinkClient()
			parent.LayoutKids()
		EndIf
	EndMethod

	Method DoLayout()
		Rethink()
	EndMethod

	Method SetTooltip( pTooltip$ )
		'ToolTips should be set on an item-by-item basis instead.
	EndMethod

	Method ClearListItems()
		While SendMessageW(_hwnd,TB_BUTTONCOUNT,0,0)
			RemoveListItem(0)
		Wend
	EndMethod

	Method InsertListItem(index,Text$,tip$,icon,tag:Object)
		Local but:TBBUTTON = New TBBUTTON
		but.SetfsState(TBSTATE_ENABLED)
		If icon = -2 Or (icon>-1 And _icons.IsBlankIcon(icon))
			but.SetidCommand(0)
			but.SetfsStyle(TBSTYLE_SEP)
		Else
			but.SetiBitmap(icon)
			but.SetidCommand(index+1)
			but.SetfsStyle(TBSTYLE_BUTTON)
		EndIf
		Desensitize()
		SendMessageW _hwnd,TB_INSERTBUTTON,WParam(index),LParam(but.buttonPtr)
		Sensitize()
		If tip
			Local ti:TOOLINFOW=New TOOLINFOW
			'ti.cbSize=SizeOf(ti)
			ti.SetuFlags(TTF_SUBCLASS)
			ti.Sethwnd(_hwnd)
			ti.SetlpszText(tip.towstring())
			ti.SetuId(Byte Ptr(index+1))
			SendMessageW _hwnd,TB_GETITEMRECT,WParam(index),LParam(ti.rect())
			SendMessageW _tooltips,TTM_ADDTOOLW,0,LParam(ti.infoPtr)
			MemFree ti.lpszText()
		EndIf
	EndMethod

	Method SetListItem(index,Text$,tip$,icon,tag:Object)
		Local tmpState:Int = ListItemState(index)
		RemoveListItem index
		InsertListItem index,Text,tip,icon,tag
		SetListItemState(index,tmpState)
	EndMethod

	Method RemoveListItem(index)
		Local ti:TOOLINFOW=New TOOLINFOW
		'ti.cbSize=SizeOf(ti)
		ti.Sethwnd(_hwnd)
		ti.SetuId(Byte Ptr(index+1))
		Desensitize()
		SendMessageW _tooltips,TTM_DELTOOLW,0,LParam(ti.infoPtr)
		SendMessageW _hwnd,TB_DELETEBUTTON,WParam(index),0
		Sensitize()
	EndMethod

	Method SetListItemState(index,state)
		Local enable,pressed
		If state&STATE_DISABLED=0 enable=$1
		If state&STATE_SELECTED pressed=$1
		SendMessageW _hwnd,TB_ENABLEBUTTON,WParam(index+1),enable
		SendMessageW _hwnd,TB_CHECKBUTTON,WParam(index+1),pressed
		InvalidateRect _hwnd, Null, False
	EndMethod

	Method ListItemState(index)
		Local state,flags
		state=SendMessageW(_hwnd,TB_GETSTATE,WParam(index+1),0)
		If state=-1 Return 0
		If Not (state&TBSTATE_ENABLED) flags:|STATE_DISABLED
		If state&TBSTATE_CHECKED flags:|STATE_SELECTED
		Return flags
	EndMethod

	Method OnCommand(msg,wp:ULong)
		Local index=wp-1
		Local extra:Object
		If index>=0 And index<items.length extra=items[index].extra
		PostGuiEvent EVENT_GADGETACTION,index,0,0,0,extra
	EndMethod

	Method Class()
		Return GADGET_TOOLBAR
	EndMethod

EndType

Type TWindowsSlider Extends TWindowsGadget
	Field	_slidertype,_ishorizontal,_visible = 5,_total = 10,_value

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	xstyle,wstyle,class$
		Local	hwnd:Byte Ptr,parent:Byte Ptr,hotkey

		_slidertype=style&$fffc
		_ishorizontal=style&SLIDER_HORIZONTAL

		Self.style = style
		wstyle=WS_CHILD|WS_CLIPSIBLINGS|WS_CLIPCHILDREN
		parent=group.query(QUERY_HWND_CLIENT)
		Select _slidertype
			Case SLIDER_SCROLLBAR
				If _ishorizontal wstyle:|SBS_HORZ;Else wstyle:|SBS_VERT
				class$="SCROLLBAR"
			Case SLIDER_TRACKBAR
				wstyle:|TBS_AUTOTICKS|WS_TABSTOP
				xstyle:|WS_EX_COMPOSITED	'Reduces flicker when resizing (doesn't like scrollbars/up-down controls)
				If _ishorizontal wstyle:|TBS_HORZ Else wstyle:|TBS_VERT
				class$=TRACKBAR_CLASS
			Case SLIDER_STEPPER
				If _ishorizontal wstyle:|UDS_HORZ
				class$="msctls_updown32"
			Default
				Return Null
		End Select

		hwnd=CreateWindowExW(xstyle,class,"",wstyle,0,0,0,0,parent,Byte Ptr(hotkey),GetModuleHandleW(Null),Null)
		Register GADGET_SLIDER,hwnd
		RefreshLook()

		Return Self
	EndMethod

	Method SetRange(visible,total)
		_visible = visible
		_total = total
		Local tmpEnabled:Int = Not( State() & STATE_DISABLED )
		Desensitize()
		Select _slidertype
			Case SLIDER_SCROLLBAR
				Local info:SCROLLINFO=New SCROLLINFO
				'info.SecbSize=SizeOf(SCROLLINFO)
				info.SetfMask(SIF_PAGE|SIF_RANGE)
				info.SetnMax(total-1)
				info.SetnPage(UInt(visible))
				SendMessageW _hwnd,SBM_SETSCROLLINFO,True,LParam(info.infoPtr)
			Case SLIDER_TRACKBAR

				SendMessageW _hwnd,TBM_SETRANGEMIN,False,visible
				SendMessageW _hwnd,TBM_SETRANGEMAX,True,total

				' Aesthetic tweak that should stop black tick bands forming when
				' large ranges are used on small trackbars.

				Local tmpFirstTick% = SendMessageW( _hwnd, TBM_GETTICPOS, 0, 0 )
				Local tmpNumTicks% = SendMessageW( _hwnd, TBM_GETNUMTICS, 0, 0)
				Local tmpLastTick% = SendMessageW( _hwnd, TBM_GETTICPOS, WParam(tmpNumTicks-3), 0 )
				If Not( tmpLastTick < 0 Or tmpFirstTick < 0 Or (total-visible-2) < 1) Then
					If (tmpLastTick-tmpFirstTick)/(total-visible-2) < 4 Then
						SendMessageW( _hwnd, TBM_CLEARTICS, True, 0 )
					EndIf
				EndIf

			Case SLIDER_STEPPER
				SendMessageW _hwnd,UDM_SETRANGE32,WParam(visible),total
		End Select
		_value = GetProp()
		SetEnabled(tmpEnabled)
		Sensitize()
	EndMethod

	Method SetProp(value)
		Desensitize()
		Select _slidertype
			Case SLIDER_SCROLLBAR
				Local info:SCROLLINFO=New SCROLLINFO
				'info.cbSize=SizeOf(SCROLLINFO)
				info.SetfMask(SIF_POS)
				info.SetnPos(value)
				SendMessageW _hwnd,SBM_SETSCROLLINFO,True,LParam(info.infoPtr)
			Case SLIDER_TRACKBAR
				If _ishorizontal Then
					SendMessageW _hwnd,TBM_SETPOS,True,value
				Else
					'Flip the value so that the scale starts from the bottom
					SendMessageW _hwnd,TBM_SETPOS,True,_visible + _total - value
				EndIf
			Case SLIDER_STEPPER
				SendMessageW _hwnd,UDM_SETPOS,True,value
		End Select
		_value = value
		Sensitize()
	EndMethod

	Method GetProp()
		Local value
		Select _slidertype
			Case SLIDER_SCROLLBAR
				value=GetScrollPos(_hwnd,SB_CTL)
			Case SLIDER_TRACKBAR
				value=SendMessageW(_hwnd,TBM_GETPOS,0,0)
				'Flip the value so that the scale starts from the bottom
				If Not _ishorizontal Then value = _visible + _total - value
			Case SLIDER_STEPPER
				value=SendMessageW(_hwnd,UDM_GETPOS32,0,Null)
		End Select
		Return value
	EndMethod

	Method OnCommand(msg,wp:ULong)
		If _slidertype=SLIDER_SCROLLBAR
			If msg=WM_COMMAND Return
			Local info:SCROLLINFO=New SCROLLINFO
			'info.cbSize=SizeOf(SCROLLINFO)
			Select Long(wp)&$ffff
				Case SB_THUMBTRACK,SB_THUMBPOSITION
					info.SetfMask(SIF_TRACKPOS)
					SendMessageW _hwnd,SBM_GETSCROLLINFO,0,LParam(info.infoPtr)
					SetScrollPos _hwnd,SB_CTL,info.nTrackPos(),True
				Default
					info.SetfMask(SIF_POS|SIF_PAGE|SIF_RANGE)
					SendMessageW _hwnd,SBM_GETSCROLLINFO,0,LParam(info.infoPtr)
					Local pos=info.nPos()
					Local vis=info.nPage()
					Select Long(wp)&$ffff
						Case SB_LINEUP pos:-1
						Case SB_LINEDOWN pos:+1
						Case SB_PAGEUP pos:-vis
						Case SB_PAGEDOWN pos:+vis
						Default Return 0
					End Select
					SetScrollPos _hwnd,SB_CTL,pos,True
			End Select
		EndIf
		Local index=GetProp()
		If (index <> _value) Then
			PostGuiEvent EVENT_GADGETACTION,index
			_value = index
		EndIf
		Return 1
	EndMethod

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
		Select msg
			Case WM_ERASEBKGND
				Return 1
		EndSelect
		Return Super.WndProc(hwnd,msg,wp,lp)
	EndMethod

	Method RefreshLook()
		Super.RefreshLook()
		SetRange(_visible,_total)
	EndMethod

	Method Class()
		Return GADGET_SLIDER
	EndMethod

EndType

Type TWindowsProgressBar Extends TWindowsGadget

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	xstyle,wstyle,hotkey
		Local	hwnd:Byte Ptr,parent:Byte Ptr
		Self.style = style
		wstyle=WS_CHILD|PBS_SMOOTH|WS_CLIPSIBLINGS
		parent=group.query(QUERY_HWND_CLIENT)
		hwnd=CreateWindowExW(xstyle,"msctls_progress32","",wstyle,0,0,0,0,parent,Byte Ptr(hotkey),GetModuleHandleW(Null),Null)
		Register GADGET_PROGBAR,hwnd
		Return Self
	EndMethod

	Method SetValue(value#)
		Local v:WParam = value*100
		SendMessageW _hwnd,PBM_SETPOS,v,0
	EndMethod

	Method SetColor(r,g,b)
		'Only works in Classic mode, but it's better than nothing.
		SendMessageW _hwnd,PBM_SETBKCOLOR ,0,(b Shl 16)|(g Shl 8)|r
	EndMethod

	Method RemoveColor()
		'Only works in Classic mode, but it's better than nothing.
		SendMessageW _hwnd,PBM_SETBKCOLOR ,1,0
	EndMethod

	Method SetTextColor(r,g,b)
		'Only works in Classic mode, but it's better than nothing.
		SendMessageW _hwnd,PBM_SETBARCOLOR ,0,(b Shl 16)|(g Shl 8)|r
	EndMethod

	Method Class()
		Return GADGET_PROGBAR
	EndMethod

EndType

Type TWindowsComboBox Extends TWindowsGadget

	Field _icons:TWindowsIconStrip
	Field _editHwnd:Byte Ptr, _comboHwnd:Byte Ptr
	Field _selected = -1

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	xstyle,wstyle,hotkey,hwnd:Byte Ptr
		Local	parent:Byte Ptr,editstyle,combostyle

		Self.style = style
		wstyle=WS_CHILD|WS_TABSTOP|WS_CLIPSIBLINGS|WS_CLIPCHILDREN|CBS_AUTOHSCROLL
		If (style & COMBOBOX_EDITABLE) Then wstyle:|CBS_DROPDOWN Else wstyle:|CBS_DROPDOWNLIST

		parent=group.query(QUERY_HWND_CLIENT)
		hwnd=CreateWindowExW(xstyle,"ComboBoxEx32","",wstyle,0,0,0,180,parent,Byte Ptr(hotkey),GetModuleHandleW(Null),Null)

		If (style & COMBOBOX_EDITABLE) Then
			_editHwnd=SendMessageW(hwnd,CBEM_GETEDITCONTROL,0,0)
			If _editHwnd Then
				editstyle=GetWindowLongW(_editHwnd,GWL_STYLE)
				SetWindowLongW _editHwnd,GWL_STYLE,editstyle|WS_TABSTOP
			EndIf
		EndIf

		_comboHwnd=SendMessageW(hwnd,CBEM_GETCOMBOCONTROL,0,0)
		comboStyle=GetWindowLongW(_comboHwnd,GWL_STYLE)
		SetWindowLongW _comboHwnd,GWL_STYLE,comboStyle|WS_TABSTOP

		Register GADGET_COMBOBOX,hwnd

		TWindowsGUIDriver.RegisterHwnd(_combohwnd,Self)
		If _edithwnd Then TWindowsGUIDriver.RegisterHwnd(_edithwnd,Self)

		SetColor(255,255,255)

		Return Self

	EndMethod

	Method SetText(Text$)
		If Not _editHwnd Then
			Local tmpWString:Short Ptr = Text.ToWString()
			Local tmpResult = SendMessageW(_comboHwnd, CB_SETCUEBANNER, 0, LParam(tmpWString))
			MemFree tmpWString
			Return tmpResult
		Else
			Return Super.SetText(Text)
		EndIf
	EndMethod

	Method GetText$()
		If Not _editHwnd Then
			If _selected > -1 Then Return items[_selected].Text Else Return ""
		Else
			Return Super.GetText()
		EndIf
	EndMethod

	Method Activate(cmd)
		If _editHwnd Then
			Select cmd
				Case ACTIVATE_CUT
					SendMessageW _editHwnd,WM_CUT,0,0
				Case ACTIVATE_COPY
					SendMessageW _editHwnd,WM_COPY,0,0
					SetFocus _hwnd
				Case ACTIVATE_PASTE
					SendMessageW _editHwnd,WM_PASTE,0,0
				Case ACTIVATE_FOCUS
					SendMessageW _editHwnd,EM_SETSEL,0,-1
			End Select
		EndIf
		Return Super.Activate(cmd)
	EndMethod

	Method SetIconStrip(iconstrip:TIconStrip)
		Local imagelist:Byte Ptr
		_icons=TWindowsIconStrip(iconstrip)
		If _icons Then imagelist = _icons._imagelist
		SendMessageW _hwnd,CBEM_SETIMAGELIST,LVSIL_SMALL,LParam(imagelist)
	EndMethod

	Method ClearListItems()
		_selected=-1
		Desensitize()
		SendMessageW _hwnd,CB_RESETCONTENT,0,0
		Sensitize()
	EndMethod

	Method InsertListItem(index,Text$,tip$,icon,tag:Object)
		Local it:COMBOBOXEXITEMW = New COMBOBOXEXITEMW
		it.Setmask(CBEIF_TEXT)
		it.SetiItem(Int Ptr(index))
		it.SetpszText(Text.toWString())
		If icon>=0
			it.Setmask(it.mask()|CBEIF_IMAGE|CBEIF_SELECTEDIMAGE)
			it.SetiImage(icon)
			it.SetiSelectedImage(icon)
		EndIf
		Desensitize()
		SendMessageW(_hwnd,CBEM_INSERTITEMW,0,LParam(it.itemPtr))
		Sensitize()
		MemFree it.pszText()
	EndMethod

	Method SetListItem(index,Text$,tip$,icon,tag:Object)
		Local it:COMBOBOXEXITEMW = New COMBOBOXEXITEMW
		it.Setmask(CBEIF_TEXT)
		it.SetiItem(Int Ptr(index))
		it.SetpszText(Text.toWString())
		If _icons And icon>-1
			it.Setmask(it.mask()|CBEIF_IMAGE|CBEIF_SELECTEDIMAGE)
			it.SetiImage(icon)
			it.SetiSelectedImage(icon)
		EndIf
		Desensitize()
		SendMessageW(_hwnd,CBEM_SETITEMW,0,LParam(it.itemPtr))
		Sensitize()
		MemFree it.pszText()
	EndMethod

	Method RemoveListItem(index)
		Desensitize()
		SendMessageW _hwnd,CBEM_DELETEITEM,WParam(index),0
		Sensitize()
	EndMethod

	Method SetListItemState(index,state)
		If state&STATE_SELECTED
			_selected=index
		Else
			If _selected=index _selected=-1
			index=-1
		EndIf
		Desensitize()
		SendMessageW _hwnd,CB_SETCURSEL,WParam(index),0
		Sensitize()
	EndMethod

	Method ListItemState(index)
		Local Current,state
		Current=SendMessageW(_hwnd,CB_GETCURSEL,0,0)
		If Current=CB_ERR Current=-1
		If Current=index state=STATE_SELECTED
		Return state
	EndMethod

	Method OnCommand(msg,wp:ULong)
		Local index
		Select wp Shr 16
			Case CBN_SELCHANGE
				index=SendMessageW(_hwnd,CB_GETCURSEL,0,0)
				If index=CB_ERR
					index=-1
				Else
					If _selected<>index	'user generated event
						_selected=index
						Local extra:Object
						If index>=0 And index<items.length extra=items[index].extra
						PostGuiEvent EVENT_GADGETACTION,index,0,0,0,extra
					EndIf
				EndIf
			Case CBN_EDITCHANGE
				_selected=-1
				PostGuiEvent EVENT_GADGETACTION,-1
		End Select
	EndMethod

	Method Class()
		Return GADGET_COMBOBOX
	EndMethod

EndType

Type TWindowsPanel Extends TWindowsGadget

	Const PANELPANEL=0
	Const PANELGROUP=1
	Const PANELCANVAS=2

	Field _type
	Field _alpha#=1.0
	Field _bitmapwidth,_bitmapheight,_bitmapflags
	Field _canvas:TGraphics
	Field _hasalpha
	Field _generatesPaintEvents:Int

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	xstyle,wstyle,hotkey
		Local	hwnd:Byte Ptr,client:Byte Ptr,parent:Byte Ptr
		Self.style = style

		parent=group.query(QUERY_HWND_CLIENT)
		If (style&3=PANEL_GROUP) Then
			_type=PANELGROUP
			hwnd=CreateWindowExW(WS_EX_CONTROLPARENT,"BUTTON","",BS_GROUPBOX|WS_CHILD|WS_CLIPSIBLINGS|WS_CLIPCHILDREN,0,0,0,0,parent,Null,GetModuleHandleW(Null),Null )
			client=CreateWindowExW(WS_EX_CONTROLPARENT,TWindowsGUIDriver.ClassName(),"",WS_CHILD|WS_VISIBLE|WS_CLIPCHILDREN|WS_CLIPSIBLINGS,0,0,0,0,hwnd,Null,GetModuleHandleW(Null),Null)
		Else
			_type=PANELPANEL
			xstyle=WS_EX_CONTROLPARENT
			wstyle=WS_CHILD|WS_CLIPCHILDREN|WS_CLIPSIBLINGS
			Select (style&3)
				Case PANEL_SUNKEN xstyle:|WS_EX_CLIENTEDGE
				Case PANEL_RAISED xstyle:|WS_EX_WINDOWEDGE ; wstyle:|WS_DLGFRAME
			EndSelect
			If (style&PANEL_CANVAS) Then _type=PANELCANVAS
			hwnd=CreateWindowExW(xstyle,TWindowsGUIDriver.ClassName(),"",wstyle,0,0,0,0,parent,Byte Ptr(hotkey),GetModuleHandleW(Null),Null)
		EndIf

		Register GADGET_PANEL,hwnd,client
		If (style & PANEL_ACTIVE) Then sensitivity = SENSITIZE_ALL

		Return Self
	EndMethod

	Method SetAlpha( alpha# )
		_alpha=alpha
		RedrawGadget(Self)
	EndMethod

	Method Activate( cmd )
		Select cmd
			Case ACTIVATE_REDRAW
				If (_type = PANELCANVAS) Then
					InvalidateRect _hwnd, Null, False
					Return True
				EndIf
		EndSelect
		Return Super.Activate(cmd)
	EndMethod

	Method SetPixmap(pixmap:TPixmap,flags)
		If _bitmap Then DeleteObject _bitmap;_bitmap = 0
		If pixmap Then
			If pixmap.format=PF_RGBA8888 Or pixmap.format=PF_BGRA8888
				_bitmap=TWindowsGraphic.PreMultipliedBitmapFromPixmap32( pixmap )
			EndIf
			If _bitmap
				_hasalpha=True
			Else
				_bitmap=TWindowsGraphic.BitmapFromPixmap( pixmap, False )
				_hasalpha=False
			EndIf
			_bitmapflags=flags
			_bitmapwidth=pixmap.width
			_bitmapheight=pixmap.height
		EndIf
		RedrawGadget(Self)
	EndMethod

	Method AttachGraphics:TGraphics( flags )
		_canvas=brl.Graphics.AttachGraphics( _hwnd,flags )
	EndMethod

	Method CanvasGraphics:TGraphics()
		Return _canvas
	EndMethod

	Method Free()
		If _canvas Then CloseGraphics(_canvas);_canvas = Null
		Super.Free()
	EndMethod

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
		Select msg

			Case WM_ERASEBKGND

				If _type = PANELCANVAS Then Return 1
				If _generatesPaintEvents Then Return 1

				Local hdc:Byte Ptr=wp,hdcCanvas:Byte Ptr,hdcBitmap:Byte Ptr
				Local srcw,srch,x,y,xoffset,yoffset
				Local clientRect[4], updateRect[4], clipRect[4], windowRect[4]

				GetClipBox( hdc, clipRect )
				GetWindowRect( hwnd, windowRect)
				GetClientRect( hwnd, clientRect )

				If Not GetUpdateRect( hwnd, updateRect, False) Then updateRect = clipRect
				If IsRectEmpty(updateRect) Then updateRect = [0,0,windowRect[2]-windowRect[0],windowRect[3]-windowRect[1]]

				'If we are drawing a bitmap or using alpha then let's do some double-buffering stuff

				If (hwnd <> _hwndclient) And ((_bitmap And _bitmapwidth And _bitmapheight) Or _alpha<1.0) Then

					hdc = CreateCompatibleDC(Byte Ptr wp)
					hdcCanvas = CreateCompatibleBitmap(Byte Ptr wp,windowRect[2]-windowRect[0],windowRect[3]-windowRect[1])
					SelectObject( hdc, hdcCanvas )

				EndIf

				'Fill the drawing context with the background colour, or the background of the parent

				If BgBrush() And (hwnd <> _hwndclient) Then FillRect(hdc,updateRect,BgBrush()) Else DrawParentBackground(hdc,hwnd)

				'If we aren't drawing to a bitmap or using alpha, then we can return now.

				If Not ((hwnd <> _hwndclient) And ((_bitmap And _bitmapwidth And _bitmapheight) Or _alpha<1.0)) Then Return 1

				If _bitmap And _bitmapwidth And _bitmapheight
					hdcBitmap=CreateCompatibleDC(hdc)
					SelectObject(hdcBitmap,_bitmap)
					srcw=_bitmapwidth
					srch=_bitmapheight
					Select (_bitmapflags & (GADGETPIXMAP_ICON-1))
						Case PANELPIXMAP_TILE
							While y<windowRect[RECT_BOTTOM]-windowRect[RECT_TOP]
								x=0
								While x<windowRect[RECT_RIGHT]-windowRect[RECT_LEFT]
									If _hasalpha
										AlphaBlend_ hdc,x,y,srcw,srch,hdcBitmap,0,0,srcw,srch,$01ff0000
									Else
										BitBlt hdc,x,y,srcw,srch,hdcBitmap,0,0,ROP_SRCCOPY
									EndIf
									x:+srcw
								Wend
								y:+srch
							Wend
						Case PANELPIXMAP_CENTER
							x=(windowRect[RECT_RIGHT]-windowRect[RECT_LEFT]-srcw)/2
							y=(windowRect[RECT_BOTTOM]-windowRect[RECT_TOP]-srch)/2
							If _hasalpha
								AlphaBlend_ hdc,x,y,srcw,srch,hdcBitmap,0,0,srcw,srch,$01ff0000
							Else
								BitBlt hdc,x,y,srcw,srch,hdcBitmap,0,0,ROP_SRCCOPY
							EndIf

						Case PANELPIXMAP_FIT, PANELPIXMAP_FIT2

							Local mx# = Float(windowRect[RECT_RIGHT]-windowRect[RECT_LEFT])/srcw
							Local my# = Float(windowRect[RECT_BOTTOM]-windowRect[RECT_TOP])/srch

							If mx>my Then
								If (_bitmapflags&(GADGETPIXMAP_ICON-1)) = PANELPIXMAP_FIT Then mx=my Else my=mx
							EndIf
							Local w=mx*srcw
							Local h=mx*srch
							x=(windowRect[RECT_RIGHT]-windowRect[RECT_LEFT]-w)/2
							y=(windowRect[RECT_BOTTOM]-windowRect[RECT_TOP]-h)/2
							SetStretchBltMode hdc,COLORONCOLOR

							If _hasalpha
								AlphaBlend_ hdc,x,y,w,h,hdcBitmap,0,0,srcw,srch,$01ff0000
							Else
								StretchBlt hdc,x,y,w,h,hdcBitmap,0,0,srcw,srch,ROP_SRCCOPY
							EndIf

						Case PANELPIXMAP_STRETCH
							SetStretchBltMode hdc,COLORONCOLOR

							If _hasalpha
								AlphaBlend_ hdc,0,0,windowRect[RECT_RIGHT]-windowRect[RECT_LEFT],windowRect[RECT_BOTTOM]-windowRect[RECT_TOP],hdcBitmap,0,0,srcw,srch,$01ff0000
							Else
								StretchBlt hdc,0,0,windowRect[RECT_RIGHT]-windowRect[RECT_LEFT],windowRect[RECT_BOTTOM]-windowRect[RECT_TOP],hdcBitmap,0,0,srcw,srch,ROP_SRCCOPY
							EndIf

					EndSelect

					DeleteDC(hdcBitmap)

				EndIf

				If _alpha < 1.0 Then

					DrawParentBackground( Byte Ptr wp, hwnd )
					Local blendfunction = ((Int(_alpha*255)&$FF) Shl 16)
					AlphaBlend_(Byte Ptr wp,updateRect[0],updateRect[1],updateRect[2]-updateRect[0],updateRect[3]-updateRect[1],hdc,updateRect[0],updateRect[1],updateRect[2]-updateRect[0],updateRect[3]-updateRect[1],blendfunction)

				Else

					BitBlt(Byte Ptr wp,0,0,windowRect[2]-windowRect[0],WindowRect[3]-windowRect[1],hdc,0,0,ROP_SRCCOPY)

				EndIf

				Assert hdc <> wp, "hdc == wp! Please post a MaxGUI bug report."

				DeleteObject( hdcCanvas )
				DeleteDC( hdc )

				Return 1

			Case WM_PAINT

				Select _type
					Case PANELCANVAS
						PostGuiEvent EVENT_GADGETPAINT
						ValidateRect _hwnd, Null
						Return 1
					Default
						If _generatesPaintEvents Then
							PostGuiEvent EVENT_GADGETPAINT
							ValidateRect _hwnd, Null
							Return 1
						End If
				EndSelect

			Case WM_LBUTTONDOWN

				SetFocus Query(QUERY_HWND_CLIENT)

		End Select

		Return Super.WndProc(hwnd,msg,wp,lp)

	EndMethod

	Method FlushBrushes(pRecurse:Int = True)
		Super.FlushBrushes()
		If Not pRecurse Then Return
		For Local tmpGadget:TWindowsGadget = EachIn kids
			tmpGadget.FlushBrushes()
		Next
	EndMethod

	Method ClientWidth()
		If _hwndClient Then
			Return (Super.ClientWidth()-8)
		Else
			Return Super.ClientWidth()
		End If
	EndMethod

	Method ClientHeight()
		If _hwndClient Then
			Return (Super.ClientHeight()-20)
		Else
			Return Super.ClientHeight()
		End If
	EndMethod

	Method RethinkClient(forceRedraw:Int = False)
		If _hwndClient Then
			MoveWindow( _hwndClient, 4+_clientX,16+_clientY,ClientWidth(),ClientHeight(),forceRedraw)
		EndIf
	EndMethod

	Method Class()
		If _type = PANELCANVAS Then
			Return GADGET_CANVAS
		Else
			Return GADGET_PANEL
		End If
	EndMethod

EndType


Type TWindowsTextField Extends TWindowsGadget

	Field _busy

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	xstyle,wstyle,hotkey
		Local	hwnd:Byte Ptr,parent:Byte Ptr
		Self.style = style
		xstyle=WS_EX_CLIENTEDGE
		wstyle=WS_CHILD|WS_TABSTOP|ES_AUTOHSCROLL|WS_CLIPSIBLINGS
		If style&TEXTFIELD_PASSWORD Then wstyle:|ES_PASSWORD
		parent=group.query(QUERY_HWND_CLIENT)
		hwnd=CreateWindowExW(xstyle,"EDIT","",wstyle,0,0,0,0,parent,Byte Ptr(hotkey),GetModuleHandleW(Null),Null)
		'SendMessageW hwnd,WM_SETFONT,TWindowsGUIDriver.GDIFont.handle,1
		Register GADGET_TEXTFIELD,hwnd
		SetColor(255,255,255)
		Return Self
	EndMethod

	Method SetText(Text$)
		Local p0,p1
		_busy:+1
		SendMessageW _hwnd,EM_GETSEL,WParam(Varptr p0),LParam(Varptr p1)
		Super.SetText(Text)
		SendMessageW _hwnd,EM_SETSEL,WParam(p0),LParam(p1)
		_busy:-1
	EndMethod

	Method Activate(cmd)
		Select cmd
			Case ACTIVATE_CUT
				SendMessageW _hwnd,WM_CUT,0,0
			Case ACTIVATE_COPY
				SendMessageW _hwnd,WM_COPY,0,0
			Case ACTIVATE_PASTE
				SendMessageW _hwnd,WM_PASTE,0,0
			Case ACTIVATE_FOCUS
				SendMessageW _hwnd,EM_SETSEL,0,-1
		End Select
		Return Super.Activate(cmd)
	EndMethod

	Method OnCommand(msg,wp:ULong)
		If Not _busy
			Select (wp Shr 16)
				Case EN_UPDATE
					PostGuiEvent EVENT_GADGETACTION
				Case EN_KILLFOCUS
					SendMessageW _hwnd,EM_SETSEL,0,0
			End Select
		EndIf
	EndMethod

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
		Local event:TEvent
		Select msg
			Case WM_ERASEBKGND
				Return 1
			Case WM_KEYDOWN
				If eventfilter<>Null
					event=CreateEvent(EVENT_KEYDOWN,Self,Int(wp),keymods())
					If Not eventfilter(event,context) Return True
				EndIf
			Case WM_CHAR
				If eventfilter<>Null
					event=CreateEvent(EVENT_KEYCHAR,Self,Int(wp),keymods())
					If Not eventfilter(event,context) Return True
				EndIf
			Case WM_KILLFOCUS
				PostGuiEvent EVENT_GADGETLOSTFOCUS
		End Select
		Return Super.WndProc(hwnd,msg,wp,lp)
	EndMethod

	Method Class()
		Return GADGET_TEXTFIELD
	EndMethod

EndType

Type TWindowsDefaultTextArea Extends TWindowsTextArea

	Global _ClassName:String = Null	'See InitializeLibrary().

	Global _pagemargin# = 0.5		'Page margin for print-out in inches

	Field _locked

	Field cr1:CHARRANGE=New CHARRANGE
	Field cr2:CHARRANGE=New CHARRANGE
	Field cf:CHARFORMATW=New CHARFORMATW

	Field ole:IRichEditOLE_
	Field idoc:ITextDocument_
	Field busy,_readonly

	Field IID_ITextDocument:GUID = New GUID

	Function _InitializeLibrary()

		If Not _ClassName Then

			'Load RichEdit DLL
			If Not LoadLibraryW("msftedit.dll") Then
				If LoadLibraryW("riched20.dll") _ClassName = "RichEdit20W"
			Else
				_ClassName = "RICHEDIT50W"
			EndIf

		EndIf

	EndFunction

	Method New()
		_InitializeLibrary()
	EndMethod

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	xstyle,wstyle,hotkey
		Local	hwnd:Byte Ptr,parent:Byte Ptr
		Local res

		xstyle=WS_EX_CLIENTEDGE
		wstyle=WS_CHILD|WS_VSCROLL|WS_CLIPSIBLINGS
		wstyle:|ES_MULTILINE|ES_NOOLEDRAGDROP|ES_NOHIDESEL|ES_LEFT
		If Not (style&TEXTAREA_WORDWRAP) wstyle:|WS_HSCROLL|ES_AUTOHSCROLL
'		If (style&TEXTAREA_READONLY) wstyle:|ES_READONLY
		If (style&TEXTAREA_READONLY) _readonly=True

		Self.style = style

		parent=group.query(QUERY_HWND_CLIENT)

		'RichText control should be made have dimensions of 1x1 pixels to fix Windows XP vertical scrollbar drawing bug.
		hwnd=CreateWindowExW(xstyle,_ClassName,"",wstyle,0,0,1,1,parent,Byte Ptr(hotkey),GetModuleHandleW(Null),Null)

		SendMessageW hwnd,EM_SETLIMITTEXT,4*1024*1024,0
		SendMessageW hwnd,EM_SETEVENTMASK,0,ENM_CHANGE|ENM_MOUSEEVENTS|ENM_SELCHANGE|ENM_KEYEVENTS
		SendMessageW hwnd,EM_SETUNDOLIMIT,0,0

		'ole = New IRichEditOLE

		SendMessageW hwnd,EM_GETOLEINTERFACE,0, LParam(Byte Ptr (Varptr ole))
		res=IIDFromString(ITextDocument_UUID,IID_ITextDocument)

		'idoc = New ITextDocument
		res=ole.QueryInterface(IID_ITextDocument.guidPtr, idoc)

		Register GADGET_TEXTAREA,hwnd

		Return Self
	EndMethod

	Method Free()
		If ole Then ole.Release_
		If idoc Then idoc.Release_
		Super.Free()
	EndMethod

	Method Activate(cmd)
		Select cmd
			Case ACTIVATE_CUT
				SendMessageW _hwnd,WM_CUT,0,0
			Case ACTIVATE_COPY
				SendMessageW _hwnd,WM_COPY,0,0
				SetFocus _hwnd
			Case ACTIVATE_PASTE
				DoPaste
			Case ACTIVATE_PRINT
				DoPrint
			Default
				Return Super.Activate(cmd)
		End Select
	EndMethod

	Method DoPaste()
		Local h:Byte Ptr,handle:Byte Ptr,n:Size_T
		Local w:Short Ptr,cp:Short Ptr
		Local tp:Byte Ptr,bp:Byte Ptr

		If OpenClipboard(_hwnd)
			If IsClipboardFormatAvailable(CF_UNICODETEXT)
				handle=GetClipboardData(CF_UNICODETEXT)
				n=GlobalSize(handle)
				w=Short Ptr GlobalLock(handle)
				h=GlobalAlloc(GMEM_MOVEABLE,n)
				cp=Short Ptr GlobalLock(h)
				memcpy_(cp,w,n)
				If cp[n/2-2]=10 Then cp[n/2-2]=13
				GlobalUnlock h
				GlobalUnlock handle
				If h
					EmptyClipboard
					SetClipboardData CF_UNICODETEXT,h
				EndIf
			ElseIf IsClipboardFormatAvailable(CF_OEMTEXT)
				handle=GetClipboardData(CF_OEMTEXT)
				n=GlobalSize(handle)
				tp=Byte Ptr GlobalLock(handle)
				h=GlobalAlloc(GMEM_MOVEABLE,n)
				bp=Byte Ptr GlobalLock(h)
				memcpy_(bp,tp,n)
				If bp[n-2]=10 Then bp[n-2]=13
				GlobalUnlock h
				GlobalUnlock handle
				If h
					EmptyClipboard
					SetClipboardData CF_OEMTEXT,h
				EndIf
			EndIf
			CloseClipboard
			SendMessageW _hwnd,WM_PASTE,0,0
			SetFocus _hwnd
		EndIf
	EndMethod

	Method DoPrint()
Rem
		Local tmpTextSelLen = TextAreaSelLen(Self)

		Local tmpPrintDialog:PRINTDLGW = New PRINTDLGW

		tmpPrintDialog.flags = PD_RETURNDC | PD_HIDEPRINTTOFILE | PD_NOPAGENUMS
		If Not tmpTextSelLen Then tmpPrintDialog.flags:|PD_NOSELECTION

		tmpPrintDialog.hwndOwner = _hwnd

		If Not PrintDlg( Byte Ptr tmpPrintDialog ) Then Return 0

		Local hdcPrinter = tmpPrintDialog.hdc

		Local tmpDoc:DOCINFOW = New DOCINFOW
		Local tmpDocTitle:Short Ptr = AppTitle.ToWString()
		tmpDoc.lpszDocName = tmpDocTitle

		Local tmpSuccess = (StartDocW( hdcPrinter, Byte Ptr tmpDoc ) > 0)

		If tmpSuccess Then

			Local _cursor = TWindowsGUIDriver._cursor

			SetPointer( POINTER_WAIT )

			SetMapMode( hdcPrinter, MM_TEXT )

			Local wPage = GetDeviceCaps( hdcPrinter, PHYSICALWIDTH )
			Local hPage = GetDeviceCaps( hdcPrinter, PHYSICALHEIGHT )
			Local xPPI = GetDeviceCaps( hdcPrinter, LOGPIXELSX )
			Local yPPI = GetDeviceCaps( hdcPrinter, LOGPIXELSY )

			Local tmpTextLengthStruct[] = [GTL_DEFAULT,1200]
			Local tmpTextLength = SendMessageW (_hwnd, EM_GETTEXTLENGTHEX, Int Byte Ptr tmpTextLengthStruct, 0)

			Local tmpTextPrinted, tmpFormatRange:FORMATRANGE = New FORMATRANGE

			tmpFormatRange.hdc = hdcPrinter
			tmpFormatRange.hdcTarget = hdcPrinter

			tmpFormatRange.rcPageRight = (wPage*1440:Long)/xPPI
			tmpFormatRange.rcPageBottom = (hPage*1440:Long)/yPPI

			tmpFormatRange.rcLeft = (1440*_pagemargin);tmpFormatRange.rcTop = (1440*_pagemargin)
			tmpFormatRange.rcRight = tmpFormatRange.rcPageRight - (2880*_pagemargin)
			tmpFormatRange.rcBottom = tmpFormatRange.rcPageBottom - (2880*_pagemargin)

			If tmpPrintDialog.flags & PD_SELECTION Then
				tmpTextPrinted = TextAreaCursor(Self)
				tmpFormatRange.CHARRANGE_cpMax = tmpTextPrinted+tmpTextSelLen
			Else
				tmpFormatRange.CHARRANGE_cpMax = tmpTextLength
			EndIf

			SendMessageW (_hwnd, EM_FORMATRANGE, False, 0)

			While tmpSuccess And ( tmpTextPrinted < tmpFormatRange.CHARRANGE_cpMax )

				tmpFormatRange.CHARRANGE_cpMin = tmpTextPrinted

				tmpSuccess = (StartPage(hdcPrinter) > 0)
				If Not tmpSuccess Then Exit

				tmpTextPrinted = SendMessageW( _hwnd, EM_FORMATRANGE, True, Int Byte Ptr tmpFormatRange )

				tmpSuccess = (EndPage(hdcPrinter) > 0)

			Wend

			If tmpSuccess Then EndDoc( hdcPrinter ) Else AbortDoc( hdcPrinter )

			SendMessageW (_hwnd, EM_FORMATRANGE, False, 0)

			TWindowsGUIDriver._cursor = _cursor
			SetCursor _cursor

		EndIf

		GlobalFree( tmpPrintDialog.hDevMode )
		GlobalFree( tmpPrintDialog.hDevNames )
		DeleteDC( hdcPrinter )

		MemFree tmpDocTitle

		Return tmpSuccess
End Rem
	EndMethod

	Global gt[] = [GTL_DEFAULT, CP_ACP]

	Method CharCount()
		Return SendMessageW(_hwnd,EM_GETTEXTLENGTHEX,WParam(Byte Ptr gt),0)
	EndMethod

	Method SetStyle(r,g,b,flags,pos,length,units)
		Local iifont:ITextFont_
		Local iirange:ITextRange_
		Local res, tmpOutput
		If units=TEXTAREA_LINES
			Local n=pos
			pos=CharAt(pos)
			If length>=0 length=CharAt(n+length)-pos
		EndIf
		If length<0 length=charcount()-pos
		busy:+1
		res=idoc.Range(pos,pos+length,iirange)
		res=iirange.GetFont(iifont)
		res=iifont.SetForeColor(((b Shl 16)|(g Shl 8)|r))
		If (flags&TEXTFORMAT_BOLD) Then iifont.SetBold(TOMTRUE) Else iifont.SetBold(TOMFALSE)
		If (flags&TEXTFORMAT_ITALIC) Then iifont.SetItalic(TOMTRUE) Else iifont.SetItalic(TOMFALSE)
		If (flags&TEXTFORMAT_UNDERLINE) Then iifont.SetUnderline(TOMSINGLE) Else iifont.SetUnderline(TOMFALSE)
		If (flags&TEXTFORMAT_STRIKETHROUGH) Then iifont.SetStrikeThrough(TOMTRUE) Else iifont.SetStrikeThrough(TOMNONE)
		iifont.Release_
		iirange.Release_
		busy:-1
	EndMethod

	Method InsertText(Text$,pos,count)
		Local iirange:ITextRange_
		Local bstr:Short Ptr, tmpWString:Short Ptr = Text.toWString()
		Local res, bool
		busy:+1
		res=idoc.Range(pos,pos+count,iirange)
		bstr=SysAllocStringLen(tmpWString,UInt(Text.length));MemFree tmpWString
		LockText()
		res=iirange.SetText(bstr)
		UnlockText()
		SysFreeString bstr
		iirange.Release_
		busy:-1
	EndMethod

	Method ReplaceText(pos,length,Text$,units)
		If units=TEXTAREA_LINES
			Local n=pos
			pos=CharAt(pos)
			If length>=0 length=CharAt(n+length)-pos
		EndIf
		If length<0 Then length=charcount()-pos
		InsertText Text,pos,length
	EndMethod

	Method AreaText$(pos,length,units)
		Local iirange:ITextRange_
		Local bstr:Short Ptr

		If units=TEXTAREA_LINES
			Local n=pos
			pos=CharAt(pos)
			If length>=0 length=CharAt(n+length)-pos
		EndIf
		If length<0 length=charcount()-pos
		idoc.Range(pos,pos+length,iirange)
		iirange.GetText(Varptr bstr)
		Local Text$=String.FromWString(bstr)
		SysFreeString bstr
		iirange.Release_
		Text=Text.Replace(Chr(13),Chr(10))
		Return Text
	EndMethod

	Method SetSelection(pos,length,units)
		If units=TEXTAREA_LINES
			Local n=pos
			pos=CharAt(pos)
			If length>0
				length=CharAt(n+length)
				length=length-pos
			EndIf
		EndIf
		If length<0 length=charcount()-pos
		'Local cr:CHARRANGE = New CHARRANGE
		cr1.SetcpMin(pos)
		cr1.SetcpMax(pos+length)
		Desensitize()
		SendMessageW _hwnd,EM_EXSETSEL,0,LParam(cr1.rangePtr)
		Sensitize()
	EndMethod

	Method SetMargins(leftmargin)
		SendMessageW _hwnd,EM_SETMARGINS,EC_LEFTMARGIN,leftmargin
	EndMethod

	' 72 points per inch

	Method SetTabs(tabs)
		Local hdc:Byte Ptr=GetDC( 0 )
		idoc.SetDefaultTabStop tabs * 72.0 / GetDeviceCaps( hdc,LOGPIXELSX )
		ReleaseDC Null,hdc
	EndMethod

	Method SetTextColor(r,g,b)
		'cf.cbSize=SizeOf(CHARFORMATW)
		cf.SetdwMask(CFM_COLOR|CFM_BOLD|CFM_ITALIC)
		cf.SetcrTextColor((b Shl 16)|(g Shl 8)|r)
		SendMessageW _hwnd,EM_SETCHARFORMAT,SCF_DEFAULT,LParam(cf.formatPtr)
		SendMessageW _hwnd,EM_SETCHARFORMAT,SCF_ALL,LParam(cf.formatPtr)
	EndMethod

	Method SetColor(r,g,b)
		SendMessageW _hwnd,EM_SETBKGNDCOLOR,0,((b Shl 16)|(g Shl 8)|r)
	EndMethod

	Method RemoveColor()
		SendMessageW _hwnd,EM_SETBKGNDCOLOR,1,0
	EndMethod

	Method GetCursorPos(units)
		'Local cr:CHARRANGE = New CHARRANGE
		SendMessageW _hwnd,EM_EXGETSEL,0,LParam(cr1.rangePtr)
		Local pos=cr1.cpMin()
		If units=TEXTAREA_LINES pos=LineAt(pos)
		Return pos
	EndMethod

	Method GetSelectionLength(units)
		'Local cr:CHARRANGE = New CHARRANGE
		SendMessageW _hwnd,EM_EXGETSEL,0,LParam(cr1.rangePtr)
		If units=TEXTAREA_LINES
			Return LineAt(cr1.cpMax()-1)-LineAt(cr1.cpMin())+1
		Else
			Return cr1.cpMax()-cr1.cpMin()
		EndIf
	EndMethod

	Method CharAt(Line)
		If Line<0 Return
		If Line>AreaLen(TEXTAREA_LINES) Return charcount()
		Return SendMessageW(_hwnd,EM_LINEINDEX,WParam(Line),0)
	EndMethod

	Method LineAt(pos)
		If pos<0 Return
		If pos>charcount() Return AreaLen(TEXTAREA_LINES)
		Return SendMessageW(_hwnd,EM_EXLINEFROMCHAR,0,pos)
	EndMethod

	Method AreaLen(units)
		If units=TEXTAREA_LINES Return LineAt(charcount())
		Return charcount()
	EndMethod

	Method CharX( char )
		Local tmpPoint[2]
		SendMessageW(_hwnd, EM_POSFROMCHAR, WParam(Byte Ptr tmpPoint), char)
		Return tmpPoint[0]
	EndMethod

	Method CharY( char )
		Local tmpPoint[2]
		SendMessageW(_hwnd, EM_POSFROMCHAR, WParam(Byte Ptr tmpPoint), char)
		Return tmpPoint[1]
	EndMethod

	Method SetText(Text$)
		InsertText Text,0,charcount()
	EndMethod

	Method AddText(Text$)
		InsertText Text,charcount(),0
		'Local cr:CHARRANGE = New CHARRANGE
		Local p = charcount()
		cr1.SetcpMin(p)
		cr1.SetcpMax(p)
		SendMessageW _hwnd,EM_EXSETSEL,0,LParam(cr1.rangePtr)
	EndMethod

	Method GetText$()
		Return AreaText(0,charcount(),TEXTAREA_CHARS)
	EndMethod

	Field _oldSelPos%, _oldSelLen% = 0

	Method LockText()

		If Not idoc.Freeze(_locked)
			_oldSelPos = GetCursorPos(TEXTAREA_CHARS)
			_oldSelLen = GetSelectionLength(TEXTAREA_CHARS)
			If Not _oldCursor Then _oldCursor = GetCursor()
		EndIf

	EndMethod

	Method UnlockText()

		If idoc.Unfreeze(_locked) = S_OK Then
			SetSelection( _oldSelPos, _oldSelLen, TEXTAREA_CHARS )
			If _oldCursor And (_oldCursor <> GetCursor()) Then
				SetCursor(_oldCursor)
			EndIf
			_oldCursor = 0
		EndIf

	EndMethod

	Method OnCommand(msg,wp:ULong)
		If busy Then Return
		Select wp Shr 16
			Case EN_CHANGE
				If Not _locked Then PostGuiEvent EVENT_GADGETACTION
		End Select
	EndMethod

	Method OnNotify(wp:WParam,lp:LParam)
		Local nmhdrPtr:Byte Ptr
		Local event:TEvent

		Super.OnNotify(wp,lp)	'Tooltip

		nmhdrPtr=lp
		Select bmx_win32_NMHDR_code(nmhdrPtr)
'			Case EN_PROTECTED
'				DebugStop
			Case EN_SELCHANGE
				If Not (busy Or _locked)
					PostGuiEvent EVENT_GADGETSELECT
				EndIf
			Case EN_MSGFILTER
				Select bmx_win32_MSGFILTER_msg(nmhdrPtr)
					Case WM_RBUTTONDOWN
						If GetSelectionLength(TEXTAREA_CHARS)=0 Then
							bmx_win32_MSGFILTER_Setmsg(nmhdrPtr, WM_LBUTTONDOWN)
						End If
					Case WM_RBUTTONUP
						Local mx=Long(bmx_win32_MSGFILTER_lParam(nmhdrPtr)) & $ffff
						Local my=Long(bmx_win32_MSGFILTER_lParam(nmhdrPtr)) Shr 16
						PostGuiEvent EVENT_GADGETMENU,0,0,mx,my
					Case WM_KEYDOWN

						Local k=Int(bmx_win32_MSGFILTER_wParam(nmhdrPtr))

						'Filtering out special shortcut combinations
						If (keymods()&MODIFIER_CONTROL) Then
							Select k
								Case 76,69,82	'ctrl+l, ctrl+e, ctrl+r
									Return 1	'Alignment shortcuts

								Case 188,190	'ctrl+<, ctrl+>
											'Font size shortcuts
									If (keymods()&MODIFIER_SHIFT) Then Return 1
							EndSelect
						EndIf

						'Read-only
						If _readonly
							If k>=33 And k<=40 Return 0 'selection keys
							If (keymods()&MODIFIER_CONTROL) Then
								Select k
									Case 65, 67;Return 0 'ctrl-a, ctrl+c
								EndSelect
							EndIf
							Return 1
						EndIf

						'Event Filter
						If eventfilter<>Null
							event=CreateEvent(EVENT_KEYDOWN,Self,k,keymods())
							Return Not eventfilter(event,context)
						EndIf

					Case WM_CHAR
						If _readonly Return 1
						If eventfilter<>Null
							event=CreateEvent(EVENT_KEYCHAR,Self,Int(bmx_win32_MSGFILTER_wParam(nmhdrPtr)),keymods())
							Return Not eventfilter(event,context)
						EndIf
				End Select
		End Select
	EndMethod

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
		Select msg

			Case WM_MOUSEWHEEL
				If (Long(wp)&MK_CONTROL) Then SendMessageW _hwnd, EM_SETZOOM, 0, 0

			Case WM_KILLFOCUS
				PostGuiEvent EVENT_GADGETLOSTFOCUS

		End Select

		Return Super.WndProc(hwnd,msg,wp,lp)

	EndMethod

	Method Class()
		Return GADGET_TEXTAREA
	EndMethod

EndType

Type TWindowsLabel Extends TWindowsGadget

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	xstyle,wstyle,hotkey
		Local	hwnd:Byte Ptr,parent:Byte Ptr

		Self.style = style
		wstyle=WS_CHILD|SS_NOPREFIX|WS_CLIPSIBLINGS|SS_NOTIFY

		Select style&24
			Case LABEL_LEFT wstyle:|SS_LEFT
			Case LABEL_RIGHT wstyle:|SS_RIGHT
			Case LABEL_CENTER wstyle:|SS_CENTER
		End Select
		Select style&7
			Case LABEL_FRAME wstyle:|WS_BORDER
			Case LABEL_SUNKENFRAME wstyle:|SS_SUNKEN
			Case LABEL_SEPARATOR wstyle:|SS_SUNKEN|SS_GRAYRECT
		End Select

		parent=group.query(QUERY_HWND_CLIENT)
		hwnd=CreateWindowExW(xstyle,"STATIC","",wstyle,0,0,0,0,parent,Byte Ptr hotkey,GetModuleHandleW(Null),Null)
		Register GADGET_LABEL,hwnd

		Return Self
	EndMethod

	Method SetArea(x,y,w,h)
		If ((style & 7) = LABEL_SEPARATOR) Then
			If (w > h) Then h = 2 Else w = 2
		EndIf
		Return Super.SetArea(x,y,w,h)
	EndMethod

	Method SetText(Text$)
		If ((style & 7) <> LABEL_SEPARATOR) Then Return Super.SetText(Text)
	EndMethod

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
		Select msg
			Case WM_ERASEBKGND
				Return 1
		EndSelect
		Return Super.WndProc(hwnd,msg,wp,lp)
	EndMethod

	Method Class()
		Return GADGET_LABEL
	EndMethod

EndType

Type TWindowsTreeNode Extends TGadget
	Field	_parent:TWindowsTreeNode
	Field	_tree:Byte Ptr		'HWND
	Field	_item:Byte Ptr		'HTREEITEM
	Field	_expanded
	Field	_icon
	Field _handle:Byte Ptr
	Field _tv:TVITEMW

	Method Activate(cmd)
		Local tmpTree:TWindowsTreeView = TWindowsTreeView(TWindowsGUIDriver.GadgetFromHwnd(_tree))
		If tmpTree Then tmpTree.Desensitize()
		Select cmd
			Case ACTIVATE_SELECT
				If _item <> TVI_ROOT Then
					SendMessageW _tree,TVM_SELECTITEM,TVGN_CARET,LParam(_item)
				Else
					SendMessageW _tree,TVM_SELECTITEM,TVGN_CARET,0
				EndIf
			Case ACTIVATE_EXPAND
				SendMessageW _tree,TVM_EXPAND,TVE_EXPAND,LParam(_item)
				_expanded=True
			Case ACTIVATE_COLLAPSE
				SendMessageW _tree,TVM_EXPAND,TVE_COLLAPSE,LParam(_item)
				_expanded=False
			Case ACTIVATE_REDRAW
				RedrawNode()
		End Select
		If tmpTree Then tmpTree.Sensitize()
	EndMethod

	Method CreateRoot:TWindowsTreeNode(owner:TWindowsTreeView)
		_tree=owner._hwnd
		_item=TVI_ROOT
		Return Self
	EndMethod

	Method CountKids()
		Return kids.count()
	EndMethod

	Method Create:TWindowsTreeNode(group:TGadget,style,Text$="",index=-1,icon = -1)
		_parent=TWindowsTreeNode(group)
		If Not _parent Throw "Parent isn't a treeview node. Use TreeViewRoot() when creating a root node."
		Self.style = style
		_tree=_parent._tree
		_icon = icon
		Spawn(Text,index)
		_SetParent group,index
		If (LocalizationMode()&LOCALIZATION_OVERRIDE) Then
			LocalizeGadget(Self, Text, "")
		EndIf
		Return Self
	EndMethod

	Method GetText$()
		If Not _tv Then
			_tv = New TVITEMW
		End If
		'Local item[10]
		Local buffer:Short[260]
		_tv.Setmask(TVIF_TEXT)
		_tv.SethItem(_item)
		_tv.SetpszText(buffer)
		_tv.SetcchTextMax(256)
		'item[0]=TVIF_TEXT
		'item[1]=_item
		'item[4]=Int Byte Ptr buffer
		'item[5]=256
		SendMessageW _tree,TVM_GETITEMW,0,LParam(_tv.itemPtr)
		Return String.FromWString(buffer)
	EndMethod

	Method SetText(Text$)
		If Not _tv Then
			_tv = New TVITEMW
		End If
		_tv.Setmask(TVIF_HANDLE|TVIF_TEXT)
		_tv.SethItem(_item)
		If _icon > -1 Then
			_tv.Setmask(_tv.mask()|TVIF_IMAGE|TVIF_SELECTEDIMAGE)
			_tv.SetiImage(_icon)
			_tv.SetiSelectedImage(_tv.iImage())
		EndIf
		_tv.SetpszText(Text.ToWString())
		SendMessageW(_tree,TVM_SETITEMW,0,LParam(_tv.itemPtr))
		MemFree _tv.pszText()
	EndMethod

	Method DoLayout()
		'Don't do anything!
	EndMethod

	Method Free()
		'If we don't have a parent then the node must have previously been freed.
		If Not _parent Then Return
		'Avoid firing events when freeing a treenode that is selected.
		If SendMessageW(_tree,TVM_GETNEXTITEM,TVGN_CARET,0) Then DeSelect()
		'Free treenode
		If _item Then
			SendMessageW(_tree,TVM_DELETEITEM,0,LParam(_item))
			_item=Null
		End If
		'Redraw parent if we were its last child node
		If Not SendMessageW(_tree, TVM_GETNEXTITEM, TVGN_CHILD, LParam(_parent._item)) Then _parent.RedrawNode()
		'Cleanup variables that could be circular references
		_parent = Null;_tree = 0;_SetParent Null
		'Release any handle we created using HandleFromObject() in Spawn()
		If _handle Then Release _handle
	EndMethod

	Method DeSelect()
		SendMessageW _tree,TVM_SELECTITEM,TVGN_CARET,0
	EndMethod

	Method InsertNode:TGadget(index,Text$,icon)
		Return New TWindowsTreeNode.Create(Self,0,Text,index,icon)
	EndMethod

	Method ModifyNode(Text$,icon)
		_icon = icon
		SetText Text
	EndMethod

	Method tviatindex:Byte Ptr(index)
		If kids.IsEmpty() Then Return TVI_FIRST
		If index<0 Or index>=kids.count() Return TVI_LAST
		Local child:TWindowsTreeNode
		child=TWindowsTreeNode(kids.valueatindex(index))
		Return child._item
	EndMethod

	Method Spawn:Byte Ptr(name$,index=-1)

		Local it:TVINSERTSTRUCTW = New TVINSERTSTRUCTW
		Local hitem
		it.SethParent(_parent._item)
		If index = 0 Then
			it.SethInsertAfter(Byte Ptr TVI_FIRST)
		Else
			it.SethInsertAfter(_parent.tviatindex(index-1))
		EndIf
		it.Setitem_mask(TVIF_TEXT|TVIF_PARAM)

		If _icon > -1 Then
			it.Setitem_mask(it.item_mask()|TVIF_IMAGE|TVIF_SELECTEDIMAGE)
			it.Setitem_iImage(_icon)
			it.Setitem_iSelectedImage(it.item_iImage())
		EndIf

		Local tmpParentHadKids = SendMessageW(_tree, TVM_GETNEXTITEM, TVGN_CHILD, LParam(_parent._item))

		it.Setitem_pszText(name.ToWString())
		it.Setitem_lparam(Byte Ptr (HandleFromObject(Self))) ' FIXME

		'Make sure that we store handle so we can release it later.
		If _handle Then Release _handle
		_handle = it.item_lparam()

		_item=SendMessageW(_tree,TVM_INSERTITEMW,0,LParam(it.structPtr))

		MemFree it.item_pszText()

		'Fix for tree-view parent status update problem.
		If Not tmpParentHadKids Then _parent.RedrawNode()

		Return _item

	EndMethod

	Method RedrawNode()

		If _item = TVI_ROOT Then
			InvalidateRect _tree, Null, True
		Else
			Local Rect[] = [Int(_item),0,0,0]
			If SendMessageW(_tree, TVM_GETITEMRECT, False, LParam Byte Ptr Rect) Then
				InvalidateRect _tree, Rect, True
			EndIf
		EndIf

	EndMethod

	Method SetTooltip( pTooltip$ )
		'At the moment, nodes don't support tooltips.
	EndMethod

	Method Class()
		Return GADGET_NODE
	EndMethod

EndType

Type TWindowsTreeView Extends TWindowsGadget

	Field	_root:TWindowsTreeNode
	Field	_selected:TWindowsTreeNode
	Field	_icons:TWindowsIconStrip

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Local	xstyle,wstyle,hotkey
		Local	hwnd:Byte Ptr,parent:Byte Ptr

		Self.style = style
		xstyle=WS_EX_CLIENTEDGE
		wstyle=WS_CHILD|TVS_SHOWSELALWAYS|TVS_NOTOOLTIPS|WS_CLIPSIBLINGS|TVS_HASBUTTONS
		If Not(style&TREEVIEW_WIN32_NO_DECORATION) wstyle:|TVS_HASLINES|TVS_LINESATROOT
		If Not(style&TREEVIEW_DRAGNDROP) wstyle:|TVS_DISABLEDRAGDROP

		parent=group.query(QUERY_HWND_CLIENT)
		hwnd=CreateWindowExW(xstyle,"SysTreeView32","",wstyle,0,0,0,0,parent,Byte Ptr hotkey,GetModuleHandleW(Null),Null)
		If TWindowsGUIDriver.CheckCommonControlVersion() Then SendMessageW hwnd, TVM_SETEXTENDEDSTYLE, TVS_EX_DOUBLEBUFFER, TVS_EX_DOUBLEBUFFER
		Register GADGET_TREEVIEW,hwnd
		_root=New TWindowsTreeNode.CreateRoot(Self)

		If TWindowsGUIDriver._explorerstyle Then UseExplorerTheme()

		Return Self

	EndMethod

	Method SetIconStrip(iconstrip:TIconStrip)
		_icons=TWindowsIconStrip(iconstrip)
		SendMessageW _hwnd,TVM_SETIMAGELIST,TVSIL_NORMAL,LParam(_icons._imagelist)
	EndMethod

	Method SetColor(r,g,b)
		SendMessageW _hwnd,TVM_SETBKCOLOR,0,(b Shl 16)|(g Shl 8)|r
	EndMethod

	Method RemoveColor()
		SendMessageW _hwnd,TVM_SETBKCOLOR,1,0
	EndMethod

	Method SetTextColor(r,g,b)
		SendMessageW _hwnd,TVM_SETTEXTCOLOR,0,(b Shl 16)|(g Shl 8)|r
	EndMethod

	Method RootNode:TGadget()
		Return _root
	EndMethod

	Method SelectedNode:TGadget()
		Return _selected
	EndMethod

	Method CountKids()
		Return _root.CountKids()
	EndMethod

	Method OnNotify(wp:WParam,lp:LParam)
		Local nmhdrPtr:Byte Ptr
		Local itemnew:Byte Ptr
		Local node:TWindowsTreeNode

		Super.OnNotify(wp,lp)	'Tool-tips

		nmhdrPtr=Byte Ptr lp
		Select bmx_win32_NMHDR_code(nmhdrPtr)

			'MSLU glitch requires handling of ANSI equivalent
			Case TVN_SELCHANGEDW, TVN_SELCHANGEDA
				itemnew=bmx_win32_NMTREEVIEW_itemNew(nmhdrPtr)
				'itemnew=nmhdr+14		'Int Ptr(nmhdr[5])	'itemNew
				If bmx_win32_TVITEMW_hItem(itemnew)=TVI_ROOT	'hItem
					_selected=_root
				Else
					_selected=TWindowsTreeNode(HandleToObject(Size_T(bmx_win32_TVITEMW_lParam(itemnew))))	'lParaM
				EndIf
				PostGuiEvent EVENT_GADGETSELECT,0,0,0,0,_selected

			Case TVN_ITEMEXPANDEDW, TVN_ITEMEXPANDEDA
				itemnew=bmx_win32_NMTREEVIEW_itemNew(nmhdrPtr)
				'itemnew=nmhdr+14		'Int Ptr(nmhdr[5])	'itemNew.TVITEM
				If bmx_win32_TVITEMW_hItem(itemnew)=TVI_ROOT		'hItem
					node=_root
				Else
					node=TWindowsTreeNode(HandleToObject(Size_T(bmx_win32_TVITEMW_lParam(itemnew))))	'lParaM
				EndIf
				Select bmx_win32_NMTREEVIEW_action(nmhdrPtr)'nmhdr[3]	'action itemnew[2]&TVIS_EXPANDED	'state
					Case 1
						PostGuiEvent EVENT_GADGETCLOSE,0,0,0,0,node
						node._expanded=False
					Case 2
						PostGuiEvent EVENT_GADGETOPEN,0,0,0,0,node
						node._expanded=True
				End Select
				Return True

			Case TVN_BEGINDRAGW, TVN_BEGINRDRAGW, TVN_BEGINDRAGA, TVN_BEGINRDRAGA

				If (style&TREEVIEW_DRAGNDROP) Then

					Local data% = 1
					If (bmx_win32_NMHDR_code(nmhdrPtr) = TVN_BEGINRDRAGW) Or (bmx_win32_NMHDR_code(nmhdrPtr) = TVN_BEGINRDRAGA) Then data = 2

					'itemnew=nmhdr+14		'Int Ptr(nmhdr[5])	'itemNew
					itemnew=bmx_win32_NMTREEVIEW_itemNew(nmhdrPtr)

					If bmx_win32_TVITEMW_hItem(itemnew)<>TVI_ROOT Then
						TGadget.dragGadget[data-1]=TWindowsTreeNode(HandleToObject(Size_T(bmx_win32_TVITEMW_lParam(itemnew))))
						PostGuiEvent EVENT_GADGETDRAG, data, KeyMods(), bmx_win32_NMTREEVIEW_x(nmhdrPtr), bmx_win32_NMTREEVIEW_y(nmhdrPtr), TGadget.dragGadget[data-1]
					Else
						TGadget.dragGadget[data-1]=Null
					EndIf

				EndIf

			Case NM_DBLCLK, NM_RETURN
				PostGuiEvent EVENT_GADGETACTION,0,0,0,0,_selected

			Case NM_RCLICK
				Local Rect[4]
				Local pt[2]
				'Local hittest[4]
				'Local item[10]
				Local hittest:TVHITTESTINFO = New TVHITTESTINFO
				GetWindowRect _hwnd,Rect
				GetCursorPos_ pt
				hittest.Setx(pt[0]-Rect[0])
				hittest.Sety(pt[1]-Rect[1])
				If SendMessageW(_hwnd,TVM_HITTEST,0,LParam(hittest.infoPtr))
					If hittest.flags()=TVI_ROOT
						node=_root
					Else
						Local item:TVITEMW = New TVITEMW
						item.Setmask(TVIF_PARAM)
						item.SethItem(hittest.hItem())
						SendMessageW _hwnd,TVM_GETITEMW,0,LParam(item.itemPtr)
						node=TWindowsTreeNode(HandleToObject(Size_T(item.LParam())))
					EndIf
					PostGuiEvent EVENT_GADGETMENU,0,0,hittest.x(),hittest.y(),node
				EndIf
				Return True

		EndSelect
	EndMethod

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
		Select msg
			'If we are using Vista's common controls, then the treeview will be double-buffered and so
			'we don't need to clear the background when redrawing (performance tweak).
			Case WM_ERASEBKGND
				If TWindowsGUIDriver.CheckCommonControlVersion() >= 2 Then Return 1
		EndSelect
		Return Super.WndProc(hwnd,msg,wp,lp)
	EndMethod

	Method UseExplorerTheme()

		If TWindowsGUIDriver.CheckCommonControlVersion() Then
			SetWindowTheme( _hwnd, _wstrExplorer, Null )
			SendMessageW _hwnd, TVM_SETEXTENDEDSTYLE, TVS_EX_FADEINOUTEXPANDOS, TVS_EX_FADEINOUTEXPANDOS
		EndIf

	EndMethod

	Method Class()
		Return GADGET_TREEVIEW
	EndMethod

EndType

Type TWindowsHTMLView Extends TWindowsGadget

	Field mshtml:Byte Ptr
	Field browser:IWebBrowser2_

	Field IID_IHTMLDocument2:GUID=New GUID

	Method Create:TWindowsGadget(group:TGadget,style,Text$="")
		Self.style = style
		Local parent:Byte Ptr=group.query(QUERY_HWND_CLIENT)
		mshtml=msHtmlCreate(Self,TWindowsGUIDriver.ClassName(),parent,style)
		msHTMLBrowser(mshtml, Varptr browser)
		Register GADGET_HTMLVIEW,msHtmlHwnd(mshtml)

		Local res = IIDFromString(IHTMLDocument2_UUID,IID_IHTMLDocument2)

		Return Self
	EndMethod

	Method Rethink()
		msHtmlSetShape mshtml,xpos,ypos,width,height
	EndMethod

	Method SetText(Text$)	'sets document url
		If Text Then msHtmlGo mshtml,Text
	EndMethod

	Method GetText$()
		Local bstr:Short Ptr
		browser.lfget_LocationURL(Varptr bstr)
		Local result$ = String.FromWString(bstr)
		SysFreeString(bstr)
		Return result
	EndMethod

	Method GetTitleText$()	'returns document title

		Local bstr:Short Ptr
		Local res

		Local disp:IDispatch_
		Local doc:IHTMLDOCUMENT2_

		res=browser.lfget_Document(Varptr disp)
		If res RuntimeError "no document"

		res=disp.QueryInterface(IID_IHTMLDocument2,doc)
		If res RuntimeError "no document2 interface"

		If doc
			doc.get_Title(Varptr bstr)
		Else
			browser.lfget_LocationName(Varptr bstr)
		EndIf

		Local result$ = String.FromWString(bstr)
		SysFreeString(bstr)
		Return result

	End Method

	Method Activate(cmd)
		Return msHtmlActivate(mshtml,cmd)
	EndMethod

	Method State()
		Return msHtmlStatus(mshtml)
	EndMethod

	Method Run$(script$)
		msHtmlRun(mshtml,script)
	EndMethod

	Method WndProc:Byte Ptr(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam)
		Select msg
			'Reduces flicker on HTMLViews
			Case WM_ERASEBKGND
				Return 1
		EndSelect
		Return Super.WndProc(hwnd,msg,wp,lp)
	EndMethod

	Method Class()
		Return GADGET_HTMLVIEW
	EndMethod

EndType

'A collection of functions that convert between Blitz pixmaps and Windows icons/bitmaps.
Type TWindowsGraphic Final

	Function BitmapMaskFromPixmap:Byte Ptr(pix:TPixmap)

		Local x, pix2:TPixmap, usealpha

		If PixmapFormat(pix) = PF_RGBA8888 Or PixmapFormat(pix) = PF_BGRA8888 Then usealpha = True

		pix2=ConvertPixmap(pix,PF_BGR888);ClearPixels(pix2)

		For Local y:Int = 0 Until pix.height
			For x = 0 Until pix.width
				If usealpha
					If (ReadPixel(pix,x,y) Shr 24) < 128 Then WritePixel(pix2,x,y,$FFFFFF)
				Else
					If (ReadPixel(pix,x,y) & $FFFFFF) = $FFFFFF Then WritePixel(pix2,x,y,$FFFFFF)
				EndIf
			Next
		Next

		Return BitmapFromPixmap(pix2,False)

	EndFunction

	Function PreMultipliedBitmapFromPixmap32:Byte Ptr( pix:TPixmap )

		Local argb, a
		Local pix2:TPixmap = CreatePixmap( pix.width, pix.height, pix.format), x

		For Local y:Int = 0 Until pix.height
			For x = 0 Until pix.width
				argb = ReadPixel(pix,x,y)
				a = ((argb Shr 24) & $FF)
				WritePixel(pix2,x,y,((((argb&$ff00ff)*a)Shr 8)&$ff00ff)|((((argb&$ff00)*a)Shr 8)&$ff00)|(a Shl 24))
			Next
		Next

		Return BitmapFromPixmap(pix2,True)

	EndFunction

	Function BitmapFromPixmap:Byte Ptr(pix:TPixmap, alpha:Int = True)

		Local bitCount:Int = 32, format:Int = PF_BGRA8888, bm:Byte Ptr

		If Not alpha Then
			bitCount = 24
			format = PF_BGR888
		EndIf

		pix=ConvertPixmap(pix,format)

		Local hdc:Byte Ptr = GetDC(0)

		Local bi:BITMAPINFOHEADER = New BITMAPINFOHEADER
		bi.SetbiWidth(pix.width)
		bi.SetbiHeight(-pix.height)
		bi.SetbiPlanes(1)
		bi.SetbiBitCount(bitCount)
		bi.SetbiCompression(BI_RGB)

		Local bits:Byte Ptr
		Local src:Byte Ptr = pix.pixels

		If alpha
			bm = CreateDibSection(hdc,bi.infoPtr,DIB_RGB_COLORS,Varptr bits,Null,0)
		Else
			bm = CreateCompatibleBitmap(hdc,pix.width,pix.height)
		EndIf

		Assert bm, "Cannot create bitmap.  The computer may be running low on resources."

		For Local y:Int = 0 Until pix.height
			SetDIBits(hdc,bm,UInt(pix.height-y-1),1,src,bi.infoPtr,DIB_RGB_COLORS)
			src:+pix.pitch
		Next

		ReleaseDC(Null,hdc)

		Return bm

	EndFunction

	Function BitmapWithBackgroundFromPixmap32:Byte Ptr( pix:TPixmap, pRed, pGreen, pBlue )

		Local tmpPixel, tmpRed, tmpGreen, tmpBlue, tmpAlpha, tmpAlphaFloat#, tmpAlphaFloat2#
		Local pix2:TPixmap = CreatePixmap( pix.width, pix.height, pix.format), x

		For Local y:Int = 0 Until pix.height
			For x = 0 Until pix.width

				'Read pixel and alpha info
				tmpPixel = ReadPixel(pix,x,y)
				tmpAlpha = ((tmpPixel Shr 24) & $FF)
				tmpAlphaFloat = tmpAlpha/255.0
				tmpAlphaFloat2 = 1-tmpAlphaFloat

				'Get individual colours
				tmpBlue = tmpPixel & $FF;tmpGreen = (tmpPixel Shr 8) & $FF;tmpRed = (tmpPixel Shr 16)&$FF

				'Courtesy of Mark T
				tmpRed = (tmpRed * tmpAlphaFloat) + (tmpAlphaFloat2 * pRed)
				tmpGreen = (tmpGreen * tmpAlphaFloat) + (tmpAlphaFloat2  * pGreen)
				tmpBlue = (tmpBlue * tmpAlphaFloat) + (tmpAlphaFloat2  * pBlue)

				'Write the new pixels
				WritePixel(pix2,x,y,(tmpAlpha Shl 24)|(tmpRed Shl 16)|(tmpGreen Shl 8)|tmpBlue)
			Next
		Next

		Return BitmapFromPixmap(pix2,False)

	EndFunction

	Function IconFromPixmap32:Byte Ptr(pix:TPixmap)

		' Convert the pixmap to a HBITMAP
		Local bitmap:Byte Ptr = BitmapFromPixmap(pix,True)

		' and then copy/resize it (to the default size for icons/cusors).
		Local hSrcBMP:Byte Ptr = CopyImage(bitmap, IMAGE_BITMAP , 0 , 0 , LR_DEFAULTSIZE)

		' Now we need to create a mask bitmap for the image
		Local hMaskBMP:Byte Ptr = BitmapMaskFromPixmap( pix )

		' So now we have our source and mask bitmaps, we can create an ICONINFO structure
		Local IconInf:ICONINFO = New ICONINFO
		IconInf.SetfIcon(True)
		IconInf.SethbmMask(hMaskBMP)
		IconInf.SethbmColor(hSrcBMP)

		' Create the icon
		Local tmpIcon:Byte Ptr = CreateIconIndirect(IconInf)

		' Free our temporary bitmaps
		DeleteObject(hMaskBMP)
		DeleteObject(hSrcBMP)
		DeleteObject(bitmap)

		Return tmpIcon

	EndFunction

EndType

Rem
bbdoc: A base type for text area gadgets.
about: Implementations are in seperate modules, except for the default TGTKDefaultTextArea
End Rem
Type TWindowsTextArea Extends TWindowsGadget
	Global _oldCursor:Byte Ptr = 0

	Method Create:TWindowsGadget(group:TGadget,style,Text$="") Abstract
End Type


Type TWindowsTextAreaDriver
	Function CreateTextArea:TWindowsGadget(group:TGadget,style,Text$="") Abstract
End Type

' default text area driver
Type TWindowsDefaultTextAreaDriver Extends TWindowsTextAreaDriver
	Function CreateTextArea:TWindowsGadget(group:TGadget,style,Text$="")
		Return New TWindowsDefaultTextArea.Create(group, style, Text)
	End Function
End Type

Global windowsmaxguiex_textarea:TWindowsTextAreaDriver


Private

Function KeyMods()
	Local mods
	If GetKeyState(VK_SHIFT)&$8000 mods:|MODIFIER_SHIFT
	If GetKeyState(VK_CONTROL)&$8000 mods:|MODIFIER_CONTROL
	If GetKeyState(VK_MENU)&$8000 mods:|MODIFIER_OPTION
	If GetKeyState(VK_LWIN)&$8000 Or GetKeyState(VK_RWIN)&$8000 mods:|MODIFIER_SYSTEM
	Return mods
EndFunction

Function FindGadgetWindowHwnd:Byte Ptr(g:TGadget)
	Local wg:TWindowsWindow
	While g
		wg=TWindowsWindow(g)
		If wg Return wg.Query(QUERY_HWND)	'handle
		g=g.parent
	Wend
EndFunction

?
