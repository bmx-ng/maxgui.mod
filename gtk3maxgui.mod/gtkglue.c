/*
  Copyright (c) 2006-2020 Bruce A Henderson
 
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
#include "gtk/gtk.h"
#include "gdk/gdk.h"

#include "brl.mod/blitz.mod/blitz.h"

int bmx_gtk3_gtkdesktop_gethertz() {

#if GTK_MINOR_VERSION >= 22
	GdkMonitor * monitor = gdk_display_get_primary_monitor(gdk_display_get_default());
	int rate = gdk_monitor_get_refresh_rate(monitor);
	return rate / 1000;
#else
	return 60;
#endif

}

GValue * bmx_gtk3_gvalue_new(int type) {
	GValue * val = (GValue*)calloc(1, sizeof(GValue));
	return g_value_init(val, type);
}

void bmx_gtk3_gvalue_free(GValue * val) {
	free(val);
}

GtkTreeIter * bmx_gtk3_gtktreeiter_new() {
	return (GtkTreeIter*)calloc(1, sizeof(GtkTreeIter));
}

void bmx_gtk3_gtktreeiter_free(GtkTreeIter * iter) {
	free(iter);
}

PangoFontDescription * bmx_gtk3_stylecontext_get_fontdesc(GtkStyleContext *context) {
	return gtk_style_context_get_font(context, GTK_STATE_FLAG_NORMAL);
}

GtkTextIter * bmx_gtk3_gtktextiter_new() {
	return (GtkTextIter*)calloc(1, sizeof(GtkTextIter));
}

void bmx_gtk3_gtktextiter_free(GtkTextIter * iter) {
	free(iter);
}

GtkTextTag * bmx_gtk3_set_text_tag_style(GtkTextBuffer *buffer, const gchar *tag, GdkRGBA * color, int _style, int _weight, int _under, int _strike) { 
	return gtk_text_buffer_create_tag(buffer, tag, "foreground-rgba", color, "style", _style, "weight", _weight, "underline", _under, "strikethrough", _strike, 0);
}

GtkTextTag * bmx_gtk3_set_text_bg_tag(GtkTextBuffer *buffer, const gchar *tag, GdkRGBA * color) {
	return gtk_text_buffer_create_tag(buffer, tag, "background-rgba", color, 0);
}

BBArray * bmx_gtk3_selection_data_get_uris(GtkSelectionData * data) {
	gchar ** uris = gtk_selection_data_get_uris(data);
	
	if (uris == NULL) {
		return &bbEmptyArray;
	}
	
	int count = 0;
	while (uris[count] && count < 128) {
		count++;
	}
	
	BBArray *p=bbArrayNew1D( "$",count );
	BBString **s=(BBString**)BBARRAYDATA( p,p->dims );
	for( int i=0;i<count;++i ){
		s[i]=bbStringFromUTF8String( uris[i] );
	}
	
	g_strfreev(uris);
	
	return p;
}

void bmx_g_object_set_int(void * handle, BBString * property, int value) {
	char * p = bbStringToUTF8String(property);
	g_object_set(handle, p, value, NULL);
	bbMemFree(p);
}

void bmx_g_object_set_double(void * handle, BBString * property, double value) {
	char * p = bbStringToUTF8String(property);
	g_object_set(handle, p, value, NULL);
	bbMemFree(p);
}

int bmx_g_signal_connect_data(void * widget, BBString * name, void * callback, void * gadget, void * destroyhandler, int flag) {
	char * n = bbStringToUTF8String(name);
	int result = g_signal_connect_data(widget, n, callback, gadget, destroyhandler, flag);
	bbMemFree(n);
	return result;
}





// SIGNALS

/* user data */
typedef struct {
    void *bm_callback;    // BlitzMax callback pointer/handle
    void *bm_destroy;     // optional destroy handler pointer/handle
    void *gadget;         // optional gadget pointer
} BMSignalData;

/* Destroy-Wrapper */
static void bm_destroy_data(gpointer data, GClosure *closure) {
    BMSignalData *d = (BMSignalData*)data;
    if (!d) return;
    if (d->bm_destroy) {
        typedef void (*bm_destroy_t)(void*, void*);
        ((bm_destroy_t)d->bm_destroy)(d->gadget, (void*)closure);
    }
    g_free(d);
}

/* =========================
   Thunks (C-side callbacks)
   ========================= */

/* cb2: void callback(widget, gadget) */
static void thunk_cb2(GtkWidget *widget, gpointer user_data) {
    BMSignalData *d = (BMSignalData*)user_data;
    if (!d || !d->bm_callback) return;
    typedef void (*bm_cb2_t)(void*, void*);
    ((bm_cb2_t)d->bm_callback)((void*)widget, d->gadget);
}

