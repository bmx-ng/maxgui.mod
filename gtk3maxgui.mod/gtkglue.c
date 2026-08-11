/*
  Copyright (c) 2006-2026 Bruce A Henderson
 
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

/*
 * MaxGUI exposes explicit child geometry. GtkLayout also has an unbounded
 * virtual canvas and derives child allocations from GTK requisitions, which
 * makes it a poor owner for MaxGUI's fixed client rectangles. In particular,
 * nested notebooks and scrolled widgets can retain an old allocation while
 * the portable gadget model has already been resized.
 *
 * BmxMaxGUIFixed retains GtkLayout's event-bearing bin window, which active
 * MaxGUI panels need for drawing and mouse input, but makes the rectangles
 * supplied by the MaxGUI adapter the sole authority when GTK allocates
 * children. The type is private to this bridge; BlitzMax sees only an opaque
 * GtkWidget pointer.
 */
typedef struct {
	int x;
	int y;
	int width;
	int height;
} BmxMaxGUIRect;

typedef struct _BmxMaxGUIFixed {
	GtkLayout parent_instance;
	GHashTable *rects;
} BmxMaxGUIFixed;

typedef struct _BmxMaxGUIFixedClass {
	GtkLayoutClass parent_class;
} BmxMaxGUIFixedClass;

G_DEFINE_TYPE(BmxMaxGUIFixed, bmx_maxgui_fixed, GTK_TYPE_LAYOUT)

static void bmx_maxgui_fixed_allocate_child(GtkWidget *child, const BmxMaxGUIRect *rect) {
	GtkAllocation allocation;
	/* A temporarily collapsed portable rectangle is not a valid allocation for
	 * a decorated GTK widget. GtkFrame and GtkNotebook can have borders larger
	 * than 1px, and older GTK 3 releases assert when their inner box becomes
	 * negative. Let GTK retain its safe natural allocation until MaxGUI supplies
	 * a usable rectangle; the next fixed-container pass applies it exactly. */
	if (rect->width <= 0 || rect->height <= 0) return;
	allocation.x = rect->x;
	allocation.y = rect->y;
	allocation.width = rect->width;
	allocation.height = rect->height;
	gtk_widget_size_allocate(child, &allocation);
}

static void bmx_maxgui_fixed_get_preferred_width(GtkWidget *widget, gint *minimum, gint *natural) {
	(void)widget;
	*minimum = 0;
	*natural = 0;
}

static void bmx_maxgui_fixed_get_preferred_height(GtkWidget *widget, gint *minimum, gint *natural) {
	(void)widget;
	*minimum = 0;
	*natural = 0;
}

static void bmx_maxgui_fixed_size_allocate(GtkWidget *widget, GtkAllocation *allocation) {
	BmxMaxGUIFixed *fixed = (BmxMaxGUIFixed *)widget;
	GList *children;
	GList *item;
	guint canvasWidth;
	guint canvasHeight;

	/* GtkLayout's bin window is a separate virtual canvas. Keep it identical
	 * to the MaxGUI client allocation so drawing and pointer events cover the
	 * complete gadget instead of GTK's small default canvas. */
	gtk_layout_get_size(GTK_LAYOUT(widget), &canvasWidth, &canvasHeight);
	if (canvasWidth != (guint)MAX(allocation->width, 1) ||
			canvasHeight != (guint)MAX(allocation->height, 1)) {
		gtk_layout_set_size(GTK_LAYOUT(widget), MAX(allocation->width, 1),
			MAX(allocation->height, 1));
	}

	GTK_WIDGET_CLASS(bmx_maxgui_fixed_parent_class)->size_allocate(widget, allocation);

	children = gtk_container_get_children(GTK_CONTAINER(widget));
	for (item = children; item; item = item->next) {
		GtkWidget *child = GTK_WIDGET(item->data);
		BmxMaxGUIRect *rect = (BmxMaxGUIRect *)g_hash_table_lookup(fixed->rects, child);
		if (rect && gtk_widget_get_visible(child)) {
			bmx_maxgui_fixed_allocate_child(child, rect);
		}
	}
	g_list_free(children);
}

