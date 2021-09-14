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
		return &bbEmptyString;
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