/* cb2_ret: int callback(widget, gadget) -> gboolean */
static gboolean thunk_cb2_ret(GtkWidget *widget, gpointer user_data) {
    BMSignalData *d = (BMSignalData*)user_data;
    if (!d || !d->bm_callback) return FALSE;
    typedef int (*bm_cb2r_t)(void*, void*);
    int r = ((bm_cb2r_t)d->bm_callback)((void*)widget, d->gadget);
    return r ? TRUE : FALSE;
}

/* cb3: void callback(widget, event, gadget) */
static void thunk_cb3(GtkWidget *widget, GdkEvent *event, gpointer user_data) {
    BMSignalData *d = (BMSignalData*)user_data;
    if (!d || !d->bm_callback) return;
    typedef void (*bm_cb3_t)(void*, void*, void*);
    ((bm_cb3_t)d->bm_callback)((void*)widget, (void*)event, d->gadget);
}

/* cb3_ret: int callback(widget, event, gadget) -> gboolean */
static gboolean thunk_cb3_ret(GtkWidget *widget, GdkEvent *event, gpointer user_data) {
    BMSignalData *d = (BMSignalData*)user_data;
    if (!d || !d->bm_callback) return FALSE;
    typedef int (*bm_cb3r_t)(void*, void*, void*);
    int r = ((bm_cb3r_t)d->bm_callback)((void*)widget, (void*)event, d->gadget);
    return r ? TRUE : FALSE;
}

/* cb3a_ret: int callback(widget, value, gadget) -> gboolean
   (value is gint) */
static gboolean thunk_cb3a_ret(GtkWidget *widget, gint value, gpointer user_data) {
    BMSignalData *d = (BMSignalData*)user_data;
    if (!d || !d->bm_callback) return FALSE;
    typedef int (*bm_cb3a_t)(void*, int, void*);
    int r = ((bm_cb3a_t)d->bm_callback)((void*)widget, (int)value, d->gadget);
    return r ? TRUE : FALSE;
}

/* cb4: void callback(widget, url, stream, gadget) */
static void thunk_cb4(GtkWidget *widget, gpointer url, gpointer stream, gpointer user_data) {
    BMSignalData *d = (BMSignalData*)user_data;
    if (!d || !d->bm_callback) return;
    typedef void (*bm_cb4_t)(void*, void*, void*, void*);
    ((bm_cb4_t)d->bm_callback)((void*)widget, url, stream, d->gadget);
}

/* cb4_ret: int callback(widget, url, stream, gadget) -> gboolean */
static gboolean thunk_cb4_ret(GtkWidget *widget, gpointer url, gpointer stream, gpointer user_data) {
    BMSignalData *d = (BMSignalData*)user_data;
    if (!d || !d->bm_callback) return FALSE;
    typedef int (*bm_cb4r_t)(void*, void*, void*, void*);
    int r = ((bm_cb4r_t)d->bm_callback)((void*)widget, url, stream, d->gadget);
    return r ? TRUE : FALSE;
}


/* cb4a: void callback(widget, val1, val2_double, gadget) -- (non-returning version) */
static void thunk_cb4a(GtkWidget *widget, int val1, double val2, gpointer user_data) {
    BMSignalData *d = (BMSignalData*)user_data;
    if (!d || !d->bm_callback) return;
    typedef void (*bm_cb4a_t)(void*, int, double, void*);
    ((bm_cb4a_t)d->bm_callback)((void*)widget, val1, val2, d->gadget);
}

/* cb4a_ret: int callback(widget, val1, val2_double, gadget) -> gboolean */
static gboolean thunk_cb4a_ret(GtkWidget *widget, int val1, double val2, gpointer user_data) {
    BMSignalData *d = (BMSignalData*)user_data;
    if (!d || !d->bm_callback) return FALSE;
    typedef int (*bm_cb4a_t)(void*, int, double, void*);
    int r = ((bm_cb4a_t)d->bm_callback)((void*)widget, val1, val2, d->gadget);
    return r ? TRUE : FALSE;
}

/* cb5: void callback(widget, val1, val2, val3, gadget) */
static void thunk_cb5(GtkWidget *widget, int v1, int v2, int v3, gpointer user_data) {
    BMSignalData *d = (BMSignalData*)user_data;
    if (!d || !d->bm_callback) return;
    typedef void (*bm_cb5_t)(void*, int, int, int, void*);
    ((bm_cb5_t)d->bm_callback)((void*)widget, v1, v2, v3, d->gadget);
}