static void bmx_maxgui_fixed_remove(GtkContainer *container, GtkWidget *child) {
	BmxMaxGUIFixed *fixed = (BmxMaxGUIFixed *)container;
	g_hash_table_remove(fixed->rects, child);
	GTK_CONTAINER_CLASS(bmx_maxgui_fixed_parent_class)->remove(container, child);
}

static void bmx_maxgui_fixed_finalize(GObject *object) {
	BmxMaxGUIFixed *fixed = (BmxMaxGUIFixed *)object;
	g_hash_table_destroy(fixed->rects);
	G_OBJECT_CLASS(bmx_maxgui_fixed_parent_class)->finalize(object);
}

static void bmx_maxgui_fixed_class_init(BmxMaxGUIFixedClass *klass) {
	GtkWidgetClass *widgetClass = GTK_WIDGET_CLASS(klass);
	GtkContainerClass *containerClass = GTK_CONTAINER_CLASS(klass);
	GObjectClass *objectClass = G_OBJECT_CLASS(klass);

	widgetClass->get_preferred_width = bmx_maxgui_fixed_get_preferred_width;
	widgetClass->get_preferred_height = bmx_maxgui_fixed_get_preferred_height;
	widgetClass->size_allocate = bmx_maxgui_fixed_size_allocate;
	containerClass->remove = bmx_maxgui_fixed_remove;
	objectClass->finalize = bmx_maxgui_fixed_finalize;
}

static void bmx_maxgui_fixed_init(BmxMaxGUIFixed *fixed) {
	fixed->rects = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL, free);
}

GtkWidget * bmx_gtk3_maxgui_fixed_new(void) {
	return GTK_WIDGET(g_object_new(bmx_maxgui_fixed_get_type(), NULL));
}

static void bmx_gtk3_maxgui_fixed_store_rect(BmxMaxGUIFixed *fixed, GtkWidget *child,
		int x, int y, int width, int height) {
	BmxMaxGUIRect *rect = (BmxMaxGUIRect *)g_hash_table_lookup(fixed->rects, child);
	GtkRequisition minimum;
	if (!rect) {
		rect = (BmxMaxGUIRect *)calloc(1, sizeof(BmxMaxGUIRect));
		g_hash_table_insert(fixed->rects, child, rect);
	}
	rect->x = x;
	rect->y = y;
	rect->width = MAX(width, 0);
	rect->height = MAX(height, 0);
	if (rect->width > 0 && rect->height > 0) {
		gtk_widget_set_size_request(child, rect->width, rect->height);
	} else {
		/* GtkLayout otherwise assigns an empty child 1x1 even when a frame needs
		 * two or more pixels for its theme extents. Restore native requisition,
		 * measure it, then retain a small but theme-safe transient request. */
		gtk_widget_set_size_request(child, -1, -1);
		gtk_widget_get_preferred_size(child, &minimum, NULL);
		gtk_widget_set_size_request(child, MAX(minimum.width, 2), MAX(minimum.height, 2));
	}
}

void bmx_gtk3_maxgui_fixed_put(GtkWidget *widget, GtkWidget *child,
		int x, int y, int width, int height) {
	BmxMaxGUIFixed *fixed = (BmxMaxGUIFixed *)widget;
	bmx_gtk3_maxgui_fixed_store_rect(fixed, child, x, y, width, height);
	gtk_layout_put(GTK_LAYOUT(widget), child, x, y);
	if (gtk_widget_get_visible(child)) {
		bmx_maxgui_fixed_allocate_child(child,
			(BmxMaxGUIRect *)g_hash_table_lookup(fixed->rects, child));
	}
	gtk_widget_queue_resize(widget);
}

