#import <Cocoa/Cocoa.h>

/*
 * Stable native identity for the Cocoa bridge.
 *
 * The BlitzMax adapter owns this peer and treats it as an opaque handle.
 * nativeHandle and clientView are non-owning references whose lifetimes are
 * managed by the widget-specific AppKit implementation in cocoa.macos.m. They
 * are cleared before the peer is destroyed. Native code does not inspect the
 * BlitzMax TNSGadget object layout.
 */
@interface BMXMaxGUIPeer : NSObject {
	id nativeHandle;
	NSView *clientView;
	int gadgetClass;
	int gadgetStyle;
	BMXMaxGUIPeer *parentPeer;
	NSColor *textColor;
	int fontStyle;
	BOOL valid;
}

- (id)initWithClass:(int)gadgetClassValue style:(int)gadgetStyleValue parentPeer:(BMXMaxGUIPeer *)parentPeerValue;
- (void)setNativeHandle:(id)handle clientView:(NSView *)view;
- (void)invalidate;
- (id)nativeHandle;
- (NSView *)clientView;
- (int)gadgetClass;
- (int)gadgetStyle;
- (BMXMaxGUIPeer *)parentPeer;
- (void)setTextColor:(NSColor *)color;
- (NSColor *)textColor;
- (void)setFontStyle:(int)style;
- (int)fontStyle;
- (BOOL)isValid;

@end

@implementation BMXMaxGUIPeer

- (id)initWithClass:(int)gadgetClassValue style:(int)gadgetStyleValue parentPeer:(BMXMaxGUIPeer *)parentPeerValue {
	self = [super init];
	if (self) {
		nativeHandle = nil;
		clientView = nil;
		gadgetClass = gadgetClassValue;
		gadgetStyle = gadgetStyleValue;
		parentPeer = [parentPeerValue retain];
		textColor = nil;
		fontStyle = 0;
		valid = YES;
	}
	return self;
}

- (void)setNativeHandle:(id)handle clientView:(NSView *)view {
	nativeHandle = handle;
	clientView = view;
}

- (void)invalidate {
	valid = NO;
	nativeHandle = nil;
	clientView = nil;
	[parentPeer release];
	parentPeer = nil;
	[textColor release];
	textColor = nil;
}

- (id)nativeHandle {
	return valid ? nativeHandle : nil;
}

- (NSView *)clientView {
	return valid ? clientView : nil;
}

- (int)gadgetClass {
	return gadgetClass;
}

- (int)gadgetStyle {
	return gadgetStyle;
}

- (BMXMaxGUIPeer *)parentPeer {
	return valid && [parentPeer isValid] ? parentPeer : nil;
}

- (void)setTextColor:(NSColor *)color {
	if (textColor == color) return;
	[textColor release];
	textColor = [color retain];
}

- (NSColor *)textColor {
	return valid ? textColor : nil;
}

- (void)setFontStyle:(int)style {
	fontStyle = style;
}

- (int)fontStyle {
	return fontStyle;
}

- (BOOL)isValid {
	return valid;
}

@end

static NSMutableDictionary *BMXPeerByNativeAddress;

static NSValue *BMXPointerKey(void *pointer) {
	return [NSValue valueWithPointer:pointer];
}

static void BMXRegisterNativeAddress(void *address, BMXMaxGUIPeer *peer) {
	if (!address) return;
	if (!BMXPeerByNativeAddress) BMXPeerByNativeAddress = [[NSMutableDictionary alloc] init];
	[BMXPeerByNativeAddress setObject:BMXPointerKey(peer) forKey:BMXPointerKey(address)];
}

static void BMXUnregisterNativeAddress(void *address, BMXMaxGUIPeer *peer) {
	if (!address || !BMXPeerByNativeAddress) return;
	NSValue *key = BMXPointerKey(address);
	NSValue *registered = [BMXPeerByNativeAddress objectForKey:key];
	if ([registered pointerValue] == peer) [BMXPeerByNativeAddress removeObjectForKey:key];
}

static void BMXMaxGUIRequireMainThread(void) {
	if (![NSThread isMainThread]) {
		[NSException raise:NSInternalInconsistencyException
			format:@"MaxGUI Cocoa peers must be accessed on the main thread"];
	}
}

void *NSPeerCreate(int gadgetClass, int gadgetStyle, void *parentPeer) {
	BMXMaxGUIRequireMainThread();
	return [[BMXMaxGUIPeer alloc] initWithClass:gadgetClass style:gadgetStyle parentPeer:(BMXMaxGUIPeer *)parentPeer];
}

void NSPeerSetNativeObjects(void *peerHandle, void *handle, void *view) {
	BMXMaxGUIRequireMainThread();
	BMXMaxGUIPeer *peer = (BMXMaxGUIPeer *)peerHandle;
	BMXUnregisterNativeAddress([peer nativeHandle], peer);
	BMXUnregisterNativeAddress([peer clientView], peer);
	[peer setNativeHandle:(id)handle clientView:(NSView *)view];
	BMXRegisterNativeAddress(handle, peer);
	BMXRegisterNativeAddress(view, peer);
}

void NSPeerDestroy(void *peerHandle) {
	BMXMaxGUIRequireMainThread();
	BMXMaxGUIPeer *peer = (BMXMaxGUIPeer *)peerHandle;
	if (!peer) return;
	BMXUnregisterNativeAddress([peer nativeHandle], peer);
	BMXUnregisterNativeAddress([peer clientView], peer);
	[peer invalidate];
	[peer release];
}

void *NSPeerForNativeHandle(void *handle) {
	BMXMaxGUIRequireMainThread();
	if (!handle || !BMXPeerByNativeAddress) return NULL;
	return [[BMXPeerByNativeAddress objectForKey:BMXPointerKey(handle)] pointerValue];
}

int NSPeerGadgetClass(void *peerHandle) {
	BMXMaxGUIRequireMainThread();
	return [(BMXMaxGUIPeer *)peerHandle gadgetClass];
}

int NSPeerGadgetStyle(void *peerHandle) {
	BMXMaxGUIRequireMainThread();
	return [(BMXMaxGUIPeer *)peerHandle gadgetStyle];
}

void *NSPeerParent(void *peerHandle) {
	BMXMaxGUIRequireMainThread();
	return [(BMXMaxGUIPeer *)peerHandle parentPeer];
}

void NSPeerStoreTextColor(void *peerHandle, void *color) {
	BMXMaxGUIRequireMainThread();
	[(BMXMaxGUIPeer *)peerHandle setTextColor:(NSColor *)color];
}

void *NSPeerTextColor(void *peerHandle) {
	BMXMaxGUIRequireMainThread();
	return [(BMXMaxGUIPeer *)peerHandle textColor];
}

void NSPeerStoreFontStyle(void *peerHandle, int style) {
	BMXMaxGUIRequireMainThread();
	[(BMXMaxGUIPeer *)peerHandle setFontStyle:style];
}

int NSPeerFontStyle(void *peerHandle) {
	BMXMaxGUIRequireMainThread();
	return [(BMXMaxGUIPeer *)peerHandle fontStyle];
}

void *NSPeerNativeHandle(void *peerHandle) {
	BMXMaxGUIRequireMainThread();
	return [(BMXMaxGUIPeer *)peerHandle nativeHandle];
}

void *NSPeerClientView(void *peerHandle) {
	BMXMaxGUIRequireMainThread();
	return [(BMXMaxGUIPeer *)peerHandle clientView];
}

int NSPeerIsValid(void *peerHandle) {
	BMXMaxGUIRequireMainThread();
	return peerHandle && [(BMXMaxGUIPeer *)peerHandle isValid];
}
