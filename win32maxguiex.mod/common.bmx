SuperStrict

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
	
	Function SystemParametersInfoW:Int(uiAction:UInt, uiParam:UInt, pvParam:Byte Ptr, fWinIni:UInt) "win32"="WINBOOL __stdcall  SystemParametersInfoW(UINT ,UINT ,PVOID ,UINT )!"
	Function SetLayeredWindowAttributes:Int(hwnd:Byte Ptr,crKey:Int,bAlpha:Byte,dwFlags:Int) "win32"="WINBOOL __stdcall SetLayeredWindowAttributes(HWND ,COLORREF ,BYTE ,DWORD )!"

	Function msHtmlCreate:Byte Ptr( owner:Object,wndclass$w,hwnd:Byte Ptr,flags:Int )
	Function msHtmlGo( handle:Byte Ptr,url$w )
	Function msHtmlRun( handle:Byte Ptr,script$w )
	Function msHtmlSetShape( handle:Byte Ptr,x:Int,y:Int,w:Int,h:Int )
	Function msHtmlSetVisible( handle:Byte Ptr,visible:Int )
	Function msHtmlSetEnabled( handle:Byte Ptr,enabled:Int )
	Function msHtmlActivate:Int(handle:Byte Ptr,cmd:Int)
	Function msHtmlStatus:Int(handle:Byte Ptr)
	Function msHtmlHwnd:Byte Ptr(handle:Byte Ptr)
	Function msHtmlBrowser(handle:Byte Ptr, browser:IWebBrowser2_ Var)
	Function mstmlDocument:Byte Ptr(handle:Byte Ptr)

End Extern

Extern "win32"
	Function OpenThemeData:Byte Ptr( hwnd:Byte Ptr, lpszClassString:Short Ptr )
	Function CloseThemeData:Int( hTheme:Byte Ptr )
	Function SetWindowTheme:Byte Ptr( pHwnd:Byte Ptr, pThemeStr:Short Ptr, pList:Short Ptr ) 
	Function IsThemeBackgroundPartiallyTransparent:Int( hTheme:Byte Ptr, iPartId%, iStateId% ) 
	Function DrawThemeParentBackground:Byte Ptr(hwnd:Byte Ptr,hDC:Byte Ptr,pRect:Int Ptr) 
	Function DrawThemeBackground:Byte Ptr( hTheme:Byte Ptr, hdc:Byte Ptr, iPartID%, iStateID%, pRect:Int Ptr, pClipRect:Int Ptr) 
	Function GetThemeBackgroundContentRect:Byte Ptr( hTheme:Byte Ptr, hdc:Byte Ptr, iPartId%, iStateId%, pBoundingRect:Int Ptr, pContentRect:Int Ptr )
End Extern

' Custom Window Messages

Const WM_MAXGUILISTREFRESH% = WM_APP + $100

'Error Codes
	
Const S_OK:Int = 0

Const E_OUTOFMEMORY:Int=$8007000E
Const E_INVALIDARG:Int=$80070057
Const E_ACCESSDENIED:Int=$80070005

' WM_SIZE message wParam values

Const SIZE_RESTORED:Int=0
Const SIZE_MINIMIZED:Int=1
Const SIZE_MAXIMIZED:Int=2
Const SIZE_MAXSHOW:Int=3
Const SIZE_MAXHIDE:Int=4

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
Const BCM_FIRST:Int = $1600
Const BCM_SETIMAGELIST% = BCM_FIRST+2

Const BUTTON_IMAGELIST_ALIGN_LEFT%		= 0
Const BUTTON_IMAGELIST_ALIGN_RIGHT%	= 1
Const BUTTON_IMAGELIST_ALIGN_TOP%		= 2
Const BUTTON_IMAGELIST_ALIGN_BOTTOM%	= 3
Const BUTTON_IMAGELIST_ALIGN_CENTER%	= 4

'ComboBox cue-banners
Const CBM_FIRST:Int = $1700
Const CB_SETCUEBANNER:Int = CBM_FIRST + 3