void bmx_gtk3_maxgui_fixed_set_child_rect(GtkWidget *widget, GtkWidget *child,
		int x, int y, int width, int height) {
	BmxMaxGUIFixed *fixed = (BmxMaxGUIFixed *)widget;
	bmx_gtk3_maxgui_fixed_store_rect(fixed, child, x, y, width, height);
	gtk_layout_move(GTK_LAYOUT(widget), child, x, y);
	if (gtk_widget_get_visible(child)) {
		bmx_maxgui_fixed_allocate_child(child,
			(BmxMaxGUIRect *)g_hash_table_lookup(fixed->rects, child));
	}
	gtk_widget_queue_resize(widget);
}

/* Current GTK themes give entries and push-button-like controls substantially
 * more vertical padding than the portable MaxGUI examples allocate. Apply a
 * private compact class only to peers whose content would otherwise be clipped
 * inside their requested rectangle. */
static GtkCssProvider *bmx_maxgui_compact_provider;

static void bmx_maxgui_ensure_compact_provider(void) {
	if (!bmx_maxgui_compact_provider) {
		static const char css[] =
			".maxgui-compact-control { min-height: 0; padding-top: 0; padding-bottom: 0; }"
			".maxgui-compact-control entry { min-height: 0; padding-top: 0; padding-bottom: 0; }"
			".maxgui-compact-control button { min-height: 0; min-width: 0; padding-top: 0; padding-bottom: 0; }"
			".maxgui-compact-combo button { min-height: 0; padding-top: 0; padding-bottom: 0; }"
			".maxgui-compact-combo entry { min-height: 0; padding-top: 0; padding-bottom: 0; }"
			".maxgui-compact-scale { min-width: 0; min-height: 0; padding: 0; }";
		bmx_maxgui_compact_provider = gtk_css_provider_new();
		gtk_css_provider_load_from_data(bmx_maxgui_compact_provider, css, -1, NULL);
		gtk_style_context_add_provider_for_screen(gdk_screen_get_default(),
			GTK_STYLE_PROVIDER(bmx_maxgui_compact_provider),
			GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
	}
}

void bmx_gtk3_widget_apply_compact_style(GtkWidget *widget, int kind) {
	bmx_maxgui_ensure_compact_provider();
	gtk_style_context_add_class(gtk_widget_get_style_context(widget),
		kind == 2 ? "maxgui-compact-scale" :
			(kind == 1 ? "maxgui-compact-combo" : "maxgui-compact-control"));
}

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
	PangoFontDescription *font = NULL;
	gtk_style_context_get(context, GTK_STATE_FLAG_NORMAL, "font", &font, NULL);
	return font;
}

GtkTextIter * bmx_gtk3_gtktextiter_new() {
	return (GtkTextIter*)calloc(1, sizeof(GtkTextIter));
}

void bmx_gtk3_gtkallocation_get(GtkAllocation *allocation, int *width, int *height) {
	*width = allocation->width;
	*height = allocation->height;
}

GtkWidget * bmx_gtk3_event_target(GdkEvent *event) {
	GdkDevice *device;
	GdkWindow *window;
	gpointer userData = NULL;
	if (!event) return NULL;
	device = gdk_event_get_device(event);
	if (device) {
		window = gdk_device_get_window_at_position(device, NULL, NULL);
		if (window) gdk_window_get_user_data(window, &userData);
	}
	if (userData && GTK_IS_WIDGET(userData)) return GTK_WIDGET(userData);
	return gtk_get_event_widget(event);
}

