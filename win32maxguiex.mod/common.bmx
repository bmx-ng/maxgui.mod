Strict

Import pub.win32

Import "-lcomdlg32"
Import "-lole32"
Import "-loleaut32"
Import "-luuid"
Import "-lmsimg32"
Import "-lshell32"
Import "-lcomctl32"
Import "-luxtheme"

'Import "commctrl.h"

Import "*.h"
Import "mshtmlview.cpp"
Import "glue.cpp"


Extern

	Function bmx_win32maxgui_choosecolor_new:Byte Ptr(parent:Byte Ptr, rgb:Int, customColors:Int Ptr, flags:Int)
	Function bmx_win32maxgui_choosecolor_ChooseColor:Int(handle:Byte Ptr)
	Function bmx_win32maxgui_choosecolor_free(handle:Byte Ptr)
	Function bmx_win32maxgui_choosecolor_rgbResult:Int(handle:Byte Ptr)
	
	Function SystemParametersInfoW:Int(uiAction:UInt, uiParam:UInt, pvParam:Byte Ptr, fWinIni:Uint) "win32"
	Function SetLayeredWindowAttributes:Int(hwnd:Byte Ptr,crKey:Int,bAlpha:Byte,dwFlags:Int) "win32"
	Function OpenThemeData:Byte Ptr( hwnd:Byte Ptr, lpszClassString:Short Ptr ) "win32"
	Function CloseThemeData( hTheme:Byte Ptr ) "win32"
	Function SetWindowTheme:Byte Ptr( pHwnd:Byte Ptr, pThemeStr:Short Ptr, pList:Short Ptr ) "win32"
	Function IsThemeBackgroundPartiallyTransparent( hTheme:Byte Ptr, iPartId%, iStateId% ) "win32"
	Function DrawThemeParentBackground:Byte Ptr(hwnd:Byte Ptr,hDC:Byte Ptr,pRect:Int Ptr) "win32"
	Function DrawThemeBackground:Byte Ptr( hTheme:Byte Ptr, hdc:Byte Ptr, iPartID%, iStateID%, pRect:Int Ptr, pClipRect:Int Ptr) "win32"
	Function GetThemeBackgroundContentRect:Byte Ptr( hTheme:Byte Ptr, hdc:Byte Ptr, iPartId%, iStateId%, pBoundingRect:Int Ptr, pContentRect:Int Ptr ) "win32"

	Function msHtmlCreate:Byte Ptr( owner:Object,wndclass$w,hwnd:Byte Ptr,flags )
	Function msHtmlGo( handle:Byte Ptr,url$w )
	Function msHtmlRun( handle:Byte Ptr,script$w )
	Function msHtmlSetShape( handle:Byte Ptr,x,y,w,h )
	Function msHtmlSetVisible( handle:Byte Ptr,visible )
	Function msHtmlSetEnabled( handle:Byte Ptr,enabled )
	Function msHtmlActivate(handle:Byte Ptr,cmd)
	Function msHtmlStatus(handle:Byte Ptr)
	Function msHtmlHwnd:Byte Ptr(handle:Byte Ptr)
	Function msHtmlBrowser(handle:Byte Ptr, browser:IWebBrowser2_ Var)
	Function mstmlDocument:Byte Ptr(handle:Byte Ptr)

End Extern

' Custom Window Messages

Const WM_MAXGUILISTREFRESH% = WM_APP + $100

'Error Codes
	
Const S_OK:Int = 0

Const E_OUTOFMEMORY=$8007000E
Const E_INVALIDARG=$80070057
Const E_ACCESSDENIED=$80070005

' WM_SIZE message wParam values

Const SIZE_RESTORED=0
Const SIZE_MINIMIZED=1
Const SIZE_MAXIMIZED=2
Const SIZE_MAXSHOW=3
Const SIZE_MAXHIDE=4

'Tool-tips

Const TTS_ALWAYSTIP% = $1
Const TTS_NOPREFIX% = $2
Const TTS_NOANIMATE% = $10
Const TTS_NOFADE% = $20
Const TTS_BALLOON% = $40

Const LPSTR_TEXTCALLBACK% = -1
'Const TTM_ADDTOOLW% = (WM_USER + 50)

