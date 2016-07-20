
#ifndef MSHTMLVIEW_H
#define MSHTMLVIEW_H

#include "brl.mod/blitz.mod/blitz.h"

struct HTMLView;

extern "C"{

HTMLView * msHtmlCreate( BBObject *gadget,wchar_t *wndclass,HWND hwnd,int flags );

void msHtmlGo( HTMLView * view,wchar_t *url );
void msHtmlRun( HTMLView * view,wchar_t *script );

void msHtmlSetShape( HTMLView * view,int x,int y,int w,int h );
void msHtmlSetVisible( HTMLView * view,int visible );
void msHtmlSetEnabled( HTMLView * view,int enabled );

int msHtmlActivate(HTMLView * view,int cmd);
int msHtmlStatus(HTMLView * view);
HWND msHtmlHwnd( HTMLView * view);
void msHtmlBrowser( HTMLView * view, IWebBrowser2 ** browser);

};

#endif