int bmx_gtk3_event_coordinates(GdkEvent *event, GtkWidget *target, int *x, int *y) {
	GtkWidget *source;
	double eventX;
	double eventY;
	double rootX;
	double rootY;
	GdkWindow *targetWindow;
	GtkAllocation allocation;
	int originX;
	int originY;
	if (!event || !target || !x || !y) return 0;
	source = gtk_get_event_widget(event);
	if (!source || !gdk_event_get_coords(event, &eventX, &eventY)) return 0;
	if (gtk_widget_translate_coordinates(source, target,
			(int)eventX, (int)eventY, x, y)) return 1;

	/* translate_coordinates only works inside one widget hierarchy. Portable
	 * MaxGUI drag/drop can cross top-level windows, so use root coordinates as
	 * the common coordinate space when GTK cannot perform the translation. */
	if (!gdk_event_get_root_coords(event, &rootX, &rootY)) return 0;
	targetWindow = gtk_widget_get_window(target);
	if (!targetWindow) return 0;
	gdk_window_get_origin(targetWindow, &originX, &originY);
	*x = (int)rootX - originX;
	*y = (int)rootY - originY;
	if (!gtk_widget_get_has_window(target)) {
		gtk_widget_get_allocation(target, &allocation);
		*x -= allocation.x;
		*y -= allocation.y;
	}
	return 1;
}

void bmx_gtk3_gtktextiter_free(GtkTextIter * iter) {
	free(iter);
}

void bmx_gtk3_widget_override_color(GtkWidget *widget, int state, double red, double green, double blue, double alpha) {
	GdkRGBA color = { red, green, blue, alpha };
	GdkRGBA selected;
	GdkRGBA selectedBackdrop;

	if (state == GTK_STATE_FLAG_NORMAL) {
		GtkStyleContext *context = gtk_widget_get_style_context(widget);
		gtk_style_context_get_color(context, GTK_STATE_FLAG_SELECTED, &selected);
		gtk_style_context_get_color(context, GTK_STATE_FLAG_SELECTED | GTK_STATE_FLAG_BACKDROP, &selectedBackdrop);
	}
	gtk_widget_override_color(widget, state, &color);
	if (state == GTK_STATE_FLAG_NORMAL) {
		/* A normal-state application override otherwise wins over the theme's
		 * selected-row foreground and makes selection difficult to see. */
		gtk_widget_override_color(widget, GTK_STATE_FLAG_SELECTED, &selected);
		gtk_widget_override_color(widget, GTK_STATE_FLAG_SELECTED | GTK_STATE_FLAG_BACKDROP, &selectedBackdrop);
	}
}

void bmx_gtk3_widget_override_background_color(GtkWidget *widget, int state, double red, double green, double blue, double alpha) {
	GdkRGBA color = { red, green, blue, alpha };
	GdkRGBA selected;
	GdkRGBA selectedBackdrop;

	if (state == GTK_STATE_FLAG_NORMAL) {
		GtkStyleContext *context = gtk_widget_get_style_context(widget);
		gtk_style_context_get_background_color(context, GTK_STATE_FLAG_SELECTED, &selected);
		gtk_style_context_get_background_color(context, GTK_STATE_FLAG_SELECTED | GTK_STATE_FLAG_BACKDROP, &selectedBackdrop);
	}
	gtk_widget_override_background_color(widget, state, &color);
	if (state == GTK_STATE_FLAG_NORMAL) {
		gtk_widget_override_background_color(widget, GTK_STATE_FLAG_SELECTED, &selected);
		gtk_widget_override_background_color(widget, GTK_STATE_FLAG_SELECTED | GTK_STATE_FLAG_BACKDROP, &selectedBackdrop);
	}
}

void bmx_gtk3_widget_remove_background_color(GtkWidget *widget, int state) {
	gtk_widget_override_background_color(widget, state, NULL);
	if (state == GTK_STATE_FLAG_NORMAL) {
		gtk_widget_override_background_color(widget, GTK_STATE_FLAG_SELECTED, NULL);
		gtk_widget_override_background_color(widget, GTK_STATE_FLAG_SELECTED | GTK_STATE_FLAG_BACKDROP, NULL);
	}
}