'WM_MENUCHAR Return Constants

Const MNC_IGNORE% = 0
Const MNC_CLOSE% = 1
Const MNC_EXECUTE% = 2
Const MNC_SELECT% = 3

'MK Constants

Const MK_CONTROL% = $8
Const MK_LBUTTON% = $1
Const MK_MBUTTON% = $10
Const MK_RBUTTON% = $2
Const MK_SHIFT% = $4
Const MK_XBUTTON1% = $20
Const MK_XBUTTON2% = $40


Const SPI_GETWORKAREA:Int = 48
Const SPI_GETNONCLIENTMETRICS:Int = 41

'Button Image
Const BCM_FIRST = $1600
Const BCM_SETIMAGELIST% = BCM_FIRST+2

Const BUTTON_IMAGELIST_ALIGN_LEFT%		= 0
Const BUTTON_IMAGELIST_ALIGN_RIGHT%	= 1
Const BUTTON_IMAGELIST_ALIGN_TOP%		= 2
Const BUTTON_IMAGELIST_ALIGN_BOTTOM%	= 3
Const BUTTON_IMAGELIST_ALIGN_CENTER%	= 4

'ComboBox cue-banners
Const CBM_FIRST = $1700
Const CB_SETCUEBANNER = CBM_FIRST + 3

'Progress bar colors
'Const PBM_SETBARCOLOR=WM_USER+9
Const PBM_SETBKCOLOR=CCM_FIRST+1

'SetBkMode() consts, etc.
Const LWA_COLORKEY=1
Const LWA_ALPHA=2
Const LWA_BOTH=3
Const TRANSPARENT=1
Const OPAQUE = 2

'RedrawWindow() flags
Const RDW_FRAME = $500
Const RDW_UPDATENOW = $100
Const RDW_INVALIDATE = $1
Const RDW_NOCHILDREN = $40
Const RDW_ALLCHILDREN = $80
Const RDW_ERASE = $4
Const RDW_ERASENOW = $200

'ScrollBar constants
Const OBJID_HSCROLL = $FFFFFFFA
Const OBJID_VSCROLL = $FFFFFFFB
Const OBJID_CLIENT = $FFFFFFFC

Const EM_GETSCROLLPOS = WM_USER + 221
Const EM_SETSCROLLPOS = WM_USER + 222
Const EM_SETZOOM = WM_USER + 225

'GetDCEx Constants
Const DCX_WINDOW = $1
Const DCX_CACHE = $2
Const DCX_NORESETATTRS = $4
Const DCX_CLIPCHILDREN = $8
Const DCX_CLIPSIBLINGS = $10
Const DCX_PARENTCLIP = $20
Const DCX_EXCLUDERGN = $40
Const DCX_INTERSECTRGN = $80
Const DCX_EXCLUDEUPDATE = $100
Const DCX_INTERSECTUPDATE = $200
Const DCX_LOCKWINDOWUPDATE = $400
Const DCX_VALIDATE = $200000

Const WM_THEMECHANGED = $31A

'Icon Stuff

'Const LR_DEFAULTSIZE = $40

'Type ICONINFO
'Field fIcon
'Field xHotspot
'Field yHotspot
'Field hbmMask
'Field hbmColor
'EndType

'Treeview Consts

Const TVM_FIRST = $1100
Const TVS_EX_DOUBLEBUFFER = $4
Const TVS_EX_FADEINOUTEXPANDOS = $40
Const TVM_SETEXTENDEDSTYLE = TVM_FIRST + 44

Const TTN_GETDISPINFOW = -530

'System State Contstants

