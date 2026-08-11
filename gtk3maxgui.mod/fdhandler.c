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
#include <glib.h>

extern void bbSystemFlushAsyncOps(void);

typedef struct {
	GSource source;
	GPollFD fd;
} MaxEventSource;

static gboolean bmx_gtk_event_source_prepare(GSource * base, int * timeout) {
	(void)base;
	*timeout = -1;
	return FALSE;
}

static gboolean bmx_gtk_event_source_check(GSource * base) {
	MaxEventSource *source = (MaxEventSource*)base;
	return source->fd.revents != 0;
}

static gboolean bmx_gtk_event_source_dispatch(GSource * base, GSourceFunc callback, void * data) {
	(void)base;
	(void)callback;
	(void)data;
	bbSystemFlushAsyncOps();
	return TRUE;
}

static GSourceFuncs bmx_gtk_event_source_funcs =
{
	.prepare = bmx_gtk_event_source_prepare,
	.check = bmx_gtk_event_source_check,
	.dispatch = bmx_gtk_event_source_dispatch,
	.finalize = NULL
};

GSource * bmx_gtk_event_source_new(int fd) {
	MaxEventSource * source = (MaxEventSource *) g_source_new(&bmx_gtk_event_source_funcs, sizeof(MaxEventSource));
	source->fd.fd = fd;
	source->fd.events = G_IO_IN | G_IO_HUP | G_IO_ERR;
	g_source_add_poll(&source->source, &source->fd);

	g_source_attach(&source->source, g_main_context_default());

	return &source->source;
}