void bmx_gtk3_color_chooser_set_rgba(GtkColorChooser *chooser, double red, double green, double blue, double alpha) {
	GdkRGBA color = { red, green, blue, alpha };
	gtk_color_chooser_set_rgba(chooser, &color);
}

BBINT bmx_gtk3_color_chooser_get_rgb(GtkColorChooser *chooser) {
	GdkRGBA color;
	gtk_color_chooser_get_rgba(chooser, &color);
	return ((BBINT)(color.red * 255.0) << 16) |
		((BBINT)(color.green * 255.0) << 8) |
		(BBINT)(color.blue * 255.0);
}

static void bmx_gtk3_set_boxed_property(GObject *object, const char *name, GType type, const void *boxed) {
	GValue value = G_VALUE_INIT;
	g_value_init(&value, type);
	g_value_set_boxed(&value, boxed);
	g_object_set_property(object, name, &value);
	g_value_unset(&value);
}

static void bmx_gtk3_set_enum_property(GObject *object, const char *name, GType type, int enumValue) {
	GValue value = G_VALUE_INIT;
	g_value_init(&value, type);
	g_value_set_enum(&value, enumValue);
	g_object_set_property(object, name, &value);
	g_value_unset(&value);
}

static void bmx_gtk3_set_int_property(GObject *object, const char *name, int intValue) {
	GValue value = G_VALUE_INIT;
	g_value_init(&value, G_TYPE_INT);
	g_value_set_int(&value, intValue);
	g_object_set_property(object, name, &value);
	g_value_unset(&value);
}

static void bmx_gtk3_set_boolean_property(GObject *object, const char *name, int boolValue) {
	GValue value = G_VALUE_INIT;
	g_value_init(&value, G_TYPE_BOOLEAN);
	g_value_set_boolean(&value, boolValue != 0);
	g_object_set_property(object, name, &value);
	g_value_unset(&value);
}

static GtkTextTag * bmx_gtk3_text_tag_new(GtkTextBuffer *buffer, const gchar *name) {
	GtkTextTag *tag = gtk_text_tag_new(name);
	gtk_text_tag_table_add(gtk_text_buffer_get_tag_table(buffer), tag);
	g_object_unref(tag);
	return tag;
}

GtkTextTag * bmx_gtk3_set_text_tag_style(GtkTextBuffer *buffer, const gchar *tagName, double red, double green, double blue, double alpha, int _style, int _weight, int _under, int _strike) {
	GdkRGBA color = { red, green, blue, alpha };
	GtkTextTag *tag = bmx_gtk3_text_tag_new(buffer, tagName);
	bmx_gtk3_set_boxed_property(G_OBJECT(tag), "foreground-rgba", GDK_TYPE_RGBA, &color);
	bmx_gtk3_set_enum_property(G_OBJECT(tag), "style", PANGO_TYPE_STYLE, _style);
	bmx_gtk3_set_int_property(G_OBJECT(tag), "weight", _weight);
	bmx_gtk3_set_enum_property(G_OBJECT(tag), "underline", PANGO_TYPE_UNDERLINE, _under);
	bmx_gtk3_set_boolean_property(G_OBJECT(tag), "strikethrough", _strike);
	return tag;
}

GtkTextTag * bmx_gtk3_set_text_bg_tag(GtkTextBuffer *buffer, const gchar *tagName, double red, double green, double blue, double alpha) {
	GdkRGBA color = { red, green, blue, alpha };
	GtkTextTag *tag = bmx_gtk3_text_tag_new(buffer, tagName);
	bmx_gtk3_set_boxed_property(G_OBJECT(tag), "background-rgba", GDK_TYPE_RGBA, &color);
	return tag;
}

BBString * bmx_gtk3_uri_to_filename(const char *uri) {
	gchar *filename = g_filename_from_uri(uri, NULL, NULL);
	BBString *result = bbStringFromUTF8String((const BBBYTE *)(filename ? filename : uri));
	if (filename) g_free(filename);
	return result;
}