Const STATE_SYSTEM_UNAVAILABLE = $00000001
Const STATE_SYSTEM_SELECTED = $00000002
Const STATE_SYSTEM_FOCUSED = $00000004
Const STATE_SYSTEM_PRESSED = $00000008
Const STATE_SYSTEM_CHECKED = $00000010
Const STATE_SYSTEM_MIXED = $00000020
Const STATE_SYSTEM_READONLY = $00000040
Const STATE_SYSTEM_HOTTRACKED = $00000080
Const STATE_SYSTEM_DEFAULT = $00000100
Const STATE_SYSTEM_EXPANDED = $00000200
Const STATE_SYSTEM_COLLAPSED = $00000400
Const STATE_SYSTEM_BUSY = $00000800
Const STATE_SYSTEM_FLOATING = $00001000
Const STATE_SYSTEM_MARQUEED = $00002000
Const STATE_SYSTEM_ANIMATED = $00004000
Const STATE_SYSTEM_INVISIBLE = $00008000
Const STATE_SYSTEM_OFFSCREEN = $00010000
Const STATE_SYSTEM_SIZEABLE = $00020000
Const STATE_SYSTEM_MOVEABLE = $00040000
Const STATE_SYSTEM_SELFVOICING = $00080000
Const STATE_SYSTEM_FOCUSABLE = $00100000
Const STATE_SYSTEM_SELECTABLE = $00200000
Const STATE_SYSTEM_LINKED = $00400000
Const STATE_SYSTEM_TRAVERSED = $00800000
Const STATE_SYSTEM_MULTISELECTABLE = $01000000
Const STATE_SYSTEM_EXTSELECTABLE = $02000000
Const STATE_SYSTEM_ALERT_LOW = $04000000
Const STATE_SYSTEM_ALERT_MEDIUM = $08000000
Const STATE_SYSTEM_ALERT_HIGH = $10000000
Const STATE_SYSTEM_VALID = $1FFFFFFF


'System Metrics

Const SM_CXSCREEN = 0
Const SM_CYSCREEN = 1
Const SM_CXVSCROLL = 2
Const SM_CYHSCROLL = 3
Const SM_CYCAPTION = 4
Const SM_CXBORDER = 5
Const SM_CYBORDER = 6
Const SM_CXDLGFRAME = 7
Const SM_CYDLGFRAME = 8
Const SM_CYVTHUMB = 9
Const SM_CXHTHUMB = 10
Const SM_CXICON = 11
Const SM_CYICON = 12
Const SM_CXCURSOR = 13
Const SM_CYCURSOR = 14
Const SM_CYMENU = 15
Const SM_CXFULLSCREEN = 16
Const SM_CYFULLSCREEN = 17
Const SM_CYKANJIWINDOW = 18
Const SM_MOUSEPRESENT = 19
Const SM_CYVSCROLL = 20
Const SM_CXHSCROLL = 21
Const SM_DEBUG = 22
Const SM_SWAPBUTTON = 23
Const SM_RESERVED1 = 24
Const SM_RESERVED2 = 25
Const SM_RESERVED3 = 26
Const SM_RESERVED4 = 27
Const SM_CXMIN = 28
Const SM_CYMIN = 29
Const SM_CXSIZE = 30
Const SM_CYSIZE = 31
Const SM_CXFRAME = 32
Const SM_CYFRAME = 33
Const SM_CXMINTRACK = 34
Const SM_CYMINTRACK = 35
Const SM_CXDOUBLECLK = 36
Const SM_CYDOUBLECLK = 37
Const SM_CXICONSPACING = 38
Const SM_CYICONSPACING = 39
Const SM_MENUDROPALIGNMENT = 40
Const SM_PENWINDOWS = 41
Const SM_DBCSENABLED = 42
Const SM_CMOUSEBUTTONS = 43
Const SM_CXFIXEDFRAME = SM_CXDLGFRAME
Const SM_CYFIXEDFRAME = SM_CYDLGFRAME
Const SM_CXSIZEFRAME = SM_CXFRAME
Const SM_CYSIZEFRAME = SM_CYFRAME
Const SM_SECURE = 44
Const SM_CXEDGE = 45
Const SM_CYEDGE = 46
Const SM_CXMINSPACING = 47
Const SM_CYMINSPACING = 48
Const SM_CXSMICON = 49
Const SM_CYSMICON = 50
Const SM_CYSMCAPTION = 51
Const SM_CXSMSIZE = 52
Const SM_CYSMSIZE = 53
Const SM_CXMENUSIZE = 54
Const SM_CYMENUSIZE = 55
Const SM_ARRANGE = 56
Const SM_CXMINIMIZED = 57
Const SM_CYMINIMIZED = 58
Const SM_CXMAXTRACK = 59
Const SM_CYMAXTRACK = 60
Const SM_CXMAXIMIZED = 61
Const SM_CYMAXIMIZED = 62
Const SM_NETWORK = 63
Const SM_CLEANBOOT = 67
Const SM_CXDRAG = 68
Const SM_CYDRAG = 69
Const SM_SHOWSOUNDS = 70
Const SM_CXMENUCHECK = 71
Const SM_CYMENUCHECK = 72
Const SM_SLOWMACHINE = 73
Const SM_MIDEASTENABLED = 74
Const SM_MOUSEWHEELPRESENT = 75
Const SM_XVIRTUALSCREEN = 76
Const SM_YVIRTUALSCREEN = 77
Const SM_CXVIRTUALSCREEN = 78
Const SM_CYVIRTUALSCREEN = 79
Const SM_CMONITORS = 80
Const SM_SAMEDISPLAYFORMAT = 81
Const SM_CMETRICS = 83



