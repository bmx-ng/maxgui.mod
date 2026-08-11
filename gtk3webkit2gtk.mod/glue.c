/*
  Copyright (c) 2026 Bruce A Henderson
 
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
#include <dlfcn.h>

typedef struct {
	void *(*web_view_new)(void);
	void (*web_view_load_uri)(void *, const char *);
	void (*web_view_stop_loading)(void *);
	int (*web_view_can_go_forward)(void *);
	int (*web_view_can_go_back)(void *);
	void (*web_view_go_forward)(void *);
	void (*web_view_go_back)(void *);
	const char *(*web_view_get_uri)(void *);
} BMXWebKitApi;

static void *bmx_webkit_library;
static BMXWebKitApi bmx_webkit_api;
static int bmx_webkit_initialized;
static int bmx_webkit_available;

static int bmx_webkit_load_symbol(void **target, const char *name) {
	*target = dlsym(bmx_webkit_library, name);
	return *target != 0;
}

static int bmx_webkit_initialize(void) {
	static const char *libraries[] = {
		"libwebkit2gtk-4.1.so.0",
		"libwebkit2gtk-4.0.so.37",
		0
	};
	int index;

	if (bmx_webkit_initialized) {
		return bmx_webkit_available;
	}
	bmx_webkit_initialized = 1;

	for (index = 0; libraries[index]; ++index) {
		bmx_webkit_library = dlopen(libraries[index], RTLD_NOW | RTLD_LOCAL);
		if (bmx_webkit_library) {
			break;
		}
	}
	if (!bmx_webkit_library) {
		return 0;
	}

	if (!bmx_webkit_load_symbol((void **)&bmx_webkit_api.web_view_new, "webkit_web_view_new") ||
		!bmx_webkit_load_symbol((void **)&bmx_webkit_api.web_view_load_uri, "webkit_web_view_load_uri") ||
		!bmx_webkit_load_symbol((void **)&bmx_webkit_api.web_view_stop_loading, "webkit_web_view_stop_loading") ||
		!bmx_webkit_load_symbol((void **)&bmx_webkit_api.web_view_can_go_forward, "webkit_web_view_can_go_forward") ||
		!bmx_webkit_load_symbol((void **)&bmx_webkit_api.web_view_can_go_back, "webkit_web_view_can_go_back") ||
		!bmx_webkit_load_symbol((void **)&bmx_webkit_api.web_view_go_forward, "webkit_web_view_go_forward") ||
		!bmx_webkit_load_symbol((void **)&bmx_webkit_api.web_view_go_back, "webkit_web_view_go_back") ||
		!bmx_webkit_load_symbol((void **)&bmx_webkit_api.web_view_get_uri, "webkit_web_view_get_uri")) {
		dlclose(bmx_webkit_library);
		bmx_webkit_library = 0;
		return 0;
	}

	bmx_webkit_available = 1;
	return 1;
}

int bmx_gtk3_webkit_available(void) {
	return bmx_webkit_initialize();
}

void *bmx_gtk3_webkit_web_view_new(void) {
	return bmx_webkit_initialize() ? bmx_webkit_api.web_view_new() : 0;
}

void bmx_gtk3_webkit_web_view_load_uri(void *handle, const char *uri) {
	if (bmx_webkit_initialize()) {
		bmx_webkit_api.web_view_load_uri(handle, uri);
	}
}

void bmx_gtk3_webkit_web_view_stop_loading(void *handle) {
	if (bmx_webkit_initialize()) {
		bmx_webkit_api.web_view_stop_loading(handle);
	}
}

int bmx_gtk3_webkit_web_view_can_go_forward(void *handle) {
	return bmx_webkit_initialize() ? bmx_webkit_api.web_view_can_go_forward(handle) : 0;
}

int bmx_gtk3_webkit_web_view_can_go_back(void *handle) {
	return bmx_webkit_initialize() ? bmx_webkit_api.web_view_can_go_back(handle) : 0;
}

void bmx_gtk3_webkit_web_view_go_forward(void *handle) {
	if (bmx_webkit_initialize()) {
		bmx_webkit_api.web_view_go_forward(handle);
	}
}

void bmx_gtk3_webkit_web_view_go_back(void *handle) {
	if (bmx_webkit_initialize()) {
		bmx_webkit_api.web_view_go_back(handle);
	}
}

const char *bmx_gtk3_webkit_web_view_get_uri(void *handle) {
	return bmx_webkit_initialize() ? bmx_webkit_api.web_view_get_uri(handle) : 0;
}