BBArray * bmx_gtk3_selection_data_get_paths(GtkSelectionData * data) {
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
		s[i]=bmx_gtk3_uri_to_filename(uris[i]);
	}
	
	g_strfreev(uris);
	
	return p;
}

void bmx_g_object_set_int(void * handle, BBString * property, int value) {
	BBBYTE *p = bbStringToUTF8String(property);
	g_object_set(handle, (const char *)p, value, NULL);
	bbMemFree(p);
}

void bmx_g_object_set_double(void * handle, BBString * property, double value) {
	BBBYTE *p = bbStringToUTF8String(property);
	g_object_set(handle, (const char *)p, value, NULL);
	bbMemFree(p);
}

typedef void (*BMXGtkCallback2)(BBBYTE *, BBOBJECT);
typedef BBINT (*BMXGtkCallback2Ret)(BBBYTE *, BBOBJECT);
typedef void (*BMXGtkCallback3)(BBBYTE *, BBBYTE *, BBOBJECT);
typedef BBINT (*BMXGtkCallback3Ret)(BBBYTE *, BBBYTE *, BBOBJECT);
typedef void (*BMXGtkCallback3A)(BBBYTE *, BBINT, BBOBJECT);
typedef void (*BMXGtkCallback4)(BBBYTE *, BBBYTE *, BBBYTE *, BBOBJECT);
typedef BBINT (*BMXGtkCallback4A)(BBBYTE *, BBINT, BBDOUBLE, BBOBJECT);
typedef void (*BMXGtkCallback5)(BBBYTE *, BBINT, BBINT, BBINT, BBOBJECT);
typedef void (*BMXGtkCallback8)(BBBYTE *, BBBYTE *, BBINT, BBINT, BBBYTE *, BBINT, BBINT, BBOBJECT);
typedef void (*BMXGtkTabCallback)(BBBYTE *, BBBYTE *, BBINT, BBOBJECT);
typedef BBINT (*BMXGtkSciNotifyCallback)(BBBYTE *, BBINT, BBBYTE *, BBOBJECT);

typedef union {
	BMXGtkCallback2 cb2;
	BMXGtkCallback2Ret cb2Ret;
	BMXGtkCallback3 cb3;
	BMXGtkCallback3Ret cb3Ret;
	BMXGtkCallback3A cb3a;
	BMXGtkCallback4 cb4;
	BMXGtkCallback4A cb4a;
	BMXGtkCallback5 cb5;
	BMXGtkCallback8 cb8;
	BMXGtkTabCallback tab;
	BMXGtkSciNotifyCallback sciNotify;
} BMXGtkSignalCallback;

typedef struct {
	BMXGtkSignalCallback callback;
	BBOBJECT gadget;
} BMXGtkSignalClosure;

static BMXGtkSignalClosure * bmx_gtk_signal_closure_new(BBOBJECT gadget) {
	BMXGtkSignalClosure *closure = g_new0(BMXGtkSignalClosure, 1);
	closure->gadget = gadget;
	bbGCRetain(gadget);
	return closure;
}

static void bmx_gtk_signal_closure_destroy(gpointer data, GClosure *gclosure) {
	BMXGtkSignalClosure *closure = (BMXGtkSignalClosure *)data;
	(void)gclosure;
	bbGCRelease(closure->gadget);
	g_free(closure);
}

static gulong bmx_gtk_signal_connect(BBBYTE *widget, BBSTRING name, GCallback callback, BMXGtkSignalClosure *closure) {
	BBBYTE *signalName = bbStringToUTF8String(name);
	gulong result = g_signal_connect_data(widget, (const char *)signalName, callback, closure, bmx_gtk_signal_closure_destroy, (GConnectFlags)0);
	bbMemFree(signalName);
	if (!result) {
		bmx_gtk_signal_closure_destroy(closure, NULL);
	}
	return result;
}