'External functions
Extern "Win32"
	
'		Function GetCharABCWidthsW(dc,firstcharcode,lastcharcode,widths:Int Ptr Ptr)
	Function GetCharABCWidthsW(dc:Byte Ptr,firstcharcode:UInt,lastcharcode:UInt,widths:Int Ptr)

	Function GetCharWidth32W(hdc:Byte Ptr,first:Uint,last:UInt,widths:Int Ptr)
	
	'BRL.System
	'Function _TrackMouseEvent( trackmouseeventstrunct:Byte Ptr )
	
	'Imagelists and pixmap conversion
	'Function ImageList_Add(himl:Byte Ptr,hbmImage:Byte Ptr,crMask)
	'Function ImageList_Destroy( hImageList:Byte Ptr )
	'Function ImageList_GetImageCount( hImageList:Byte Ptr )
	Function CreateDIBSection(hdc:Byte Ptr,bminfo:Byte Ptr,iUsage:UInt,bits:Byte Ptr Ptr,hSection:Byte Ptr,dwOffset)
	Function SendMessageSetImageList(hwnd:Byte Ptr, _buttonImageList:Byte Ptr Ptr, _imageAlign:Int)
	
	'WM_CTLCOLORXXXX handling
	Function SetBkMode( hdc:Byte Ptr, mode)
	Function SetBkColor( hdc:Byte Ptr, crColor )
	Function GetAncestor_:Byte Ptr( hwnd:Byte Ptr, gaFlags ) = "GetAncestor"
	Function SetTextColor_( hdc:Byte Ptr, crColor ) = "SetTextColor"
	
	'Drawing Contexts
	Function GetObjectW( hgdiobj:Byte Ptr, cbBuffer, lpvObject:Byte Ptr )
	Function SaveDC( hdc:Byte Ptr )
	Function RestoreDC( hdc:Byte Ptr, savestate )
	Function CreatePatternBrush:Byte Ptr( bitmap:Byte Ptr )
	Function GetDCEx:Byte Ptr( hwnd:Byte Ptr, hRgn:Byte Ptr, flags )
	Function ReleaseDC( hwnd:Byte Ptr, hdc:Byte Ptr )
	Function GetDCOrgEx( hdc:Byte Ptr, point:Int Ptr )
	Function GetWindowOrgEx( hdc:Byte Ptr, point:Int Ptr )
	Function GetWindowExtEx( hdc:Byte Ptr, size:Int Ptr )

	'Drawing
	Function DrawTextW( hdc:Byte Ptr, lpString$w, nCount, lpRect:Int Ptr, uFormat )
	Function DrawFocusRect( hdc:Byte Ptr, lprc:Int Ptr )
	Function DrawFrameControl( hdc:Byte Ptr, lprc:Int Ptr, uType%, uState% )
	Function ExtTextOutW( hdc:Byte Ptr, x, y, fuOptions, lpRc:Int Ptr, lpString$w, cbCount, lpDx:Int Ptr )
	
	'Resizing
	Function BeginDeferWindowPos:Byte Ptr( nCount )
	Function EndDeferWindowPos( hdwpStruct:Byte Ptr )
	Function DeferWindowPos:Byte Ptr( hWinPosInfo:Byte Ptr, hWnd:Byte Ptr, hWndInsertAfter:Byte Ptr, x, y, cx, cy, uFlags)
	
	'Position and regions
	Function IsRectEmpty( rect:Int Ptr )
	Function GetClipBox( hdc:Byte Ptr, rect:Int Ptr)
	Function GetUpdateRect( hwnd:Byte Ptr, rect:Int Ptr, pErase )
	Function ScreenToClient( hwnd:Byte Ptr, rect:Int Ptr )
	Function RedrawWindow(hwnd:Byte Ptr, lprcUpdate:Int Ptr, hrgnUpdate:Int Ptr, flags )
	Function FrameRect( hdc:Byte Ptr, rect:Int Ptr, hBrush:Byte Ptr )
	Function InflateRect( rect:Int Ptr, dx, dy )
	Function OffsetRect( rect:Int Ptr, dx, dy )
	Function IntersectRect( lprcDest:Int Ptr, lprcSrc1:Int Ptr, lprcSrc2:Int Ptr )
	Function CopyRect( dest:Int Ptr, src:Int Ptr )
	Function GDISetRect( rect:Int Ptr, xLeft, yTop, xRight, yBottom ) = "SetRect"
	
	'Menu Stuff
	Function GetMenu_:Byte Ptr( hwnd:Byte Ptr ) = "GetMenu"
	Function SetMenuItemBitmaps( hMenu:Byte Ptr, uPosition, uFlags, hBitmapUnchecked:Byte Ptr, hBitmapChecked:Byte Ptr )
	Function SetMenuInfo( hMenu:Byte Ptr, lpcMenuInfo:Byte Ptr )
	Function GetSysColor( hColor )
	
	'Scroll-bar fixes
	Function GetSystemMetrics( metric )
	Function GetScrollBarInfo( hwnd:Byte Ptr, idObject, pScrollBarInfo:Int Ptr )
	
	'Gadget text retrieval
	Function GetWindowTextLengthW( hwnd:Byte Ptr )
	
	'Missing misc. system functions
	Function GetCursor:Byte Ptr()
	Function FreeLibrary( hLibrary:Byte Ptr )
	
	'Printing functions for text-area GadgetPrint()
	Function PrintDlg( printDialogStruct:Byte Ptr ) = "PrintDlgW"
	Function StartDocW( hdc:Byte Ptr, pDocStruct:Byte Ptr )
	Function EndDoc( hdc:Byte Ptr )
	Function AbortDoc( hdc:Byte Ptr )
	Function StartPage( hdc:Byte Ptr )
	Function EndPage( hdc:Byte Ptr )
	Function SetMapMode( hdc:Byte Ptr, pMode )
	Function PrintWindow( hwnd:Byte Ptr, hdc:Byte Ptr, flags )

	'Icons
	Function CreateIconIndirect:Byte Ptr(IconInf:Byte Ptr)
	Function CopyImage:Byte Ptr(hImage:Byte Ptr , uType , xDesired , yDesired , flags)
	Function DestroyIcon(hIcon:Byte Ptr)