/* cb8: void callback(widget, context, val1, val2, data, val3, val4, gadget) */
static void thunk_cb8(GtkWidget *widget, gpointer context, int val1, int val2, gpointer data, int val3, int val4, gpointer user_data) {
    BMSignalData *d = (BMSignalData*)user_data;
    if (!d || !d->bm_callback) return;
    typedef void (*bm_cb8_t)(void*, void*, int, int, void*, int, int, void*);
    ((bm_cb8_t)d->bm_callback)((void*)widget, context, val1, val2, data, val3, val4, d->gadget);
}

/* tabchange: void callback(widget, a, index, gadget) */
static void thunk_tabchange(GtkWidget *widget, gpointer a, int index, gpointer user_data) {
    BMSignalData *d = (BMSignalData*)user_data;
    if (!d || !d->bm_callback) return;
    typedef void (*bm_tab_t)(void*, void*, int, void*);
    ((bm_tab_t)d->bm_callback)((void*)widget, a, index, d->gadget);
}


/* =========================
   Wrapper connect functions
   ========================= */

/* helper: creates BMSignalData and calls g_signal_connect_data */
static unsigned long bmx_connect_with_thunk(void *widget, BBString *name, GCallback thunk, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    char *n = bbStringToUTF8String(name);
    BMSignalData *d = g_malloc0(sizeof(BMSignalData));
    d->bm_callback = bm_callback;
    d->bm_destroy = bm_destroy;
    d->gadget = gadget;
    unsigned long id = g_signal_connect_data(widget, n, thunk, d, (GClosureNotify)bm_destroy_data, (GConnectFlags)flag);
    bbMemFree(n);
    return id;
}

/* wrapper per arity */
unsigned long bmx_g_signal_connect_data_cb2(void *widget, BBString *name, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    return bmx_connect_with_thunk(widget, name, (GCallback)thunk_cb2, bm_callback, gadget, bm_destroy, flag);
}
unsigned long bmx_g_signal_connect_data_cb2_ret(void *widget, BBString *name, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    return bmx_connect_with_thunk(widget, name, (GCallback)thunk_cb2_ret, bm_callback, gadget, bm_destroy, flag);
}
unsigned long bmx_g_signal_connect_data_cb3(void *widget, BBString *name, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    return bmx_connect_with_thunk(widget, name, (GCallback)thunk_cb3, bm_callback, gadget, bm_destroy, flag);
}
unsigned long bmx_g_signal_connect_data_cb3_ret(void *widget, BBString *name, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    return bmx_connect_with_thunk(widget, name, (GCallback)thunk_cb3_ret, bm_callback, gadget, bm_destroy, flag);
}
unsigned long bmx_g_signal_connect_data_cb3a_ret(void *widget, BBString *name, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    return bmx_connect_with_thunk(widget, name, (GCallback)thunk_cb3a_ret, bm_callback, gadget, bm_destroy, flag);
}
unsigned long bmx_g_signal_connect_data_cb4(void *widget, BBString *name, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    return bmx_connect_with_thunk(widget, name, (GCallback)thunk_cb4, bm_callback, gadget, bm_destroy, flag);
}
unsigned long bmx_g_signal_connect_data_cb4_ret(void *widget, BBString *name, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    return bmx_connect_with_thunk(widget, name, (GCallback)thunk_cb4_ret, bm_callback, gadget, bm_destroy, flag);
}
unsigned long bmx_g_signal_connect_data_cb4a(void *widget, BBString *name, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    return bmx_connect_with_thunk(widget, name, (GCallback)thunk_cb4a, bm_callback, gadget, bm_destroy, flag);
}
unsigned long bmx_g_signal_connect_data_cb4a_ret(void *widget, BBString *name, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    return bmx_connect_with_thunk(widget, name, (GCallback)thunk_cb4a_ret, bm_callback, gadget, bm_destroy, flag);
}
unsigned long bmx_g_signal_connect_data_cb5(void *widget, BBString *name, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    return bmx_connect_with_thunk(widget, name, (GCallback)thunk_cb5, bm_callback, gadget, bm_destroy, flag);
}
unsigned long bmx_g_signal_connect_data_cb8(void *widget, BBString *name, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    return bmx_connect_with_thunk(widget, name, (GCallback)thunk_cb8, bm_callback, gadget, bm_destroy, flag);
}
unsigned long bmx_g_signal_connect_data_tabchange(void *widget, BBString *name, void *bm_callback, void *gadget, void *bm_destroy, int flag) {
    return bmx_connect_with_thunk(widget, name, (GCallback)thunk_tabchange, bm_callback, gadget, bm_destroy, flag);
}

/* optional disconnect wrapper */
void bmx_g_signal_handler_disconnect(void *widget, unsigned long handlerid) {
    g_signal_handler_disconnect(widget, handlerid);
}