static void bmx_gtk_signal_cb2(void *widget, gpointer data) {
	BMXGtkSignalClosure *closure = (BMXGtkSignalClosure *)data;
	closure->callback.cb2(widget, closure->gadget);
}

static gboolean bmx_gtk_signal_cb2_ret(void *widget, gpointer data) {
	BMXGtkSignalClosure *closure = (BMXGtkSignalClosure *)data;
	return closure->callback.cb2Ret(widget, closure->gadget);
}

static void bmx_gtk_signal_cb3(void *widget, void *arg, gpointer data) {
	BMXGtkSignalClosure *closure = (BMXGtkSignalClosure *)data;
	closure->callback.cb3(widget, arg, closure->gadget);
}

static gboolean bmx_gtk_signal_cb3_ret(void *widget, void *arg, gpointer data) {
	BMXGtkSignalClosure *closure = (BMXGtkSignalClosure *)data;
	return closure->callback.cb3Ret(widget, arg, closure->gadget);
}

static void bmx_gtk_signal_cb3a(void *widget, int value, gpointer data) {
	BMXGtkSignalClosure *closure = (BMXGtkSignalClosure *)data;
	closure->callback.cb3a(widget, value, closure->gadget);
}

static void bmx_gtk_signal_cb4(void *widget, void *arg1, void *arg2, gpointer data) {
	BMXGtkSignalClosure *closure = (BMXGtkSignalClosure *)data;
	closure->callback.cb4(widget, arg1, arg2, closure->gadget);
}

static gboolean bmx_gtk_signal_cb4a(void *widget, int value1, double value2, gpointer data) {
	BMXGtkSignalClosure *closure = (BMXGtkSignalClosure *)data;
	return closure->callback.cb4a(widget, value1, value2, closure->gadget);
}

static void bmx_gtk_signal_cb5(void *widget, int value1, int value2, int value3, gpointer data) {
	BMXGtkSignalClosure *closure = (BMXGtkSignalClosure *)data;
	closure->callback.cb5(widget, value1, value2, value3, closure->gadget);
}

static void bmx_gtk_signal_cb8(void *widget, void *context, int x, int y, void *selectionData, int info, int time, gpointer data) {
	BMXGtkSignalClosure *closure = (BMXGtkSignalClosure *)data;
	closure->callback.cb8(widget, context, x, y, selectionData, info, time, closure->gadget);
}

static void bmx_gtk_signal_tabchange(void *widget, void *page, unsigned int index, gpointer data) {
	BMXGtkSignalClosure *closure = (BMXGtkSignalClosure *)data;
	closure->callback.tab(widget, page, (int)index, closure->gadget);
}

static void bmx_gtk_signal_sci_notify(void *widget, int id, void *notification, gpointer data) {
	BMXGtkSignalClosure *closure = (BMXGtkSignalClosure *)data;
	(void)closure->callback.sciNotify(widget, id, notification, closure->gadget);
}

BBULONGINT bmx_g_signal_connect_cb2(BBBYTE *widget, BBSTRING name, BMXGtkCallback2 callback, BBOBJECT gadget) {
	BMXGtkSignalClosure *closure = bmx_gtk_signal_closure_new(gadget);
	closure->callback.cb2 = callback;
	return bmx_gtk_signal_connect(widget, name, G_CALLBACK(bmx_gtk_signal_cb2), closure);
}

BBULONGINT bmx_g_signal_connect_cb2_ret(BBBYTE *widget, BBSTRING name, BMXGtkCallback2Ret callback, BBOBJECT gadget) {
	BMXGtkSignalClosure *closure = bmx_gtk_signal_closure_new(gadget);
	closure->callback.cb2Ret = callback;
	return bmx_gtk_signal_connect(widget, name, G_CALLBACK(bmx_gtk_signal_cb2_ret), closure);
}