'Progress bar colors
'Const PBM_SETBARCOLOR=WM_USER+9
Const PBM_SETBKCOLOR:Int=CCM_FIRST+1

'SetBkMode() consts, etc.
Const LWA_COLORKEY:Int=1
Const LWA_ALPHA:Int=2
Const LWA_BOTH:Int=3
Const TRANSPARENT:Int=1
Const OPAQUE:Int = 2

'RedrawWindow() flags
Const RDW_FRAME:Int = $500
Const RDW_UPDATENOW:Int = $100
Const RDW_INVALIDATE:Int = $1
Const RDW_NOCHILDREN:Int = $40
Const RDW_ALLCHILDREN:Int = $80
Const RDW_ERASE:Int = $4
Const RDW_ERASENOW:Int = $200

'ScrollBar constants
Const OBJID_HSCROLL:Int = $FFFFFFFA
Const OBJID_VSCROLL:Int = $FFFFFFFB
Const OBJID_CLIENT:Int = $FFFFFFFC

Const EM_GETSCROLLPOS:Int = WM_USER + 221
Const EM_SETSCROLLPOS:Int = WM_USER + 222
Const EM_SETZOOM:Int = WM_USER + 225

'GetDCEx Constants
Const DCX_WINDOW:Int = $1
Const DCX_CACHE:Int = $2
Const DCX_NORESETATTRS:Int = $4
Const DCX_CLIPCHILDREN:Int = $8
Const DCX_CLIPSIBLINGS:Int = $10
Const DCX_PARENTCLIP:Int = $20
Const DCX_EXCLUDERGN:Int = $40
Const DCX_INTERSECTRGN:Int = $80
Const DCX_EXCLUDEUPDATE:Int = $100
Const DCX_INTERSECTUPDATE:Int = $200
Const DCX_LOCKWINDOWUPDATE:Int = $400
Const DCX_VALIDATE:Int = $200000

Const WM_THEMECHANGED:Int = $31A

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

Const TVM_FIRST:Int = $1100
Const TVS_EX_DOUBLEBUFFER:Int = $4
Const TVS_EX_FADEINOUTEXPANDOS:Int = $40
Const TVM_SETEXTENDEDSTYLE:Int = TVM_FIRST + 44

Const TTN_GETDISPINFOW:Int = -530

'System State Contstants

Const STATE_SYSTEM_UNAVAILABLE:Int = $00000001
Const STATE_SYSTEM_SELECTED:Int = $00000002
Const STATE_SYSTEM_FOCUSED:Int = $00000004
Const STATE_SYSTEM_PRESSED:Int = $00000008
Const STATE_SYSTEM_CHECKED:Int = $00000010
Const STATE_SYSTEM_MIXED:Int = $00000020
Const STATE_SYSTEM_READONLY:Int = $00000040
Const STATE_SYSTEM_HOTTRACKED:Int = $00000080
Const STATE_SYSTEM_DEFAULT:Int = $00000100
Const STATE_SYSTEM_EXPANDED:Int = $00000200
Const STATE_SYSTEM_COLLAPSED:Int = $00000400
Const STATE_SYSTEM_BUSY:Int = $00000800
Const STATE_SYSTEM_FLOATING:Int = $00001000
Const STATE_SYSTEM_MARQUEED:Int = $00002000
Const STATE_SYSTEM_ANIMATED:Int = $00004000
Const STATE_SYSTEM_INVISIBLE:Int = $00008000
Const STATE_SYSTEM_OFFSCREEN:Int = $00010000
Const STATE_SYSTEM_SIZEABLE:Int = $00020000
Const STATE_SYSTEM_MOVEABLE:Int = $00040000
Const STATE_SYSTEM_SELFVOICING:Int = $00080000
Const STATE_SYSTEM_FOCUSABLE:Int = $00100000
Const STATE_SYSTEM_SELECTABLE:Int = $00200000
Const STATE_SYSTEM_LINKED:Int = $00400000
Const STATE_SYSTEM_TRAVERSED:Int = $00800000
Const STATE_SYSTEM_MULTISELECTABLE:Int = $01000000
Const STATE_SYSTEM_EXTSELECTABLE:Int = $02000000
Const STATE_SYSTEM_ALERT_LOW:Int = $04000000
Const STATE_SYSTEM_ALERT_MEDIUM:Int = $08000000
Const STATE_SYSTEM_ALERT_HIGH:Int = $10000000
Const STATE_SYSTEM_VALID:Int = $1FFFFFFF