EndExtern

Extern
	Function AlphaBlend_(hdc:Byte Ptr,dx,dy,dw,dh,hdc2:Byte Ptr,src,sry,srcw,srch,rop)="AlphaBlendArgs"
End Extern

Extern
	Function bmx_win32_DLLVERSIONINFO2_new:Byte Ptr()
	Function bmx_win32_DLLVERSIONINFO2_free(handle:Byte Ptr)
	Function bmx_win32_DLLVERSIONINFO2_dwMajorVersion:Int(handle:Byte Ptr)
	Function bmx_win32_DLLVERSIONINFO2_dwMinorVersion:Int(handle:Byte Ptr)
	Function bmx_win32_DLLVERSIONINFO2_dwBuildNumber:Int(handle:Byte Ptr)
End Extern

Type DLLVERSIONINFO2
	Field infoPtr:Byte Ptr

	Method New()
		infoPtr = bmx_win32_DLLVERSIONINFO2_new()
	End Method
	
	Method Delete()
		Free()
	End Method
	
	Method Free()
		If infoPtr Then
			bmx_win32_DLLVERSIONINFO2_free(infoPtr)
			infoPtr = Null
		End If
	End Method

	Method dwMajorVersion:Int()
		Return bmx_win32_DLLVERSIONINFO2_dwMajorVersion(infoPtr)
	End Method
	
	Method dwMinorVersion:Int()
		Return bmx_win32_DLLVERSIONINFO2_dwMinorVersion(infoPtr)
	End Method
	
	Method dwBuildNumber:Int()
		Return bmx_win32_DLLVERSIONINFO2_dwBuildNumber(infoPtr)
	End Method

