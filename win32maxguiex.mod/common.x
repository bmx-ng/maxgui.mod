WINBOOL __stdcall  SystemParametersInfoW(UINT ,UINT ,PVOID ,UINT )!
WINBOOL __stdcall SetLayeredWindowAttributes(HWND ,COLORREF ,BYTE ,DWORD )!

WINBOOL __stdcall GetCharABCWidthsW(HDC ,UINT ,UINT ,LPABC )!
WINBOOL __stdcall GetCharWidth32W(HDC ,UINT ,UINT ,LPINT )!
HBITMAP __stdcall CreateDIBSection(HDC ,CONST BITMAPINFO *,UINT ,VOID **,HANDLE ,DWORD )!
int __stdcall SetBkMode(HDC ,int )!
COLORREF __stdcall SetBkColor(HDC ,COLORREF )!
HWND __stdcall GetAncestor(HWND ,UINT )!
COLORREF __stdcall SetTextColor(HDC ,COLORREF )!
int __stdcall GetObjectW(HANDLE ,int ,LPVOID )!
int __stdcall SaveDC(HDC )!
WINBOOL __stdcall RestoreDC(HDC ,int )!
HBRUSH __stdcall CreatePatternBrush(HBITMAP )!
HDC __stdcall GetDCEx(HWND ,HRGN ,DWORD )!
int __stdcall ReleaseDC(HWND ,HDC )!
WINBOOL __stdcall GetDCOrgEx(HDC ,LPPOINT )!
WINBOOL __stdcall GetWindowOrgEx(HDC ,LPPOINT )!
WINBOOL __stdcall GetWindowExtEx(HDC ,LPSIZE )!
int __stdcall DrawTextW(HDC ,LPCWSTR ,int ,LPRECT ,UINT )!
WINBOOL __stdcall DrawFocusRect(HDC ,CONST RECT *)!
WINBOOL __stdcall DrawFrameControl(HDC,LPRECT,UINT,UINT)!
WINBOOL __stdcall ExtTextOutW(HDC ,int ,int ,UINT ,CONST RECT *,LPCWSTR ,UINT ,CONST INT *)!
HDWP __stdcall BeginDeferWindowPos(int )!
WINBOOL __stdcall EndDeferWindowPos(HDWP )!
HDWP __stdcall DeferWindowPos(HDWP ,HWND ,HWND ,int ,int ,int ,int ,UINT )!
WINBOOL __stdcall IsRectEmpty(CONST RECT *)!
int __stdcall GetClipBox(HDC ,LPRECT )!
WINBOOL __stdcall GetUpdateRect(HWND ,LPRECT ,WINBOOL )!
WINBOOL __stdcall ScreenToClient(HWND ,LPPOINT )!
WINBOOL __stdcall RedrawWindow(HWND ,CONST RECT *,HRGN ,UINT )!
int __stdcall FrameRect(HDC ,CONST RECT *,HBRUSH )!
WINBOOL __stdcall InflateRect(LPRECT ,int ,int )!
WINBOOL __stdcall OffsetRect(LPRECT ,int ,int )!
WINBOOL __stdcall IntersectRect(LPRECT ,CONST RECT *,CONST RECT *)!
WINBOOL __stdcall CopyRect(LPRECT ,CONST RECT *)!
WINBOOL __stdcall SetRect(LPRECT ,int ,int ,int ,int )!
HMENU __stdcall GetMenu(HWND )!
WINBOOL __stdcall SetMenuItemBitmaps(HMENU ,UINT ,UINT ,HBITMAP ,HBITMAP )!
WINBOOL __stdcall SetMenuInfo(HMENU,LPCMENUINFO)!
DWORD __stdcall GetSysColor(int )!
int __stdcall GetSystemMetrics(int )!
WINBOOL __stdcall GetScrollBarInfo(HWND ,LONG ,PSCROLLBARINFO )!
int __stdcall GetWindowTextLengthW(HWND )!
HCURSOR __stdcall GetCursor()!
WINBOOL __stdcall FreeLibrary (HMODULE )!
WINBOOL __stdcall PrintDlgW(LPPRINTDLGW)!
int __stdcall StartDocW(HDC ,CONST DOCINFOW *)!
int __stdcall EndDoc(HDC )!
int __stdcall AbortDoc(HDC )!
int __stdcall StartPage(HDC )!
int __stdcall EndPage(HDC )!
int __stdcall SetMapMode(HDC ,int )!
WINBOOL __stdcall PrintWindow(HWND ,HDC ,UINT )!
HICON __stdcall CreateIconIndirect(PICONINFO )!
HANDLE __stdcall CopyImage(HANDLE ,UINT ,int ,int ,UINT )!
WINBOOL __stdcall DestroyIcon(HICON )!