'System Metrics

Const SM_CXSCREEN:Int = 0
Const SM_CYSCREEN:Int = 1
Const SM_CXVSCROLL:Int = 2
Const SM_CYHSCROLL:Int = 3
Const SM_CYCAPTION:Int = 4
Const SM_CXBORDER:Int = 5
Const SM_CYBORDER:Int = 6
Const SM_CXDLGFRAME:Int = 7
Const SM_CYDLGFRAME:Int = 8
Const SM_CYVTHUMB:Int = 9
Const SM_CXHTHUMB:Int = 10
Const SM_CXICON:Int = 11
Const SM_CYICON:Int = 12
Const SM_CXCURSOR:Int = 13
Const SM_CYCURSOR:Int = 14
Const SM_CYMENU:Int = 15
Const SM_CXFULLSCREEN:Int = 16
Const SM_CYFULLSCREEN:Int = 17
Const SM_CYKANJIWINDOW:Int = 18
Const SM_MOUSEPRESENT:Int = 19
Const SM_CYVSCROLL:Int = 20
Const SM_CXHSCROLL:Int = 21
Const SM_DEBUG:Int = 22
Const SM_SWAPBUTTON:Int = 23
Const SM_RESERVED1:Int = 24
Const SM_RESERVED2:Int = 25
Const SM_RESERVED3:Int = 26
Const SM_RESERVED4:Int = 27
Const SM_CXMIN:Int = 28
Const SM_CYMIN:Int = 29
Const SM_CXSIZE:Int = 30
Const SM_CYSIZE:Int = 31
Const SM_CXFRAME:Int = 32
Const SM_CYFRAME:Int = 33
Const SM_CXMINTRACK:Int = 34
Const SM_CYMINTRACK:Int = 35
Const SM_CXDOUBLECLK:Int = 36
Const SM_CYDOUBLECLK:Int = 37
Const SM_CXICONSPACING:Int = 38
Const SM_CYICONSPACING:Int = 39
Const SM_MENUDROPALIGNMENT:Int = 40
Const SM_PENWINDOWS:Int = 41
Const SM_DBCSENABLED:Int = 42
Const SM_CMOUSEBUTTONS:Int = 43
Const SM_CXFIXEDFRAME:Int = SM_CXDLGFRAME
Const SM_CYFIXEDFRAME:Int = SM_CYDLGFRAME
Const SM_CXSIZEFRAME:Int = SM_CXFRAME
Const SM_CYSIZEFRAME:Int = SM_CYFRAME
Const SM_SECURE:Int = 44
Const SM_CXEDGE:Int = 45
Const SM_CYEDGE:Int = 46
Const SM_CXMINSPACING:Int = 47
Const SM_CYMINSPACING:Int = 48
Const SM_CXSMICON:Int = 49
Const SM_CYSMICON:Int = 50
Const SM_CYSMCAPTION:Int = 51
Const SM_CXSMSIZE:Int = 52
Const SM_CYSMSIZE:Int = 53
Const SM_CXMENUSIZE:Int = 54
Const SM_CYMENUSIZE:Int = 55
Const SM_ARRANGE:Int = 56
Const SM_CXMINIMIZED:Int = 57
Const SM_CYMINIMIZED:Int = 58
Const SM_CXMAXTRACK:Int = 59
Const SM_CYMAXTRACK:Int = 60
Const SM_CXMAXIMIZED:Int = 61
Const SM_CYMAXIMIZED:Int = 62
Const SM_NETWORK:Int = 63
Const SM_CLEANBOOT:Int = 67
Const SM_CXDRAG:Int = 68
Const SM_CYDRAG:Int = 69
Const SM_SHOWSOUNDS:Int = 70
Const SM_CXMENUCHECK:Int = 71
Const SM_CYMENUCHECK:Int = 72
Const SM_SLOWMACHINE:Int = 73
Const SM_MIDEASTENABLED:Int = 74
Const SM_MOUSEWHEELPRESENT:Int = 75
Const SM_XVIRTUALSCREEN:Int = 76
Const SM_YVIRTUALSCREEN:Int = 77
Const SM_CXVIRTUALSCREEN:Int = 78
Const SM_CYVIRTUALSCREEN:Int = 79
Const SM_CMONITORS:Int = 80
Const SM_SAMEDISPLAYFORMAT:Int = 81
Const SM_CMETRICS:Int = 83