BBULONGINT bmx_g_signal_connect_cb3(BBBYTE *widget, BBSTRING name, BMXGtkCallback3 callback, BBOBJECT gadget) {
	BMXGtkSignalClosure *closure = bmx_gtk_signal_closure_new(gadget);
	closure->callback.cb3 = callback;
	return bmx_gtk_signal_connect(widget, name, G_CALLBACK(bmx_gtk_signal_cb3), closure);
}

BBULONGINT bmx_g_signal_connect_cb3_ret(BBBYTE *widget, BBSTRING name, BMXGtkCallback3Ret callback, BBOBJECT gadget) {
	BMXGtkSignalClosure *closure = bmx_gtk_signal_closure_new(gadget);
	closure->callback.cb3Ret = callback;
	return bmx_gtk_signal_connect(widget, name, G_CALLBACK(bmx_gtk_signal_cb3_ret), closure);
}

BBULONGINT bmx_g_signal_connect_cb3a(BBBYTE *widget, BBSTRING name, BMXGtkCallback3A callback, BBOBJECT gadget) {
	BMXGtkSignalClosure *closure = bmx_gtk_signal_closure_new(gadget);
	closure->callback.cb3a = callback;
	return bmx_gtk_signal_connect(widget, name, G_CALLBACK(bmx_gtk_signal_cb3a), closure);
}

BBULONGINT bmx_g_signal_connect_cb4(BBBYTE *widget, BBSTRING name, BMXGtkCallback4 callback, BBOBJECT gadget) {
	BMXGtkSignalClosure *closure = bmx_gtk_signal_closure_new(gadget);
	closure->callback.cb4 = callback;
	return bmx_gtk_signal_connect(widget, name, G_CALLBACK(bmx_gtk_signal_cb4), closure);
}

BBULONGINT bmx_g_signal_connect_cb4a(BBBYTE *widget, BBSTRING name, BMXGtkCallback4A callback, BBOBJECT gadget) {
	BMXGtkSignalClosure *closure = bmx_gtk_signal_closure_new(gadget);
	closure->callback.cb4a = callback;
	return bmx_gtk_signal_connect(widget, name, G_CALLBACK(bmx_gtk_signal_cb4a), closure);
}

BBULONGINT bmx_g_signal_connect_cb5(BBBYTE *widget, BBSTRING name, BMXGtkCallback5 callback, BBOBJECT gadget) {
	BMXGtkSignalClosure *closure = bmx_gtk_signal_closure_new(gadget);
	closure->callback.cb5 = callback;
	return bmx_gtk_signal_connect(widget, name, G_CALLBACK(bmx_gtk_signal_cb5), closure);
}

BBULONGINT bmx_g_signal_connect_cb8(BBBYTE *widget, BBSTRING name, BMXGtkCallback8 callback, BBOBJECT gadget) {
	BMXGtkSignalClosure *closure = bmx_gtk_signal_closure_new(gadget);
	closure->callback.cb8 = callback;
	return bmx_gtk_signal_connect(widget, name, G_CALLBACK(bmx_gtk_signal_cb8), closure);
}

BBULONGINT bmx_g_signal_connect_tabchange(BBBYTE *widget, BBSTRING name, BMXGtkTabCallback callback, BBOBJECT gadget) {
	BMXGtkSignalClosure *closure = bmx_gtk_signal_closure_new(gadget);
	closure->callback.tab = callback;
	return bmx_gtk_signal_connect(widget, name, G_CALLBACK(bmx_gtk_signal_tabchange), closure);
}

BBULONGINT bmx_g_signal_connect_sci_notify(BBBYTE *widget, BBSTRING name, BMXGtkSciNotifyCallback callback, BBOBJECT gadget) {
	BMXGtkSignalClosure *closure = bmx_gtk_signal_closure_new(gadget);
	closure->callback.sciNotify = callback;
	return bmx_gtk_signal_connect(widget, name, G_CALLBACK(bmx_gtk_signal_sci_notify), closure);
}
