#include "windows.h"
#include <stdio.h>
#include <shlwapi.h>

extern "C" {

	CHOOSECOLORW * bmx_win32maxgui_choosecolor_new(HWND parent, int rgb, int * customColors, int flags);
	int bmx_win32maxgui_choosecolor_ChooseColor(CHOOSECOLORW * cc);
	void bmx_win32maxgui_choosecolor_free(CHOOSECOLORW * cc);
	int bmx_win32maxgui_choosecolor_rgbResult(CHOOSECOLORW * cc);

	DLLVERSIONINFO2 * bmx_win32_DLLVERSIONINFO2_new();
	void bmx_win32_DLLVERSIONINFO2_free(DLLVERSIONINFO2 * info);
	int bmx_win32_DLLVERSIONINFO2_dwMajorVersion(DLLVERSIONINFO2 * info);
	int bmx_win32_DLLVERSIONINFO2_dwMinorVersion(DLLVERSIONINFO2 * info);
	int bmx_win32_DLLVERSIONINFO2_dwBuildNumber(DLLVERSIONINFO2 * info);

	DRAWITEMSTRUCT * bmx_win32_DRAWITEMSTRUCT_new();
	void bmx_win32_DRAWITEMSTRUCT_free(DRAWITEMSTRUCT * item);
	UINT bmx_win32_DRAWITEMSTRUCT_CtlType(DRAWITEMSTRUCT * item);
	UINT bmx_win32_DRAWITEMSTRUCT_CtlID(DRAWITEMSTRUCT * item);
	UINT bmx_win32_DRAWITEMSTRUCT_itemID(DRAWITEMSTRUCT * item);
	UINT bmx_win32_DRAWITEMSTRUCT_itemAction(DRAWITEMSTRUCT * item);
	HWND bmx_win32_DRAWITEMSTRUCT_hwndItem(DRAWITEMSTRUCT * item);
	HDC bmx_win32_DRAWITEMSTRUCT_hDC(DRAWITEMSTRUCT * item);
	RECT* bmx_win32_DRAWITEMSTRUCT_rcItem(DRAWITEMSTRUCT * item);
	UINT bmx_win32_DRAWITEMSTRUCT_itemState(DRAWITEMSTRUCT * item);
	ULONG_PTR bmx_win32_DRAWITEMSTRUCT_itemData(DRAWITEMSTRUCT * item);

	BOOL AlphaBlendArgs(HDC hdcDest, int xoriginDest, int yoriginDest, int wDest, int hDest, HDC hdcSrc, int xoriginSrc,
		int yoriginSrc, int wSrc, int hSrc, int blend);

	NONCLIENTMETRICSW * bmx_win32_NONCLIENTMETRICSW_new();
	void bmx_win32_NONCLIENTMETRICSW_free(NONCLIENTMETRICSW * metrics);
	LOGFONTW * bmx_win32_NONCLIENTMETRICSW_lfMessageFont(NONCLIENTMETRICSW * metrics);

	int bmx_win32_MOUSEHOOKSTRUCT_x(MOUSEHOOKSTRUCT * hook);
	int bmx_win32_MOUSEHOOKSTRUCT_y(MOUSEHOOKSTRUCT * hook);
	HWND bmx_win32_MOUSEHOOKSTRUCT_hwnd(MOUSEHOOKSTRUCT * hook);
	UINT bmx_win32_MOUSEHOOKSTRUCT_wHitTestCode(MOUSEHOOKSTRUCT * hook);
}

BOOL AlphaBlendArgs(HDC hdcDest, int xoriginDest, int yoriginDest, int wDest, int hDest, HDC hdcSrc, int xoriginSrc,
		int yoriginSrc, int wSrc, int hSrc, int blend) {

	BLENDFUNCTION ftn = { blend & 0xff, (blend & 0xff00) >> 8, (blend & 0xff0000) >> 16,(blend & 0xff000000) >> 24 };
	
	return AlphaBlend(hdcDest, xoriginDest, yoriginDest, wDest, hDest, hdcSrc, xoriginSrc,
		yoriginSrc, wSrc, hSrc, ftn);
}

// ********************************************************


CHOOSECOLORW * bmx_win32maxgui_choosecolor_new(HWND parent, int rgb, int * customColors, int flags) {
	CHOOSECOLORW * cc = (CHOOSECOLORW *)malloc(sizeof(CHOOSECOLORW));
	cc->lStructSize = sizeof(CHOOSECOLORW);
	cc->hwndOwner = parent;
	cc->rgbResult = rgb;
	cc->lpCustColors = (COLORREF*)customColors;
	cc->Flags = flags;
	
	return cc;
}