'External functions
Extern "Win32"
	
'		Function GetCharABCWidthsW(dc,firstcharcode,lastcharcode,widths:Int Ptr Ptr)
	Function GetCharABCWidthsW:Int(dc:Byte Ptr,firstcharcode:UInt,lastcharcode:UInt,widths:Int Ptr)="WINBOOL __stdcall GetCharABCWidthsW(HDC ,UINT ,UINT ,LPABC )!"

	Function GetCharWidth32W:Int(hdc:Byte Ptr,First:UInt,last:UInt,widths:Int Ptr)="WINBOOL __stdcall GetCharWidth32W(HDC ,UINT ,UINT ,LPINT )!"
	
	'BRL.System
	'Function _TrackMouseEvent( trackmouseeventstrunct:Byte Ptr )
	
	'Imagelists and pixmap conversion
	'Function ImageList_Add(himl:Byte Ptr,hbmImage:Byte Ptr,crMask)
	'Function ImageList_Destroy( hImageList:Byte Ptr )
	'Function ImageList_GetImageCount( hImageList:Byte Ptr )
	Function CreateDIBSection:Byte Ptr(hdc:Byte Ptr,bminfo:Byte Ptr,iUsage:UInt,bits:Byte Ptr Ptr,hSection:Byte Ptr,dwOffset:Int)="HBITMAP __stdcall CreateDIBSection(HDC ,CONST BITMAPINFO *,UINT ,VOID **,HANDLE ,DWORD )!"
	Function SendMessageSetImageList(hwnd:Byte Ptr, _buttonImageList:Byte Ptr Ptr, _imageAlign:Int)
	
	'WM_CTLCOLORXXXX handling
	Function SetBkMode:Int( hdc:Byte Ptr, Mode:Int)="int __stdcall SetBkMode(HDC ,int )!"
	Function SetBkColor:Int( hdc:Byte Ptr, crColor:Int )="COLORREF __stdcall SetBkColor(HDC ,COLORREF )!"
	Function GetAncestor_:Byte Ptr( hwnd:Byte Ptr, gaFlags:Int ) = "HWND __stdcall GetAncestor(HWND ,UINT )!"
	Function SetTextColor_:Int( hdc:Byte Ptr, crColor:Int ) = "COLORREF __stdcall SetTextColor(HDC ,COLORREF )!"
	
	'Drawing Contexts
	Function GetObjectW:Int( hgdiobj:Byte Ptr, cbBuffer:Int, lpvObject:Byte Ptr )="int __stdcall GetObjectW(HANDLE ,int ,LPVOID )!"
	Function SaveDC:Int( hdc:Byte Ptr )="int __stdcall SaveDC(HDC )!"
	Function RestoreDC:Int( hdc:Byte Ptr, savestate:Int )="WINBOOL __stdcall RestoreDC(HDC ,int )!"
	Function CreatePatternBrush:Byte Ptr( bitmap:Byte Ptr )="HBRUSH __stdcall CreatePatternBrush(HBITMAP )!"
	Function GetDCEx:Byte Ptr( hwnd:Byte Ptr, hRgn:Byte Ptr, flags:Int )="HDC __stdcall GetDCEx(HWND ,HRGN ,DWORD )!"
	Function ReleaseDC:Int( hwnd:Byte Ptr, hdc:Byte Ptr )="int __stdcall ReleaseDC(HWND ,HDC )!"
	Function GetDCOrgEx:Int( hdc:Byte Ptr, point:Int Ptr )="WINBOOL __stdcall GetDCOrgEx(HDC ,LPPOINT )!"
	Function GetWindowOrgEx:Int( hdc:Byte Ptr, point:Int Ptr )="WINBOOL __stdcall GetWindowOrgEx(HDC ,LPPOINT )!"
	Function GetWindowExtEx:Int( hdc:Byte Ptr, size:Int Ptr )="WINBOOL __stdcall GetWindowExtEx(HDC ,LPSIZE )!"

	'Drawing
	Function DrawTextW:Int( hdc:Byte Ptr, lpString$w, nCount:Int, lpRect:Int Ptr, uFormat:Int )="int __stdcall DrawTextW(HDC ,LPCWSTR ,int ,LPRECT ,UINT )!"
	Function DrawFocusRect:Int( hdc:Byte Ptr, lprc:Int Ptr )="WINBOOL __stdcall DrawFocusRect(HDC ,CONST RECT *)!"
	Function DrawFrameControl:Int( hdc:Byte Ptr, lprc:Int Ptr, uType%, uState% )="WINBOOL __stdcall DrawFrameControl(HDC,LPRECT,UINT,UINT)!"
	Function ExtTextOutW:Int( hdc:Byte Ptr, x:Int, y:Int, fuOptions:UInt, lpRc:Int Ptr, lpString$w, cbCount:Int, lpDx:Int Ptr )="WINBOOL __stdcall ExtTextOutW(HDC ,int ,int ,UINT ,CONST RECT *,LPCWSTR ,UINT ,CONST INT *)!"
	
	'Resizing
	Function BeginDeferWindowPos:Byte Ptr( nCount:Int )="HDWP __stdcall BeginDeferWindowPos(int )!"
	Function EndDeferWindowPos:Int( hdwpStruct:Byte Ptr )="WINBOOL __stdcall EndDeferWindowPos(HDWP )!"
	Function DeferWindowPos:Byte Ptr( hWinPosInfo:Byte Ptr, hWnd:Byte Ptr, hWndInsertAfter:Byte Ptr, x:Int, y:Int, cx:Int, cy:Int, uFlags:UInt)="HDWP __stdcall DeferWindowPos(HDWP ,HWND ,HWND ,int ,int ,int ,int ,UINT )!"
	
	'Position and regions
	Function IsRectEmpty:Int( rect:Int Ptr )="WINBOOL __stdcall IsRectEmpty(CONST RECT *)!"
	Function GetClipBox:Int( hdc:Byte Ptr, rect:Int Ptr)="int __stdcall GetClipBox(HDC ,LPRECT )!"
	Function GetUpdateRect:Int( hwnd:Byte Ptr, rect:Int Ptr, pErase:Int )="WINBOOL __stdcall GetUpdateRect(HWND ,LPRECT ,WINBOOL )!"
	Function ScreenToClient:Int( hwnd:Byte Ptr, rect:Int Ptr )="WINBOOL __stdcall ScreenToClient(HWND ,LPPOINT )!"
	Function RedrawWindow:Int(hwnd:Byte Ptr, lprcUpdate:Int Ptr, hrgnUpdate:Int Ptr, flags:UInt )="WINBOOL __stdcall RedrawWindow(HWND ,CONST RECT *,HRGN ,UINT )!"
	Function FrameRect:Int( hdc:Byte Ptr, rect:Int Ptr, hBrush:Byte Ptr )="int __stdcall FrameRect(HDC ,CONST RECT *,HBRUSH )!"
	Function InflateRect:Int( rect:Int Ptr, dx:Int, dy:Int )="WINBOOL __stdcall InflateRect(LPRECT ,int ,int )!"
	Function OffsetRect:Int( rect:Int Ptr, dx:Int, dy:Int )="WINBOOL __stdcall OffsetRect(LPRECT ,int ,int )!"
	Function IntersectRect:Int( lprcDest:Int Ptr, lprcSrc1:Int Ptr, lprcSrc2:Int Ptr )="WINBOOL __stdcall IntersectRect(LPRECT ,CONST RECT *,CONST RECT *)!"
	Function CopyRect:Int( dest:Int Ptr, src:Int Ptr )="WINBOOL __stdcall CopyRect(LPRECT ,CONST RECT *)!"
	Function GDISetRect:Int( rect:Int Ptr, xLeft:Int, yTop:Int, xRight:Int, yBottom:Int) = "WINBOOL __stdcall SetRect(LPRECT ,int ,int ,int ,int )!"
	
	'Menu Stuff
	Function GetMenu_:Byte Ptr( hwnd:Byte Ptr ) = "HMENU __stdcall GetMenu(HWND )!"
	Function SetMenuItemBitmaps:Int( hMenu:Byte Ptr, uPosition:UInt, uFlags:UInt, hBitmapUnchecked:Byte Ptr, hBitmapChecked:Byte Ptr )="WINBOOL __stdcall SetMenuItemBitmaps(HMENU ,UINT ,UINT ,HBITMAP ,HBITMAP )!"
	Function SetMenuInfo:Int( hMenu:Byte Ptr, lpcMenuInfo:Byte Ptr )="WINBOOL __stdcall SetMenuInfo(HMENU,LPCMENUINFO)!"
	Function GetSysColor:Int( hColor:Int )="DWORD __stdcall GetSysColor(int )!"
	
	'Scroll-bar fixes
	Function GetSystemMetrics:Int( metric:Int )="int __stdcall GetSystemMetrics(int )!"
	Function GetScrollBarInfo:Int( hwnd:Byte Ptr, idObject:Int, pScrollBarInfo:Int Ptr )="WINBOOL __stdcall GetScrollBarInfo(HWND ,LONG ,PSCROLLBARINFO )!"
	
	'Gadget text retrieval
	Function GetWindowTextLengthW:Int( hwnd:Byte Ptr )="int __stdcall GetWindowTextLengthW(HWND )!"
	
	'Missing misc. system functions
	Function GetCursor:Byte Ptr()="HCURSOR __stdcall GetCursor()!"
	Function FreeLibrary:Int( hLibrary:Byte Ptr )="WINBOOL __stdcall FreeLibrary (HMODULE )!"
	
	'Printing functions for text-area GadgetPrint()
	Function PrintDlg:Int( printDialogStruct:Byte Ptr ) = "WINBOOL __stdcall PrintDlgW(LPPRINTDLGW)!"
	Function StartDocW:Int( hdc:Byte Ptr, pDocStruct:Byte Ptr )="int __stdcall StartDocW(HDC ,CONST DOCINFOW *)!"
	Function EndDoc:Int( hdc:Byte Ptr )="int __stdcall EndDoc(HDC )!"
	Function AbortDoc:Int( hdc:Byte Ptr )="int __stdcall AbortDoc(HDC )!"
	Function StartPage:Int( hdc:Byte Ptr )="int __stdcall StartPage(HDC )!"
	Function EndPage:Int( hdc:Byte Ptr )="int __stdcall EndPage(HDC )!"
	Function SetMapMode:Int( hdc:Byte Ptr, pMode:Int )="int __stdcall SetMapMode(HDC ,int )!"
	Function PrintWindow:Int( hwnd:Byte Ptr, hdc:Byte Ptr, flags:UInt )="WINBOOL __stdcall PrintWindow(HWND ,HDC ,UINT )!"

	'Icons
	Function CreateIconIndirect:Byte Ptr(IconInf:Byte Ptr)="HICON __stdcall CreateIconIndirect(PICONINFO )!"
	Function CopyImage:Byte Ptr(hImage:Byte Ptr , uType:UInt , xDesired:Int , yDesired:Int , flags:UInt)="HANDLE __stdcall CopyImage(HANDLE ,UINT ,int ,int ,UINT )!"
	Function DestroyIcon:Int(hIcon:Byte Ptr)="WINBOOL __stdcall DestroyIcon(HICON )!"