'	Field cbSize = SizeOf(Self), dwMajorVersion, dwMinorVersion, dwBuildNo, dwPlatformID
'	Field dwFlags, ulVersion:Long
EndType

Extern
	Function bmx_win32_DRAWITEMSTRUCT_new:Byte Ptr()
	Function bmx_win32_DRAWITEMSTRUCT_free(handle:Byte Ptr)
	Function bmx_win32_DRAWITEMSTRUCT_CtlType:Uint(handle:Byte Ptr)
	Function bmx_win32_DRAWITEMSTRUCT_CtlID:Uint(handle:Byte Ptr)
	Function bmx_win32_DRAWITEMSTRUCT_itemID:Uint(handle:Byte Ptr)
	Function bmx_win32_DRAWITEMSTRUCT_itemAction:Uint(handle:Byte Ptr)
	Function bmx_win32_DRAWITEMSTRUCT_hwndItem:Byte Ptr(handle:Byte Ptr)
	Function bmx_win32_DRAWITEMSTRUCT_hDC:Byte Ptr(handle:Byte Ptr)
	Function bmx_win32_DRAWITEMSTRUCT_rcItem:Int Ptr(handle:Byte Ptr)
	Function bmx_win32_DRAWITEMSTRUCT_itemState:UInt(handle:Byte Ptr)
	Function bmx_win32_DRAWITEMSTRUCT_itemData:Byte Ptr(handle:Byte Ptr)
End Extern
'DrawItemStruct
Type DRAWITEMSTRUCT
	Field itemPtr:Byte Ptr

	Field _owner:Int = True

	Method New()
		itemPtr = bmx_win32_DRAWITEMSTRUCT_new()
	End Method
	
	Function _create:DRAWITEMSTRUCT(handle:Byte Ptr)
		Local this:DRAWITEMSTRUCT = New DRAWITEMSTRUCT
		this.Free()
		this._owner = False
		this.itemPtr = handle
		Return this
	End Function

	Method Delete()
		Free()
	End Method
	
	Method Free()
		If _owner And itemPtr Then
			bmx_win32_DRAWITEMSTRUCT_free(itemPtr)
		End If
		itemPtr = Null
	End Method

	Method CtlType:UInt()
		Return bmx_win32_DRAWITEMSTRUCT_CtlType(itemPtr)
	End Method
	
	Method CtlID:UInt()
		Return bmx_win32_DRAWITEMSTRUCT_CtlID(itemPtr)
	End Method
	
	Method itemID:UInt()
		Return bmx_win32_DRAWITEMSTRUCT_itemID(itemPtr)
	End Method
	
	Method itemAction:UInt()
		Return bmx_win32_DRAWITEMSTRUCT_itemAction(itemPtr)
	End Method
	
	Method hwndItem:Byte Ptr()
		Return bmx_win32_DRAWITEMSTRUCT_hwndItem(itemPtr)
	End Method
	
	Method hDC:Byte Ptr()
		Return bmx_win32_DRAWITEMSTRUCT_hDC(itemPtr)
	End Method
	
	Method rcItem:Int Ptr()
		Return bmx_win32_DRAWITEMSTRUCT_rcItem(itemPtr)
	End Method
	
	Method itemState:UInt()
		Return bmx_win32_DRAWITEMSTRUCT_itemState(itemPtr)
	End Method
	
	Method itemData:Byte Ptr()
		Return bmx_win32_DRAWITEMSTRUCT_itemData(itemPtr)
	End Method
	
'	Field CtlType, CtlID, ItemID, ItemAction, ItemState
'	Field hwndItem, hDC, rcItem_Left, rcItem_Top, rcItem_Right, rcItem_Bottom, itemData
EndType

'WM_DRAWITEM States
Const ODS_SELECTED = $1
Const ODS_GRAYED = $2
Const ODS_DISABLED = $4
Const ODS_CHECKED = $8
Const ODS_FOCUS = $10
Const ODS_HOTLIGHT = $40
Const ODS_INACTIVE = $80
Const ODS_NOACCEL = $100
Const ODS_NOFOCUSRECT = $200