int bmx_win32maxgui_choosecolor_ChooseColor(CHOOSECOLORW * cc) {
	return ChooseColorW(cc);
}

void bmx_win32maxgui_choosecolor_free(CHOOSECOLORW * cc) {
	free(cc);
}

int bmx_win32maxgui_choosecolor_rgbResult(CHOOSECOLORW * cc) {
	return cc->rgbResult;
}

// ********************************************************

DLLVERSIONINFO2 * bmx_win32_DLLVERSIONINFO2_new() {
	DLLVERSIONINFO2 * info = (DLLVERSIONINFO2 *)calloc(1,sizeof(DLLVERSIONINFO2));
	info->info1.cbSize = sizeof(DLLVERSIONINFO2);
	return info;
}

void bmx_win32_DLLVERSIONINFO2_free(DLLVERSIONINFO2 * info) {
	free(info);
}

int bmx_win32_DLLVERSIONINFO2_dwMajorVersion(DLLVERSIONINFO2 * info) {
	return info->info1.dwMajorVersion;
}

int bmx_win32_DLLVERSIONINFO2_dwMinorVersion(DLLVERSIONINFO2 * info) {
	return info->info1.dwMinorVersion;
}

int bmx_win32_DLLVERSIONINFO2_dwBuildNumber(DLLVERSIONINFO2 * info) {
	return info->info1.dwBuildNumber;
}

// ********************************************************

DRAWITEMSTRUCT * bmx_win32_DRAWITEMSTRUCT_new() {
	return (DRAWITEMSTRUCT*)malloc(sizeof(DRAWITEMSTRUCT));
}

void bmx_win32_DRAWITEMSTRUCT_free(DRAWITEMSTRUCT * item) {
	free(item);
}

UINT bmx_win32_DRAWITEMSTRUCT_CtlType(DRAWITEMSTRUCT * item) {
	return item->CtlType;
}

UINT bmx_win32_DRAWITEMSTRUCT_CtlID(DRAWITEMSTRUCT * item) {
	return item->CtlID;
}

UINT bmx_win32_DRAWITEMSTRUCT_itemID(DRAWITEMSTRUCT * item) {
	return item->itemID;
}

UINT bmx_win32_DRAWITEMSTRUCT_itemAction(DRAWITEMSTRUCT * item) {
	return item->itemAction;
}

HWND bmx_win32_DRAWITEMSTRUCT_hwndItem(DRAWITEMSTRUCT * item) {
	return item->hwndItem;
}

HDC bmx_win32_DRAWITEMSTRUCT_hDC(DRAWITEMSTRUCT * item) {
	return item->hDC;
}

RECT* bmx_win32_DRAWITEMSTRUCT_rcItem(DRAWITEMSTRUCT * item) {
	return &item->rcItem;
}

UINT bmx_win32_DRAWITEMSTRUCT_itemState(DRAWITEMSTRUCT * item) {
	return item->itemState;
}

ULONG_PTR bmx_win32_DRAWITEMSTRUCT_itemData(DRAWITEMSTRUCT * item) {
	return item->itemData;
}

// ********************************************************

NONCLIENTMETRICSW * bmx_win32_NONCLIENTMETRICSW_new() {
	return (NONCLIENTMETRICSW *)calloc(1, sizeof(NONCLIENTMETRICSW));
}

void bmx_win32_NONCLIENTMETRICSW_free(NONCLIENTMETRICSW * metrics) {
	free(metrics);
}

LOGFONTW * bmx_win32_NONCLIENTMETRICSW_lfMessageFont(NONCLIENTMETRICSW * metrics) {
	return &metrics->lfMessageFont;
}

// ********************************************************

int bmx_win32_MOUSEHOOKSTRUCT_x(MOUSEHOOKSTRUCT * hook) {
	return hook->pt.x;
}

int bmx_win32_MOUSEHOOKSTRUCT_y(MOUSEHOOKSTRUCT * hook) {
	return hook->pt.y;
}

HWND bmx_win32_MOUSEHOOKSTRUCT_hwnd(MOUSEHOOKSTRUCT * hook) {
	return hook->hwnd;
}

UINT bmx_win32_MOUSEHOOKSTRUCT_wHitTestCode(MOUSEHOOKSTRUCT * hook) {
	return hook->wHitTestCode;
}