EndExtern

Extern
	Function AlphaBlend_(hdc:Byte Ptr,dx:Int,dy:Int,dw:Int,dh:Int,hdc2:Byte Ptr,src:Int,sry:Int,srcw:Int,srch:Int,rop:Int)="AlphaBlendArgs"
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
	Function bmx_win32_DRAWITEMSTRUCT_CtlType:UInt(handle:Byte Ptr)
	Function bmx_win32_DRAWITEMSTRUCT_CtlID:UInt(handle:Byte Ptr)
	Function bmx_win32_DRAWITEMSTRUCT_itemID:UInt(handle:Byte Ptr)
	Function bmx_win32_DRAWITEMSTRUCT_itemAction:UInt(handle:Byte Ptr)
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
Const ODS_SELECTED:Int = $1
Const ODS_GRAYED:Int = $2
Const ODS_DISABLED:Int = $4
Const ODS_CHECKED:Int = $8
Const ODS_FOCUS:Int = $10
Const ODS_HOTLIGHT:Int = $40
Const ODS_INACTIVE:Int = $80
Const ODS_NOACCEL:Int = $100
Const ODS_NOFOCUSRECT:Int = $200

'DrawThemeBackground Button States
Const BP_PUSHBUTTON:Int = 1
Const PBS_NORMAL:Int = 1
Const PBS_HOT:Int = 2
Const PBS_PRESSED:Int = 3
Const PBS_DISABLED:Int = 4
Const PBS_DEFAULTED:Int = 5