'DrawThemeBackground Button States
Const BP_PUSHBUTTON = 1
Const PBS_NORMAL = 1
Const PBS_HOT = 2
Const PBS_PRESSED = 3
Const PBS_DISABLED = 4
Const PBS_DEFAULTED = 5

'DrawFrameControl Constants
Const DFC_BUTTON = $4
Const DFCS_BUTTONPUSH = $10
Const DFCS_INACTIVE = $100
Const DFCS_PUSHED = $200
Const DFCS_CHECKED = $400
Const DFCS_TRANSPARENT = $800
Const DFCS_HOT = $1000
Const DFCS_ADJUSTRECT = $2000
Const DFCS_FLAT = $4000
Const DFCS_MONO = $8000

'DrawText Constants
Const DT_BOTTOM= $8
Const DT_CALCRECT= $400
Const DT_CENTER= $1
Const DT_EDITCONTROL= $2000
Const DT_END_ELLIPSIS= $8000
Const DT_EXPANDTABS = $40
Const DT_EXTERNALLEADING = $200
Const DT_HIDEPREFIX = $100000
Const DT_INTERNAL = $1000
Const DT_LEFT = $0
Const DT_MODIFYSTRING = $10000
Const DT_NOCLIP = $100
Const DT_NOFULLWIDTHCHARBREAK = $80000
Const DT_NOPREFIX = $800
Const DT_NOT_SPECIFIC = $50000
Const DT_PATH_ELLIPSIS = $4000
Const DT_PREFIXONLY = $200000
Const DT_RIGHT = $2
Const DT_RTLREADING = $20000
Const DT_SINGLELINE = $20
Const DT_TABSTOP = $80
Const DT_TOP = $0
Const DT_VCENTER = $4
Const DT_WORD_ELLIPSIS = $40000
Const DT_WORDBREAK = $10

'TextArea Gadget Printing
Const MM_TEXT = 1

Extern
	Function bmx_win32_NONCLIENTMETRICSW_new:Byte Ptr()
	Function bmx_win32_NONCLIENTMETRICSW_free(handle:Byte Ptr)
	Function bmx_win32_NONCLIENTMETRICSW_lfMessageFont:Byte Ptr(handle:Byte Ptr)
End Extern
Type NONCLIENTMETRICSW
	Field metricsPtr:Byte Ptr
	
	Method New()
		metricsPtr = bmx_win32_NONCLIENTMETRICSW_new()
	End Method

	Method Delete()
		Free()
	End Method
	
	Method Free()
		If metricsPtr Then
			bmx_win32_NONCLIENTMETRICSW_free(metricsPtr)
			metricsPtr = Null
		End If
	End Method

	Method lfMessageFont:LOGFONTW()
		Return LOGFONTW._create(bmx_win32_NONCLIENTMETRICSW_lfMessageFont(metricsPtr))
	End Method
	
End Type

Extern
	Function bmx_win32_MOUSEHOOKSTRUCT_x:Int(handle:Byte Ptr)
	Function bmx_win32_MOUSEHOOKSTRUCT_y:Int(handle:Byte Ptr)
	Function bmx_win32_MOUSEHOOKSTRUCT_hwnd:Byte Ptr(handle:Byte Ptr)
	Function bmx_win32_MOUSEHOOKSTRUCT_wHitTestCode:UInt(handle:Byte Ptr)
End Extern
Type MOUSEHOOKSTRUCT
	Field hookPtr:Byte Ptr

	Method x:Int()
		Return bmx_win32_MOUSEHOOKSTRUCT_x(hookPtr)
	End Method
	
	Method y:Int()
		Return bmx_win32_MOUSEHOOKSTRUCT_y(hookPtr)
	End Method
	
	Method hwnd:Byte Ptr()
		Return bmx_win32_MOUSEHOOKSTRUCT_hwnd(hookPtr)
	End Method
	
	Method wHitTestCode:UInt()
		Return bmx_win32_MOUSEHOOKSTRUCT_wHitTestCode(hookPtr)
	End Method
	
End Type