'DrawFrameControl Constants
Const DFC_BUTTON:Int = $4
Const DFCS_BUTTONPUSH:Int = $10
Const DFCS_INACTIVE:Int = $100
Const DFCS_PUSHED:Int = $200
Const DFCS_CHECKED:Int = $400
Const DFCS_TRANSPARENT:Int = $800
Const DFCS_HOT:Int = $1000
Const DFCS_ADJUSTRECT:Int = $2000
Const DFCS_FLAT:Int = $4000
Const DFCS_MONO:Int = $8000

'DrawText Constants
Const DT_BOTTOM:Int = $8
Const DT_CALCRECT:Int = $400
Const DT_CENTER:Int = $1
Const DT_EDITCONTROL:Int = $2000
Const DT_END_ELLIPSIS:Int = $8000
Const DT_EXPANDTABS:Int = $40
Const DT_EXTERNALLEADING:Int = $200
Const DT_HIDEPREFIX:Int = $100000
Const DT_INTERNAL:Int = $1000
Const DT_LEFT:Int = $0
Const DT_MODIFYSTRING:Int = $10000
Const DT_NOCLIP:Int = $100
Const DT_NOFULLWIDTHCHARBREAK:Int = $80000
Const DT_NOPREFIX:Int = $800
Const DT_NOT_SPECIFIC:Int = $50000
Const DT_PATH_ELLIPSIS:Int = $4000
Const DT_PREFIXONLY:Int = $200000
Const DT_RIGHT:Int = $2
Const DT_RTLREADING:Int = $20000
Const DT_SINGLELINE:Int = $20
Const DT_TABSTOP:Int = $80
Const DT_TOP:Int = $0
Const DT_VCENTER:Int = $4
Const DT_WORD_ELLIPSIS:Int = $40000
Const DT_WORDBREAK:Int = $10

'TextArea Gadget Printing
Const MM_TEXT:Int = 1

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
