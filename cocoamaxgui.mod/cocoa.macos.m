// cocoa.macos.m
// blitzmax cocoa interface 
// by simonarmstrong@blitzbasic.com

#include <AppKit/AppKit.h>
#include <WebKit/WebView.h>
#include <WebKit/WebFrame.h>
#include <WebKit/WebPolicyDelegate.h>
#include <WebKit/WebFrameLoadDelegate.h>
#include <WebKit/WebDataSource.h>
#include <ApplicationServices/ApplicationServices.h>
#include <stdint.h>

#include <brl.mod/blitz.mod/blitz.h>
#include <maxgui.mod/maxgui.mod/maxgui.h>
#include <pub.mod/macos.mod/macos.h>

#define STATUSBARHEIGHT 18

static CGFloat MaxGUIScrollerWidth(){
	return [NSScroller scrollerWidthForControlSize:NSControlSizeRegular scrollerStyle:NSScrollerStyleLegacy];
}

// Custom Cursor Stuff

const int curNoEntry = 0;
const int curHelp = 1;
const int curSizeAll = 2;
const int curNESW = 3;
const int curNWSE = 4;

typedef struct { short bits[16]; short mask[16]; short hitpoint[2]; } ArrayCursor;

ArrayCursor arrCursors[5] =
{{{0x0000, 0x07E0, 0x1FF0, 0x3838, 0x3C0C, 0x6E0E, 0x6706, 0x6386, 0x61C6, 0x60E6, 0x7076, 0x303C, 0x1C1C, 0x0FF8, 0x07E0, 0x0000},
{0x0540, 0x0FF0, 0x3FF8, 0x3C3C, 0x7E0E, 0xFF0F, 0x6F86, 0xE7C7, 0x63E6, 0xE1F7, 0x70FE, 0x707E, 0x3C3C, 0x1FFC, 0x0FF0, 0x0540},
{0x0007, 0x0007}},
{{0x0000, 0x4078, 0x60FC, 0x71CE, 0x7986, 0x7C06, 0x7E0E, 0x7F1C, 0x7FB8, 0x7C30, 0x6C30, 0x4600, 0x0630, 0x0330, 0x0300, 0x0000},
{0xC078, 0xE0FC, 0xF1FE, 0xFBFF, 0xFFCF, 0xFF8F, 0xFF1F, 0xFFBE, 0xFFFC, 0xFE78, 0xFF78, 0xEFF8, 0xCFF8, 0x87F8, 0x07F8, 0x0300},
{0x0001, 0x0001}},
{{0x0000, 0x0080, 0x01C0, 0x03E0, 0x0080, 0x0888, 0x188C, 0x3FFE, 0x188C, 0x0888, 0x0080, 0x03E0, 0x01C0, 0x0080, 0x0000, 0x0000},
{0x0080, 0x01C0, 0x03E0, 0x07F0, 0x0BE8, 0x1DDC, 0x3FFE, 0x7FFF, 0x3FFE, 0x1DDC, 0x0BE8, 0x07F0, 0x03E0, 0x01C0, 0x0080, 0x0000},
{0x0007, 0x0008}},
{{0x0000, 0x001E, 0x000E, 0x060E, 0x0712, 0x03A0, 0x01C0, 0x00E0, 0x0170, 0x1238, 0x1C18, 0x1C00, 0x1E00, 0x0000, 0x0000, 0x0000},
{0x007F, 0x003F, 0x0E1F, 0x0F0F, 0x0F97, 0x07E3, 0x03E1, 0x21F0, 0x31F8, 0x3A7C, 0x3C3C, 0x3E1C, 0x3F00, 0x3F80, 0x0000, 0x0000},
{0x0006, 0x0009}},
{{0x0000, 0x7800, 0x7000, 0x7060, 0x48E0, 0x05C0, 0x0380, 0x0700, 0x0E80, 0x1C48, 0x1838, 0x0038, 0x0078, 0x0000, 0x0000, 0x0000},
{0xFE00, 0xFC00, 0xF870, 0xF0F0, 0xE9F0, 0xC7E0, 0x87C0, 0x0F84, 0x1F8C, 0x3E5C, 0x3C3C, 0x387C, 0x00FC, 0x01FC, 0x0000, 0x0000},
{0x0006, 0x0006}}};

// End of Cursor Stuff

void* NSActiveGadget();

void brl_event_EmitEvent( BBObject *event );
BBObject *maxgui_maxgui_HotKeyEvent( int key,int mods );
void maxgui_maxgui_event_DispatchGuiEvents();
void maxgui_cocoamaxgui_cocoagui_EmitCocoaOSEvent( NSEvent *event,void *handle,void *view,BBObject *gadget );
int maxgui_cocoamaxgui_cocoagui_EmitCocoaMouseEvent( NSEvent *event,void *handle,void *view );
int maxgui_cocoamaxgui_cocoagui_EmitCocoaKeyEvent( NSEvent *event,void *handle,void *view );
void maxgui_cocoamaxgui_cocoagui_PostCocoaTreeEvent( int ev,void *treeHandle,void *nodeHandle,int mods,int x,int y );
int maxgui_cocoamaxgui_cocoagui_PostCocoaTreeDragEvent( void *treeHandle,void *nodeHandle,int button,int mods,int x,int y );
int maxgui_cocoamaxgui_cocoagui_PostCocoaGadgetDropEvent( void *targetHandle,int button,int mods,int x,int y );
int maxgui_cocoamaxgui_cocoagui_CancelCocoaGadgetDrag( int button );
void *NSPeerForNativeHandle( void *handle );
void NSPeerSetNativeObjects( void *peer,void *handle,void *view );
void *NSPeerNativeHandle( void *peer );
void *NSPeerClientView( void *peer );
int NSPeerGadgetClass( void *peer );
int NSPeerGadgetStyle( void *peer );
void *NSPeerParent( void *peer );
void NSPeerStoreTextColor( void *peer,void *color );
void *NSPeerTextColor( void *peer );
void NSPeerStoreFontStyle( void *peer,int style );
int NSPeerFontStyle( void *peer );
#if defined(__LP64__)
void maxgui_cocoamaxgui_cocoagui_PostCocoaGuiEvent( int ev,void *handle,BBInt64 data,int mods,int x,int y,BBObject *extra );
#else
void maxgui_cocoamaxgui_cocoagui_PostCocoaGuiEvent( int ev,void *handle,int data,int mods,int x,int y,BBObject *extra );
#endif

int maxgui_cocoamaxgui_cocoagui_FilterChar( void *handle,int key,int mods );
int maxgui_cocoamaxgui_cocoagui_FilterKeyDown( void *handle,int key,int mods );

static void EmitOSEvent( NSEvent *event,void *handle ){
//printf("EmitOSEvent\n");fflush(stdout);
	void *peer=NSPeerForNativeHandle(handle);
	maxgui_cocoamaxgui_cocoagui_EmitCocoaOSEvent( event,peer ? peer : handle,handle,&bbNullObject );
}

int HaltMouseEvents;

static int EmitMouseEvent( NSEvent *event,void *handle ){
	if(([event type] == NSEventTypeScrollWheel) && ([event deltaY] == 0)) return 0;
	void *peer=NSPeerForNativeHandle(handle);
	if(!HaltMouseEvents) return maxgui_cocoamaxgui_cocoagui_EmitCocoaMouseEvent( event,peer ? peer : handle,handle );
	return 0;
}

static int EmitKeyEvent( NSEvent *event,void *handle ){
	void *peer=NSPeerForNativeHandle(handle);
	return maxgui_cocoamaxgui_cocoagui_EmitCocoaKeyEvent( event,peer ? peer : handle,handle );
}

#if defined(__LP64__)
static void PostGuiEvent( int ev,void *handle,BBInt64 data,int mods,int x,int y,BBObject *extra ){
#else
static void PostGuiEvent( int ev,void *handle,int data,int mods,int x,int y,BBObject *extra ){
#endif
//printf("PostGuiEvent\n");fflush(stdout);
	if (extra==0) extra=&bbNullObject;
	void *peer=NSPeerForNativeHandle(handle);
	maxgui_cocoamaxgui_cocoagui_PostCocoaGuiEvent( ev,peer ? peer : handle,data,mods,x,y,extra );
}

static NSPoint MaxGUIEventPointInView(NSEvent *event,NSView *view){
	NSRect bounds=[view bounds];
	NSPoint point=[view convertPoint:[event locationInWindow] fromView:nil];
	point.x-=NSMinX(bounds);
	if ([view isFlipped]) point.y-=NSMinY(bounds);
	else point.y=NSMaxY(bounds)-point.y;
	return point;
}

static NSPoint MaxGUIWindowPointInView(NSPoint windowPoint,NSView *view){
	NSRect bounds=[view bounds];
	NSPoint point=[view convertPoint:windowPoint fromView:nil];
	point.x-=NSMinX(bounds);
	if ([view isFlipped]) point.y-=NSMinY(bounds);
	else point.y=NSMaxY(bounds)-point.y;
	return point;
}

static void *MaxGUIPeerForViewHierarchy(NSView *view){
	while (view){
		void *peer=NSPeerForNativeHandle(view);
		if (peer) return peer;
		view=[view superview];
	}
	return 0;
}

static int MaxGUIMouseButtonForEvent(NSEvent *event){
	NSInteger button=[event buttonNumber]+1;
	return button>=MOUSE_LEFT && button<=MOUSE_MIDDLE ? (int)button : 0;
}

static int MaxGUIPostDropForEvent(NSEvent *event){
	int button=MaxGUIMouseButtonForEvent(event);
	if (!button) return 0;
	NSWindow *eventWindow=[event window];
	if (!eventWindow) return maxgui_cocoamaxgui_cocoagui_CancelCocoaGadgetDrag(button);
	NSPoint screenPoint=[eventWindow convertPointToScreen:[event locationInWindow]];
	NSInteger windowNumber=[NSWindow windowNumberAtPoint:screenPoint belowWindowWithWindowNumber:0];
	NSWindow *dropWindow=[NSApp windowWithWindowNumber:windowNumber];
	if (!dropWindow) return maxgui_cocoamaxgui_cocoagui_CancelCocoaGadgetDrag(button);
	NSPoint windowPoint=[dropWindow convertPointFromScreen:screenPoint];
	NSView *hitView=[[dropWindow contentView] hitTest:windowPoint];
	void *targetPeer=MaxGUIPeerForViewHierarchy(hitView);
	if (!targetPeer) return maxgui_cocoamaxgui_cocoagui_CancelCocoaGadgetDrag(button);
	NSView *targetView=(NSView*)NSPeerClientView(targetPeer);
	if (!targetView || ![targetView isKindOfClass:[NSView class]]) return maxgui_cocoamaxgui_cocoagui_CancelCocoaGadgetDrag(button);
	NSPoint point=MaxGUIWindowPointInView(windowPoint,targetView);
	int posted=maxgui_cocoamaxgui_cocoagui_PostCocoaGadgetDropEvent(targetPeer,button,bbSystemTranslateMods([event modifierFlags]),(int)point.x,(int)point.y);
	if (!posted) maxgui_cocoamaxgui_cocoagui_CancelCocoaGadgetDrag(button);
	return posted;
}

static NSColor *MaxGUIRGBColor(int r,int g,int b){
	return [NSColor colorWithSRGBRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

static NSAppearance *MaxGUIAppearanceForRGBBackground(int r,int g,int b){
	double luminance=(0.2126*r+0.7152*g+0.0722*b)/255.0;
	NSString *name=luminance>=0.5 ? NSAppearanceNameAqua : NSAppearanceNameDarkAqua;
	return [NSAppearance appearanceNamed:name];
}

static NSDictionary *MaxGUIFileURLReadingOptions(){
	return [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
}

static NSArray *MaxGUIFileURLsFromPasteboard(NSPasteboard *pasteboard){
	return [pasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]] options:MaxGUIFileURLReadingOptions()];
}

static NSDragOperation MaxGUIFileDragOperation(id <NSDraggingInfo> sender){
	NSPasteboard *pasteboard=[sender draggingPasteboard];
	if ([pasteboard canReadObjectForClasses:[NSArray arrayWithObject:[NSURL class]] options:MaxGUIFileURLReadingOptions()]) return NSDragOperationCopy;
	return NSDragOperationNone;
}

static BOOL MaxGUIAcceptDroppedFiles(id window,id <NSDraggingInfo> sender){
	NSArray *urls=MaxGUIFileURLsFromPasteboard([sender draggingPasteboard]);
	void *peer=NSPeerForNativeHandle(window);
	NSView *view=(NSView*)(peer ? NSPeerClientView(peer) : [window contentView]);
	NSPoint point=MaxGUIWindowPointInView([sender draggingLocation],view);
	for (NSURL *url in urls){
		NSString *path=[url path];
		if (!path) continue;
		BBString *name=bbStringFromNSString(path);
		PostGuiEvent(BBEVENT_WINDOWACCEPT,window,0,0,(int)point.x,(int)point.y,(BBObject*)name);
	}
	return [urls count]>0;
}

int NSMaxGUIFileURLPasteboardItemRoundTrip(){
	NSString *expected=@"/tmp";
	NSPasteboardItem *item=[[[NSPasteboardItem alloc] init] autorelease];
	if (![item setString:[[NSURL fileURLWithPath:expected] absoluteString] forType:NSPasteboardTypeFileURL]) return 0;
	NSURL *url=[NSURL URLWithString:[item stringForType:NSPasteboardTypeFileURL]];
	return [url isFileURL] && [[url path] isEqualToString:expected] ? 1 : 0;
}

static int filterKeyDownEvent( NSEvent *event,id source ){
	int i,sz,res,key,mods;
	NSString *ch;
	key=bbSystemTranslateKey( [event keyCode] );
	mods=bbSystemTranslateMods( [event modifierFlags] );
	void *peer=NSPeerForNativeHandle(source);
	res=maxgui_cocoamaxgui_cocoagui_FilterKeyDown( peer ? peer : source,key,mods );
	if (res==0) return 0;
	ch=[event characters];
	sz=[ch length];
	for( i=0;i<sz;++i ){
		key=[ch characterAtIndex:i];
		switch( key ){
			case 3:key=13;break;	//Brucey's numberpad enter-key hack
			case 127:key=8;break;
			case 63272:key=127;break;
		}
		res=maxgui_cocoamaxgui_cocoagui_FilterChar( peer ? peer : source,key,mods );
		if (res==0) return 0;
	}
	return 1;
}

void NSRelease( NSObject *obj ){[obj release];}

// prototypes

@class CocoaApp;
@class FlippedView;
@class PanelView;
@class CanvasView;
@class ListView;
@class TreeView;
@class NodeItem;
@class TextView;
@class TabView;
@class WindowView;
@class ImageString;
@class MaxGUIItemCellView;
@class TableView;
@class ToolView;
@class Scroller;

@interface CocoaApp:NSObject <NSWindowDelegate,NSTextFieldDelegate,NSComboBoxDelegate,NSToolbarItemValidation>{
	NSMutableArray		*menuitems;
}
-(id)init;
+(void)delayedGadgetAction:(NSObject*)o;
+(void)scheduleGadgetAction:(NSObject*)o;
+(void)dispatchGuiEvents;
-(BOOL)windowShouldClose:(id)sender;
-(void)windowDidResize:(NSNotification *)aNotification;
-(void)windowDidMove:(NSNotification *)aNotification;
-(BOOL)windowShouldZoom:(NSWindow *)sender toFrame:(NSRect)newFrame;
-(void)windowDidBecomeKey:(NSNotification *)aNotification;
-(void)menuSelect:(id)sender;
-(void)iconSelect:(id)sender;
-(void)sliderSelect:(id)sender;
-(void)scrollerSelect:(id)sender;
-(void)buttonPush:(id)sender;
-(void)textEdit:(id)sender;
-(void)comboBoxSelectionDidChange:(NSNotification *)notification;
-(BOOL)validateToolbarItem:(NSToolbarItem *)theItem;
-(void)addMenuItem:(NSMenuItem *)item;
-(void)removeMenuItem:(NSMenuItem *)item;
@end

void ScheduleEventDispatch(){
	[CocoaApp performSelector:@selector(dispatchGuiEvents) withObject:nil afterDelay:0.0];
}

@interface Scroller:NSScroller{
}
-(id)init;
//-(id)initWithFrame:(NSRect)rect;
//-(void)drawParts;
//-(void)drawKnob;
//-(void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag;
//-(void)drawArrow:(NSScrollerArrow)arrow highlight:(BOOL)flag;
//-(void)highlight:(BOOL)flag;
@end

@interface FlippedView:NSView{
}
-(BOOL)isFlipped;
-(BOOL)mouseDownCanMoveWindow;
@end

@interface PanelView:NSBox{
	int			style;
	int			enabled;
}
-(BOOL)mouseDownCanMoveWindow;
-(void)setColor:(NSColor*)rgb;
-(void)setAlpha:(float)alpha;
-(void)setStyle:(int)s;
-(void)setImage:(NSImage *)image withFlags:(int)flags;
-(BOOL)acceptsFirstResponder;
-(BOOL)becomeFirstResponder;

-(void)setEnabled:(BOOL)flag;
-(BOOL)isEnabled;
@end

@interface PanelViewContent:NSView{
	NSColor		*color;
	NSImage		*image;
	int			imageflags;
	float		alpha;
}
-(BOOL)isFlipped;
-(BOOL)mouseDownCanMoveWindow;
-(void)setColor:(NSColor*)rgb;
-(void)setAlpha:(float)alpha;
-(void)setImage:(NSImage *)image withFlags:(int)flags;
-(void)drawRect:(NSRect)rect;
-(BOOL)hasColor;
-(void)dealloc;
@end

@interface CanvasView:PanelView{
}
-(void)drawRect:(NSRect)rect;
-(BOOL)acceptsFirstResponder;
-(BOOL)becomeFirstResponder;
@end

@interface ListView:NSScrollView <NSTableViewDataSource,NSTableViewDelegate>{
	TableView *table;
	NSTableColumn *column;
	NSMutableArray *items;
	NSColor *textColor;
	NSFont *font;
}
-(id)initWithFrame:(NSRect)rect;
-(id)table;
-(id)items;
-(void)removeItemAtIndex:(int)index;
-(void)setColor:(NSColor*)color;
-(void)setTextColor:(NSColor*)color;
-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
-(NSView *)tableView:(NSTableView *)aTableView viewForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
-(BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex;
-(void)clear;
-(void)addItem:(NSString*)text atIndex:(unsigned)index withImage:(NSImage*)image withTip:(NSString*)tip withExtra:(BBObject*)extra;
-(void)setItem:(NSString*)text atIndex:(unsigned)index withImage:(NSImage*)image withTip:(NSString*)tip withExtra:(BBObject*)extra;
-(void)selectItem:(unsigned)index;
-(void)deselectItem:(unsigned)index;
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification;
-(void)setEnabled:(BOOL)flag;
-(BOOL)isEnabled;
-(BOOL)configureRowView:(MaxGUIItemCellView *)rowView atRow:(NSInteger)rowIndex;
-(void)updateVisibleRows;
-(void)updateWidthForString:(ImageString *) string;
-(void)updateWidth;
-(void)queueWidthUpdate;
-(void)dealloc;
-(void)setFont:(NSFont*)font;
-(BOOL)performDoubleActionAtIndex:(NSInteger)index;
-(void)doubleClick:(id)sender;
@end

@interface MaxGUIItemCellView:NSTableCellView{
}
-(id)initWithIdentifier:(NSString *)identifier;
-(void)layout;
@end

@interface TableView:NSTableView{
}
-(NSMenu*)menuForEvent:(NSEvent *)theEvent;
@end

@interface OutlineView:NSOutlineView{
	id pressedItem;
	int pressedButton;
	BOOL dragPosted;
}
-(NSMenu*)menuForEvent:(NSEvent *)theEvent;
-(void)prepareDragWithEvent:(NSEvent *)event button:(int)button;
-(void)postDragWithEvent:(NSEvent *)event button:(int)button;
-(void)clearDrag;
@end

@interface NodeItem:NSObject{
	TreeView		*owner;
	NodeItem		*parent;
	NSMutableArray *kids;
	NSString		*title;
	NSImage		*icon;
}
-(void)dealloc;
-(id)initWithTitle:(NSString*)text;
-(void)updateWidth;
-(void)queueWidthUpdate;
-(void)setOwner:(TreeView*)treeview;
-(id)getOwner;
-(void)show;
-(void)attach:(NodeItem*)parent_ atIndex:(unsigned)index_;
-(void)remove;
-(BOOL)canExpand;
-(NSMutableArray*)kids;
-(NSString *)value;
-(NSImage *)icon;
-(void)setTitle:(NSString*)text;
-(void)setIcon:(NSImage*)image;
-(unsigned)count;
@end

@interface TreeView:NSScrollView <NSOutlineViewDataSource,NSOutlineViewDelegate>{
@public
	NSOutlineView	*outline;
	NSTableColumn	*column,*colin;
	NodeItem		*rootNode;
	NSColor *textColor;
	NSFont *font;
	int suppressSelectionEvents;
}
-(id)initWithFrame:(NSRect)rect;
-(void)refresh;
-(NSInteger)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item;
-(id)outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item;
-(BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item;
-(id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item;
-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item;
-(unsigned)count;
-(id)rootNode;
-(id)selectedNode;
-(void)selectNode:(id)node;
-(void)expandNode:(id)node;
-(void)collapseNode:(id)node;
-(void)reconcileCollapsedNode:(id)node;
-(void)outlineViewItemDidExpand:(NSNotification *)notification;
-(void)outlineViewItemDidCollapse:(NSNotification *)notification;
-(void)outlineViewSelectionDidChange:(NSNotification *)notification;
-(BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item;
-(void)setColor:(NSColor*)color;
-(void)setExplicitColor:(NSColor*)color appearance:(NSAppearance*)appearance;
-(void)removeColor;
-(void)setTextColor:(NSColor*)color;
-(void)setFont:(NSFont*)font;
-(void)setEnabled:(BOOL)e;
-(BOOL)isEnabled;
-(void)configureRowView:(MaxGUIItemCellView *)rowView forNode:(NodeItem *)node;
-(void)updateVisibleRows;
-(void)dealloc;
-(BOOL)performDoubleActionAtIndex:(NSInteger)index;
-(void)doubleClick:(id)sender;
-(BOOL)performUserSelectionAtIndex:(NSInteger)index;
-(BOOL)performUserExpansionAtIndex:(NSInteger)index expand:(BOOL)expand;
-(BOOL)isItemExpandedAtIndex:(NSInteger)index;
@end

@interface TextView:NSTextView <NSTextViewDelegate,NSTextStorageDelegate>{
	@public
	NSScrollView	*scroll;
	NSMutableParagraphStyle *style;
	NSMutableDictionary *styles;
	NSTextStorage *storage;
	
	int lockedNest;
	NSRange lockedRange;
	int programmaticChangeNest;
}
-(NSSize)contentSize;
-(id)storage;
-(id)initWithFrame:(NSRect)rect;
-(id)getScroll;
-(void)setHidden:(BOOL)flag;
-(void)setWordWrap:(BOOL)flag;
-(void)setTabs:(int)tabs;
-(void)setMargins:(int)leftmargin;
-(void)beginProgrammaticChange;
-(void)endProgrammaticChange;
-(void)setText:(NSString*)text;
-(void)addText:(NSString*)text;
-(void)setScrollFrame:(NSRect)rect;
-(void)setTextColor:(NSColor*)color;
-(void)setColor:(NSColor*)color;
-(void)setFont:(NSFont*)font;
-(NSMenu *)menuForEvent:(NSEvent*)theEvent;
-(void)textDidChange:(NSNotification*)aNotification;
-(void)textDidEndEditing:(NSNotification*)aNotification;
-(void)textViewDidChangeSelection:(NSNotification *)aNotification;
-(void)textStorageDidProcessEditing:(NSNotification *)aNotification;
-(void)textStorageWillProcessEditing:(NSNotification *)aNotification;
-(void)updateDragTypeRegistration;
-(NSArray *)acceptableDragTypes;
-(void)free;
@end

@interface TabStripScrollView:NSScrollView
@end

@interface TabSegmentedControl:NSSegmentedControl
@end

@interface TabView:NSTabView <NSTabViewDelegate>{
	NSView		*client;
	TabStripScrollView *tabScroll;
	TabSegmentedControl *segments;
	NSButton *scrollLeft;
	NSButton *scrollRight;
	int		user;
}
-(id)initWithFrame:(NSRect)rect;
-(id)clientView;
-(NSRect)contentRect;
-(void)layout;
-(CGFloat)naturalSegmentWidth;
-(NSRect)rectForSegment:(NSInteger)index;
-(void)synchronizeSegments;
-(void)revealSelectedSegment;
-(void)updateScrollButtons;
-(void)scrollTabsLeft:(id)sender;
-(void)scrollTabsRight:(id)sender;
-(void)scrollBy:(CGFloat)distance;
-(void)segmentSelected:(id)sender;
-(void)insertTabViewItem:(NSTabViewItem *)tabViewItem atIndex:(NSInteger)index;
-(void)removeTabViewItem:(NSTabViewItem *)tabViewItem;
-(void)removeAllItemsForFree;
-(void)setEnabled:(BOOL)enabled;
-(BOOL)isEnabled;
-(void)setFrame:(NSRect)frameRect;
-(void)selectTabViewItemAtIndex:(int)index;
-(BOOL)performUserSelectionAtIndex:(NSInteger)index;
-(BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem;
-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
-(NSTabViewItem *)tabViewItemAtPoint:(NSPoint)point;
-(void)setFont:(NSFont *)font;
-(int)overflowPresentation;
-(void)dealloc;
@end

@interface WindowView:NSWindow{
	id	view;
	id	label[3];
	int gadgetStyle;
	int enabled;
	int zooming;
	NSView *dragging;
}
-(id)textFirstResponder;
-(id)initWithContentRect:(NSRect)rect styleMask:(unsigned int)mask backing:(NSBackingStoreType)backing defer:(BOOL)flag withStyle:(int)style;
-(id)clientView;
-(void)setStatus:(NSString*)text align:(int)pos;
-(id)statusLabelAtIndex:(NSInteger)index;
-(void)sendEvent:(NSEvent*)event;
-(NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
-(void)didResize;
-(void)didMove;
-(void)zoom;
-(NSRect)localRect;
-(BOOL)canBecomeKeyWindow;
-(BOOL)canBecomeMainWindow;
-(BOOL)becomeFirstResponder;
-(void)setEnabled:(BOOL)flag;
-(BOOL)isEnabled;
-(void)dealloc;
@end

@interface ToolView:NSPanel{
	id	view;
	id	label[3];
	int gadgetStyle;
	int enabled;
	int zooming;
	NSView *dragging;
}
-(id)textFirstResponder;
-(id)initWithContentRect:(NSRect)rect styleMask:(unsigned int)mask backing:(NSBackingStoreType)backing defer:(BOOL)flag withStyle:(int)style;
-(id)clientView;
-(void)setStatus:(NSString*)text align:(int)pos;
-(id)statusLabelAtIndex:(NSInteger)index;
-(void)sendEvent:(NSEvent*)event;
-(NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
-(void)didResize;
-(void)didMove;
-(void)zoom;
-(NSRect)localRect;
-(BOOL)canBecomeKeyWindow;
-(BOOL)canBecomeMainWindow;
-(BOOL)becomeFirstResponder;
-(void)setEnabled:(BOOL)flag;
-(BOOL)isEnabled;
-(void)dealloc;
@end

static CocoaApp *GlobalApp;

enum {
	MAXGUI_APP_MENU_NONE=0,
	MAXGUI_APP_MENU_ABOUT=1,
	MAXGUI_APP_MENU_PREFERENCES=2,
	MAXGUI_APP_MENU_QUIT=3
};

enum {
	MAXGUI_TOP_MENU_NONE=0,
	MAXGUI_TOP_MENU_VIEW=1,
	MAXGUI_TOP_MENU_WINDOW=2,
	MAXGUI_TOP_MENU_HELP=3
};

typedef struct MaxGUIApplicationMenuBinding {
	SEL action;
	NSMenuItem *standardItem;
	NSMenuItem *mappedItem;
	NSInteger index;
} MaxGUIApplicationMenuBinding;

static NSMenu *MaxGUIAppMenu;
static MaxGUIApplicationMenuBinding MaxGUIAppMenuBindings[4];
static NSMutableDictionary *MaxGUITopMenuProxies;

static NSValue *MaxGUITopMenuProxyKey(NSMenuItem *item){
	return [NSValue valueWithPointer:item];
}

static void MaxGUIRegisterTopMenuProxy(NSMenuItem *item,NSMenu *menu){
	if (!MaxGUITopMenuProxies) MaxGUITopMenuProxies=[[NSMutableDictionary alloc] init];
	[MaxGUITopMenuProxies setObject:menu forKey:MaxGUITopMenuProxyKey(item)];
}

static NSMenu *MaxGUITopMenuProxy(NSMenuItem *item){
	return [MaxGUITopMenuProxies objectForKey:MaxGUITopMenuProxyKey(item)];
}

static NSString *MaxGUICanonicalMenuTitle(NSString *title){
	if (!title) return @"";
	NSString *canonical=[[title stringByReplacingOccurrencesOfString:@"&" withString:@""] lowercaseString];
	canonical=[canonical stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	while ([canonical hasSuffix:@"."] || [canonical hasSuffix:@"…"]){
		canonical=[canonical substringToIndex:[canonical length]-1];
		canonical=[canonical stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	return canonical;
}

static int MaxGUIApplicationMenuRole(NSString *title){
	NSString *canonical=MaxGUICanonicalMenuTitle(title);
	if ([canonical hasPrefix:@"{{"] && [canonical hasSuffix:@"}}"]){
		if ([canonical isEqualToString:@"{{menu_about}}"] ||
			[canonical isEqualToString:@"{{menu_help_aboutmaxide}}"]) return MAXGUI_APP_MENU_ABOUT;
		if ([canonical isEqualToString:@"{{menu_preferences}}"] ||
			[canonical isEqualToString:@"{{menu_options}}"] ||
			[canonical isEqualToString:@"{{menu_file_ideoptions}}"]) return MAXGUI_APP_MENU_PREFERENCES;
		if ([canonical isEqualToString:@"{{menu_quit}}"] ||
			[canonical isEqualToString:@"{{menu_exit}}"] ||
			[canonical isEqualToString:@"{{menu_file_exit}}"]) return MAXGUI_APP_MENU_QUIT;
	}
	if ([canonical isEqualToString:@"about"] || [canonical hasPrefix:@"about "]) return MAXGUI_APP_MENU_ABOUT;
	if ([canonical isEqualToString:@"preferences"] || [canonical hasPrefix:@"preferences "] ||
		[canonical isEqualToString:@"settings"] || [canonical isEqualToString:@"options"] ||
		[canonical isEqualToString:@"ide options"]) return MAXGUI_APP_MENU_PREFERENCES;
	if ([canonical isEqualToString:@"quit"] || [canonical hasPrefix:@"quit "] ||
		[canonical isEqualToString:@"exit"] || [canonical hasPrefix:@"exit "]) return MAXGUI_APP_MENU_QUIT;
	return MAXGUI_APP_MENU_NONE;
}

static int MaxGUITopLevelMenuRole(NSString *title){
	NSString *canonical=MaxGUICanonicalMenuTitle(title);
	if ([canonical hasPrefix:@"{{"] && [canonical hasSuffix:@"}}"]){
		if ([canonical isEqualToString:@"{{menu_view}}"]) return MAXGUI_TOP_MENU_VIEW;
		if ([canonical isEqualToString:@"{{menu_window}}"]) return MAXGUI_TOP_MENU_WINDOW;
		if ([canonical isEqualToString:@"{{menu_help}}"]) return MAXGUI_TOP_MENU_HELP;
	}
	if ([canonical isEqualToString:@"view"]) return MAXGUI_TOP_MENU_VIEW;
	if ([canonical isEqualToString:@"window"]) return MAXGUI_TOP_MENU_WINDOW;
	if ([canonical isEqualToString:@"help"]) return MAXGUI_TOP_MENU_HELP;
	return MAXGUI_TOP_MENU_NONE;
}

static void MaxGUIInitializeApplicationMenuBindings(){
	if (!MaxGUIAppMenuBindings[MAXGUI_APP_MENU_ABOUT].action){
		MaxGUIAppMenuBindings[MAXGUI_APP_MENU_ABOUT].action=@selector(orderFrontStandardAboutPanel:);
		MaxGUIAppMenuBindings[MAXGUI_APP_MENU_PREFERENCES].action=@selector(showPreferences:);
		MaxGUIAppMenuBindings[MAXGUI_APP_MENU_QUIT].action=@selector(terminate:);
	}
}

static NSMenuItem *MaxGUIItemWithAction(NSMenu *menu,SEL action){
	for (NSMenuItem *item in [menu itemArray]) if ([item action]==action) return item;
	return nil;
}

static NSMenu *MaxGUIApplicationMenu(){
	if (MaxGUIAppMenu) return MaxGUIAppMenu;
	MaxGUIInitializeApplicationMenuBindings();
	for (NSMenuItem *root in [[NSApp mainMenu] itemArray]){
		NSMenu *submenu=[root submenu];
		if (submenu && (MaxGUIItemWithAction(submenu,@selector(orderFrontStandardAboutPanel:)) ||
			MaxGUIItemWithAction(submenu,@selector(terminate:)))){
			MaxGUIAppMenu=submenu;
			break;
		}
	}
	return MaxGUIAppMenu;
}

static BOOL MaxGUIMapApplicationMenuItem(NSMenuItem *item,int role){
	if (role<=MAXGUI_APP_MENU_NONE || role>MAXGUI_APP_MENU_QUIT) return NO;
	NSMenu *appMenu=MaxGUIApplicationMenu();
	if (!appMenu) return NO;
	MaxGUIApplicationMenuBinding *binding=&MaxGUIAppMenuBindings[role];
	if (binding->mappedItem) return NO;
	NSMenuItem *standard=MaxGUIItemWithAction(appMenu,binding->action);
	if (!standard) return NO;
	binding->index=[appMenu indexOfItem:standard];
	binding->standardItem=[standard retain];
	binding->mappedItem=item;
	[item setKeyEquivalent:[standard keyEquivalent]];
	[item setKeyEquivalentModifierMask:[standard keyEquivalentModifierMask]];
	[appMenu removeItem:standard];
	if ([item menu]) [[item menu] removeItem:item];
	[appMenu insertItem:item atIndex:MIN(binding->index,(NSInteger)[appMenu numberOfItems])];
	return YES;
}

static BOOL MaxGUIUnmapApplicationMenuItem(NSMenuItem *item){
	NSMenu *appMenu=MaxGUIApplicationMenu();
	for (int role=MAXGUI_APP_MENU_ABOUT;role<=MAXGUI_APP_MENU_QUIT;role++){
		MaxGUIApplicationMenuBinding *binding=&MaxGUIAppMenuBindings[role];
		if (binding->mappedItem!=item) continue;
		if ([item menu]) [[item menu] removeItem:item];
		if (appMenu && binding->standardItem){
			[appMenu insertItem:binding->standardItem atIndex:MIN(binding->index,(NSInteger)[appMenu numberOfItems])];
		}
		[binding->standardItem release];
		binding->standardItem=nil;
		binding->mappedItem=nil;
		binding->index=0;
		return YES;
	}
	return NO;
}

static NSMenuItem *MaxGUITopLevelItem(int role){
	NSMenu *mainMenu=[NSApp mainMenu];
	for (NSMenuItem *item in [mainMenu itemArray]){
		if (role==MAXGUI_TOP_MENU_WINDOW && [item submenu]==[NSApp windowsMenu]) return item;
		if (role==MAXGUI_TOP_MENU_HELP && [item submenu]==[NSApp helpMenu]) return item;
		if (role==MAXGUI_TOP_MENU_VIEW && [MaxGUICanonicalMenuTitle([item title]) isEqualToString:@"view"]) return item;
	}
	return nil;
}

static NSInteger MaxGUIApplicationMenuInsertionIndex(){
	NSMenu *mainMenu=[NSApp mainMenu];
	NSInteger index=0;
	for (NSMenuItem *item in [mainMenu itemArray]){
		if ([item submenu]==MaxGUIApplicationMenu()) { index++; continue; }
		if ([item submenu]==[NSApp windowsMenu] || [item submenu]==[NSApp helpMenu] ||
			[MaxGUICanonicalMenuTitle([item title]) isEqualToString:@"view"]) return index;
		index++;
	}
	return [mainMenu numberOfItems];
}

static void MaxGUIReconcileMenuItemRole(NSMenuItem *item){
	int appRole=MaxGUIApplicationMenuRole([item title]);
	if (appRole){
		MaxGUIMapApplicationMenuItem(item,appRole);
		return;
	}
	int topRole=MaxGUITopLevelMenuRole([item title]);
	if (!topRole || [item menu]!=[NSApp mainMenu]) return;
	if (topRole==MAXGUI_TOP_MENU_HELP){
		if (![NSApp helpMenu] || [NSApp helpMenu]==[item submenu]){
			[[NSApp mainMenu] removeItem:item];
			[[NSApp mainMenu] addItem:item];
			[NSApp setHelpMenu:[item submenu]];
		}
		return;
	}
	NSMenu *standardMenu=nil;
	if (topRole==MAXGUI_TOP_MENU_WINDOW) standardMenu=[NSApp windowsMenu];
	else {
		for (NSMenuItem *root in [[NSApp mainMenu] itemArray]){
			if (root!=item && [MaxGUICanonicalMenuTitle([root title]) isEqualToString:@"view"]){
				standardMenu=[root submenu];
				break;
			}
		}
	}
	if (!standardMenu) return;
	[[NSApp mainMenu] removeItem:item];
	[item setSubmenu:nil];
	MaxGUIRegisterTopMenuProxy(item,standardMenu);
}

static void MaxGUIPrepareMenuItemForFree(NSMenuItem *item){
	MaxGUIUnmapApplicationMenuItem(item);
	if ([NSApp helpMenu] && [item submenu]==[NSApp helpMenu]) [NSApp setHelpMenu:nil];
	[MaxGUITopMenuProxies removeObjectForKey:MaxGUITopMenuProxyKey(item)];
}

// WebView is intentionally retained for the final legacy release because
// HtmlViewRun() synchronously returns a JavaScript result. WKWebView cannot
// preserve that contract without re-entrant main-run-loop pumping.
#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#endif

@class HTMLView;
@interface HTMLView:WebView <WebPolicyDelegate,WebFrameLoadDelegate>{
	int		_state, _style;
}
-(id)initWithFrame:(NSRect)rect;
-(int)loaded;
-(void)setStyle:(int)style;
-(void)setAddress:(NSString*)address;
-(NSString*)address;
@end
@implementation HTMLView
-(id)initWithFrame:(NSRect)rect{
	self=[super initWithFrame:rect];
	[self setAutoresizingMask:NSViewNotSizable];
	[self setPolicyDelegate:self];
	[self setFrameLoadDelegate:self];
	[self setUIDelegate:(id<WebUIDelegate>)self];
	[self unregisterDraggedTypes];
	_state=0;
	return self;
}
-(int)loaded{
	return _state;
}
-(void)setStyle:(int)style{
	_style = style;
}
-(NSString*)address{
	WebDataSource		*datasource;
	datasource = [[self mainFrame] provisionalDataSource];
	if(datasource==nil) datasource = [[self mainFrame] dataSource];
	if(datasource==nil) return @"";
	return [[[datasource request] URL] absoluteString];
}
-(void)setAddress:(NSString*)address{
	NSURL			*url;
	NSURLRequest		*request;
	WebFrame			*frame;
		
	url=[NSURL URLWithString:address];
	if (url==nil) url=[NSURL fileURLWithPath:address];
	if (url==nil) return;
	_state=1;
	request=[NSURLRequest requestWithURL:url];
	frame=[self mainFrame];
	[frame loadRequest:request];
}
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
	int oldstate = _state;
	NSURLRequest *url;
	BBString*text;
	
	_state=0;
	
	url=[[frame dataSource]initialRequest];
	text=bbStringFromNSString([[url URL] relativePath]);
	
	if(oldstate)
		PostGuiEvent( BBEVENT_GADGETDONE,sender,0,0,0,0,(BBObject*)text );
}
- (void)webView:(WebView *)sender didChangeLocationWithinPageForFrame:(WebFrame *)frame{
	int oldstate = _state;
	NSURLRequest *url;
	BBString*text;
	
	_state=0;
	
	url=[[frame dataSource]initialRequest];
	text=bbStringFromNSString([[url URL] relativePath]);
	
	if(oldstate)
		PostGuiEvent( BBEVENT_GADGETDONE,sender,0,0,0,0,(BBObject*)text );
}
- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)url frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener{
	BBString*text;
	int	key;
	key=(int)[[actionInformation objectForKey:WebActionNavigationTypeKey] intValue];
	switch (key){
	case WebNavigationTypeOther:
	case WebNavigationTypeLinkClicked:
		if ((_state==0) && (_style & HTMLVIEW_NONAVIGATE)) {
			[listener ignore];
			text=bbStringFromNSString([[url URL] absoluteString]);
			PostGuiEvent( BBEVENT_GADGETACTION,sender,0,0,0,0,(BBObject*)text );
		}else{
			[listener use];
		}
		break;
	default:
		[listener use];
	}
}
- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems{
	if(_style&HTMLVIEW_NOCONTEXTMENU)
		return [NSArray array];
	else
		return defaultMenuItems;
}
@end

@interface MaxGUIWebPolicyTestListener:NSObject <WebPolicyDecisionListener>{
	@public
	int useCount;
	int ignoreCount;
}
@end
@implementation MaxGUIWebPolicyTestListener
-(void)use{useCount++;}
-(void)ignore{ignoreCount++;}
-(void)download{}
@end

int NSMaxGUIHTMLNonavigatePolicy(void *handle){
	if (!handle || ![(id)handle isKindOfClass:[HTMLView class]]) return 0;
	HTMLView *view=(HTMLView*)handle;
	[view setStyle:HTMLVIEW_NONAVIGATE];
	MaxGUIWebPolicyTestListener *listener=[[MaxGUIWebPolicyTestListener alloc] init];
	NSDictionary *action=[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:WebNavigationTypeLinkClicked] forKey:WebActionNavigationTypeKey];
	NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://example.invalid/maxgui-policy"]];
	[view webView:view decidePolicyForNavigationAction:action request:request frame:[view mainFrame] decisionListener:listener];
	int passed=listener->ignoreCount==1 && listener->useCount==0;
	[listener release];
	return passed;
}

#if defined(__clang__)
#pragma clang diagnostic pop
#endif


//Toolbar

@class Toolbar;
@interface Toolbar:NSToolbar <NSToolbarDelegate>{
	NSMutableDictionary	*itemsByIdentifier;
	NSMutableArray		*orderedIdentifiers;
	NSUInteger		nextItemNumber;
}
-(id)initWithIdentifier:(NSString *)string;
-(NSString *)nextItemIdentifier;
-(void)registerToolbarItem:(NSToolbarItem *)item atIndex:(NSInteger)index;
-(void)registerStandardIdentifier:(NSString *)identifier atIndex:(NSInteger)index;
-(NSToolbarItem *)registeredToolbarItemAtIndex:(NSInteger)index;
-(void)forgetToolbarItemAtIndex:(NSInteger)index;
@end
@implementation Toolbar
-(id)initWithIdentifier:(NSString *)string{
	self=[super initWithIdentifier:string];
	if (self) {
		itemsByIdentifier=[[NSMutableDictionary alloc] initWithCapacity:10];
		orderedIdentifiers=[[NSMutableArray alloc] initWithCapacity:10];
		nextItemNumber=0;
	}
	return self;
}
-(NSString *)nextItemIdentifier{
	NSString *identifier=[NSString stringWithFormat:@"%@.item.%lu",[self identifier],(unsigned long)nextItemNumber];
	nextItemNumber++;
	return identifier;
}
-(void)registerToolbarItem:(NSToolbarItem *)item atIndex:(NSInteger)index{
	NSString *identifier=[item itemIdentifier];
	[itemsByIdentifier setObject:item forKey:identifier];
	[orderedIdentifiers insertObject:identifier atIndex:index];
}
-(void)registerStandardIdentifier:(NSString *)identifier atIndex:(NSInteger)index{
	[orderedIdentifiers insertObject:identifier atIndex:index];
}
-(NSToolbarItem *)registeredToolbarItemAtIndex:(NSInteger)index{
	NSString *identifier=[orderedIdentifiers objectAtIndex:index];
	return [itemsByIdentifier objectForKey:identifier];
}
-(void)forgetToolbarItemAtIndex:(NSInteger)index{
	NSString *identifier=[orderedIdentifiers objectAtIndex:index];
	[itemsByIdentifier removeObjectForKey:identifier];
	[orderedIdentifiers removeObjectAtIndex:index];
}
-(NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag{
	return [itemsByIdentifier objectForKey:itemIdentifier];
}
-(NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar{
	return [NSArray arrayWithArray:orderedIdentifiers];
}
-(NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar{
	return [NSArray arrayWithArray:orderedIdentifiers];
}
-(void)dealloc{
	[self setDelegate:nil];
	[itemsByIdentifier release];
	[orderedIdentifiers release];
	[super dealloc];
}
@end


// CocoaApp
@implementation CocoaApp
+(void)dispatchGuiEvents{
	maxgui_maxgui_event_DispatchGuiEvents();
}
+(void)delayedGadgetAction:(NSObject*)o{  // See controlTextDidChange
	NSInteger selection=0;
	if ([o isKindOfClass:[NSComboBox class]]) selection=[(NSComboBox*)o indexOfSelectedItem];
	PostGuiEvent( BBEVENT_GADGETACTION, 
	              o, 
	              selection,
	              0,0,0,0 );
}
+(void)scheduleGadgetAction:(NSObject*)o{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedGadgetAction:) object:o];
	[self performSelector:@selector(delayedGadgetAction:) withObject:o afterDelay:0.0];
}
-(void)controlTextDidEndEditing:(NSNotification*)n{
	PostGuiEvent( BBEVENT_GADGETLOSTFOCUS,[n object],0,0,0,0,0 );
}
-(void)controlTextDidChange:(NSNotification*)n{
	NSObject *o = [n object];
	if ([o isKindOfClass:[NSComboBox class]]){
		if ([(NSComboBox*)o indexOfSelectedItem]>=0) return;
		[CocoaApp scheduleGadgetAction:o];
		return;
	}
	PostGuiEvent(BBEVENT_GADGETACTION,o,0,0,0,0,0);
}

-(id)init{
	self=[super init];
	if (self) menuitems=[[NSMutableArray arrayWithCapacity:10] retain];
	return self;
}
-(void)dealloc{
	[NSObject cancelPreviousPerformRequestsWithTarget:[CocoaApp class]];
	[menuitems release];
	[super dealloc];
}
-(BOOL)windowShouldClose:(id)sender{
	PostGuiEvent( BBEVENT_WINDOWCLOSE,sender,0,0,0,0,0 );
	return NO;
}
-(void)windowDidResize:(NSNotification *)aNotification{
	WindowView *window;
	ToolView * panel;
	if ([[aNotification object] isKindOfClass:[WindowView class]]) {
		window=(WindowView*)[aNotification object];
		[window didResize];
	} else {
		panel =(ToolView*)[aNotification object];
		[panel didResize];
	}
}
-(void)windowDidMove:(NSNotification *)aNotification{
	WindowView *window;
	ToolView * panel;
	if ([[aNotification object] isKindOfClass:[WindowView class]]) {
		window=(WindowView*)[aNotification object];
		[window didMove];
	} else {
		panel =(ToolView*)[aNotification object];
		[panel didMove];
	}
}
-(BOOL)windowShouldZoom:(NSWindow *)sender toFrame:(NSRect)newFrame{
	[(WindowView*)sender zoom];
	return YES;
}
-(void)windowDidBecomeKey:(NSNotification *)aNotification{
	NSWindow *window;
	window=(NSWindow*)[aNotification object];
	PostGuiEvent( BBEVENT_WINDOWACTIVATE,window,0,0,0,0,0 );
}
-(void)menuSelect:(id)sender{
	PostGuiEvent( BBEVENT_MENUACTION,sender,[sender tag],0,0,0,0 );
}
-(void)iconSelect:(id)sender{
	NSToolbar	*toolbar;
	int			index;
	toolbar=[sender toolbar];
	index=[[toolbar items] indexOfObject:sender];
	PostGuiEvent( BBEVENT_GADGETACTION,toolbar,index,0,0,0,0 );
}
-(void)sliderSelect:(id)sender{
	PostGuiEvent( BBEVENT_GADGETACTION,sender,0,0,0,0,0 );
}
-(void)scrollerSelect:(id)sender{
	NSScroller *scroller;
	int delta=0;
	scroller=(NSScroller *)sender;
	switch([scroller hitPart]){
	case NSScrollerDecrementPage:
		delta=-2;
		break;
	case NSScrollerIncrementPage:
		delta=2;
		break;
	default:
		break;
	}
	PostGuiEvent( BBEVENT_GADGETACTION,sender,delta,0,0,0,0 );
}
-(void)buttonPush:(id)sender{
	if([sender allowsMixedState]) [sender setAllowsMixedState:NO];
	PostGuiEvent( BBEVENT_GADGETACTION,sender,0,0,0,0,0 );
}
-(void)textEdit:(id)sender{
	PostGuiEvent( BBEVENT_GADGETACTION,sender,0,0,0,0,0 );
}
-(void)comboBoxSelectionDidChange:(NSNotification *)notification{
	NSComboBox *o=(NSComboBox*)[notification object];
	[CocoaApp scheduleGadgetAction:o];
}
-(void)comboBoxSelectionIsChanging:(NSNotification *)notification{
	
}
-(void)comboBoxWillPopUp:(NSNotification *)notification{
	HaltMouseEvents = 1;
}
-(void)comboBoxWillDismiss:(NSNotification *)notification{
	HaltMouseEvents = 0;
}
-(BOOL)validateToolbarItem:(NSToolbarItem *)item{
	return [item isEnabled];
}
-(void)addMenuItem:(NSMenuItem *)item{
	[menuitems addObject:item];
}
-(void)removeMenuItem:(NSMenuItem *)item{
	[menuitems removeObject:item];
}

@end

// Scroller

@implementation Scroller
-(id)init{
	self=[super init];
	if (self) [self setAlphaValue:.5f];
	return self;
}
//-(void)drawKnob{}
//-(void)drawParts{}
//-(void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag{}
//-(void)drawArrow:(NSScrollerArrow)arrow highlight:(BOOL)flag{}
//-(void)highlight:(BOOL)flag{}
@end

// FlippedView

@implementation FlippedView
-(BOOL)isFlipped{
	return YES;
}
-(BOOL)mouseDownCanMoveWindow{
	return YES;
}
@end

// PanelView

@implementation PanelView
- (BOOL)acceptsFirstResponder{
	return YES;
}
-(BOOL)becomeFirstResponder{
	return [self isEnabled];
}
-(void)setColor:(NSColor *)rgb{
	[[self contentView] setColor:rgb];
}
-(void)setAlpha:(float)al{
	[(PanelViewContent*)[self contentView] setAlpha:al];
}
-(void)setImage:(NSImage *)img withFlags:(int)flags{
	[[self contentView] setImage:img withFlags:flags];
}
-(void)setEnabled:(BOOL)e{
	enabled=e;
}
-(BOOL)isEnabled{
	return (enabled)?YES:NO;
}
-(void)setStyle:(int)s{
	switch ( s & (PANEL_SUNKEN|PANEL_RAISED|PANEL_GROUP) ){
		case PANEL_GROUP:
			[self setContentViewMargins: NSMakeSize(4.0,4.0)];
			[self setBoxType:NSBoxPrimary];
			[self setTransparent:NO];
			[self setTitlePosition: NSAtTop];
			break;
		case PANEL_RAISED:
		case PANEL_SUNKEN:
			[self setContentViewMargins: NSMakeSize(0.0,0.0)];
			[self setBoxType:NSBoxCustom];
			[self setBorderWidth:1.0];
			[self setBorderColor:[NSColor separatorColor]];
			[self setFillColor:[NSColor clearColor]];
			[self setCornerRadius:0.0];
			[self setTransparent:NO];
			[self setTitlePosition: NSNoTitle];
			break;
		default:
			[self setContentViewMargins: NSMakeSize(0.0,0.0)];
			[self setBoxType:NSBoxCustom];
			[self setTransparent:YES];
			[self setTitlePosition: NSNoTitle];
	}
	
	style=s;
}
-(BOOL)mouseDownCanMoveWindow{
	return NO;
}
@end

//PanelViewContent
@implementation PanelViewContent
-(BOOL)isFlipped{
	return YES;
}
-(BOOL)mouseDownCanMoveWindow{
	return NO;
}
-(void)dealloc{
	[color release];
	[image release];
	[super dealloc];
}
-(void)setColor:(NSColor *)rgb{
	if (color){
		[color release];
		color=0;
	}
	if(rgb){
		color=[rgb colorWithAlphaComponent:1.0];
		[color retain];
	}
	[self setNeedsDisplay:YES];
}
-(BOOL)hasColor{
	return color!=nil;
}
-(void)setImage:(NSImage *)img withFlags:(int)flags{
	if (img) [img retain];
	if (image) [image release];
	image=img;
	imageflags=flags;
	[self setNeedsDisplay:YES];
}
-(void)setAlpha:(float)al{
	alpha=al;
	if (color){
		[color release];
		color=[color colorWithAlphaComponent:alpha];
		[color retain];
	}
	[self setNeedsDisplay:YES];
}
-(void)drawRect:(NSRect)rect{
	
	NSRect dest = [self bounds];
	
	if (color){
		[color set];
		if (alpha<1.0)
			NSRectFillUsingOperation(dest,NSCompositingOperationSourceOver);
		else
			NSRectFill( dest );
	}
	
	if (image){
		NSCompositingOperation op;
		int		x,y,w,h;
		float	a;
		float	m,mm;
		NSRect	src,tile;

		a=alpha;
		op=NSCompositingOperationSourceOver;
		src.origin.x=0;
		src.origin.y=0;
		src.size=[image size];
		switch (imageflags&(GADGETPIXMAP_ICON-1)){
		case PANELPIXMAP_TILE:
			tile.size=[image size];
			for (y=0;y<dest.size.height;y+=src.size.height){
				tile.origin.y=y;
				for (x=0;x<dest.size.width;x+=src.size.width){
					tile.origin.x=x;
					[image drawInRect:tile fromRect:src operation:op fraction:a respectFlipped:YES hints:nil];
				}
			}					
			break;
		case PANELPIXMAP_CENTER:
			dest.origin.x=(dest.size.width-src.size.width)/2;
			dest.origin.y=(dest.size.height-src.size.height)/2;
			dest.size=src.size;
			[image drawInRect:dest fromRect:src operation:op fraction:a respectFlipped:YES hints:nil];
			break;
		case PANELPIXMAP_FIT:
			m=dest.size.width/src.size.width;
			mm=dest.size.height/src.size.height;
			if (m>mm) m=mm;
			dest.origin.x+=(dest.size.width-src.size.width*m)/2;
			dest.origin.y+=(dest.size.height-src.size.height*m)/2;
			dest.size.width=src.size.width*m;
			dest.size.height=src.size.height*m;
			[image drawInRect:dest fromRect:src operation:op fraction:a respectFlipped:YES hints:nil];
			break;
		case PANELPIXMAP_STRETCH:
			[image drawInRect:dest fromRect:src operation:op fraction:a respectFlipped:YES hints:nil];
			break;
		case PANELPIXMAP_FIT2:
			m = dest.size.width/dest.size.height;
			
			if ((dest.size.width/src.size.width)<(dest.size.height/src.size.height)){
				src.origin.x = (src.size.width-(src.size.height*m))/2;
				src.size.width = src.size.height*m;
			} else {
				src.origin.y = (src.size.height-(src.size.width/m))/2;
				src.size.height = src.size.width/m;
			}
			
			[image drawInRect:dest fromRect:src operation:op fraction:a respectFlipped:YES hints:nil];
			break;
		}
	}
	
	[super drawRect:rect];
} 
@end

// CanvasView
@implementation CanvasView
-(void)drawRect:(NSRect)rect{
	[super drawRect:rect];
	PostGuiEvent( BBEVENT_GADGETPAINT,self,0,0,0,0,0 );
} 
- (BOOL)acceptsFirstResponder{
	return YES;
}
-(BOOL)becomeFirstResponder{
	return [self isEnabled];
}
@end

int NSMaxGUIPanelCacheDisplay(void *handle){
	if (!handle || ![(id)handle isKindOfClass:[PanelView class]]) return 0;
	NSView *content=[(PanelView*)handle contentView];
	NSRect bounds=[content bounds];
	if (NSIsEmptyRect(bounds)) return 0;
	NSBitmapImageRep *bitmap=[content bitmapImageRepForCachingDisplayInRect:bounds];
	if (!bitmap) return 0;
	[content cacheDisplayInRect:bounds toBitmapImageRep:bitmap];
	return [bitmap pixelsWide]>0 && [bitmap pixelsHigh]>0 ? 1 : 0;
}

int NSMaxGUIPanelContentContained(void *handle){
	if (!handle || ![(id)handle isKindOfClass:[PanelView class]]) return 0;
	PanelView *panel=(PanelView*)handle;
	return NSContainsRect([panel bounds],[[panel contentView] frame]) ? 1 : 0;
}

// ImageString

@class ImageString;
@interface ImageString:NSObject{
	NSString	*_string;
	NSImage	*_image;
	NSString	*_tip;
	BBObject	*_extra;
}
-(id)initWithString:(NSString *)text image:(NSImage *)image tip:(NSString *)tip extra:(BBObject*)extra;
-(void)dealloc;
-(id)copyWithZone:(NSZone *)zone;
-(NSString*)string;
-(NSImage*)image;
-(NSString*)description;
-(BBObject*)extra;
@end
@implementation ImageString
-(id)initWithString:(NSString *)string image:(NSImage *)image tip:(NSString*)tip extra:(BBObject*)extra{
	_string=string;
	_image=image;
	_tip=tip;
	_extra=extra;
	if (string) [string retain];
	if (image) [image retain];
	if (tip) [tip retain];
	return self;
}
-(void)dealloc{
	if (_string) [_string release];
	if (_image) [_image release];
	if (_tip) [_tip release];
	[super dealloc];
}
-(id)copyWithZone:(NSZone *)zone{
	ImageString *copy=[[[self class] allocWithZone:zone] initWithString:_string image:_image tip:_tip extra:_extra];
	return copy;
}
-(NSString*)string{return _string;}
-(NSImage*)image{return _image;}
-(NSString*)description{return _tip;}
-(BBObject*)extra{return _extra;}
@end

// Shared view-based row presentation for modern list controls.

@implementation MaxGUIItemCellView
-(id)initWithIdentifier:(NSString *)identifier{
	self=[super initWithFrame:NSZeroRect];
	if (self){
		[self setIdentifier:identifier];
		NSImageView *iconView=[[NSImageView alloc] initWithFrame:NSZeroRect];
		[iconView setImageScaling:NSImageScaleProportionallyDown];
		[self addSubview:iconView];
		[self setImageView:iconView];
		[iconView release];

		NSTextField *label=[[NSTextField alloc] initWithFrame:NSZeroRect];
		[label setBezeled:NO];
		[label setDrawsBackground:NO];
		[label setEditable:NO];
		[label setSelectable:NO];
		[label setLineBreakMode:NSLineBreakByTruncatingTail];
		[self addSubview:label];
		[self setTextField:label];
		[label release];
	}
	return self;
}
-(void)layout{
	[super layout];
	NSRect bounds=[self bounds];
	NSImageView *iconView=[self imageView];
	NSTextField *label=[self textField];
	CGFloat x=4.0;
	NSImage *image=[iconView image];
	if (image){
		CGFloat side=MIN(16.0,MAX(0.0,bounds.size.height-2.0));
		[iconView setHidden:NO];
		[iconView setFrame:NSMakeRect(x,NSMidY(bounds)-side/2.0,side,side)];
		x+=side+4.0;
	}else{
		[iconView setHidden:YES];
	}
	[label setFrame:NSMakeRect(x,0.0,MAX(0.0,bounds.size.width-x-4.0),bounds.size.height)];
}
@end

// ListView

@implementation ListView
-(id)initWithFrame:(NSRect)rect{
	self=[super initWithFrame:rect];
	if (!self) return nil;
	[self setBorderType:NSNoBorder];
	[self setHasVerticalScroller:YES];
	[self setHasHorizontalScroller:YES];
	[self setAutohidesScrollers:YES];
	column=[[NSTableColumn alloc] init];
	NSSize contentSize = [self contentSize];	
	table=[[TableView alloc] initWithFrame:NSMakeRect(0, 0,contentSize.width, contentSize.height)];
	[table setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
	items=[[NSMutableArray alloc] initWithCapacity:10];
	[table setHeaderView:nil];	
	[table setDataSource:self];
	[table setDelegate:self];
	[table setTarget:self];
	[table setDoubleAction:@selector(doubleClick:)];
	[table setUsesAlternatingRowBackgroundColors:NO];
	[self setDocumentView:table];
	[table addTableColumn:column];
	font=[[NSFont systemFontOfSize:[NSFont systemFontSize]] retain];
	[table sizeLastColumnToFit];
	return self;
}
-(id)table{
	return table;
}
-(id)items{
	return items;
}
-(void)removeItemAtIndex:(int)index{
	[items removeObjectAtIndex:index];
	[table reloadData];
	[self queueWidthUpdate];
}
-(void)setColor:(NSColor*)color{
	[table setBackgroundColor:color];
}
-(void)setEnabled:(BOOL)e{
	[table setEnabled:e];
	[self updateVisibleRows];
}
-(BOOL)isEnabled{
	return [table isEnabled];
}
-(void)setTextColor:(NSColor*)color{
	if (textColor==color) return;
	[textColor release];
	textColor=[color retain];
	[self updateVisibleRows];
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
	return [items count];
}
-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
	if (rowIndex<0 || rowIndex>=[items count]) return nil;
	return [items objectAtIndex:rowIndex];
}
-(NSView *)tableView:(NSTableView *)aTableView viewForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
	static NSString *identifier=@"MaxGUIListCell";
	MaxGUIItemCellView *rowView=(MaxGUIItemCellView*)[aTableView makeViewWithIdentifier:identifier owner:self];
	if (!rowView) rowView=[[[MaxGUIItemCellView alloc] initWithIdentifier:identifier] autorelease];
	[self configureRowView:rowView atRow:rowIndex];
	return rowView;
}
-(BOOL)configureRowView:(MaxGUIItemCellView *)rowView atRow:(NSInteger)rowIndex{
	if (rowIndex<0 || rowIndex>=[items count]){
		[[rowView textField] setStringValue:@""];
		[[rowView imageView] setImage:nil];
		[rowView setToolTip:nil];
		return NO;
	}
	id value=[items objectAtIndex:rowIndex];
	if (![value isKindOfClass:[ImageString class]]){
		[[rowView textField] setStringValue:@""];
		[[rowView imageView] setImage:nil];
		[rowView setToolTip:nil];
		return NO;
	}
	ImageString *item=(ImageString*)value;
	[[rowView textField] setStringValue:[item string] ? [item string] : @""];
	[[rowView textField] setFont:font];
	NSColor *color=textColor ? textColor : [NSColor controlTextColor];
	if (![table isEnabled]) color=[NSColor disabledControlTextColor];
	else if ([table isRowSelected:rowIndex]) color=[NSColor alternateSelectedControlTextColor];
	[[rowView textField] setTextColor:color];
	[[rowView imageView] setImage:[item image]];
	[rowView setToolTip:[item description]];
	[rowView setNeedsLayout:YES];
	return YES;
}
-(void)updateVisibleRows{
	NSRange visibleRows=[table rowsInRect:[table visibleRect]];
	if (visibleRows.location==NSNotFound) return;
	NSUInteger end=NSMaxRange(visibleRows);
	for (NSUInteger row=visibleRows.location;row<end && row<[items count];row++){
		MaxGUIItemCellView *rowView=(MaxGUIItemCellView*)[table viewAtColumn:0 row:row makeIfNecessary:NO];
		if (rowView) [self configureRowView:rowView atRow:row];
	}
}
-(BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex{
	return NO;
}
-(BOOL)performDoubleActionAtIndex:(NSInteger)index{
	if (![table isEnabled] || index<0 || index>=[items count]) return NO;
	ImageString *item=(ImageString*)[items objectAtIndex:index];
	PostGuiEvent(BBEVENT_GADGETACTION,self,index,0,0,0,[item extra]);
	return YES;
}
-(void)doubleClick:(id)sender{
	[self performDoubleActionAtIndex:[table clickedRow]];
}
-(void)clear{
	[table setDelegate:nil];
	[items removeAllObjects];
	[table reloadData];
	[table setDelegate:self];
	[self queueWidthUpdate];
}
-(void)addItem:(NSString*)text atIndex:(unsigned)index withImage:(NSImage*)image withTip:(NSString*)tip withExtra:(BBObject*)extra{
	ImageString *item;
	item=[[ImageString alloc] initWithString:text image:image tip:tip extra:extra];
	[items insertObject:item atIndex:index];
	[self updateWidthForString:item];
	[item release];
	[table noteNumberOfRowsChanged];
}
-(void)setItem:(NSString*)text atIndex:(unsigned)index withImage:(NSImage*)image withTip:(NSString*)tip withExtra:(BBObject*)extra{
	ImageString *item;
	item=[[ImageString alloc] initWithString:text image:image tip:tip extra:extra];
	[items replaceObjectAtIndex:index withObject:item];
	[item release];
	[table reloadData];
	[self queueWidthUpdate];
}
-(void)selectItem:(unsigned)index{
	[table setDelegate:nil];
	[table selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:[table allowsMultipleSelection]];
	[table setDelegate:self];
	[self updateVisibleRows];
}
-(void)deselectItem:(unsigned)index{
	[table setDelegate:nil];
	[table deselectRow:index];
	[table setDelegate:self];
	[self updateVisibleRows];
}
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification{/*new from BAH*/
	[self updateVisibleRows];
        int index=[table selectedRow];
        ImageString *item=nil;
	if (index>=0 && index<[items count]) item=(ImageString*)[items objectAtIndex:index]; else index=-1;
        if (item){
                PostGuiEvent( BBEVENT_GADGETSELECT,self,index,0,0,0,[item extra]);
        }else{
                PostGuiEvent( BBEVENT_GADGETSELECT,self,-1,0,0,0,&bbNullObject);
        }
}
-(void)updateWidthForString:(ImageString *) imgstring{
	NSDictionary *attributes=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
	CGFloat cellWidth=[[imgstring string] sizeWithAttributes:attributes].width+8.0;
	if ([imgstring image]) cellWidth+=20.0;

	if([column minWidth] < cellWidth){
		[column setMinWidth:cellWidth];
		[column setWidth:cellWidth];
		[table setNeedsDisplay:YES];
	}
	
}
-(void)updateWidth{
	int i, count;
	count = [items count];
	for (i=0;i<count;i++)
		[self updateWidthForString:(ImageString*)[items objectAtIndex:i]];
}
-(void)queueWidthUpdate{
	[NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(updateWidth) object:nil];
	[self performSelector:@selector(updateWidth) withObject:nil afterDelay:0.0];
}
-(void)dealloc{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[table setDelegate:nil];
	[table setDataSource:nil];
	[table release];
	[column release];
	[items release];
	[textColor release];
	[font release];
	[super dealloc];
}

-(void)setFont:(NSFont*)newFont{
	if (newFont) {
		if (font!=newFont){
			[newFont retain];
			[self->font release];
			self->font=newFont;
		}
		NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
		[table setRowHeight:[layoutManager defaultLineHeightForFont:newFont]+2];
		[layoutManager release];
		[self updateVisibleRows];
		[self updateWidth];
	}
}

- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect 
tableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation{
	if (row<0 || row>=[items count]) return nil;
	return [[items objectAtIndex:row] description];
}

@end

int NSMaxGUIListUsesViewBasedRows(void *handle){
	if (!handle || ![(id)handle isKindOfClass:[ListView class]]) return 0;
	NSTableView *table=(NSTableView*)[(ListView*)handle table];
	if ([table numberOfRows]<1) return 0;
	NSView *rowView=[table viewAtColumn:0 row:0 makeIfNecessary:YES];
	[rowView layoutSubtreeIfNeeded];
	return [rowView isKindOfClass:[MaxGUIItemCellView class]] ? 1 : 0;
}

int NSMaxGUIListDeferredLayoutPresentation(void *handle){
	if (!handle || ![(id)handle isKindOfClass:[ListView class]]) return 0;
	ListView *list=(ListView*)handle;
	NSTableView *table=(NSTableView*)[list table];
	[table reloadData];
	[table layoutSubtreeIfNeeded];
	MaxGUIItemCellView *rowView=[[[MaxGUIItemCellView alloc] initWithIdentifier:@"MaxGUIListDeferredCell"] autorelease];
	int result=[list configureRowView:rowView atRow:0] ? 1 : 0;
	NSMutableArray *models=(NSMutableArray*)[list items];
	if (![list configureRowView:rowView atRow:[models count]]) result|=2;
	NSView *visible=[table viewAtColumn:0 row:0 makeIfNecessary:YES];
	if ([visible isKindOfClass:[MaxGUIItemCellView class]]) result|=4;
	return result;
}

// TableView

@implementation TableView
-(NSMenu*)menuForEvent:(NSEvent *)theEvent{
	NSPoint tablePoint=[self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSPoint gadgetPoint=MaxGUIEventPointInView(theEvent,[self enclosingScrollView]);
	NSInteger row=[self rowAtPoint:tablePoint];

	if (row>=0 && row<[self numberOfRows]) {
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	}
	else row=-1;
	PostGuiEvent( BBEVENT_GADGETMENU,[self dataSource],row,0,(int)gadgetPoint.x,(int)gadgetPoint.y,0 );

	return nil;
}
@end

// OutlineView

@implementation OutlineView
-(NSMenu*)menuForEvent:(NSEvent *)theEvent{
	id node=nil;
	NSPoint outlinePoint=[self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSPoint gadgetPoint=MaxGUIEventPointInView(theEvent,[self enclosingScrollView]);
	NSInteger i=[self rowAtPoint:outlinePoint];
	if (i>-1 && i<[self numberOfRows] && NSPointInRect(outlinePoint,[self rectOfRow:i])){
		node=[self itemAtRow:i];
	}
	maxgui_cocoamaxgui_cocoagui_PostCocoaTreeEvent( BBEVENT_GADGETMENU,NSPeerForNativeHandle([self dataSource]),node,0,(int)gadgetPoint.x,(int)gadgetPoint.y );
	return nil;
}
-(void)prepareDragWithEvent:(NSEvent *)event button:(int)button{
	pressedItem=nil;
	pressedButton=button;
	dragPosted=NO;
	NSPoint point=[self convertPoint:[event locationInWindow] fromView:nil];
	NSInteger row=[self rowAtPoint:point];
	if (row>=0 && row<[self numberOfRows] && NSPointInRect(point,[self rectOfRow:row])) pressedItem=[self itemAtRow:row];
}
-(void)postDragWithEvent:(NSEvent *)event button:(int)button{
	if (dragPosted || !pressedItem || button!=pressedButton || ![self isEnabled]) return;
	void *treePeer=NSPeerForNativeHandle([self dataSource]);
	if (!treePeer || !(NSPeerGadgetStyle(treePeer)&TREEVIEW_DRAGNDROP)) return;
	NSPoint point=MaxGUIEventPointInView(event,[self enclosingScrollView]);
	if (maxgui_cocoamaxgui_cocoagui_PostCocoaTreeDragEvent(treePeer,pressedItem,button,bbSystemTranslateMods([event modifierFlags]),(int)point.x,(int)point.y)) dragPosted=YES;
}
-(void)clearDrag{
	pressedItem=nil;
	pressedButton=0;
	dragPosted=NO;
}
-(void)mouseDown:(NSEvent *)event{
	[self prepareDragWithEvent:event button:MOUSE_LEFT];
	[super mouseDown:event];
}
-(void)rightMouseDown:(NSEvent *)event{
	[self prepareDragWithEvent:event button:MOUSE_RIGHT];
	[super rightMouseDown:event];
}
-(void)otherMouseDown:(NSEvent *)event{
	[self prepareDragWithEvent:event button:MOUSE_MIDDLE];
	[super otherMouseDown:event];
}
-(void)mouseDragged:(NSEvent *)event{
	[self postDragWithEvent:event button:MOUSE_LEFT];
	[super mouseDragged:event];
}
-(void)rightMouseDragged:(NSEvent *)event{
	[self postDragWithEvent:event button:MOUSE_RIGHT];
	[super rightMouseDragged:event];
}
-(void)otherMouseDragged:(NSEvent *)event{
	[self postDragWithEvent:event button:MOUSE_MIDDLE];
	[super otherMouseDragged:event];
}
-(void)mouseUp:(NSEvent *)event{
	[super mouseUp:event];
	[self clearDrag];
}
-(void)rightMouseUp:(NSEvent *)event{
	[super rightMouseUp:event];
	[self clearDrag];
}
-(void)otherMouseUp:(NSEvent *)event{
	[super otherMouseUp:event];
	[self clearDrag];
}
@end

// TreeView

@implementation TreeView
-(id)initWithFrame:(NSRect)rect{
	self=[super initWithFrame:rect];
	if (!self) return nil;
	[self setBorderType:NSNoBorder];
	[self setHasVerticalScroller:YES];
	[self setHasHorizontalScroller:YES];
	[self setAutohidesScrollers:YES];
	rootNode=[[NodeItem alloc] initWithTitle:@"root"];
	[rootNode setOwner:self];
	NSSize contentSize = [self contentSize];	
	outline=[[OutlineView alloc] initWithFrame:NSMakeRect(0, 0,contentSize.width, contentSize.height)];
	[outline setHeaderView:nil];	
	[outline setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
	[outline setDataSource:self];
	[outline setDelegate:self];
	[outline setTarget:self];
	[outline setDoubleAction:@selector(doubleClick:)];
	column=[[NSTableColumn alloc] init];
	[outline addTableColumn:column];
	[outline setOutlineTableColumn:column];
	font=[[NSFont systemFontOfSize:[NSFont systemFontSize]] retain];
	suppressSelectionEvents=0;
	[self setDocumentView:outline];
	[outline sizeLastColumnToFit];
	return self;
}
-(void)dealloc{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[outline setDelegate:nil];
	[outline setDataSource:nil];
	[outline release];
	[column release];
	[textColor release];
	[font release];
	[rootNode setOwner:nil];
	[rootNode release];
	[super dealloc];
}
-(void)refresh{
	[rootNode updateWidth];
	[outline reloadData];
}
-(NSInteger)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item{
	if( !item ) item=rootNode;
	return [[item kids] count];
}
-(id)outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item{
	if( !item ) item=rootNode;
	if (index>=[[item kids] count]) return 0;
	return [[item kids] objectAtIndex:index];
}
-(BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item{
	if( !item ) item=rootNode;
	return [item canExpand];
}
-(id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item{
	if (tableColumn==colin) return @"";	
	if( !item ) item=rootNode;
	return [(NodeItem*)item value];
}
-(NSView *)outlineView:(NSOutlineView *)anOutlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
	static NSString *identifier=@"MaxGUITreeCell";
	MaxGUIItemCellView *rowView=(MaxGUIItemCellView*)[anOutlineView makeViewWithIdentifier:identifier owner:self];
	if (!rowView) rowView=[[[MaxGUIItemCellView alloc] initWithIdentifier:identifier] autorelease];
	[self configureRowView:rowView forNode:(NodeItem*)item];
	return rowView;
}
-(void)configureRowView:(MaxGUIItemCellView *)rowView forNode:(NodeItem *)node{
	NSInteger row=[outline rowForItem:node];
	[[rowView textField] setStringValue:[node value] ? [node value] : @""];
	[[rowView textField] setFont:font];
	NSColor *color=textColor ? textColor : [NSColor controlTextColor];
	if (![outline isEnabled]) color=[NSColor disabledControlTextColor];
	else if ([outline isRowSelected:row]) color=[NSColor alternateSelectedControlTextColor];
	[[rowView textField] setTextColor:color];
	[[rowView imageView] setImage:[node icon]];
	[rowView setNeedsLayout:YES];
}
-(void)updateVisibleRows{
	for (NSView *view in [outline subviews]){
		if (![view isKindOfClass:[NSTableRowView class]]) continue;
		NSInteger row=[outline rowForView:view];
		if (row<0 || row>=[outline numberOfRows]) continue;
		MaxGUIItemCellView *rowView=(MaxGUIItemCellView*)[(NSTableRowView*)view viewAtColumn:0];
		NodeItem *node=(NodeItem*)[outline itemAtRow:row];
		if (rowView && node) [self configureRowView:rowView forNode:node];
	}
}
-(unsigned)count{
	return [rootNode count];
}
-(id)rootNode{
	return rootNode;
}
-(id)selectedNode{
	int		index;
	index=[outline selectedRow];
	if (index==-1) return nil;
	return [outline itemAtRow:index];
}
-(void)selectNode:(id)node{
	int index;
	[node show];
	index = [outline rowForItem:node];
	suppressSelectionEvents++;
	[outline selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
	[outline scrollRowToVisible:index];
	suppressSelectionEvents--;
	[self updateVisibleRows];
}
-(void)expandNode:(id)node{
	[outline setDelegate:nil];
	[outline expandItem:node];
	[outline tile];
	[outline setDelegate:self];
	[self updateVisibleRows];
	[node queueWidthUpdate];
}
-(void)collapseNode:(id)node{
	[outline setDelegate:nil];
	[outline collapseItem:node];
	[self reconcileCollapsedNode:node];
	[outline setDelegate:self];
	[rootNode queueWidthUpdate];
}
-(void)reconcileCollapsedNode:(id)node{
	[outline reloadItem:node reloadChildren:YES];
	[outline tile];
	[outline setNeedsDisplay:YES];
	[outline layoutSubtreeIfNeeded];
	[self updateVisibleRows];
}
-(void)outlineViewItemDidExpand:(NSNotification *)notification{
	id		node;
	node=[[notification userInfo] objectForKey:@"NSObject"];
	[node queueWidthUpdate];
	maxgui_cocoamaxgui_cocoagui_PostCocoaTreeEvent( BBEVENT_GADGETOPEN,NSPeerForNativeHandle(self),node,0,0,0 );
}
-(void)outlineViewItemDidCollapse:(NSNotification *)notification{
	id		node;
	node=[[notification userInfo] objectForKey:@"NSObject"];
	// AppKit is still removing rows while posting this notification. Reconcile
	// cached row views on the next main-loop turn, after that transaction ends.
	[self performSelector:@selector(reconcileCollapsedNode:) withObject:node afterDelay:0.0];
	[rootNode queueWidthUpdate];
	maxgui_cocoamaxgui_cocoagui_PostCocoaTreeEvent( BBEVENT_GADGETCLOSE,NSPeerForNativeHandle(self),node,0,0,0 );
}
-(void)outlineViewSelectionDidChange:(NSNotification *)notification{
	id		node;
	[self updateVisibleRows];
	if (suppressSelectionEvents) return;
	node=[self selectedNode];
	maxgui_cocoamaxgui_cocoagui_PostCocoaTreeEvent( BBEVENT_GADGETSELECT,NSPeerForNativeHandle(self),node,0,0,0 );
}
-(BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item{
	return NO;
}
-(BOOL)performDoubleActionAtIndex:(NSInteger)index{
	if (![outline isEnabled] || index<0 || index>=[outline numberOfRows]) return NO;
	id item=[outline itemAtRow:index];
	maxgui_cocoamaxgui_cocoagui_PostCocoaTreeEvent( BBEVENT_GADGETACTION,NSPeerForNativeHandle(self),item,0,0,0 );
	return YES;
}
-(void)doubleClick:(id)sender{
	[self performDoubleActionAtIndex:[outline clickedRow]];
}
-(BOOL)performUserSelectionAtIndex:(NSInteger)index{
	if (![outline isEnabled] || index<0 || index>=[outline numberOfRows]) return NO;
	[outline selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
	return YES;
}
-(BOOL)performUserExpansionAtIndex:(NSInteger)index expand:(BOOL)expand{
	if (![outline isEnabled] || index<0 || index>=[outline numberOfRows]) return NO;
	id item=[outline itemAtRow:index];
	if (![item canExpand]) return NO;
	if (expand) [outline expandItem:item]; else [outline collapseItem:item];
	return YES;
}
-(BOOL)isItemExpandedAtIndex:(NSInteger)index{
	if (index<0 || index>=[outline numberOfRows]) return NO;
	return [outline isItemExpanded:[outline itemAtRow:index]];
}
-(void)setColor:(NSColor*)color{
	[outline setBackgroundColor:color];
}
-(void)setExplicitColor:(NSColor*)color appearance:(NSAppearance*)appearance{
	[self setAppearance:appearance];
	[outline setAppearance:nil];
	[self setColor:color];
	[self updateVisibleRows];
	[outline setNeedsDisplay:YES];
}
-(void)removeColor{
	[self setAppearance:nil];
	[outline setAppearance:nil];
	[self setColor:[NSColor controlBackgroundColor]];
	[self updateVisibleRows];
	[outline setNeedsDisplay:YES];
}
-(void)setTextColor:(NSColor*)color{
	if (textColor==color) return;
	[textColor release];
	textColor=[color retain];
	[self updateVisibleRows];
}

- (void)setFont:(NSFont*)newFont{
	if (newFont) {
		if (font!=newFont){
			[newFont retain];
			[font release];
			font=newFont;
		}
		NSLayoutManager* layoutManager = [[[NSLayoutManager alloc] init] autorelease];
		[outline setRowHeight:[layoutManager defaultLineHeightForFont:newFont]+3];
		[self updateVisibleRows];
		[rootNode queueWidthUpdate];
	}
}
-(void)setEnabled:(BOOL)e{
	[outline setEnabled:e];
	[self updateVisibleRows];
}
-(BOOL)isEnabled{
	return [outline isEnabled];
}
@end

int NSMaxGUITreeUsesViewBasedRows(void *handle){
	if (!handle || ![(id)handle isKindOfClass:[TreeView class]]) return 0;
	NSOutlineView *outline=((TreeView*)handle)->outline;
	if ([outline numberOfRows]<1) return 0;
	NSView *rowView=[outline viewAtColumn:0 row:0 makeIfNecessary:YES];
	[rowView layoutSubtreeIfNeeded];
	return [rowView isKindOfClass:[MaxGUIItemCellView class]] ? 1 : 0;
}

int NSMaxGUITreeAppearance(void *handle){
	if (!handle || ![(id)handle isKindOfClass:[TreeView class]]) return -2;
	NSAppearance *appearance=[(TreeView*)handle appearance];
	if (!appearance) return -1;
	NSString *match=[appearance bestMatchFromAppearancesWithNames:[NSArray arrayWithObjects:NSAppearanceNameAqua,NSAppearanceNameDarkAqua,nil]];
	if ([match isEqualToString:NSAppearanceNameAqua]) return 0;
	if ([match isEqualToString:NSAppearanceNameDarkAqua]) return 1;
	return -2;
}

int NSMaxGUITreeEffectiveAppearance(void *handle){
	if (!handle || ![(id)handle isKindOfClass:[TreeView class]]) return -2;
	NSOutlineView *outline=((TreeView*)handle)->outline;
	NSAppearance *appearance=[outline effectiveAppearance];
	NSString *match=[appearance bestMatchFromAppearancesWithNames:[NSArray arrayWithObjects:NSAppearanceNameAqua,NSAppearanceNameDarkAqua,nil]];
	if ([match isEqualToString:NSAppearanceNameAqua]) return 0;
	if ([match isEqualToString:NSAppearanceNameDarkAqua]) return 1;
	return -2;
}

// NodeItem

@implementation NodeItem
-(void)dealloc{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[title release];
	[icon release];
	[kids release];
	[super dealloc];
}
-(id)initWithTitle:(NSString*)text{
	self=[super init];
	if (self){
		owner=nil;
		parent=nil;
		title=[text retain];
		icon=nil;
		kids=[[NSMutableArray alloc] initWithCapacity:10];
	}
	return self;
}
-(void)updateWidth{
	int 		i;
	CGFloat cellWidth;
	CGFloat indentationWidth;
	
	if(owner==nil) return;
	
	NSOutlineView*	outline = owner->outline;
	NSTableColumn*	tableColumn = owner->column;
	
	if(tableColumn!=nil){
		NSDictionary *attributes=[NSDictionary dictionaryWithObject:owner->font forKey:NSFontAttributeName];
		cellWidth=[title sizeWithAttributes:attributes].width+8.0;
		if (icon) cellWidth+=20.0;
		indentationWidth = [outline levelForItem: self];
		if(isnan(indentationWidth)) indentationWidth = 0; else indentationWidth=([outline indentationPerLevel]*(indentationWidth+1));
		if((owner->rootNode == self) || [outline isItemExpanded:self])
			for (i= 0; i < [kids count]; i++) [[kids objectAtIndex:i] updateWidth];
		if([tableColumn minWidth] < (cellWidth+indentationWidth)){
			[tableColumn setMinWidth:(cellWidth+indentationWidth)];
			[tableColumn setWidth:(cellWidth+indentationWidth+10)];
		}
	}
}
-(void)queueWidthUpdate{
	[NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(updateWidth) object:nil];
	[self performSelector:@selector(updateWidth) withObject:nil afterDelay:0.0];
}
-(void)setOwner:(TreeView*)treeview{
	owner=treeview;
}
-(id)getOwner{
	return owner;
}
-(void)show{
	if (parent){
		[parent show];
		[owner expandNode:parent];
	}
}
-(void)attach:(NodeItem*)parent_ atIndex:(unsigned)index_{
	parent=parent_;
	if( parent ){
		owner=parent->owner;
		[[parent kids] insertObject:self atIndex:index_];
		[self release];
	}
	if (owner) [owner refresh];
}
-(void)remove{
	TreeView *tree=owner;
	[self retain];
	if( parent ) [[parent kids] removeObjectIdenticalTo:self];
	parent=nil;
	owner=nil;
	if (tree) [tree refresh];
	[self release];
}
-(BOOL)canExpand{
	return [kids count]>0;
}
-(NSMutableArray*)kids{
	return kids;
}
-(NSString *)value{return title;}
-(NSImage *)icon{return icon;}
-(void)setTitle:(NSString*)text{
	if (title==text) return;
	[text retain];
	[title release];
	title=text;
	if (owner){
		[owner->outline reloadItem:self];
		[owner->rootNode queueWidthUpdate];
	}
}
-(void)setIcon:(NSImage*)image{
	if (icon==image) return;
	[image retain];
	[icon release];
	icon=image;
	if (owner){
		[owner->outline reloadItem:self];
		[(icon ? self : owner->rootNode) queueWidthUpdate];
	}
}
-(unsigned)count{
	return [kids count];
}
@end

// TextView

@implementation TextView
-(id)initWithFrame:(NSRect)rect{
	
	scroll=[[NSScrollView alloc] initWithFrame:rect];

//	[scroll setVerticalScroller:[[Scroller alloc] init]];
//	[scroll setHorizontalScroller:[[Scroller alloc] init]];

	[scroll setHasVerticalScroller:YES];
	[scroll setHasHorizontalScroller:YES];

	[scroll setDrawsBackground:NO];
	[scroll setRulersVisible:NO];
	[scroll setBorderType:NSNoBorder];
	[scroll setAutohidesScrollers:YES];
				
	NSSize contentSize = [scroll contentSize];	

	self=[super initWithFrame:NSMakeRect(0, 0,contentSize.width,contentSize.height)];
	[self setMinSize:NSMakeSize(contentSize.width, contentSize.height)];
	[self setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
	[self setVerticallyResizable:YES];
	[self setHorizontallyResizable:YES];
	[self setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
	[[self textContainer] setContainerSize:NSMakeSize(FLT_MAX,FLT_MAX)];
	[[self textContainer] setWidthTracksTextView:NO];	
	[self setUsesRuler:NO];

	[scroll setDocumentView:self];

	style=[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[style setLineBreakMode:NSLineBreakByClipping];
	
	styles=[NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
	[styles retain];
	storage=[[self textStorage] retain];
	[storage setDelegate:self];
	
	lockedNest=0;
	programmaticChangeNest=0;
	
	[self setTabs: 4];
	if ([self respondsToSelector: @selector(setDefaultParagraphStyle)])
		[self setDefaultParagraphStyle: style];
	
	if ([self respondsToSelector: @selector(setAutomaticLinkDetectionEnabled)])
		[self setAutomaticLinkDetectionEnabled: NO];
	if ([self respondsToSelector: @selector(setAutomaticQuoteSubstitutionEnabled)])
		[self setAutomaticQuoteSubstitutionEnabled: NO];
	if ([self respondsToSelector: @selector(setAutomaticSpellingCorrectionEnabled)])
		[self setAutomaticSpellingCorrectionEnabled: NO];
	if ([self respondsToSelector: @selector(setAutomaticTextReplacementEnabled)])
		[self setAutomaticTextReplacementEnabled: NO];
	if ([self respondsToSelector: @selector(setAutomaticDataDetectionEnabled)])
		[self setAutomaticDataDetectionEnabled: NO];
		
// on OS X 10.6+, disable all TextCheckingTypes, as the above code has no effect.
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
	[self setEnabledTextCheckingTypes:0];
#endif
#endif

	[self setDelegate:self];
	return self;
}
-(void)free{
	[self setDelegate:nil];
	[storage setDelegate:nil];
	[scroll setDocumentView:nil];
	[scroll release];
	[style release];
	[styles release];
	[storage release];
}
-(void)setHidden:(BOOL)flag{
	[scroll setHidden:flag];
}
-(id)storage{
	return storage;
}
-(NSSize)contentSize{
	return [scroll contentSize];
}
-(id)getScroll{
	return scroll;
}
-(void)setWordWrap:(BOOL)flag{
	NSSize contentSize=[self contentSize];
	if (flag){
		[scroll setHasHorizontalScroller:NO];
		[self setHorizontallyResizable:NO];
		[self setAutoresizingMask:NSViewWidthSizable];
		[[self textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
		[[self textContainer] setWidthTracksTextView:YES];
		[style setLineBreakMode:NSLineBreakByWordWrapping];
	}
	else{
		[scroll setHasHorizontalScroller:YES];
		[self setHorizontallyResizable:YES];
		[self setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
		[[self textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
		[[self textContainer] setWidthTracksTextView:NO];
		[style setLineBreakMode:NSLineBreakByClipping];
	}
	[storage addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,[storage length])];	
}

-(void)setTabs:(int)tabs{	
	[style setTabStops:[NSArray array]];	//Clear any TabStops
	[style setDefaultTabInterval: tabs];	//Set recurring TabStops remembering to convert from twips->pixels
	[storage addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,[storage length])];
}

-(void)setMargins:(int)leftmargin{

	[self setTextContainerInset:NSMakeSize( leftmargin, 0) ];
//	[style setFirstLineHeadIndent: leftmargin*8];
//	[style setHeadIndent: leftmargin*8];
//	[storage addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,[storage length])];	
}

-(void)beginProgrammaticChange{
	programmaticChangeNest++;
}

-(void)endProgrammaticChange{
	if (programmaticChangeNest>0) programmaticChangeNest--;
}

-(void)setText:(NSString*)text{
	NSAttributedString	*astring;
	[self beginProgrammaticChange];
	astring=[[NSAttributedString alloc] initWithString:text attributes:styles];
	if (lockedNest) [storage endEditing];
	[storage setAttributedString:astring];
	if (lockedNest) [storage beginEditing]; else [self setSelectedRange:NSMakeRange(0,0)];
	[astring release];
	[self endProgrammaticChange];
}
-(void)addText:(NSString*)text{
	NSAttributedString	*astring;
	astring=[[NSAttributedString alloc] initWithString:text attributes:styles];
	if (lockedNest) [storage endEditing];
	[storage appendAttributedString:astring];
	if (lockedNest) [storage beginEditing];
	[astring release];
}
-(void)setScrollFrame:(NSRect)rect{
	[scroll setFrame:rect];
}
-(void)setTextColor:(NSColor*)color{
	[styles setObject:color forKey:NSForegroundColorAttributeName];
	[storage addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,[storage length])];
	[self setInsertionPointColor:color];	
}
-(void)setColor:(NSColor*)color{
	if(color){
		[self setBackgroundColor:color];	
		[self setDrawsBackground:true];
		[scroll setBackgroundColor:color];
		[scroll setDrawsBackground:true];
	}else{
		NSColor *defaultColor=[NSColor textBackgroundColor];
		[self setBackgroundColor:defaultColor];
		[self setDrawsBackground:true];
		[scroll setBackgroundColor:defaultColor];
		[scroll setDrawsBackground:false];
	}
}
-(void)setFont:(NSFont*)font{
	[styles setObject:font forKey:NSFontAttributeName];
	[storage setFont:font];	
	[super setFont:font];	
}
-(NSMenu *)menuForEvent:(NSEvent *)event{
	NSPoint point=MaxGUIEventPointInView(event,[self enclosingScrollView]);
	PostGuiEvent( BBEVENT_GADGETMENU,self,0,0,(int)point.x,(int)point.y,0 );
	return nil;
}
-(void)updateDragTypeRegistration{
}
-(NSArray *)acceptableDragTypes{
	return nil;
}
-(void)textDidBeginEditing:(NSNotification*)n{
//	printf( "textDidBeginEditing:%p\n",_textEditor );fflush(stdout);
}
-(void)textDidChange:(NSNotification*)n{
	if (!programmaticChangeNest) PostGuiEvent( BBEVENT_GADGETACTION,self,0,0,0,0,0 );
}
-(void)textDidEndEditing:(NSNotification*)n{
//	printf( "textDidEndEditing:%p\n",_textEditor );fflush(stdout);
	PostGuiEvent( BBEVENT_GADGETLOSTFOCUS,[n object],0,0,0,0,0 );
}
-(void)textViewDidChangeSelection:(NSNotification *)aNotification{
	if (!programmaticChangeNest) PostGuiEvent( BBEVENT_GADGETSELECT,self,0,0,0,0,0 );
}
-(void)textStorageDidProcessEditing:(NSNotification *)aNotification{

}
-(void)textStorageWillProcessEditing:(NSNotification *)aNotification{
	[storage removeAttribute:NSLinkAttributeName range:[storage editedRange]];
}
@end


// TabViewItem

@class TabViewItem;
@interface TabViewItem:NSTabViewItem{
	NSImage	*_image;
}
-(id)initWithIdentifier:(NSString *)text;
-(void)setImage:(NSImage*)image;
-(id)copyWithZone:(NSZone *)zone;
-(NSImage*)image;
-(NSSize)sizeOfLabel:(BOOL)shouldTruncateLabel;
-(void)drawLabel:(BOOL)shouldTruncateLabel inRect:(NSRect)tabRect;
@end
@implementation TabViewItem
-(id)initWithIdentifier:(NSString *)string{
	self=[super initWithIdentifier:string];
	_image=nil;
	return self;
}
-(void)setImage:(NSImage*)image{
	if (_image==image) return;
	[_image release];
	_image=[image retain];
}
-(id)copyWithZone:(NSZone *)zone{
	TabViewItem *copy=[[[self class] allocWithZone:zone] initWithIdentifier:[self identifier]];
	[copy setLabel:[self label]];
	[copy setImage:_image];
	[copy setToolTip:[self toolTip]];
	return copy;
}
-(NSImage*)image{
	return _image;
}
-(NSSize)sizeOfLabel:(BOOL)shouldTruncateLabel{
	NSSize	size;
	NSSize	imageDimensions;
	CGFloat		ratio;
	size=[super sizeOfLabel:shouldTruncateLabel];
	
	if (_image) {
		imageDimensions = [_image size];
		if (imageDimensions.height > size.height){
			ratio = size.height/imageDimensions.height;
			imageDimensions.width*=ratio;imageDimensions.height*=ratio;
		}
		size.width += imageDimensions.width+4.0;
	}
	return size;
}
-(void)drawLabel:(BOOL)shouldTruncateLabel inRect:(NSRect)content{
	NSSize	imageDimensions;
	NSRect imageRect;
	if (_image){
		imageDimensions = [_image size];
		if (imageDimensions.height > content.size.height){
			CGFloat ratio=content.size.height/imageDimensions.height;
			imageDimensions.width*=ratio;
			imageDimensions.height*=ratio;
		}
		imageRect=NSMakeRect(content.origin.x,NSMidY(content)-imageDimensions.height/2.0,imageDimensions.width,imageDimensions.height);
		[_image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0 respectFlipped:YES hints:nil];
		content.origin.x+=imageDimensions.width+4.0;
		content.size.width-=imageDimensions.width+4.0;
	}
	[super drawLabel:shouldTruncateLabel inRect:content];
}
-(void)dealloc{
	[_image release];
	[super dealloc];
}
@end

// TabView

@implementation TabStripScrollView
-(void)scrollWheel:(NSEvent *)event{
	NSClipView *clip=[self contentView];
	NSRect bounds=[clip bounds];
	CGFloat delta=[event scrollingDeltaX];
	if (fabs(delta)<fabs([event scrollingDeltaY])) delta=[event scrollingDeltaY];
	if (![event hasPreciseScrollingDeltas]) delta*=12.0;
	bounds.origin.x+=delta;
	[clip scrollToPoint:[clip constrainBoundsRect:bounds].origin];
	[self reflectScrolledClipView:clip];
	id owner=[self superview];
	if ([owner respondsToSelector:@selector(updateScrollButtons)]) [owner updateScrollButtons];
}
@end

@implementation TabSegmentedControl
-(void)scrollWheel:(NSEvent *)event{
	[[self enclosingScrollView] scrollWheel:event];
}
-(NSMenu *)menuForEvent:(NSEvent *)event{
	NSView *owner=[[self enclosingScrollView] superview];
	if ([owner isKindOfClass:[TabView class]]) return [(TabView*)owner menuForEvent:event];
	return [super menuForEvent:event];
}
@end

@implementation TabView
-(id)initWithFrame:(NSRect)rect{
	self=[super initWithFrame:rect];
	if (self){
		[self setTabViewType:NSNoTabsNoBorder];
		[self setDrawsBackground:NO];
		client=[[FlippedView alloc] initWithFrame:[self contentRect]];
		[client setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
		segments=[[TabSegmentedControl alloc] initWithFrame:NSZeroRect];
		[segments setSegmentStyle:NSSegmentStyleSeparated];
		[segments setTrackingMode:NSSegmentSwitchTrackingSelectOne];
		[segments setTarget:self];
		[segments setAction:@selector(segmentSelected:)];
		tabScroll=[[TabStripScrollView alloc] initWithFrame:NSZeroRect];
		[tabScroll setBorderType:NSNoBorder];
		[tabScroll setDrawsBackground:NO];
		[tabScroll setHasHorizontalScroller:NO];
		[tabScroll setHasVerticalScroller:NO];
		[tabScroll setDocumentView:segments];
		[self addSubview:tabScroll positioned:NSWindowAbove relativeTo:nil];
		scrollLeft=[[NSButton alloc] initWithFrame:NSZeroRect];
		[scrollLeft setTitle:@"\u2039"];
		[scrollLeft setBezelStyle:NSBezelStyleTexturedRounded];
		[scrollLeft setTarget:self];
		[scrollLeft setAction:@selector(scrollTabsLeft:)];
		[self addSubview:scrollLeft positioned:NSWindowAbove relativeTo:nil];
		scrollRight=[[NSButton alloc] initWithFrame:NSZeroRect];
		[scrollRight setTitle:@"\u203a"];
		[scrollRight setBezelStyle:NSBezelStyleTexturedRounded];
		[scrollRight setTarget:self];
		[scrollRight setAction:@selector(scrollTabsRight:)];
		[self addSubview:scrollRight positioned:NSWindowAbove relativeTo:nil];
		user=1;
		[self setDelegate:self];
		[self synchronizeSegments];
	}
	return self;
}
-(id)clientView{
	return client;
}
-(NSRect)contentRect{
	NSRect bounds=[self bounds];
	if ([self isFlipped]) bounds.origin.y+=28.0;
	bounds.size.height=MAX(0.0,bounds.size.height-28.0);
	return bounds;
}
-(CGFloat)naturalSegmentWidth{
	CGFloat width=0.0;
	for (NSInteger index=0;index<[segments segmentCount];index++) width+=[segments widthForSegment:index];
	return width;
}
-(NSRect)rectForSegment:(NSInteger)wanted{
	CGFloat x=0.0;
	for (NSInteger index=0;index<wanted;index++) x+=[segments widthForSegment:index];
	return NSMakeRect(x,0.0,[segments widthForSegment:wanted],[segments bounds].size.height);
}
-(void)layout{
	[super layout];
	NSRect bounds=[self bounds];
	CGFloat barHeight=26.0;
	CGFloat buttonWidth=22.0;
	CGFloat naturalWidth=[self naturalSegmentWidth];
	BOOL overflow=naturalWidth>bounds.size.width;
	CGFloat scrollX=overflow ? buttonWidth : 0.0;
	CGFloat scrollWidth=MAX(0.0,bounds.size.width-(overflow ? buttonWidth*2.0 : 0.0));
	CGFloat stripY=[self isFlipped] ? 1.0 : MAX(0.0,bounds.size.height-barHeight-1.0);
	[scrollLeft setHidden:!overflow];
	[scrollRight setHidden:!overflow];
	[scrollLeft setFrame:NSMakeRect(0.0,stripY,buttonWidth,barHeight)];
	[scrollRight setFrame:NSMakeRect(MAX(0.0,bounds.size.width-buttonWidth),stripY,buttonWidth,barHeight)];
	[tabScroll setFrame:NSMakeRect(scrollX,stripY,scrollWidth,barHeight)];
	[segments setFrame:NSMakeRect(0.0,0.0,MAX(naturalWidth+8.0,scrollWidth),barHeight)];
	[client setFrame:[self contentRect]];
	[self updateScrollButtons];
}
-(void)synchronizeSegments{
	NSInteger count=[self numberOfTabViewItems];
	NSInteger selected=[self indexOfTabViewItem:[self selectedTabViewItem]];
	[segments setSegmentCount:count];
	NSFont *font=[segments font] ? [segments font] : [NSFont systemFontOfSize:[NSFont systemFontSize]];
	NSDictionary *attributes=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
	for (NSInteger index=0;index<count;index++){
		TabViewItem *item=(TabViewItem*)[self tabViewItemAtIndex:index];
		NSString *label=[item label] ? [item label] : @"";
		CGFloat width=ceil([label sizeWithAttributes:attributes].width)+28.0;
		if ([item image]) width+=20.0;
		width=MIN(220.0,MAX(64.0,width));
		[segments setLabel:label forSegment:index];
		[segments setImage:[item image] forSegment:index];
		[segments setImageScaling:NSImageScaleProportionallyDown forSegment:index];
		[segments setToolTip:[item toolTip] forSegment:index];
		[segments setWidth:width forSegment:index];
	}
	[segments setSelectedSegment:selected==NSNotFound ? -1 : selected];
	[self setNeedsLayout:YES];
	[self layoutSubtreeIfNeeded];
	[self revealSelectedSegment];
}
-(void)revealSelectedSegment{
	NSInteger selected=[segments selectedSegment];
	if (selected<0 || selected>=[segments segmentCount]) return;
	NSClipView *clip=[tabScroll contentView];
	NSRect visible=[clip bounds];
	NSRect wanted=NSInsetRect([self rectForSegment:selected],-4.0,0.0);
	if (NSMinX(wanted)<NSMinX(visible)) visible.origin.x=NSMinX(wanted);
	else if (NSMaxX(wanted)>NSMaxX(visible)) visible.origin.x=NSMaxX(wanted)-visible.size.width;
	[clip scrollToPoint:[clip constrainBoundsRect:visible].origin];
	[tabScroll reflectScrolledClipView:clip];
	[self updateScrollButtons];
}
-(void)updateScrollButtons{
	NSClipView *clip=[tabScroll contentView];
	CGFloat origin=[clip bounds].origin.x;
	CGFloat maximum=MAX(0.0,[segments frame].size.width-[clip bounds].size.width);
	BOOL enabled=[self isEnabled];
	[scrollLeft setEnabled:enabled && origin>0.5];
	[scrollRight setEnabled:enabled && origin<maximum-0.5];
}
-(void)scrollBy:(CGFloat)distance{
	NSClipView *clip=[tabScroll contentView];
	NSRect bounds=[clip bounds];
	bounds.origin.x+=distance;
	[clip scrollToPoint:[clip constrainBoundsRect:bounds].origin];
	[tabScroll reflectScrolledClipView:clip];
	[self updateScrollButtons];
}
-(void)scrollTabsLeft:(id)sender{
	[self scrollBy:-MAX(80.0,[tabScroll bounds].size.width*0.7)];
}
-(void)scrollTabsRight:(id)sender{
	[self scrollBy:MAX(80.0,[tabScroll bounds].size.width*0.7)];
}
-(void)segmentSelected:(id)sender{
	if (![self isEnabled]) return;
	NSInteger index=[segments selectedSegment];
	if (index>=0 && index<[self numberOfTabViewItems]) [super selectTabViewItemAtIndex:index];
}
-(void)insertTabViewItem:(NSTabViewItem *)tabViewItem atIndex:(NSInteger)index{
	[super insertTabViewItem:tabViewItem atIndex:index];
	[self synchronizeSegments];
}
-(void)removeTabViewItem:(NSTabViewItem *)tabViewItem{
	[super removeTabViewItem:tabViewItem];
	[self synchronizeSegments];
}
-(void)removeAllItemsForFree{
	[self setDelegate:nil];
	while ([self numberOfTabViewItems]) [super removeTabViewItem:[self tabViewItemAtIndex:0]];
	[segments setSegmentCount:0];
}
-(void)setEnabled:(BOOL)enabled{
	[segments setEnabled:enabled];
	[self updateScrollButtons];
}
-(BOOL)isEnabled{
	return [segments isEnabled];
}
-(void)selectTabViewItemAtIndex:(int)index{
	user=0;
	[super selectTabViewItemAtIndex:index];
	user=1;
	[segments setSelectedSegment:index];
	[self revealSelectedSegment];
}
-(BOOL)performUserSelectionAtIndex:(NSInteger)index{
	if (![self isEnabled] || index<0 || index>=[self numberOfTabViewItems]) return NO;
	[segments setSelectedSegment:index];
	[self segmentSelected:segments];
	[self revealSelectedSegment];
	return YES;
}
-(void)setFrame:(NSRect)rect{
	[super setFrame:rect];
	[self setNeedsLayout:YES];
}
-(BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem{
	int		index;
	[tabViewItem setView:client];
	[client setFrame:[self contentRect]];
	if (user && [self selectedTabViewItem]!=tabViewItem){
		index=[self indexOfTabViewItem:tabViewItem];
		PostGuiEvent( BBEVENT_GADGETACTION,self,index,0,0,0,0);
	}
	return YES;
}
-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem{
	NSInteger index=[self indexOfTabViewItem:tabViewItem];
	[segments setSelectedSegment:index==NSNotFound ? -1 : index];
	[self revealSelectedSegment];
}
-(NSTabViewItem *)tabViewItemAtPoint:(NSPoint)point{
	if (!NSPointInRect(point,[tabScroll frame])) return nil;
	NSPoint segmentPoint=[segments convertPoint:point fromView:self];
	if (!NSPointInRect(segmentPoint,[segments visibleRect])) return nil;
	for (NSInteger index=0;index<[segments segmentCount];index++){
		if (NSPointInRect(segmentPoint,[self rectForSegment:index])) return [self tabViewItemAtIndex:index];
	}
	return nil;
}
-(void)setFont:(NSFont *)font{
	[super setFont:font];
	[segments setFont:font];
	[self synchronizeSegments];
}
-(int)overflowPresentation{
	[self layoutSubtreeIfNeeded];
	int result=[segments isKindOfClass:[NSSegmentedControl class]] ? 1 : 0;
	if (![scrollLeft isHidden] && ![scrollRight isHidden]) result|=2;
	if ([segments frame].size.width>[tabScroll contentView].bounds.size.width) result|=4;
	NSInteger selected=[segments selectedSegment];
	if (selected>=0){
		NSRect visible=[[tabScroll contentView] bounds];
		NSRect selectedRect=[self rectForSegment:selected];
		CGFloat visibleWidth=NSIntersectionRect(visible,selectedRect).size.width;
		if (visibleWidth>=MIN(visible.size.width,selectedRect.size.width)-8.0) result|=8;
	}
	BOOL ordered=YES;
	CGFloat edge=-CGFLOAT_MAX;
	for (NSInteger index=0;index<[segments segmentCount];index++){
		NSRect rect=[self rectForSegment:index];
		if (rect.size.width<=0.0 || NSMinX(rect)<edge-0.5){ ordered=NO; break; }
		edge=NSMaxX(rect);
	}
	if (ordered) result|=16;
	NSRect bounds=[self bounds];
	NSRect strip=[tabScroll frame];
	BOOL atTop=[self isFlipped] ? NSMinY(strip)<=NSMinY(bounds)+2.0 : NSMaxY(strip)>=NSMaxY(bounds)-2.0;
	if (atTop) result|=32;
	return result;
}
-(void)dealloc{
	[self removeAllItemsForFree];

	[tabScroll setDocumentView:nil];
	[segments release];
	[tabScroll release];
	[scrollLeft release];
	[scrollRight release];
	[client release];
	[super dealloc];
}
-(NSMenu *)menuForEvent:(NSEvent *)event{
	int	index;
	NSTabViewItem*	tabItem;
	tabItem = [self tabViewItemAtPoint:[self convertPoint:[event locationInWindow] fromView:nil]];
	if (tabItem) index = [self indexOfTabViewItem:tabItem]; else index = -1;
	NSPoint point=MaxGUIEventPointInView(event,self);
	PostGuiEvent( BBEVENT_GADGETMENU,self,index,0,(int)point.x,(int)point.y,0);
	return nil;
}
@end

int NSMaxGUIContextMenuEvent(void *handle,int gadgetClass,int x,int y){
	NSView *gadgetView=nil;
	NSView *eventView=nil;
	switch (gadgetClass){
		case GADGET_LISTBOX:
			gadgetView=(ListView*)handle;
			eventView=[(ListView*)handle table];
			break;
		case GADGET_TREEVIEW:
			gadgetView=(TreeView*)handle;
			eventView=((TreeView*)handle)->outline;
			break;
		case GADGET_TEXTAREA:
			eventView=(TextView*)handle;
			gadgetView=[(TextView*)handle getScroll];
			break;
		case GADGET_TABBER:
			gadgetView=(TabView*)handle;
			eventView=gadgetView;
			break;
		default:
			return 0;
	}
	if (!gadgetView || !eventView || ![gadgetView window]) return 0;
	[gadgetView layoutSubtreeIfNeeded];
	[eventView layoutSubtreeIfNeeded];
	NSRect bounds=[gadgetView bounds];
	NSPoint gadgetPoint=NSMakePoint(NSMinX(bounds)+x,[gadgetView isFlipped] ? NSMinY(bounds)+y : NSMaxY(bounds)-y);
	NSPoint windowPoint=[gadgetView convertPoint:gadgetPoint toView:nil];
	NSEvent *event=[NSEvent mouseEventWithType:NSEventTypeRightMouseUp
		location:windowPoint modifierFlags:0 timestamp:0
		windowNumber:[[gadgetView window] windowNumber] context:nil
		eventNumber:0 clickCount:1 pressure:0];
	[eventView menuForEvent:event];
	return 1;
}

int NSMaxGUIContextMenuItemEvent(void *handle,int gadgetClass,int index){
	NSView *gadgetView=nil;
	NSView *eventView=nil;
	NSPoint eventPoint=NSZeroPoint;
	if (gadgetClass==GADGET_LISTBOX){
		ListView *list=(ListView*)handle;
		NSTableView *table=(NSTableView*)[list table];
		gadgetView=list;
		eventView=table;
		if (index<0 || index>=[table numberOfRows]) return -1;
		eventPoint=NSMakePoint(12,NSMidY([table rectOfRow:index]));
	}
	else if (gadgetClass==GADGET_TREEVIEW){
		TreeView *tree=(TreeView*)handle;
		gadgetView=tree;
		eventView=tree->outline;
		if (index<0 || index>=[tree->outline numberOfRows]) return -1;
		eventPoint=NSMakePoint(20,NSMidY([tree->outline rectOfRow:index]));
	}
	else if (gadgetClass==GADGET_TABBER){
		TabView *tab=(TabView*)handle;
		gadgetView=tab;
		eventView=tab;
		if (index<0 || index>=[tab numberOfTabViewItems]) return -1;
		NSTabViewItem *wanted=[tab tabViewItemAtIndex:index];
		NSRect bounds=[tab bounds];
		for (NSInteger y=(NSInteger)NSMinY(bounds); y<(NSInteger)NSMaxY(bounds); y++){
			for (NSInteger x=(NSInteger)NSMinX(bounds); x<(NSInteger)NSMaxX(bounds); x++){
				NSPoint candidate=NSMakePoint(x,y);
				if ([tab tabViewItemAtPoint:candidate]==wanted){
					eventPoint=candidate;
					y=(NSInteger)NSMaxY(bounds);
					break;
				}
			}
		}
		if (NSEqualPoints(eventPoint,NSZeroPoint)) return -1;
	}
	else return -1;
	[gadgetView layoutSubtreeIfNeeded];
	[eventView layoutSubtreeIfNeeded];
	NSPoint windowPoint=[eventView convertPoint:eventPoint toView:nil];
	NSEvent *event=[NSEvent mouseEventWithType:NSEventTypeRightMouseUp
		location:windowPoint modifierFlags:0 timestamp:0
		windowNumber:[[gadgetView window] windowNumber] context:nil
		eventNumber:0 clickCount:1 pressure:0];
	NSPoint gadgetPoint=MaxGUIEventPointInView(event,gadgetView);
	[eventView menuForEvent:event];
	return (((int)gadgetPoint.y & 0xffff)<<16)|((int)gadgetPoint.x & 0xffff);
}

int NSMaxGUIContextMenuBlankEvent(void *handle,int gadgetClass){
	NSView *gadgetView=nil;
	NSView *eventView=nil;
	if (gadgetClass==GADGET_LISTBOX){
		gadgetView=(ListView*)handle;
		eventView=[(ListView*)handle table];
	}
	else if (gadgetClass==GADGET_TREEVIEW){
		gadgetView=(TreeView*)handle;
		eventView=((TreeView*)handle)->outline;
	}
	else if (gadgetClass==GADGET_TABBER){
		gadgetView=(TabView*)handle;
		eventView=gadgetView;
	}
	else return -1;
	[gadgetView layoutSubtreeIfNeeded];
	[eventView layoutSubtreeIfNeeded];
	NSRect bounds=[gadgetView bounds];
	for (int y=5; y<(int)NSHeight(bounds)-5; y++){
		for (int x=5; x<(int)NSWidth(bounds)-5; x++){
			NSPoint gadgetPoint=NSMakePoint(NSMinX(bounds)+x,[gadgetView isFlipped] ? NSMinY(bounds)+y : NSMaxY(bounds)-y);
			NSPoint windowPoint=[gadgetView convertPoint:gadgetPoint toView:nil];
			NSPoint eventPoint=[eventView convertPoint:windowPoint fromView:nil];
			BOOL blank=NO;
			if (gadgetClass==GADGET_TABBER) blank=[(TabView*)eventView tabViewItemAtPoint:eventPoint]==nil;
			else{
				NSTableView *table=(NSTableView*)eventView;
				NSInteger row=[table rowAtPoint:eventPoint];
				blank=row<0 || row>=[table numberOfRows] || !NSPointInRect(eventPoint,[table rectOfRow:row]);
			}
			if (blank){
				if (!NSMaxGUIContextMenuEvent(handle,gadgetClass,x,y)) return -1;
				return ((y & 0xffff)<<16)|(x & 0xffff);
			}
		}
	}
	return -1;
}

// WindowView

@implementation WindowView
-(id)textFirstResponder{
	id r=[self firstResponder];
	//if ([r isKindOfClass:[PanelView class]]) return r;
	if ([r isKindOfClass:[NSTextView class]]){
		id d=[r delegate];
		if( [d isKindOfClass:[NSTextField class]] ) return d;
	}
	return r;
}
-(id)initWithContentRect:(NSRect)rect styleMask:(unsigned int)mask backing:(NSBackingStoreType)backing defer:(BOOL)flag withStyle:(int)style{
//withStatus:(BOOL)status{
	NSView		*client;
	int		i;
	NSTextField	*l;
	NSBox	*box;
	dragging = nil;
	self=[super initWithContentRect:rect styleMask:mask backing:backing defer:flag];
	gadgetStyle=style;
	view=[[FlippedView alloc] init];
	enabled=true;
	[self setContentView:view];
	[self setAcceptsMouseMovedEvents:YES];
	[self disableCursorRects];	//Fixes NSSetPointer not sticking.
	if (gadgetStyle&WINDOW_STATUS){
		rect.origin.x=rect.origin.y=0;
		rect.size.height-=STATUSBARHEIGHT;
		client=[[FlippedView alloc] initWithFrame:rect];
		[client setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];	
		[view addSubview:client];
// label for window status
		rect.origin.y=rect.size.height+3;
		rect.size.height=STATUSBARHEIGHT-4;		
		rect.size.width-=MaxGUIScrollerWidth();
		for (i=0;i<3;i++){
			l=[[NSTextField alloc] initWithFrame:rect];
			[l setBezeled:NO];
			[l setBordered:NO];
			[l setDrawsBackground:NO];
			[l setEditable:NO];
			[l setSelectable:NO];
			[l setLineBreakMode:NSLineBreakByTruncatingTail];
			[l setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
			[l setTextColor:[NSColor secondaryLabelColor]];
			[l setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
			switch (i){
				case 0:[l setAlignment:NSTextAlignmentLeft];break;
				case 1:[l setAlignment:NSTextAlignmentCenter];break;
				case 2:[l setAlignment:NSTextAlignmentRight];break;
			}
			if (view) [view addSubview:l];
			label[i]=l;
		}
		
		rect.origin.y-=3;
		rect.size.height=2;
		rect.size.width+=MaxGUIScrollerWidth();
		
		box=[[NSBox alloc] initWithFrame:rect];
		[box setBoxType:NSBoxSeparator];
		[box setTitlePosition:NSNoTitle];
		[box setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
		if (view) [view addSubview:box];
		
// set clientview to inner view
		view=client;		
	}
	return self;
}
-(id)clientView{
	return view;
}
-(void)setStatus:(NSString*)text align:(int)pos{
	if (label[pos]) [label[pos] setStringValue:text];
}
-(id)statusLabelAtIndex:(NSInteger)index{
	return index>=0 && index<3 ? label[index] : nil;
}
-(void)sendEvent:(NSEvent*)event{
	
	static int lastHotKey;
	int key;
	id source;
	
	// Handling of Generic Key/Mouse Events
	
	switch( [event type] ){
	case NSEventTypeMouseEntered:
		[self disableCursorRects];
	case NSEventTypeLeftMouseDown:
	case NSEventTypeRightMouseDown:
	case NSEventTypeOtherMouseDown:
		if( [event type] != NSEventTypeMouseEntered ){
			dragging = [[self contentView] hitTest:[event locationInWindow]];
			[self makeFirstResponder:dragging];
		}
	case NSEventTypeMouseMoved:
	case NSEventTypeMouseExited:
	case NSEventTypeScrollWheel:
	{
		NSView *hitView = [[self contentView] hitTest:[event locationInWindow]];
		if (hitView) EmitMouseEvent( event, hitView );
		if(![self isEnabled]) return;
		break;
	}
	case NSEventTypeLeftMouseUp:
	case NSEventTypeRightMouseUp:
	case NSEventTypeOtherMouseUp:
	{
		MaxGUIPostDropForEvent(event);
		//fire event for the dragged view
		if (dragging) {
			EmitMouseEvent( event, dragging );
			dragging = nil;
		} else {
			//fire the event for the recieving view (if it exists)
			NSView *hitView = [[self contentView] hitTest:[event locationInWindow]];
			if (hitView) EmitMouseEvent( event, hitView );
		}
		
		if(![self isEnabled]) return;
		break;
	}
	case NSEventTypeLeftMouseDragged:
	case NSEventTypeRightMouseDragged:
	case NSEventTypeOtherMouseDragged:
	{
		if( dragging == nil ) dragging = [[self contentView] hitTest:[event locationInWindow]];
		if( dragging ) EmitMouseEvent( event, dragging );
		if(![self isEnabled]) return;
		break;
	}
	case NSEventTypeKeyDown:
	case NSEventTypeKeyUp:
	case NSEventTypeFlagsChanged:
	{
		NSResponder *handle=(NSResponder*)NSActiveGadget();
		if( handle && EmitKeyEvent( event, handle )) return;
		break;
	}
	default:
		break;
	}
	
	// End of Generic Key/Mouse Events
	
	// Gadget Filterkey Processing
	
	switch( [event type] ){
	case NSEventTypeKeyDown:
		if( (key=bbSystemTranslateKey( [event keyCode] )) ){
			int mods=bbSystemTranslateMods( [event modifierFlags] );
			BBObject *event=maxgui_maxgui_HotKeyEvent( key,mods );
			if( event!=&bbNullObject ){
				lastHotKey=key;
				brl_event_EmitEvent( event );
				return;
			}
		}
		source=[self textFirstResponder];
		if( source && !filterKeyDownEvent( event,source ) ) return;		
		if(![self isEnabled]) return;
		break;
	case NSEventTypeKeyUp:
		key=bbSystemTranslateKey([event keyCode]);
		if( lastHotKey && (key==lastHotKey ) ){
			lastHotKey=0;
			return;
		}
		if(![self isEnabled]) return;
		break;
	default:
		break;
	}
	lastHotKey=0;
	
	// End of FilterKey Processing
	
	[super sendEvent:event];
}
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
	return MaxGUIFileDragOperation(sender);
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender{
	return MaxGUIAcceptDroppedFiles(self,sender);
}
-(void)didResize{
	NSRect rect=[self localRect];
	[self didMove];
	PostGuiEvent( BBEVENT_WINDOWSIZE,self,0,0,rect.size.width,rect.size.height,0 );
}
-(void)didMove{
	NSRect rect=[self localRect];
	PostGuiEvent( BBEVENT_WINDOWMOVE,self,0,0,rect.origin.x,rect.origin.y,0 );		
}
-(void)zoom{
	zooming = 1;
}
-(NSRect)localRect{
	NSRect rect,vis;
	int style;

	rect=[self frame];
	style=gadgetStyle;
	if (style&WINDOW_CLIENTCOORDS){
		rect=[self contentRectForFrameRect:rect];
		if (style&WINDOW_STATUS) {
			rect.size.height-=STATUSBARHEIGHT;		
			rect.origin.y+=STATUSBARHEIGHT;		
		}
	}
	vis=[[NSScreen deepestScreen] visibleFrame];
	rect.origin.x-=vis.origin.x;
	rect.origin.y=vis.size.height-(rect.origin.y-vis.origin.y)-rect.size.height;	
	return rect;
}
-(BOOL)canBecomeKeyWindow{
	return ([self isEnabled]);
}
-(BOOL)canBecomeMainWindow{
	return ([self isEnabled] && [self isVisible] && ([self parentWindow]==nil));
}
-(BOOL)becomeFirstResponder{
	return ([self isEnabled] && [self isVisible]);
}
-(void)setEnabled:(BOOL)e{
	enabled=e;
	if (enabled) [self makeKeyWindow];
}
-(BOOL)isEnabled{
	return (enabled)?YES:NO;
}
-(void)dealloc{
	int i;
	id sview;
	if (gadgetStyle&WINDOW_STATUS) {
		for (i = 0; i < 3; i++) {
			if (label[i]) {
				[label[i] removeFromSuperview];
				[label[i] release];
			}
		}
		
		sview = [view superview];
		[view removeFromSuperview];
		[view release];

		[sview removeFromSuperview];
		[sview release];
	} else {
		[view removeFromSuperview];
		[view release];
	}

	[super dealloc];
}
@end

// ToolView

@implementation ToolView
-(id)textFirstResponder{
	id r=[self firstResponder];
	//if ([r isKindOfClass:[PanelView class]]) return r;
	if ([r isKindOfClass:[NSTextView class]]){
		id d=[r delegate];
		if( [d isKindOfClass:[NSTextField class]] ) return d;
	}
	return r;
}
-(id)initWithContentRect:(NSRect)rect styleMask:(unsigned int)mask backing:(NSBackingStoreType)backing defer:(BOOL)flag withStyle:(int)style{
//withStatus:(BOOL)status{
	NSView		*client;
	int		i;
	NSTextField	*l;
	NSBox	*box;
	dragging = nil;
	self=[super initWithContentRect:rect styleMask:mask backing:backing defer:flag];
	gadgetStyle=style;
	view=[[FlippedView alloc] init];
	enabled=true;
	[self setContentView:view];
	[self setAcceptsMouseMovedEvents:YES];
	[self disableCursorRects];	//Fixes NSSetPointer not sticking.
	if (gadgetStyle&WINDOW_STATUS){			//status){	//mask&NSTexturedBackgroundWindowMask)
		rect.origin.x=rect.origin.y=0;
		rect.size.height-=STATUSBARHEIGHT;
		client=[[FlippedView alloc] initWithFrame:rect];
		[client setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];	
		[view addSubview:client];
// label for window status
		rect.origin.y=rect.size.height+3;
		rect.size.height=STATUSBARHEIGHT-4;		
		rect.size.width-=MaxGUIScrollerWidth();
		for (i=0;i<3;i++){
			l=[[NSTextField alloc] initWithFrame:rect];
			[l setBezeled:NO];
			[l setBordered:NO];
			[l setDrawsBackground:NO];
			[l setEditable:NO];
			[l setSelectable:NO];
			[l setLineBreakMode:NSLineBreakByTruncatingTail];
			[l setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
			[l setTextColor:[NSColor secondaryLabelColor]];
			[l setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
			switch (i){
				case 0:[l setAlignment:NSTextAlignmentLeft];break;
				case 1:[l setAlignment:NSTextAlignmentCenter];break;
				case 2:[l setAlignment:NSTextAlignmentRight];break;
			}
			if (view) [view addSubview:l];
			label[i]=l;
		}
		
		rect.origin.y-=3;
		rect.size.height=2;
		rect.size.width+=MaxGUIScrollerWidth();
		
		box=[[NSBox alloc] initWithFrame:rect];
		[box setBoxType:NSBoxSeparator];
		[box setTitlePosition:NSNoTitle];
		[box setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
		if (view) [view addSubview:box];
		
// set clientview to inner view
		view=client;		
	}
	if ([self respondsToSelector: @selector(setShowsToolbarButton)]) [self setShowsToolbarButton: NO];
	return self;
}
-(id)clientView{
	return view;
}
-(void)setStatus:(NSString*)text align:(int)pos{
	if (label[pos]) [label[pos] setStringValue:text];
}
-(id)statusLabelAtIndex:(NSInteger)index{
	return index>=0 && index<3 ? label[index] : nil;
}
-(void)sendEvent:(NSEvent*)event{
	
	static int lastHotKey;
	int key;
	id source;
	
	// Handling of Generic Key/Mouse Events
	
	switch( [event type] ){
	case NSEventTypeMouseEntered:
		[self disableCursorRects];
	case NSEventTypeLeftMouseDown:
	case NSEventTypeRightMouseDown:
	case NSEventTypeOtherMouseDown:
	{
		if( [event type] != NSEventTypeMouseEntered ){
			dragging = [[self contentView] hitTest:[event locationInWindow]];
			[self makeFirstResponder:dragging];
		}
	}
	case NSEventTypeMouseMoved:
	case NSEventTypeMouseExited:
	case NSEventTypeScrollWheel:
	{
		NSView *hitView = [[self contentView] hitTest:[event locationInWindow]];
		if (hitView) EmitMouseEvent( event, hitView );
		if(![self isEnabled]) return;
		break;
	}
	case NSEventTypeLeftMouseUp:
	case NSEventTypeRightMouseUp:
	case NSEventTypeOtherMouseUp:
	{
		MaxGUIPostDropForEvent(event);
		//fire event for the dragged view
		if (dragging) {
			EmitMouseEvent( event, dragging );
			dragging = nil;
		} else {
			//fire the event for the recieving view (if it exists)
			NSView *hitView = [[self contentView] hitTest:[event locationInWindow]];
			if (hitView) EmitMouseEvent( event, hitView );
		}
		
		if(![self isEnabled]) return;
		break;
	}
	case NSEventTypeLeftMouseDragged:
	case NSEventTypeRightMouseDragged:
	case NSEventTypeOtherMouseDragged:
	{
		if( dragging == nil ) dragging = [[self contentView] hitTest:[event locationInWindow]];
		if( dragging ) EmitMouseEvent( event, dragging );
		if(![self isEnabled]) return;
		break;
	}
	case NSEventTypeKeyDown:
	case NSEventTypeKeyUp:
	case NSEventTypeFlagsChanged:
	{
		NSResponder *handle=(NSResponder*)NSActiveGadget();
		if( handle && EmitKeyEvent( event, handle )) return;
		break;
	}
	default:
		break;
	}
	
	// End of Generic Key/Mouse Events
	
	// Gadget Filterkey Processing
	
	switch( [event type] ){
	case NSEventTypeKeyDown:
		if( (key=bbSystemTranslateKey( [event keyCode] )) ){
			int mods=bbSystemTranslateMods( [event modifierFlags] );
			BBObject *event=maxgui_maxgui_HotKeyEvent( key,mods );
			if( event!=&bbNullObject ){
				lastHotKey=key;
				brl_event_EmitEvent( event );
				return;
			}
		}
		source=[self textFirstResponder];
		if( source && !filterKeyDownEvent( event,source ) ) return;		
		if(![self isEnabled]) return;
		break;
	case NSEventTypeKeyUp:
		key=bbSystemTranslateKey([event keyCode]);
		if( lastHotKey && (key==lastHotKey ) ){
			lastHotKey=0;
			return;
		}
		if(![self isEnabled]) return;
		break;
	default:
		break;
	}
	lastHotKey=0;
	
	// End of FilterKey Processing
	
	[super sendEvent:event];
}
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
	return MaxGUIFileDragOperation(sender);
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender{
	return MaxGUIAcceptDroppedFiles(self,sender);
}
-(void)didResize{
	if (zooming) {
		zooming = 0;
		[self didMove];
	}
	NSRect rect=[self localRect];
	PostGuiEvent( BBEVENT_WINDOWSIZE,self,0,0,rect.size.width,rect.size.height,0 );
}
-(void)didMove{
	NSRect rect=[self localRect];
	PostGuiEvent( BBEVENT_WINDOWMOVE,self,0,0,rect.origin.x,rect.origin.y,0 );		
}
-(void)zoom{
	zooming = 1;
}
-(NSRect)localRect{
	NSRect rect,vis;
	int style;

	rect=[self frame];
	style=gadgetStyle;
	if (style&WINDOW_CLIENTCOORDS){
		rect=[self contentRectForFrameRect:rect];
		if (style&WINDOW_STATUS) {
			rect.size.height-=STATUSBARHEIGHT;		
			rect.origin.y+=STATUSBARHEIGHT;		
		}
	}
	vis=[[NSScreen deepestScreen] visibleFrame];
	rect.origin.x=rect.origin.x-vis.origin.x;
	rect.origin.y=vis.size.height-(rect.origin.y-vis.origin.y)-rect.size.height;	
	return rect;
}
-(BOOL)canBecomeKeyWindow{
	return ([self isEnabled]);
}
-(BOOL)canBecomeMainWindow{
	return ([self isEnabled] && [self isVisible] && ([self parentWindow]==nil));
}
-(BOOL)becomeFirstResponder{
	return ([self isEnabled] && [self isVisible]);
}
-(void)setEnabled:(BOOL)e{
	enabled=e;
	if (enabled) [self makeKeyWindow];
}
-(BOOL)isEnabled{
	return (enabled)?YES:NO;
}
-(void)dealloc{
	int i;
	id sview;
	if (gadgetStyle&WINDOW_STATUS) {
		for (i = 0; i < 3; i++) {
			if (label[i]) {
				[label[i] removeFromSuperview];
				[label[i] release];
			}
		}
		
		sview = [view superview];
		[view removeFromSuperview];
		[view release];

		[sview removeFromSuperview];
		[sview release];
	} else {
		[view removeFromSuperview];
		[view release];
	}

	[super dealloc];
}
@end

// global app stuff

void NSBegin(){
	GlobalApp=[[CocoaApp alloc] init];
	HaltMouseEvents=0;
}

void NSEnd(){
	[GlobalApp release];
	[MaxGUITopMenuProxies release];
	MaxGUITopMenuProxies=nil;
	MaxGUIAppMenu=nil;
}

void* NSActiveGadget(){
	NSWindow	*window;
	NSResponder *responder;
	window=[NSApp keyWindow];
	if (!window) return 0;
	responder=[window firstResponder];
	if (!responder) return window;
	if ([responder isKindOfClass:[NSTextView class]] && 
   		[window fieldEditor:NO forObject:nil] != nil ) { 
			NSTextView *view=(NSTextView*)responder;
			return [view delegate];
		}
	return responder;
}

void NSPeerInitializeGadget(void *peer,BBString *textarg,int *x,int *y,int *w,int *h,void *groupPeer){
	NSRect 				rect,vis;
	NSString 			*text;
	NSView				*view=nil;
	id				nativeHandle=nil;
	NSView				*clientView=nil;
	NSWindow		*window;
	NSButton			*button;
	NSTextField			*textfield;
	TextView			*textarea;
	NSComboBox 		*combobox;
	Toolbar			*toolbar;
	TabView				*tabber;
	TreeView			*treeview;
	HTMLView			*htmlview;
	PanelView			*panel;
	PanelViewContent		*pnlcontent;
	CanvasView			*canvas;
	ListView				*listbox;
	NSText				*label;
	NSBox				*box;
	NSSlider				*slider;
	NSScroller			*scroller;
	NSStepper				*stepper;
	NSProgressIndicator	*progbar;
	NSMenu				*menu;
	NSMenuItem			*menuitem;
	NodeItem			*node,*parent;
	int 					gadgetClass=NSPeerGadgetClass(peer);
	int 					style=NSPeerGadgetStyle(peer);
	int					groupClass=0;
	id					groupHandle=nil;
	int 					flags=0;
	NSImage			*image;
		
	rect=NSMakeRect(*x,*y,*w,*h);
	text=NSStringFromBBString(textarg);
	if (groupPeer){
		groupClass=NSPeerGadgetClass(groupPeer);
		groupHandle=NSPeerNativeHandle(groupPeer);
		view=(NSView*)NSPeerClientView(groupPeer);
	}
	
	switch (gadgetClass){
	case GADGET_DESKTOP:
		rect=[[NSScreen deepestScreen] frame];
		*x=rect.origin.x;
		*y=rect.origin.y;
		*w=rect.size.width;
		*h=rect.size.height;
		break;
	case GADGET_WINDOW:
		vis=[[NSScreen deepestScreen] visibleFrame];
		rect.origin.x+=vis.origin.x;
		rect.origin.y=vis.origin.y+vis.size.height-rect.origin.y-rect.size.height;
		if (style&WINDOW_TITLEBAR) flags|=NSWindowStyleMaskTitled|NSWindowStyleMaskClosable;
		if (style&WINDOW_RESIZABLE){
			flags|=NSWindowStyleMaskResizable;
			if (!(groupPeer && groupClass==GADGET_WINDOW)) flags |=NSWindowStyleMaskMiniaturizable;
		}
		if (style&WINDOW_TOOL) flags|=NSWindowStyleMaskUtilityWindow;
		[NSApp activateIgnoringOtherApps:YES];
		if (!(style&WINDOW_CLIENTCOORDS)){
			rect=[NSWindow contentRectForFrameRect:rect styleMask:flags];
		}else{
			if (style&WINDOW_STATUS) {
				rect.origin.y-=STATUSBARHEIGHT;		
				rect.size.height+=STATUSBARHEIGHT;		
			}
		}
		if (!(style&WINDOW_TOOL)) {
			window=[[WindowView alloc] initWithContentRect:rect styleMask:flags backing:NSBackingStoreBuffered defer:YES withStyle:style];
		} else {
			window=[[ToolView alloc] initWithContentRect:rect styleMask:flags backing:NSBackingStoreBuffered defer:YES withStyle:style];
		}
		[window setOpaque:YES];
		[window setAlphaValue:1.0];
		
		if (style&WINDOW_HIDDEN) [window orderOut:window]; else [window makeKeyAndOrderFront:NSApp];
		
		if (groupPeer && groupClass==GADGET_WINDOW){
			NSWindow	*parent;
			parent=(NSWindow*)groupHandle;
			if(!(style&WINDOW_HIDDEN)) [parent addChildWindow:window ordered:NSWindowAbove];
			[window setParentWindow:parent];
		}
		
		if (style&WINDOW_ACCEPTFILES)
			[window registerForDraggedTypes:[NSArray arrayWithObject:NSPasteboardTypeFileURL]];
		
		[window setTitle:text];	
		[window setDelegate:GlobalApp];
		nativeHandle=window;
		if ([window isKindOfClass:[ToolView class]]) clientView=[(ToolView*)window clientView];
		else clientView=[(WindowView*)window clientView];
		break;
		
	case GADGET_BUTTON:
		button=[[NSButton alloc] initWithFrame:rect];
		[button setTitle:text];
		
		[button setBezelStyle:NSBezelStyleRounded];
		
		switch (style&7){
			case 0:
				// Push Button Size Hack
				if (*h > 30) {
					[button setBezelStyle:NSBezelStyleRegularSquare];
				} else {
					if (*h < 24) [button setBezelStyle:NSBezelStyleShadowlessSquare];
					else [button setBezelStyle:NSBezelStyleRounded];
				}
				break;
			case BUTTON_CHECKBOX:
				if (style&BUTTON_PUSH){
					[button setBezelStyle:NSBezelStyleShadowlessSquare];
					[button setButtonType:NSButtonTypePushOnPushOff];
				} else {
					[button setButtonType:NSButtonTypeSwitch];
				}
				break;
			case BUTTON_RADIO:
				if (style&BUTTON_PUSH){
					[button setBezelStyle:NSBezelStyleShadowlessSquare];
					[button setButtonType:NSButtonTypePushOnPushOff];
				} else {
					[button setButtonType:NSButtonTypeRadio];
				}
				break;
			case BUTTON_OK:
				[button setKeyEquivalent:@"\r"];
				break;
			case BUTTON_CANCEL:
				[button setKeyEquivalent:@"\x1b"];
				break;
		}
		[button setTarget:GlobalApp];
		[button setAction:@selector(buttonPush:)];
		if (view) [view addSubview:button];		
		nativeHandle=button;
		clientView=button;
		break;
	case GADGET_PANEL:
		panel=[[PanelView alloc] initWithFrame:rect];
		[panel setContentViewMargins:NSMakeSize(0.0,0.0)];
		pnlcontent=[[PanelViewContent alloc] initWithFrame:[panel bounds]];
		[pnlcontent setAutoresizesSubviews:NO];
		[panel setContentView:pnlcontent];
		[pnlcontent release];
		[panel setStyle:style];
		[panel setEnabled:true];
		[panel setTitle:text];
		[pnlcontent setAlpha:1.0];
		if (view) [view addSubview:panel];
		clientView=pnlcontent;
		nativeHandle=panel;
		break;
	case GADGET_CANVAS:
		canvas=[[CanvasView alloc] initWithFrame:rect];
		[canvas setAutoresizesSubviews:NO];
		if (view) [view addSubview:canvas];
		[canvas setStyle:style|PANEL_ACTIVE];
		[canvas setEnabled:true];
		clientView=[canvas contentView];
		nativeHandle=canvas;
		break;	
	case GADGET_TEXTFIELD:
		if (style==TEXTFIELD_PASSWORD){
			textfield=[[NSSecureTextField alloc] initWithFrame:rect];
		}else{
			textfield=[[NSTextField alloc] initWithFrame:rect];
		}
		[textfield setDelegate:GlobalApp];
		[textfield setEditable:YES];
		[[textfield cell] setWraps:NO];
		[[textfield cell] setScrollable:YES];
		if (view) [view addSubview:textfield];		
		nativeHandle=textfield;
		clientView=textfield;
		break;
	case GADGET_TEXTAREA://http://developer.apple.com/documentation/Cocoa/Conceptual/TextUILayer/Tasks/TextInScrollView.html
		textarea=[[TextView alloc] initWithFrame:rect];
		if (style&TEXTAREA_READONLY) [textarea setEditable:NO];
		if (style&TEXTAREA_WORDWRAP) [textarea setWordWrap:YES];
		if (view) [view addSubview:[textarea getScroll]];
		nativeHandle=textarea;
		clientView=[textarea getScroll];
		break;		
	case GADGET_COMBOBOX:
		if (rect.size.height > 26) rect.size.height = 26;
		combobox=[[NSComboBox alloc] initWithFrame:rect];
		[combobox setUsesDataSource:NO];
		[combobox setCompletes:YES];
		[combobox setDelegate:GlobalApp];		
		[combobox setEditable:(style&COMBOBOX_EDITABLE)?YES:NO];			
		[combobox setSelectable:YES];			
		if (view) [view addSubview:combobox];		
		nativeHandle=combobox;
		clientView=combobox;
		break;
	case GADGET_LISTBOX:
		listbox=[[ListView alloc] initWithFrame:rect];
		[[listbox table] setAllowsMultipleSelection:(style&LISTBOX_MULTISELECT)?YES:NO];
		if (view) [view addSubview:listbox];		
		nativeHandle=listbox;
		clientView=listbox;
		break;
	case GADGET_TOOLBAR:
		toolbar=[[Toolbar alloc] initWithIdentifier:text];
		[toolbar setSizeMode:NSToolbarSizeModeDefault];
		[toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
		[toolbar setDelegate:toolbar];
		window=(WindowView*)groupHandle;
		[window setToolbar:toolbar];
		if (@available(macOS 11.0,*)) [window setToolbarStyle:NSWindowToolbarStyleExpanded];
		nativeHandle=toolbar;
		if ([window isKindOfClass:[ToolView class]]) clientView=[(ToolView*)window clientView];
		else clientView=[(WindowView*)window clientView];
		break;
	case GADGET_TABBER:
		tabber=[[TabView alloc] initWithFrame:rect];
		[tabber setAutoresizesSubviews:NO];
		if (view) [view addSubview:tabber];		//[tabber hostView]];		
		nativeHandle=tabber;
		clientView=[tabber clientView];
		break;
	case GADGET_TREEVIEW:
		treeview=[[TreeView alloc] initWithFrame:rect];	//NSOutlineView
		if (view) [view addSubview:treeview];		
		nativeHandle=treeview;
		clientView=treeview;
		break;
	case GADGET_HTMLVIEW:
		htmlview=[[HTMLView alloc] initWithFrame:rect];
		if (view) [view addSubview:htmlview];
		[htmlview setStyle: style];
		nativeHandle=htmlview;
		clientView=htmlview;
		break;
    case GADGET_LABEL: /* BaH */
		switch (style&3) {
		case LABEL_SEPARATOR:
			
			box=[[NSBox alloc] initWithFrame:rect];
			
			[box setTitle:text];
			[box setBoxType:NSBoxSeparator];
			[box setTitlePosition:NSNoTitle];
			
			[box setContentView:[[FlippedView alloc] init]];
			
			if (view) [view addSubview:box];
			nativeHandle=box;
			clientView=[box contentView];
			
			break;
			
		default:
			
			textfield = [[NSTextField alloc] initWithFrame:rect];
			
			[textfield setEditable:NO];
			[textfield setDrawsBackground:NO];
			
			if ((style&3)==LABEL_SUNKENFRAME) {
				[textfield setBezeled:YES];
				[textfield setBezelStyle:NSTextFieldSquareBezel];
			} else {
				[textfield setBezeled:NO];
				if ((style&3)==LABEL_FRAME)
				        [textfield setBordered:YES];
				else
				        [textfield setBordered:NO];
			}
			
			[[textfield cell] setWraps:YES];
			[[textfield cell] setScrollable:NO];
			[textfield setStringValue:text];
			
			switch (style&24){
				case LABEL_LEFT:[textfield setAlignment:NSTextAlignmentLeft];break;
				case LABEL_RIGHT:[textfield setAlignment:NSTextAlignmentRight];break;
				case LABEL_CENTER:[textfield setAlignment:NSTextAlignmentCenter];break;
			}               
			
			if (view) [view addSubview: textfield];
			nativeHandle=textfield;
			clientView=textfield;
			
			break;
		}
		break;			
	case GADGET_SLIDER:
		switch (style&12){
		case SLIDER_SCROLLBAR:
			if (rect.size.width>rect.size.height)		{
				rect.size.height=MaxGUIScrollerWidth();
			}
			else{
				rect.size.width=MaxGUIScrollerWidth();
			}
			scroller=[[NSScroller alloc] initWithFrame:rect];
			[scroller setEnabled:YES];
			[scroller setTarget:GlobalApp];
			[scroller setAction:@selector(scrollerSelect:)];
			if (view) [view addSubview:scroller];		
			nativeHandle=scroller;
			clientView=scroller;
			break;
		case SLIDER_TRACKBAR:
			slider=[[NSSlider alloc] initWithFrame:rect];
			[slider setEnabled:YES];
			[slider setTarget:GlobalApp];
			[slider setAction:@selector(sliderSelect:)];
			if (view) [view addSubview:slider];
			nativeHandle=slider;
			clientView=slider;
			break;
		case SLIDER_DIAL:
			slider=[[NSSlider alloc] initWithFrame:rect];
			[slider setSliderType:NSSliderTypeCircular];
			[slider setEnabled:YES];
			[slider setTarget:GlobalApp];
			[slider setAction:@selector(sliderSelect:)];
			if (view) [view addSubview:slider];
			nativeHandle=slider;
			clientView=slider;
			break;
		case SLIDER_STEPPER:
			stepper=[[NSStepper alloc] initWithFrame:rect];
			[stepper setEnabled:YES];
			[stepper setTarget:GlobalApp];
			[stepper setAction:@selector(sliderSelect:)];
			[stepper setValueWraps:NO];
			if (view) [view addSubview:stepper];
			nativeHandle=stepper;
			clientView=stepper;
			break;
		}
		break;
	case GADGET_PROGBAR:
		progbar=[[NSProgressIndicator alloc] initWithFrame:rect];
		[progbar setStyle:NSProgressIndicatorStyleBar];
		[progbar setIndeterminate:NO];
		[progbar setMaxValue:1.0];
		if (view) [view addSubview:progbar];		
		nativeHandle=progbar;
		clientView=progbar;
		break;
	case GADGET_MENUITEM:
		// Allows a popup-menu to be created with no text without crashing.
		if ([text length] || groupClass==GADGET_DESKTOP) {
			menuitem=[[NSMenuItem alloc] initWithTitle:text action:@selector(menuSelect:) keyEquivalent:@""];
			[menuitem setTag:style];
		}
		else{
			menuitem=[(NSMenuItem*)[NSMenuItem separatorItem] retain];
		}
		[menuitem setTarget:GlobalApp];
		[GlobalApp addMenuItem:menuitem];
		if (groupPeer){
			switch (groupClass){
				case GADGET_WINDOW:{
					int role=MaxGUITopLevelMenuRole(text);
					NSMenuItem *standardRoot=MaxGUITopLevelItem(role);
					if (role==MAXGUI_TOP_MENU_WINDOW && [NSApp windowsMenu]){
						MaxGUIRegisterTopMenuProxy(menuitem,[NSApp windowsMenu]);
						break;
					}
					if (role==MAXGUI_TOP_MENU_VIEW && standardRoot && [standardRoot submenu]){
						MaxGUIRegisterTopMenuProxy(menuitem,[standardRoot submenu]);
						break;
					}
					menu=[[NSMenu alloc] initWithTitle:text];
					[menu setAutoenablesItems:NO];
					[menuitem setSubmenu:menu];
					[menu release];
					menu=[NSApp mainMenu];
					if (role==MAXGUI_TOP_MENU_HELP && ![NSApp helpMenu]){
						[menu addItem:menuitem];
						[NSApp setHelpMenu:[menuitem submenu]];
					}else{
						[menu insertItem:menuitem atIndex:MaxGUIApplicationMenuInsertionIndex()];
					}
					break;
				}
				case GADGET_MENUITEM:{
					int role=MaxGUIApplicationMenuRole(text);
					if (role && MaxGUIMapApplicationMenuItem(menuitem,role)) break;
					menu=MaxGUITopMenuProxy((NSMenuItem*)groupHandle);
					if (!menu) menu=(NSMenu*)[groupHandle submenu];
					if (!menu){
						menu=(NSMenu*)[[NSMenu alloc] initWithTitle:text];
						[menu setAutoenablesItems:NO];
						[groupHandle setSubmenu:menu];
						[menu addItem:menuitem];
						[menu release];
					} else {
						[menu addItem:menuitem];
					}
					break;
				}
			}
		}
		nativeHandle=menuitem;
		// GlobalApp owns every menu item until its MaxGUI peer is freed. Menus
		// retain attached items independently, so standalone popup roots follow
		// the same deterministic ownership rule as window and submenu items.
		[menuitem release];
		break;
	case GADGET_NODE:
		if (!groupPeer) break;
		parent=0;
		switch (groupClass){
			case GADGET_TREEVIEW:
				parent=[((TreeView*)groupHandle) rootNode];
				break;
			case GADGET_NODE:
				parent=(NodeItem*)groupHandle;
				break;
		}
		if (!parent) break;
		node=[[NodeItem alloc] initWithTitle:text];
		int index=style;
		if (index==-1) index=[parent count];
		if (index>[parent count]) index=[parent count];
		[node attach:parent atIndex:index];
		nativeHandle=node;
		break;
	}
	NSPeerSetNativeObjects(peer,nativeHandle,clientView);
}

int NSMaxGUIMenuAttachment(void *rootHandle,void *childHandle){
	NSMenuItem *root=(NSMenuItem*)rootHandle;
	NSMenuItem *child=(NSMenuItem*)childHandle;
	if (!root || !child) return 0;
	NSMenu *submenu=MaxGUITopMenuProxy(root);
	if (!submenu) submenu=[root submenu];
	if (!submenu || [child menu]!=submenu) return 0;
	if ([root target]!=GlobalApp || [child target]!=GlobalApp) return 0;
	return 1;
}

int NSMaxGUIMenuPerformAction(void *handle){
	NSMenuItem *item=(NSMenuItem*)handle;
	if (!item || ![item action] || ![item target]) return 0;
	return [NSApp sendAction:[item action] to:[item target] from:item];
}

int NSMaxGUIInstallTestApplicationMenus(){
	if (MaxGUIApplicationMenu()) return 1;
	NSMenu *mainMenu=[[NSMenu alloc] initWithTitle:@""];
	[NSApp setMainMenu:mainMenu];
	[mainMenu release];
	NSMenu *appMenu=[[NSMenu alloc] initWithTitle:@""];
	[appMenu addItemWithTitle:@"About Menu Test" action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
	[appMenu addItem:[NSMenuItem separatorItem]];
	[appMenu addItemWithTitle:@"Preferences…" action:@selector(showPreferences:) keyEquivalent:@","];
	[appMenu addItem:[NSMenuItem separatorItem]];
	[appMenu addItemWithTitle:@"Quit Menu Test" action:@selector(terminate:) keyEquivalent:@"q"];
	NSMenuItem *root=[[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
	[root setSubmenu:appMenu];
	[[NSApp mainMenu] addItem:root];
	[root release];
	[appMenu release];
	NSMenu *viewMenu=[[NSMenu alloc] initWithTitle:@"View"];
	[viewMenu addItemWithTitle:@"Toggle Full Screen" action:@selector(toggleFullScreen:) keyEquivalent:@"f"];
	root=[[NSMenuItem alloc] initWithTitle:@"View" action:nil keyEquivalent:@""];
	[root setSubmenu:viewMenu];
	[[NSApp mainMenu] addItem:root];
	[root release];
	[viewMenu release];
	NSMenu *windowMenu=[[NSMenu alloc] initWithTitle:@"Window"];
	[windowMenu addItemWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
	root=[[NSMenuItem alloc] initWithTitle:@"Window" action:nil keyEquivalent:@""];
	[root setSubmenu:windowMenu];
	[[NSApp mainMenu] addItem:root];
	[root release];
	[NSApp setWindowsMenu:windowMenu];
	[windowMenu release];
	MaxGUIAppMenu=nil;
	return MaxGUIApplicationMenu()!=nil ? 1 : 0;
}

int NSMaxGUIApplicationMenuItemPresentation(void *handle,int role){
	NSMenuItem *item=(NSMenuItem*)handle;
	if (!item || role<=MAXGUI_APP_MENU_NONE || role>MAXGUI_APP_MENU_QUIT) return 0;
	NSMenu *appMenu=MaxGUIApplicationMenu();
	MaxGUIApplicationMenuBinding *binding=&MaxGUIAppMenuBindings[role];
	int result=0;
	if ([item menu]==appMenu) result|=1;
	if (binding->mappedItem==item) result|=2;
	if ([item target]==GlobalApp && [item action]==@selector(menuSelect:)) result|=4;
	if ([appMenu indexOfItem:item]==binding->index) result|=8;
	if (binding->standardItem && [[item keyEquivalent] isEqualToString:[binding->standardItem keyEquivalent]] &&
		[item keyEquivalentModifierMask]==[binding->standardItem keyEquivalentModifierMask]) result|=16;
	return result;
}

int NSMaxGUITopLevelMenuPresentation(void *handle,int role){
	NSMenuItem *item=(NSMenuItem*)handle;
	if (!item || role<=MAXGUI_TOP_MENU_NONE || role>MAXGUI_TOP_MENU_HELP) return 0;
	NSMenu *submenu=MaxGUITopMenuProxy(item);
	if (!submenu) submenu=[item submenu];
	NSMenu *expected=nil;
	if (role==MAXGUI_TOP_MENU_WINDOW) expected=[NSApp windowsMenu];
	else if (role==MAXGUI_TOP_MENU_HELP) expected=[NSApp helpMenu];
	else {
		NSMenuItem *standard=MaxGUITopLevelItem(MAXGUI_TOP_MENU_VIEW);
		expected=[standard submenu];
	}
	int result=0;
	if (submenu && submenu==expected) result|=1;
	NSInteger count=0;
	for (NSMenuItem *root in [[NSApp mainMenu] itemArray]) if ([root submenu]==submenu) count++;
	if (count==1) result|=2;
	BOOL attached=[item menu]==[NSApp mainMenu];
	if ((role==MAXGUI_TOP_MENU_HELP && attached) || (role!=MAXGUI_TOP_MENU_HELP && !attached)) result|=4;
	NSMenuItem *visible=MaxGUITopLevelItem(role);
	if (visible && [[NSApp mainMenu] indexOfItem:visible]>0) result|=8;
	return result;
}

int NSMaxGUIMainMenuOrderPresentation(void *fileHandle,void *helpHandle){
	NSMenu *mainMenu=[NSApp mainMenu];
	NSMenuItem *file=(NSMenuItem*)fileHandle;
	NSMenuItem *help=(NSMenuItem*)helpHandle;
	NSMenuItem *view=MaxGUITopLevelItem(MAXGUI_TOP_MENU_VIEW);
	NSMenuItem *window=MaxGUITopLevelItem(MAXGUI_TOP_MENU_WINDOW);
	NSInteger appIndex=[mainMenu indexOfItemWithSubmenu:MaxGUIApplicationMenu()];
	NSInteger fileIndex=[mainMenu indexOfItem:file];
	NSInteger viewIndex=[mainMenu indexOfItem:view];
	NSInteger windowIndex=[mainMenu indexOfItem:window];
	NSInteger helpIndex=[mainMenu indexOfItem:help];
	return appIndex>=0 && appIndex<fileIndex && fileIndex<viewIndex && viewIndex<windowIndex && windowIndex<helpIndex;
}

int NSMaxGUIApplicationMenuDefaultsPresentation(){
	NSMenu *appMenu=MaxGUIApplicationMenu();
	MaxGUIInitializeApplicationMenuBindings();
	int result=0;
	for (int role=MAXGUI_APP_MENU_ABOUT;role<=MAXGUI_APP_MENU_QUIT;role++){
		NSInteger count=0;
		for (NSMenuItem *item in [appMenu itemArray]) if ([item action]==MaxGUIAppMenuBindings[role].action) count++;
		if (count==1 && !MaxGUIAppMenuBindings[role].mappedItem && !MaxGUIAppMenuBindings[role].standardItem) result|=1<<(role-1);
	}
	return result;
}

int NSMaxGUIHelpMenuIsClear(){
	return [NSApp helpMenu]==nil ? 1 : 0;
}

int NSMaxGUIApplicationDelegatePresentation(){
	id <NSApplicationDelegate> delegate=[NSApp delegate];
	if (!delegate) return 0;
	int result=1;
	if ([delegate respondsToSelector:@selector(applicationShouldTerminate:)]) result|=2;
	if ([delegate respondsToSelector:@selector(applicationWillTerminate:)]) result|=4;
	if ([delegate respondsToSelector:@selector(applicationDidBecomeActive:)]) result|=8;
	if ([delegate respondsToSelector:@selector(applicationDidResignActive:)]) result|=16;
	if ([delegate respondsToSelector:@selector(application:openFile:)]) result|=32;
	BOOL terminatesAfterLastWindow=NO;
	if ([delegate respondsToSelector:@selector(applicationShouldTerminateAfterLastWindowClosed:)]){
		terminatesAfterLastWindow=[delegate applicationShouldTerminateAfterLastWindowClosed:NSApp];
	}
	if (!terminatesAfterLastWindow) result|=64;
	if (NSApp) result|=128;
	return result;
}

int NSMaxGUIApplicationResumeAction(){
	id <NSApplicationDelegate> delegate=[NSApp delegate];
	if (!delegate || ![delegate respondsToSelector:@selector(applicationDidBecomeActive:)]) return 0;
	[delegate applicationDidBecomeActive:[NSNotification notificationWithName:NSApplicationDidBecomeActiveNotification object:NSApp]];
	return 1;
}

int NSMaxGUIApplicationSuspendAction(){
	id <NSApplicationDelegate> delegate=[NSApp delegate];
	if (!delegate || ![delegate respondsToSelector:@selector(applicationDidResignActive:)]) return 0;
	[delegate applicationDidResignActive:[NSNotification notificationWithName:NSApplicationDidResignActiveNotification object:NSApp]];
	return 1;
}

int NSMaxGUIApplicationTerminateAction(){
	id <NSApplicationDelegate> delegate=[NSApp delegate];
	if (!delegate || ![delegate respondsToSelector:@selector(applicationShouldTerminate:)]) return 0;
	return [delegate applicationShouldTerminate:NSApp]==NSTerminateCancel ? 1 : 0;
}

int NSMaxGUIApplicationOpenFileAction(BBString *patharg){
	id <NSApplicationDelegate> delegate=[NSApp delegate];
	if (!delegate || ![delegate respondsToSelector:@selector(application:openFile:)]) return 0;
	return [delegate application:NSApp openFile:NSStringFromBBString(patharg)] ? 1 : 0;
}

int NSMaxGUIButtonPerformClick(void *handle){
	NSButton *button=(NSButton*)handle;
	if (!button || ![button isKindOfClass:[NSButton class]]) return 0;
	[button performClick:nil];
	return 1;
}

int NSMaxGUIControlSetDoubleValueAndSendAction(void *handle,double value){
	NSControl *control=(NSControl*)handle;
	if (!control || ![control isKindOfClass:[NSControl class]]) return 0;
	if (![control action] || ![control target]) return 0;
	[control setDoubleValue:value];
	return [control sendAction:[control action] to:[control target]] ? 1 : 0;
}

int NSMaxGUIItemDoubleAction(void *handle,int gadgetClass,int index){
	if (!handle) return 0;
	switch (gadgetClass){
		case GADGET_LISTBOX:
			if (![(id)handle isKindOfClass:[ListView class]]) return 0;
			return [(ListView*)handle performDoubleActionAtIndex:index] ? 1 : 0;
		case GADGET_TREEVIEW:
			if (![(id)handle isKindOfClass:[TreeView class]]) return 0;
			return [(TreeView*)handle performDoubleActionAtIndex:index] ? 1 : 0;
	}
	return 0;
}

int NSMaxGUIComboSelectionAction(void *handle,int index){
	NSComboBox *combo=(NSComboBox*)handle;
	if (!combo || ![combo isKindOfClass:[NSComboBox class]]) return 0;
	if (index<0 || index>=[combo numberOfItems]) return 0;
	[combo selectItemAtIndex:index];
	[combo setObjectValue:[combo objectValueOfSelectedItem]];
	NSNotification *notification=[NSNotification notificationWithName:NSComboBoxSelectionDidChangeNotification object:combo];
	[GlobalApp controlTextDidChange:notification];
	[GlobalApp comboBoxSelectionDidChange:notification];
	return 1;
}

int NSMaxGUIComboEditAction(void *handle,BBString *textarg){
	NSComboBox *combo=(NSComboBox*)handle;
	if (!combo || ![combo isKindOfClass:[NSComboBox class]] || ![combo isEditable]) return 0;
	NSInteger selected=[combo indexOfSelectedItem];
	if (selected>=0) [combo deselectItemAtIndex:selected];
	[combo setStringValue:NSStringFromBBString(textarg)];
	NSNotification *notification=[NSNotification notificationWithName:NSControlTextDidChangeNotification object:combo];
	[GlobalApp controlTextDidChange:notification];
	return 1;
}

int NSMaxGUITabSelectionAction(void *handle,int index){
	TabView *tabView=(TabView*)handle;
	if (!tabView || ![tabView isKindOfClass:[TabView class]]) return 0;
	return [tabView performUserSelectionAtIndex:index] ? 1 : 0;
}

int NSMaxGUITabOverflowPresentation(void *handle){
	TabView *tabView=(TabView*)handle;
	if (!tabView || ![tabView isKindOfClass:[TabView class]]) return 0;
	return [tabView overflowPresentation];
}

int NSMaxGUIWindowPresentation(void *handle){
	NSWindow *window=(NSWindow*)handle;
	if (!window || ![window isKindOfClass:[NSWindow class]]) return 0;
	int result=0;
	if ([window isOpaque]) result|=1;
	if (fabs([window alphaValue]-1.0)<0.0001) result|=2;
	return result;
}

int NSMaxGUISetWindowAppearance(void *handle,int mode){
	NSWindow *window=(NSWindow*)handle;
	if (!window || ![window isKindOfClass:[NSWindow class]]) return 0;
	NSAppearance *appearance=nil;
	if (mode==0) appearance=[NSAppearance appearanceNamed:NSAppearanceNameAqua];
	else if (mode==1) appearance=[NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
	else if (mode!=-1) return 0;
	[window setAppearance:appearance];
	[[window contentView] setNeedsDisplay:YES];
	[window displayIfNeeded];
	return 1;
}

int NSMaxGUIWindowAppearance(void *handle){
	NSWindow *window=(NSWindow*)handle;
	if (!window || ![window isKindOfClass:[NSWindow class]]) return -2;
	NSAppearance *appearance=[window appearance];
	if (!appearance) return -1;
	NSString *match=[appearance bestMatchFromAppearancesWithNames:[NSArray arrayWithObjects:NSAppearanceNameAqua,NSAppearanceNameDarkAqua,nil]];
	if ([match isEqualToString:NSAppearanceNameAqua]) return 0;
	if ([match isEqualToString:NSAppearanceNameDarkAqua]) return 1;
	return -2;
}

int NSMaxGUIWindowCacheDisplay(void *handle){
	NSWindow *window=(NSWindow*)handle;
	if (!window || ![window isKindOfClass:[NSWindow class]]) return 0;
	NSView *content=[window contentView];
	NSRect bounds=[content bounds];
	if (NSIsEmptyRect(bounds)) return 0;
	NSBitmapImageRep *bitmap=[content bitmapImageRepForCachingDisplayInRect:bounds];
	if (!bitmap) return 0;
	[content cacheDisplayInRect:bounds toBitmapImageRep:bitmap];
	return [bitmap pixelsWide]>0 && [bitmap pixelsHigh]>0 ? 1 : 0;
}

static NSData *MaxGUIWindowPNGData(NSWindow *window){
	NSView *content=[window contentView];
	NSRect bounds=[content bounds];
	if (NSIsEmptyRect(bounds)) return nil;
	[content layoutSubtreeIfNeeded];
	[content setNeedsDisplay:YES];
	[content displayIfNeededIgnoringOpacity];
	NSBitmapImageRep *bitmap=[content bitmapImageRepForCachingDisplayInRect:bounds];
	if (!bitmap) return nil;
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap]];
	[[window backgroundColor] setFill];
	NSRectFill(bounds);
	[NSGraphicsContext restoreGraphicsState];
	[content cacheDisplayInRect:bounds toBitmapImageRep:bitmap];
	return [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:[NSDictionary dictionary]];
}

int NSMaxGUIWindowWritePNG(void *handle,BBString *patharg){
	NSWindow *window=(NSWindow*)handle;
	if (!window || ![window isKindOfClass:[NSWindow class]] || !patharg) return 0;
	NSString *path=NSStringFromBBString(patharg);
	if (@available(macOS 11.0,*)){
		__block BOOL written=NO;
		[[window effectiveAppearance] performAsCurrentDrawingAppearance:^{
			written=[MaxGUIWindowPNGData(window) writeToFile:path atomically:YES];
		}];
		return written ? 1 : 0;
	}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	NSAppearance *previous=[NSAppearance currentAppearance];
	[NSAppearance setCurrentAppearance:[window effectiveAppearance]];
	BOOL written=[MaxGUIWindowPNGData(window) writeToFile:path atomically:YES];
	[NSAppearance setCurrentAppearance:previous];
#pragma clang diagnostic pop
	return written ? 1 : 0;
}

int NSMaxGUIBackgroundState(void *handle,int gadgetClass){
	if (!handle) return -1;
	NSColor *color=nil;
	NSColor *semantic=nil;
	BOOL drawsBackground=NO;
	BOOL secondaryDrawsBackground=NO;
	switch (gadgetClass){
		case GADGET_BUTTON:{
			if (![(id)handle isKindOfClass:[NSButton class]]) return -1;
			color=[[(NSButton*)handle cell] backgroundColor];
			break;
		}
		case GADGET_WINDOW:
			if (![(id)handle isKindOfClass:[NSWindow class]]) return -1;
			color=[(NSWindow*)handle backgroundColor];
			semantic=[NSColor windowBackgroundColor];
			drawsBackground=[(NSWindow*)handle isOpaque];
			break;
		case GADGET_LABEL:
		case GADGET_COMBOBOX:
		case GADGET_TEXTFIELD:
			if (![(id)handle isKindOfClass:[NSTextField class]]) return -1;
			color=[(NSTextField*)handle backgroundColor];
			semantic=[NSColor textBackgroundColor];
			drawsBackground=[(NSTextField*)handle drawsBackground];
			break;
		case GADGET_LISTBOX:{
			if (![(id)handle isKindOfClass:[ListView class]]) return -1;
			NSTableView *table=[(ListView*)handle table];
			color=[table backgroundColor];
			semantic=[NSColor controlBackgroundColor];
			drawsBackground=YES;
			break;
		}
		case GADGET_TREEVIEW:{
			if (![(id)handle isKindOfClass:[TreeView class]]) return -1;
			NSOutlineView *outline=((TreeView*)handle)->outline;
			color=[outline backgroundColor];
			semantic=[NSColor controlBackgroundColor];
			drawsBackground=YES;
			break;
		}
		case GADGET_TEXTAREA:{
			if (![(id)handle isKindOfClass:[TextView class]]) return -1;
			TextView *textView=(TextView*)handle;
			color=[textView backgroundColor];
			semantic=[NSColor textBackgroundColor];
			drawsBackground=[textView drawsBackground];
			secondaryDrawsBackground=[[textView getScroll] drawsBackground];
			break;
		}
		case GADGET_PANEL:{
			if (![(id)handle isKindOfClass:[PanelView class]]) return -1;
			return [[(PanelView*)handle contentView] hasColor] ? 1 : 0;
		}
		default:
			return -1;
	}
	int result=color ? 1 : 0;
	if (drawsBackground) result|=2;
	if (color && semantic && [color isEqual:semantic]) result|=4;
	if (secondaryDrawsBackground) result|=8;
	return result;
}

int NSMaxGUIWindowStatusPresentation(void *handle){
	id window=(id)handle;
	if (![window isKindOfClass:[WindowView class]] && ![window isKindOfClass:[ToolView class]]) return 0;
	NSArray *expected=[NSArray arrayWithObjects:@"left",@"center",@"right",nil];
	NSTextAlignment alignments[3]={NSTextAlignmentLeft,NSTextAlignmentCenter,NSTextAlignmentRight};
	BOOL modern=YES;
	BOOL text=YES;
	BOOL alignment=YES;
	BOOL behavior=YES;
	BOOL semantic=YES;
	BOOL geometry=YES;
	NSView *root=[window contentView];
	for (NSInteger i=0;i<3;i++){
		id statusLabel=[window statusLabelAtIndex:i];
		if (![statusLabel isKindOfClass:[NSTextField class]]) modern=NO;
		NSString *value=[statusLabel respondsToSelector:@selector(stringValue)] ? [statusLabel stringValue] : [statusLabel string];
		if (![value isEqualToString:[expected objectAtIndex:i]]) text=NO;
		if ([statusLabel alignment]!=alignments[i]) alignment=NO;
		if ([statusLabel drawsBackground] || [statusLabel isEditable] || [statusLabel isSelectable]) behavior=NO;
		if (![[statusLabel textColor] isEqual:[NSColor secondaryLabelColor]]) semantic=NO;
		if (!NSContainsRect([root bounds],[statusLabel frame])) geometry=NO;
	}
	int result=modern ? 1 : 0;
	if (text) result|=2;
	if (alignment) result|=4;
	if (behavior) result|=8;
	if (semantic) result|=16;
	if (geometry) result|=32;
	return result;
}

int NSMaxGUIToolbarPresentation(void *toolbarHandle,void *windowHandle,int width,int height){
	if (!toolbarHandle || ![(id)toolbarHandle isKindOfClass:[Toolbar class]]) return 0;
	if (!windowHandle || (![(id)windowHandle isKindOfClass:[WindowView class]] && ![(id)windowHandle isKindOfClass:[ToolView class]])) return 0;
	Toolbar *toolbar=(Toolbar*)toolbarHandle;
	NSWindow *window=(NSWindow*)windowHandle;
	int result=[toolbar sizeMode]!=NSToolbarSizeModeSmall ? 1 : 0;
	if ([toolbar displayMode]==NSToolbarDisplayModeIconOnly) result|=2;
	if ([window toolbar]==toolbar) result|=4;
	BOOL expanded=YES;
	if (@available(macOS 11.0,*)) expanded=[window toolbarStyle]==NSWindowToolbarStyleExpanded;
	if (expanded) result|=8;
	if ([toolbar isVisible]) result|=16;
	NSView *client=[window isKindOfClass:[ToolView class]] ? [(ToolView*)window clientView] : [(WindowView*)window clientView];
	NSSize clientSize=[client frame].size;
	if (fabs(clientSize.width-width)<0.0001 && fabs(clientSize.height-height)<0.0001) result|=32;
	return result;
}

int NSMaxGUIEmitMouseMovedForTest(void *handle){
	void *peer=NSPeerForNativeHandle(handle);
	NSView *view=(NSView*)(peer ? NSPeerClientView(peer) : handle);
	if (!view || ![(id)view isKindOfClass:[NSView class]]) return 0;
	CGEventRef cgEvent=CGEventCreateMouseEvent(NULL,kCGEventMouseMoved,CGPointMake(0,0),kCGMouseButtonLeft);
	if (!cgEvent) return 0;
	NSEvent *event=[NSEvent eventWithCGEvent:cgEvent];
	int result=event ? EmitMouseEvent(event,view) : 0;
	CFRelease(cgEvent);
	return result;
}

int NSMaxGUIWindowUserRect(void *handle,int x,int y,int width,int height){
	NSWindow *window=(NSWindow*)handle;
	if (!window || ![window isKindOfClass:[WindowView class]]) return 0;
	void *peer=NSPeerForNativeHandle(handle);
	if (!peer) return 0;
	int style=NSPeerGadgetStyle(peer);
	NSRect rect=NSMakeRect(x,y,width,height);
	NSRect visible=[[NSScreen deepestScreen] visibleFrame];
	rect.origin.x+=visible.origin.x;
	rect.origin.y=visible.origin.y+visible.size.height-rect.origin.y-rect.size.height;
	if (style&WINDOW_CLIENTCOORDS){
		if (style&WINDOW_STATUS){
			rect.origin.y-=STATUSBARHEIGHT;
			rect.size.height+=STATUSBARHEIGHT;
		}
		rect=[window frameRectForContentRect:rect];
	}
	[window setFrame:rect display:NO];
	return 1;
}

int NSMaxGUIWindowActivateAction(void *handle){
	NSWindow *window=(NSWindow*)handle;
	if (!window || ![window isKindOfClass:[NSWindow class]]) return 0;
	[GlobalApp windowDidBecomeKey:[NSNotification notificationWithName:NSWindowDidBecomeKeyNotification object:window]];
	return 1;
}

int NSMaxGUIWindowCloseAction(void *handle){
	NSWindow *window=(NSWindow*)handle;
	if (!window || ![window isKindOfClass:[NSWindow class]]) return 0;
	return [GlobalApp windowShouldClose:window] ? 0 : 1;
}

int NSMaxGUIWindowFileDropAction(void *handle,BBString *patharg,int x,int y){
	NSWindow *window=(NSWindow*)handle;
	if (!window || ![window isKindOfClass:[NSWindow class]]) return 0;
	PostGuiEvent(BBEVENT_WINDOWACCEPT,window,0,0,x,y,(BBObject*)patharg);
	return 1;
}

int NSMaxGUITextFieldEditAction(void *handle,BBString *textarg){
	NSTextField *field=(NSTextField*)handle;
	if (!field || ![field isKindOfClass:[NSTextField class]] || ![field isEditable]) return 0;
	[field setStringValue:NSStringFromBBString(textarg)];
	[GlobalApp controlTextDidChange:[NSNotification notificationWithName:NSControlTextDidChangeNotification object:field]];
	return 1;
}

int NSMaxGUITextFieldEndEditingAction(void *handle){
	NSTextField *field=(NSTextField*)handle;
	if (!field || ![field isKindOfClass:[NSTextField class]]) return 0;
	[GlobalApp controlTextDidEndEditing:[NSNotification notificationWithName:NSControlTextDidEndEditingNotification object:field]];
	return 1;
}

int NSMaxGUIFilterAction(void *handle,int key,int mods,int character){
	void *peer=NSPeerForNativeHandle(handle);
	if (!peer) return 0;
	if (character) return maxgui_cocoamaxgui_cocoagui_FilterChar(peer,key,mods);
	return maxgui_cocoamaxgui_cocoagui_FilterKeyDown(peer,key,mods);
}

int NSMaxGUITextAreaReplaceSelectionAction(void *handle,BBString *textarg){
	TextView *textView=(TextView*)handle;
	if (!textView || ![textView isKindOfClass:[TextView class]] || ![textView isEditable]) return 0;
	NSRange range=[textView selectedRange];
	if (NSMaxRange(range)>[[textView string] length]) return 0;
	if ([textView window]) [[textView window] makeFirstResponder:textView];
	[textView insertText:NSStringFromBBString(textarg) replacementRange:range];
	return 1;
}

int NSMaxGUITextAreaSelectionAction(void *handle,int location,int length){
	TextView *textView=(TextView*)handle;
	if (!textView || ![textView isKindOfClass:[TextView class]]) return 0;
	if (location<0 || length<0 || (NSUInteger)location>[[textView string] length] || (NSUInteger)length>[[textView string] length]-(NSUInteger)location) return 0;
	[textView setSelectedRange:NSMakeRange((NSUInteger)location,(NSUInteger)length)];
	return 1;
}

int NSMaxGUITreeSelectionAction(void *handle,int index){
	TreeView *treeView=(TreeView*)handle;
	if (!treeView || ![treeView isKindOfClass:[TreeView class]]) return 0;
	return [treeView performUserSelectionAtIndex:index] ? 1 : 0;
}

int NSMaxGUITreeExpansionAction(void *handle,int index,int expand){
	TreeView *treeView=(TreeView*)handle;
	if (!treeView || ![treeView isKindOfClass:[TreeView class]]) return 0;
	return [treeView performUserExpansionAtIndex:index expand:expand ? YES : NO] ? 1 : 0;
}

int NSMaxGUITreeExpanded(void *handle,int index){
	TreeView *treeView=(TreeView*)handle;
	if (!treeView || ![treeView isKindOfClass:[TreeView class]]) return 0;
	return [treeView isItemExpandedAtIndex:index] ? 1 : 0;
}

int NSMaxGUITreeVisibleRowCount(void *handle){
	TreeView *treeView=(TreeView*)handle;
	if (!treeView || ![treeView isKindOfClass:[TreeView class]]) return -1;
	return (int)[treeView->outline numberOfRows];
}

int NSMaxGUITreeRowPresentation(void *handle){
	TreeView *treeView=(TreeView*)handle;
	if (!treeView || ![treeView isKindOfClass:[TreeView class]]) return 0;
	NSOutlineView *outlineView=treeView->outline;
	[outlineView layoutSubtreeIfNeeded];
	NSInteger rowCount=[outlineView numberOfRows];
	for (NSView *view in [outlineView subviews]){
		if (![view isKindOfClass:[NSTableRowView class]] || [view isHidden]) continue;
		NSInteger row=[outlineView rowForView:view];
		if (row<0 || row>=rowCount) return 0;
	}
	return 1;
}

int NSMaxGUITreeDragHooks(void *handle){
	TreeView *treeView=(TreeView*)handle;
	if (!treeView || ![treeView isKindOfClass:[TreeView class]]) return 0;
	OutlineView *outlineView=(OutlineView*)treeView->outline;
	if (![outlineView isKindOfClass:[OutlineView class]]) return 0;
	return [outlineView respondsToSelector:@selector(mouseDragged:)] && [outlineView respondsToSelector:@selector(rightMouseDragged:)] && [outlineView respondsToSelector:@selector(otherMouseDragged:)] ? 1 : 0;
}

int NSMaxGUITreeDragAction(void *handle,int index,int button,int mods,int x,int y){
	TreeView *treeView=(TreeView*)handle;
	if (!treeView || ![treeView isKindOfClass:[TreeView class]]) return 0;
	void *treePeer=NSPeerForNativeHandle(handle);
	if (!treePeer || !(NSPeerGadgetStyle(treePeer)&TREEVIEW_DRAGNDROP)) return 0;
	if (index<0 || index>=[treeView->outline numberOfRows]) return 0;
	id node=[treeView->outline itemAtRow:index];
	return maxgui_cocoamaxgui_cocoagui_PostCocoaTreeDragEvent(treePeer,node,button,mods,x,y);
}

int NSMaxGUIGadgetDropAction(void *handle,int button,int mods,int x,int y){
	void *targetPeer=NSPeerForNativeHandle(handle);
	if (!targetPeer) return 0;
	return maxgui_cocoamaxgui_cocoagui_PostCocoaGadgetDropEvent(targetPeer,button,mods,x,y);
}

int NSMaxGUICancelDragAction(int button){
	return maxgui_cocoamaxgui_cocoagui_CancelCocoaGadgetDrag(button);
}

@class color_delegate;
@interface color_delegate:NSObject <NSWindowDelegate>{}
@end
@implementation color_delegate
- (void)windowWillClose:(NSNotification *)aNotification{[NSApp stopModal];}
@end

int NSColorRequester(int r,int g,int b){
	NSColorPanel	*panel;
	NSColor			*color;
	color_delegate	*dele;
	dele=[[color_delegate alloc] init];
	color=MaxGUIRGBColor(r,g,b);
	panel=[NSColorPanel sharedColorPanel];
	[panel setColor:color];
	[panel setDelegate:dele];
	[NSApp runModalForWindow:panel];
	color=[panel color];
	if (color){
		color=[color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
		r=(int)((255*[color redComponent])+0.5);
		g=(int)((255*[color greenComponent])+0.5);
		b=(int)((255*[color blueComponent])+0.5);
	}
	[panel setDelegate:nil];
	[dele release];
	return 0xff000000|(r<<16)|(g<<8)|b;
}

@class font_delegate;
@interface font_delegate:NSObject <NSWindowDelegate>{
	NSFont		*_font;
}
-(id)initWithFont:(NSFont*)font;
-(void)changeFont:(id)sender;
-(id)font;
-(void)windowWillClose:(NSNotification *)aNotification;
-(unsigned int)validModesForFontPanel:(NSFontPanel *)fontPanel;
-(void)dealloc;
@end
@implementation font_delegate
-(id)initWithFont:(NSFont*)font{
	self=[super init];
	if (self) _font=[font retain];
	return self;
}
-(id)font{
	return _font;
}
-(void)changeFont:(id)sender{
	NSFont *font=[sender convertFont:_font];
	if (font!=_font){
		[font retain];
		[_font release];
		_font=font;
	}
	return; 
}
-(void)dealloc{
	[_font release];
	[super dealloc];
}
- (void)windowWillClose:(NSNotification *)aNotification{
	[NSApp stopModal];
}
-(unsigned int)validModesForFontPanel:(NSFontPanel *)fontPanel{
	return NSFontPanelFaceModeMask|NSFontPanelSizeModeMask|NSFontPanelCollectionModeMask;//|NSFontPanelUnderlineEffectModeMask;
}
@end

int NSGetSysColor( int colorindex, int* red, int* green, int* blue ){
	
	CGFloat r, g, b;
	NSColor* c;
	NSWindow* w;
	
	switch(colorindex){
		case GUICOLOR_WINDOWBG:
			w = [[NSWindow alloc] initWithContentRect:NSZeroRect styleMask:NSWindowStyleMaskTitled backing:NSBackingStoreBuffered defer:YES];
			c = [w backgroundColor];
			[w release];
			break;
		case GUICOLOR_GADGETBG:
			c = [NSColor controlBackgroundColor];
			break;
		case GUICOLOR_GADGETFG:
			c = [NSColor controlTextColor];
			break;
		case GUICOLOR_SELECTIONBG:
			c = [NSColor selectedTextBackgroundColor];
			break;
		default:
			return 0;
			break;
	}
	
	[[c colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]] getRed:&r green:&g blue:&b alpha:NULL];
	*red = (int)(255 * r);
	*green = (int)(255 * g);
	*blue = (int)(255 * b);
	
	return 1;
}

NSFont *NSRequestFont(NSFont *font){
	NSFontPanel		*panel;
	font_delegate		*dele;
	BOOL hadInput=font!=nil;
	if (!font) font=[NSFont userFontOfSize:0];
	dele=[[font_delegate alloc] initWithFont:font];
	panel=[NSFontPanel sharedFontPanel];
	if (font) [panel setPanelFont:font isMultiple:NO];
	[panel setEnabled:YES];
	[panel setDelegate:dele];
	[NSApp runModalForWindow:panel];
	NSFont *result=[dele font];
	if (!hadInput || result!=font) [result retain];
	[panel setDelegate:nil];
	[dele release];
	return result;
}

NSFont *NSLoadFont(BBString *name,double size,int flags){
	NSString			*text;
	NSFont				*font;
	NSFontManager		*manager;

	text=NSStringFromBBString(name);
	font=[NSFont fontWithName:text size:size];
	if (!font) font=[NSFont systemFontOfSize:size];
	if (flags){
		manager=[NSFontManager sharedFontManager];
		if (flags&FONT_BOLD) font=[manager convertFont:font toHaveTrait:NSBoldFontMask];
		if (flags&FONT_ITALIC) font=[manager convertFont:font toHaveTrait:NSItalicFontMask];
	}
	[font retain];
	return font;
}

NSFont *NSGetDefaultFont(){
	return [NSFont systemFontOfSize:[NSFont systemFontSize]];
}

BBString *NSFontName(NSFont *font){
	return bbStringFromNSString([font displayName]);	
}

int NSFontStyle(NSFont *font){
	int	intBBStyleFlags;
	int	intCocoaFontTraits;
	NSFontManager *manager;
	
	manager = [NSFontManager sharedFontManager];
	intCocoaFontTraits = [manager traitsOfFont: font];
	
	intBBStyleFlags = 0;
	if (intCocoaFontTraits & NSBoldFontMask) intBBStyleFlags|=FONT_BOLD;
	if (intCocoaFontTraits & NSItalicFontMask) intBBStyleFlags|=FONT_ITALIC;
	
	return intBBStyleFlags;
}

double NSFontSize(NSFont *font){
	return (double)[font pointSize];
}

void* NSSuperview(NSView* handle){
	if(handle) return [handle superview];
	return 0;
}

// generic gadget commands

void NSPeerFreeGadget(void *peer){
	int gadgetClass=NSPeerGadgetClass(peer);
	int gadgetStyle=NSPeerGadgetStyle(peer);
	id handle=NSPeerNativeHandle(peer);
	NSView *view=NSPeerClientView(peer);
	TextView *textview;
	FlippedView *flipped;
	if (handle){
		switch (gadgetClass){
		case GADGET_WINDOW:
			if ([handle parentWindow]!=nil){
				[[handle parentWindow] removeChildWindow:(NSWindow*)handle];
			}			
			[handle close];
			break;
		case GADGET_NODE:
			[handle remove];
			break;
		case GADGET_MENUITEM:
			MaxGUIPrepareMenuItemForFree((NSMenuItem*)handle);
			[[handle menu] removeItem:handle];
			[GlobalApp removeMenuItem:handle];
			break;
		case GADGET_TEXTAREA:
			textview=(TextView*)handle;
			[view removeFromSuperview];
			[textview free];
			[textview autorelease];
			break;
		case GADGET_LABEL:
			switch (gadgetStyle&3) {
			case LABEL_SEPARATOR:
				flipped=(FlippedView*)view;
				[flipped removeFromSuperview];
				[handle removeFromSuperview];
				[flipped release];
				break;
			default:
				[view removeFromSuperview];
				break;
			}
			[handle autorelease];
			break;
		case GADGET_TABBER:
			flipped=(FlippedView*)view;
			[handle setDelegate:nil];
			[flipped removeFromSuperview];
			[handle removeFromSuperview];
			// Cocoa throws an exception if items exist when handle is autoreleased.
			[(TabView*)handle removeAllItemsForFree];
			[handle autorelease];
			break;
		case GADGET_TOOLBAR:
			if ([[view window] toolbar]==handle) [[view window] setToolbar:nil];
			[handle setDelegate:nil];
			[handle autorelease];
			break;
		case GADGET_PANEL:
			[(PanelView*)handle setColor:nil];
			[handle removeFromSuperview];
			[handle release];
			break;
		case GADGET_CANVAS:
			[handle removeFromSuperview];
			[handle autorelease];
			break;
		case GADGET_TEXTFIELD:
		case GADGET_COMBOBOX:
			[NSObject cancelPreviousPerformRequestsWithTarget:[CocoaApp class] selector:@selector(delayedGadgetAction:) object:handle];
			[handle setDelegate:nil];
			[[view superview] setNeedsDisplayInRect:[view frame]];
			[view removeFromSuperview];
			[handle autorelease];
			break;
		default:
			[[view superview] setNeedsDisplayInRect:[view frame]];
			[view removeFromSuperview];
			[handle autorelease];
			break;
		}	
	}
	NSPeerSetNativeObjects(peer,0,0);
}

void NSPeerSetEnabled(void *peer,int state){
	id handle=NSPeerNativeHandle(peer);
	switch (NSPeerGadgetClass(peer)){
	case GADGET_WINDOW:
	case GADGET_SLIDER:
	case GADGET_TEXTFIELD:
	case GADGET_MENUITEM:
	case GADGET_BUTTON:
	case GADGET_LISTBOX:
	case GADGET_COMBOBOX:
	case GADGET_TREEVIEW:
	case GADGET_TABBER:
	case GADGET_PANEL:
	case GADGET_CANVAS:
		[handle setEnabled:state];
		break;
	case GADGET_TEXTAREA:
		[handle setSelectable:state];
		if (!(NSPeerGadgetStyle(peer)&TEXTAREA_READONLY)) [handle setEditable:state];
		break;
	}
}

void NSPeerSetShown(void *peer,int state){
	id handle=NSPeerNativeHandle(peer);
	switch (NSPeerGadgetClass(peer)){
	case GADGET_WINDOW:
		if (state==[handle isVisible]) return;
		if (state) {
			void *parentPeer=NSPeerParent(peer);
			if(parentPeer && (NSPeerGadgetClass(parentPeer)==GADGET_WINDOW) &&
			([handle parentWindow]==nil)) [(NSWindow*)NSPeerNativeHandle(parentPeer) addChildWindow:handle ordered:NSWindowAbove];
			[handle makeKeyAndOrderFront:NSApp];
		} else {
			if([handle parentWindow]!=nil) [[handle parentWindow] removeChildWindow:(NSWindow*)handle];
			[handle orderOut:NSApp];
		}
		break;
	case GADGET_TOOLBAR:
		[handle setVisible:state];
		break;
	default:
		[handle setHidden:!state];
	}
}

void NSPeerSetChecked(void *peer,int state){
	NSButton			*button;
	id handle=NSPeerNativeHandle(peer);
	switch (NSPeerGadgetClass(peer)){
	case GADGET_MENUITEM:
		[handle setState:state];
		break;
	case GADGET_BUTTON:
		button=(NSButton *)handle;
		if(state==NSControlStateValueMixed) [button setAllowsMixedState:YES]; else [button setAllowsMixedState:NO];
		[button setState:state];
		break; 
	}
}

void NSPeerPopupMenu(void *peer,void *menuPeer){
	NSView			*view;
	NSWindow			*window;
	NSMenuItem		*menuitem;
	NSEvent			*event;
	NSPoint			loc;
	
	window=(NSWindow*)NSPeerNativeHandle(peer);
	view=NSPeerClientView(peer);
	menuitem=(NSMenuItem*)NSPeerNativeHandle(menuPeer);
	if (![menuitem submenu]) return;
	event=[NSEvent 
		mouseEventWithType:NSEventTypeRightMouseUp
		location:[window convertPointFromScreen:[NSEvent mouseLocation]]
		modifierFlags:0
		timestamp:0 
		windowNumber:[window windowNumber] 
     	context:nil
		eventNumber:0
		clickCount:1 
		pressure:0];
	[NSMenu popUpContextMenu:[menuitem submenu] withEvent:event forView:view];		
//	[event release];
}

int NSPeerState(void *peer){
	NSWindow		*window;
	TextView		*textview;
	NSButton		*button;
	NSView		*view;
	Toolbar		*toolbar;
	HTMLView		*browser;
	NSMenuItem 	*menuItem;
	int			state;
	id handle=NSPeerNativeHandle(peer);
	int gadgetStyle=NSPeerGadgetStyle(peer);

	state=0;

	switch (NSPeerGadgetClass(peer)){
	case GADGET_TEXTAREA:
		textview=(TextView*)handle;
		if ([textview isHidden]) state|=STATE_HIDDEN;
		if ((!(gadgetStyle&TEXTAREA_READONLY)) && (![textview isEditable])) state|=STATE_DISABLED;
		break;
	case GADGET_HTMLVIEW:
		browser=(HTMLView*)handle;
		return [browser loaded];
	case GADGET_WINDOW:
		window=(NSWindow*)handle;
		if ([window isMiniaturized]) state|=STATE_MINIMIZED;
		if ([window isZoomed]) state|=STATE_MAXIMIZED;
		if (![window isVisible]) state|=STATE_HIDDEN;
		break;
	case GADGET_MENUITEM:
		menuItem=(NSMenuItem*)handle;
		if ([menuItem state]==NSControlStateValueOn) state|=STATE_SELECTED;
		if (![menuItem isEnabled]) state|=STATE_DISABLED;
		break;
	case GADGET_BUTTON:
		button=(NSButton *)handle;
		switch (gadgetStyle&7){
			case BUTTON_RADIO: case BUTTON_CHECKBOX:
			if ([button state]==NSControlStateValueOn) state|=STATE_SELECTED;
			if ([button state]==NSControlStateValueMixed) state|=STATE_INDETERMINATE;
		}
		if ([button isHidden]) state|=STATE_HIDDEN;
		if (![button isEnabled]) state|=STATE_DISABLED;
		break;
	case GADGET_TOOLBAR:
		toolbar=(Toolbar*)handle;
		if ([toolbar isVisible]==NO) state|=STATE_HIDDEN;
		break;		
	case GADGET_PROGBAR:
		view=(NSView*)handle;
		if ([view isHidden]) state|=STATE_HIDDEN;
		break;
	default:
		view=(NSView*)handle;
		if ([view isHidden]) state|=STATE_HIDDEN;
		if ([view respondsToSelector:@selector(isEnabled)] && ![(id)view isEnabled]) state|=STATE_DISABLED;
		break;
	}
	return state;
}

void NSPeerSetMinimumSize(void *peer,int width,int height){
	NSWindow	*window;
	NSRect	rect;
	int		style;
	window=(NSWindow*)NSPeerNativeHandle(peer);
	rect.origin.x=0;
	rect.origin.y=0;
	rect.size.width=width;
	rect.size.height=height;
	style=NSPeerGadgetStyle(peer);
	if (!(style&WINDOW_CLIENTCOORDS)){
		rect=[window contentRectForFrameRect:rect];
		rect.size.width-=rect.origin.x;
		rect.size.height-=rect.origin.y;
	}else{
		if (style&WINDOW_STATUS) rect.size.height+=STATUSBARHEIGHT;		
	}
	[window setContentMinSize:rect.size];
}

void NSPeerSetMaximumSize(void *peer,int width,int height){
	NSWindow	*window;
	NSRect	rect;
	int		style;
	window=(NSWindow*)NSPeerNativeHandle(peer);
	rect.origin.x=0;
	rect.origin.y=0;
	rect.size.width=width;
	rect.size.height=height;
	style=NSPeerGadgetStyle(peer);
	if (!(style&WINDOW_CLIENTCOORDS)){
		rect=[window contentRectForFrameRect:rect];
		rect.size.width-=rect.origin.x;
		rect.size.height-=rect.origin.y;
	}else{
		if (style&WINDOW_STATUS) rect.size.height+=STATUSBARHEIGHT;		
	}
	[window setContentMaxSize:rect.size];
}


void NSPeerSetStatus(void *peer,BBString *data,int pos){
	NSString			*text;
	WindowView			*window;
	ToolView			*toolview;

	text=NSStringFromBBString(data);
	if ((NSPeerGadgetStyle(peer)&WINDOW_TOOL) == 0) {
		window=(WindowView*)NSPeerNativeHandle(peer);
		[window setStatus:text align:pos];
	} else {
		toolview =(ToolView*)NSPeerNativeHandle(peer);
		[toolview setStatus:text align:pos];
	}
}

int NSPeerClientWidth(void *peer,int fallbackWidth){
	NSRect		frame;	
	if (NSPeerGadgetClass(peer)==GADGET_DESKTOP){
		frame=[[NSScreen deepestScreen] visibleFrame];
		return frame.size.width;
	}
	NSView *view=NSPeerClientView(peer);
	if (!view) return fallbackWidth;
	frame=[view frame];
	return frame.size.width;
}

int NSPeerClientHeight(void *peer,int fallbackHeight){
	NSRect		frame;
	if (NSPeerGadgetClass(peer)==GADGET_DESKTOP){
		frame=[[NSScreen deepestScreen] visibleFrame];
		return frame.size.height;
	}
	NSView *view=NSPeerClientView(peer);
	if (!view) return fallbackHeight;
	frame=[view frame];
	return frame.size.height;
}

static void NSPeerRedraw(void *peer){
	NSView	*view;
	
	view=(NSView*)NSPeerNativeHandle(peer);
	[view display];	//Can just call the display method
}

void NSPeerActivate(void *peer,int code){
	NSWindow	*window;
	NSView		*view;
	NSRect		frame;
	NodeItem	*node;
	TreeView	*treeview;
	HTMLView	*browser;
	TextView	*textview;
	NSTextField *textfield;
	NSText *text;
	NSComboBox *combo;
	id handle=NSPeerNativeHandle(peer);

// generic commands

	switch (code){
	case ACTIVATE_REDRAW:
		NSPeerRedraw(peer);
		return;
	}
	
// gadget specific	

	switch (NSPeerGadgetClass(peer)){
	case GADGET_WINDOW:
		window=(NSWindow*)handle;
		switch (code){
		case ACTIVATE_FOCUS:
			if([window isVisible]) [window makeKeyAndOrderFront:NSApp];		
			break;
		case ACTIVATE_CUT:
			break;
		case ACTIVATE_COPY:
			break;
		case ACTIVATE_PASTE:
			break;
		case ACTIVATE_MINIMIZE:
			NSPeerSetShown(peer,true);
			[window miniaturize:window];
			break;
		case ACTIVATE_MAXIMIZE:
			if ([window isMiniaturized]) [window deminiaturize:window];
			if ([window isZoomed]==NO) [window performZoom:window];
			NSPeerSetShown(peer,true);
			break;
		case ACTIVATE_RESTORE:
			if ([window isMiniaturized]) [window deminiaturize:window];
			if ([window isZoomed]) [window performZoom:window];
			NSPeerSetShown(peer,true);
			break;
		}
		break;

	case GADGET_TEXTFIELD:
		textfield=(NSTextField*)handle;
		window=[textfield window];
		if (window) 
		switch (code){
		case ACTIVATE_FOCUS:
			[window makeFirstResponder:textfield];
			break;
		case ACTIVATE_CUT:
			text=[[textfield window] fieldEditor:YES forObject:textfield];
			[text cut:textfield];
			break;	
		case ACTIVATE_COPY:
			text=[[textfield window] fieldEditor:YES forObject:textfield];
			[text copy:textfield];
			break;	
		case ACTIVATE_PASTE:
			text=[[textfield window] fieldEditor:YES forObject:textfield];
			[text paste:textfield];
			break;
		}
		break;

	case GADGET_TEXTAREA:
		textview=(TextView*)handle;
		switch (code){
		case ACTIVATE_FOCUS:
			window=[textview window];
			if (window) [window makeFirstResponder:textview];
			break;
		case ACTIVATE_CUT:
			[textview cut:textview];
			break;	
		case ACTIVATE_COPY:
			[textview copy:textview];
			break;	
		case ACTIVATE_PASTE:
			[textview pasteAsPlainText:textview];//paste:textview];
			break;		
		case ACTIVATE_PRINT:
			[textview print:textview];
			break;
		}
		break;

	case GADGET_NODE:
		node=(NodeItem*)handle;
		treeview=[node getOwner];
		switch (code){	
		case ACTIVATE_SELECT:
			[treeview selectNode:node];			
			break;
		case ACTIVATE_EXPAND:
			[treeview expandNode:node];
			break;
		case ACTIVATE_COLLAPSE:
			[treeview collapseNode:node];
			break;
		}
		break;
				
	case GADGET_COMBOBOX:
		switch (code){
		case ACTIVATE_FOCUS:
			combo=(NSComboBox*)handle;
			[combo selectText:nil];
			break;	
		}
		break;

	case GADGET_HTMLVIEW:
		browser=(HTMLView*)handle;
		switch(code){
		case ACTIVATE_COPY:
			[browser copy:browser];
			break;	
		case ACTIVATE_BACK:
			[browser goBack:browser];
			break;
		case ACTIVATE_FORWARD:
			[browser goForward:browser];
			break;
		case ACTIVATE_PRINT:
			view = [[[browser mainFrame] frameView] documentView];
			if (view != nil) [view print:view];
			break;
		}
						
	default:
		switch (code){
		case ACTIVATE_FOCUS:
			window=[handle window];
			if (window) [window makeFirstResponder:handle];
			break;
		}
	}
}

void NSPeerRethink(void *peer,int x,int y,int width,int height){
	NSView		*view;
	NSWindow		*window;
	NSRect		rect,vis;
	TextView	*textview;
	TabView		*tabber;
	NSButton		*button;
	NSComboBox 	*combobox;
	int			shouldhide;
	
	int gadgetClass=NSPeerGadgetClass(peer);
	int gadgetStyle=NSPeerGadgetStyle(peer);
	view=(NSView*)NSPeerNativeHandle(peer);
	rect=NSMakeRect(x,y,width,height);
	
	shouldhide = FALSE;
	
	switch(gadgetClass){
	case GADGET_WINDOW:
		window=(NSWindow*)view;
		vis=[[NSScreen deepestScreen] visibleFrame];
		rect.origin.x+=vis.origin.x;
		rect.origin.y=vis.origin.y+vis.size.height-rect.origin.y-rect.size.height;
		if ((gadgetStyle&WINDOW_CLIENTCOORDS)!=0){
			if (gadgetStyle&WINDOW_STATUS) {
				rect.origin.y-=STATUSBARHEIGHT;		
				rect.size.height+=STATUSBARHEIGHT;		
			}
			rect = [window frameRectForContentRect:rect];
		}
		
		if(![window isVisible]) shouldhide = TRUE;
		[window setFrame:rect display:YES];
		if(shouldhide) [window orderOut:window];
		return;
	case GADGET_NODE:
	case GADGET_MENUITEM:
	case GADGET_TOOLBAR:
 		return;
	case GADGET_TEXTAREA:
		textview=(TextView*)view;
		[textview setScrollFrame:rect];
		return;
	case GADGET_COMBOBOX:
		if (rect.size.height > 26) rect.size.height = 26;
		break;
	case GADGET_BUTTON:
		button=(NSButton*)view;
		// Push Button Size Hack
		if ((gadgetStyle&7)==0){
			if (height > 30) {
				[button setBezelStyle:NSBezelStyleRegularSquare];
			} else {
				if (height < 24) {
					[button setBezelStyle:NSBezelStyleShadowlessSquare];
				} else {
					[button setBezelStyle:NSBezelStyleRounded];
				}
			}	
		}
		break;
	case GADGET_SLIDER:
		switch (gadgetStyle&12){
			case SLIDER_SCROLLBAR:
				if (gadgetStyle & SLIDER_HORIZONTAL)
					rect.size.height = MaxGUIScrollerWidth();
				else
					rect.size.width = MaxGUIScrollerWidth();
				break;
		}
	}
	[[view superview] setNeedsDisplayInRect:[view frame]];
	[view setFrame:rect];
	[view setNeedsDisplay:YES];	
}

void NSPeerRemoveColor(void *peer){
	int gadgetClass=NSPeerGadgetClass(peer);
	int gadgetStyle=NSPeerGadgetStyle(peer);
	id handle=NSPeerNativeHandle(peer);
	switch (gadgetClass){
	case GADGET_BUTTON:
		[[handle cell] setBackgroundColor:nil];
		break;
	case GADGET_WINDOW:
		[handle setBackgroundColor:[NSColor windowBackgroundColor]];
		[handle display];
		break;
	case GADGET_LABEL:
		if((gadgetStyle&3)==LABEL_SEPARATOR) break;
		[handle setBackgroundColor:[NSColor textBackgroundColor]];
		[handle setDrawsBackground:false];
		break;
	case GADGET_COMBOBOX:
	case GADGET_TEXTFIELD:
		[handle setBackgroundColor:[NSColor textBackgroundColor]];
		[handle setDrawsBackground:true];
		break;
	case GADGET_LISTBOX:
		[(ListView*)handle setColor:[NSColor controlBackgroundColor]];
		break;
	case GADGET_TREEVIEW:
		[(TreeView*)handle removeColor];
		break;
	case GADGET_PANEL:
		[(PanelView*)handle setColor:nil];
		break;
	case GADGET_TEXTAREA:
		[(TextView*)handle setColor:nil];
		break;	
	}
}

void NSPeerSetColor(void *peer,int r,int g,int b){
	NSColor				*color;
	int gadgetClass=NSPeerGadgetClass(peer);
	int gadgetStyle=NSPeerGadgetStyle(peer);
	id handle=NSPeerNativeHandle(peer);

	color=MaxGUIRGBColor(r,g,b);
	
	switch (gadgetClass){
	case GADGET_BUTTON:
		if ([[handle cell] respondsToSelector:@selector(setBackgroundColor)]) [[handle cell] setBackgroundColor:color];
		break;
	case GADGET_COMBOBOX:
	case GADGET_WINDOW:
		[handle setBackgroundColor:color];
		[handle display];
		break;
	case GADGET_LABEL:
		if((gadgetStyle&3)==LABEL_SEPARATOR) break;
		[handle setDrawsBackground:YES];
	case GADGET_TEXTFIELD:
		[handle setBackgroundColor:color];
		break;
	case GADGET_LISTBOX:
	case GADGET_PANEL:
	case GADGET_TEXTAREA:
		[handle setColor:color];
		break;	
	case GADGET_TREEVIEW:
		[(TreeView*)handle setExplicitColor:color appearance:MaxGUIAppearanceForRGBBackground(r,g,b)];
		break;
	}
}

void NSPeerSetAlpha(void *peer,float alpha){
	NSWindow	*window;
	PanelView	*panel;
	int gadgetClass=NSPeerGadgetClass(peer);
	id handle=NSPeerNativeHandle(peer);
	
	switch (gadgetClass){
	case GADGET_WINDOW:
		window=(NSWindow*)handle;
		[window setAlphaValue:alpha];
		break;		
	case GADGET_PANEL:
		panel=(PanelView*)handle;
		[panel setAlpha:alpha];
		break;	
	}
}

BBString *NSGetUserName(){
	return bbStringFromNSString(NSUserName());
}

BBString *NSGetComputerName(){
	NSString *name=[[NSHost currentHost] localizedName];
	return bbStringFromNSString(name ? name : @"");
}

BBString *NSPeerRun(void *peer,BBString *text){
	HTMLView			*htmlview;
	NSString			*script;
	BBString			*result;

	result=&bbEmptyString;
	switch (NSPeerGadgetClass(peer)){
	case GADGET_HTMLVIEW:
		htmlview=(HTMLView*)NSPeerNativeHandle(peer);
		script=NSStringFromBBString(text);
		script=[htmlview stringByEvaluatingJavaScriptFromString:script];
		result=bbStringFromNSString(script);
		break;
	}
	return result;
}

void NSPeerSetText(void *peer,BBString *data){
	NSString				*text;
	NSMutableDictionary	*textAttributes;
	NSMutableParagraphStyle *parastyle;
	NSAttributedString		*attribtext;
	id					nsobject;
	int gadgetClass=NSPeerGadgetClass(peer);
	int gadgetStyle=NSPeerGadgetStyle(peer);
	NSColor *textColor=NSPeerTextColor(peer);
	int fontStyle=NSPeerFontStyle(peer);
	
	attribtext = nil;
	
	if(data == nil) data = &bbEmptyString;
	
	text = NSStringFromBBString(data);
	
	nsobject = (NSObject*)NSPeerNativeHandle(peer);
	
	//printf( "data->length: %d\n", data->length );fflush(stdout);
	
	switch (gadgetClass){
	case GADGET_TEXTAREA:
		[(TextView*)nsobject setText:text];
		break;
	case GADGET_HTMLVIEW:
		[(HTMLView*)nsobject setAddress:text];
		break;
	case GADGET_LABEL: /* BaH */
		switch (gadgetStyle&3) {
		case LABEL_SEPARATOR:
			return;
		default:
			[(NSTextField*)nsobject setStringValue:text];
			return;
		}
		break;
	case GADGET_BUTTON:
		
		//if ([nsobject respondsToSelector:@selector(setAttributedTitle)] /*&& [nsobject respondsToSelector:@selector(font)]*/){
			
			// Create attribute dictionary (autorelease'd)
			textAttributes = [NSMutableDictionary dictionary];
			
			// Font
			[textAttributes setObject:[(NSButton*)nsobject font] forKey:NSFontAttributeName];
	
	 		// Paragraph style
			parastyle = [[NSMutableParagraphStyle alloc] init];
			[parastyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
			
			if(gadgetClass == GADGET_BUTTON){
				if(((gadgetStyle & BUTTON_PUSH) == BUTTON_PUSH) ||
				  (((gadgetStyle & 7) != BUTTON_RADIO) &&
				   ((gadgetStyle & 7) != BUTTON_CHECKBOX)))
					[parastyle setAlignment:NSTextAlignmentCenter];
			}
			
			[textAttributes setObject: parastyle forKey:NSParagraphStyleAttributeName];
			[parastyle release];
			
			// Text color
			if(textColor) [textAttributes setObject:textColor forKey:NSForegroundColorAttributeName];
			
			// Underline / strikethrough
			[textAttributes setObject: [NSNumber numberWithInt:0] forKey: NSUnderlineStyleAttributeName];
			[textAttributes setObject: [NSNumber numberWithInt:0] forKey: NSStrikethroughStyleAttributeName];
			
			if ((fontStyle&FONT_UNDERLINE)!=0) [textAttributes setObject: [NSNumber numberWithInt:(NSUnderlineStyleSingle|NSUnderlinePatternSolid)] forKey: NSUnderlineStyleAttributeName];
			if ((fontStyle&FONT_STRIKETHROUGH)!=0) [textAttributes setObject: [NSNumber numberWithInt:(NSUnderlineStyleSingle|NSUnderlinePatternSolid)] forKey: NSStrikethroughStyleAttributeName];
			
			// Create attibuted text
			attribtext = [[NSAttributedString alloc] initWithString: text attributes: textAttributes];
			
			[(NSButton*)nsobject setAttributedTitle:attribtext];
			[attribtext release];
			break;
		//}
	case GADGET_MENUITEM:
		[(NSMenuItem*)nsobject setTitle:text];
		// Required otherwise root window menus aren't updated.
		[[(NSMenuItem*)nsobject submenu] setTitle:text];
		MaxGUIReconcileMenuItemRole((NSMenuItem*)nsobject);
		break;
	case GADGET_PANEL:
		[(PanelView*)nsobject setTitle:text];
		break;
	case GADGET_NODE:
		[(NodeItem*)nsobject setTitle:text];
		break;
	case GADGET_WINDOW:
		[(NSWindow*)nsobject setTitle:text];
		break;
	case GADGET_COMBOBOX:
		if(!(gadgetStyle & COMBOBOX_EDITABLE)) break;
	case GADGET_TEXTFIELD:
		[(NSControl*)nsobject setStringValue:text];
		break;
	}
}

BBString *NSPeerGetText(void *peer){
	
	id			nsobject;
	BBString		*result;

	result=&bbEmptyString;
	int gadgetClass=NSPeerGadgetClass(peer);
	int gadgetStyle=NSPeerGadgetStyle(peer);
	nsobject=(NSObject*)NSPeerNativeHandle(peer);
	
	switch (gadgetClass){
	case GADGET_TEXTAREA:
		result=bbStringFromNSString([[((TextView*)nsobject) storage] string]);
		break;
	case GADGET_TEXTFIELD:
	case GADGET_COMBOBOX:
		result=bbStringFromNSString([(NSControl*)nsobject stringValue]);
		break;	
	case GADGET_HTMLVIEW:
		result=bbStringFromNSString([(HTMLView*)nsobject address]);
		break;
	case GADGET_NODE:
		result=bbStringFromNSString([(NodeItem*)nsobject value]);
		break;
	case GADGET_LABEL: /* BaH */
		switch (gadgetStyle&3) {
		case 0:
		case LABEL_FRAME:
		case LABEL_SUNKENFRAME:
			result=bbStringFromNSString([(NSTextField*)nsobject stringValue]);
		}
		break;
	case GADGET_PANEL:
		result=bbStringFromNSString([(PanelView*)nsobject title]);
		break;
	case GADGET_WINDOW:
		result=bbStringFromNSString([(NSWindow*)nsobject title]);
		break;
	case GADGET_BUTTON:
		result=bbStringFromNSString([(NSButton*)nsobject title]);
		break;
	case GADGET_MENUITEM:
		result=bbStringFromNSString([(NSMenuItem*)nsobject title]);
		break;
	}
	return result;
}

int NSCharWidth(NSFont *font,int charcode){	
	NSSize size=[font advancementForGlyph:charcode];
	return (int)size.width;
}

void NSPeerSetFont(void *peer,NSFont *font,int fontStyle){
	id			view;
	int gadgetClass=NSPeerGadgetClass(peer);
	int gadgetStyle=NSPeerGadgetStyle(peer);
	
	NSPeerStoreFontStyle(peer,fontStyle);
	view = (NSView*)NSPeerNativeHandle(peer);
	
	switch (gadgetClass){
		case GADGET_LABEL:
			if ((gadgetStyle&3)==LABEL_SEPARATOR) break;
		case GADGET_BUTTON:
			[(NSControl*)view setFont:font];
			NSPeerSetText(peer, NSPeerGetText(peer));		//Apply underline/strikethough formatting as attributed text.
			break;
		case GADGET_LISTBOX:
			[(ListView*)view setFont:font];
			break;
		case GADGET_TREEVIEW:
			[(TreeView*)view setFont:font];
			break;
		case GADGET_COMBOBOX:
		case GADGET_TEXTFIELD:
			[(NSControl*)view setFont:font];
			break;
		case GADGET_TEXTAREA:
			[(TextView*)view setFont:font];
			break;
		case GADGET_TABBER:
			[(NSTabView*)view setFont:font];
			break;
		
	}
}

BBString * NSPeerGetTooltip(void *peer){

	BBString			*result;
	NSView			*view;
	
	result=&bbEmptyString;
	view=(NSView*)NSPeerNativeHandle(peer);
	
	if(view) result=bbStringFromNSString([view toolTip]);
	
	return result;
}

int NSPeerSetTooltip(void *peer,BBString *data){
	
	NSString			*text;
	NSView			*view;
	
	view =(NSView*)NSPeerNativeHandle(peer);
	text=NSStringFromBBString(data);
	
	if(view){
		[view setToolTip:text];
		return 1;
	}
	
	return 0;
}

// gadgetitem commands

void NSPeerClearItems(void *peer)
{
	ListView			*listbox;
	NSComboBox 		*combo;
	NSTabView			*tabber;
	Toolbar			*toolbar;
	NSToolbarItem		*item;
	NSArray			*items;
	int				i,n;
	int gadgetClass=NSPeerGadgetClass(peer);
	id handle=NSPeerNativeHandle(peer);
		
	switch (gadgetClass){
	case GADGET_LISTBOX:
		listbox=(ListView*)handle;
		[listbox clear];
		break;
	case GADGET_COMBOBOX:
		combo=(NSComboBox*)handle;
		[combo removeAllItems];
		break;
	case GADGET_TABBER:
		tabber=(NSTabView*)handle;
		items=[tabber tabViewItems];
		n=[tabber numberOfTabViewItems];
		for (i=0;i<n;i++) [tabber removeTabViewItem:[tabber tabViewItemAtIndex:0]];
		break;
	case GADGET_TOOLBAR:
		toolbar=(Toolbar*)handle;
		items=[toolbar items];
		n=[items count];
		for (i=0;i<n;i++) {
			[toolbar removeItemAtIndex:0];
			[toolbar forgetToolbarItemAtIndex:0];
		}
		break;
	}
}

void NSPeerAddItem(void *peer,int index,BBString *data,BBString *tip,NSImage *image,BBObject *extra){
	NSString			*text,*tiptext;
	NSComboBox 		*combo;
	NSTabView			*tabber;
	TabViewItem		*tabitem;
	ListView			*listbox;
	Toolbar			*toolbar;
	NSToolbarItem		*item;
	int gadgetClass=NSPeerGadgetClass(peer);
	id handle=NSPeerNativeHandle(peer);

	text=NSStringFromBBString(data);
	tiptext=NSStringFromBBString(tip);
	switch (gadgetClass){
	case GADGET_LISTBOX:
		listbox=(ListView*)handle;
		[listbox addItem:text atIndex:index withImage:image withTip:tiptext withExtra:extra];
		break;
	case GADGET_COMBOBOX:
		combo=(NSComboBox*)handle;
		[combo insertItemWithObjectValue:text atIndex:index];
//		[[combo itemAtIndex:index] setImage:image];
		break;
	case GADGET_TABBER:
		tabber=(NSTabView*)handle;
		tabitem=[[TabViewItem alloc] initWithIdentifier:text];
		[tabitem setLabel:text];
		[tabitem setImage:image];
		[tabitem setToolTip:tiptext];
		[tabber insertTabViewItem:tabitem atIndex:index];	
		[tabitem release];
		break;
	case GADGET_TOOLBAR:	
		toolbar=(Toolbar*)handle;
		if (image==0){
			[toolbar registerStandardIdentifier:NSToolbarSpaceItemIdentifier atIndex:index];
			[toolbar insertItemWithItemIdentifier:NSToolbarSpaceItemIdentifier atIndex:index];
		}
		else{
			item=[[NSToolbarItem alloc] initWithItemIdentifier:[toolbar nextItemIdentifier]];
			[item setImage:image];
//			[item setLabel:text];
			[item setAction:@selector(iconSelect:)];
			[item setTarget:GlobalApp];
			[item setToolTip:tiptext];
			[item setTag:0];
			[toolbar registerToolbarItem:item atIndex:index];
			[toolbar insertItemWithItemIdentifier:[item itemIdentifier] atIndex:index];
			[item release];
		}
		break;
	}
}

void NSPeerSetItem(void *peer,int index,BBString *data,BBString *tip,NSImage *image,BBObject *extra){
	NSString			*text,*tiptext;
	NSComboBox 		*combo;
	NSTabView			*tabber;
	TabViewItem		*tabitem;
	ListView			*listbox;
	Toolbar			*toolbar;
	NSToolbarItem		*item;
	int gadgetClass=NSPeerGadgetClass(peer);
	id handle=NSPeerNativeHandle(peer);

	text=NSStringFromBBString(data);
	tiptext=NSStringFromBBString(tip);

	switch (gadgetClass){
	case GADGET_LISTBOX:
		listbox=(ListView*)handle;
		[listbox setItem:text atIndex:index withImage:image withTip:tiptext withExtra:extra];
		break;
	case GADGET_COMBOBOX:
		combo=(NSComboBox*)handle;
		[combo removeItemAtIndex:index];
		[combo insertItemWithObjectValue:text atIndex:index];
//		[[combo itemAtIndex:index] setImage:image];
		break;
	case GADGET_TABBER:
		tabber=(NSTabView*)handle;
		tabitem=(TabViewItem*)[tabber tabViewItemAtIndex:index];
		[tabitem setLabel:text];
		[tabitem setImage:image];
		[tabitem setToolTip:tiptext];
		[(TabView*)tabber synchronizeSegments];
		break;
	case GADGET_TOOLBAR:	
		toolbar=(Toolbar*)handle;
		item=[toolbar registeredToolbarItemAtIndex:index];
		if (item)	{
//			[item setLabel:text];
			[item setImage:image];
			[item setToolTip:tiptext];
			[item setTag:0];
		}
		break;
	}
}

void NSPeerRemoveItem(void *peer,int index){
	ListView		*listbox;
	NSComboBox 	*combo;
	NSTabView		*tabber;
	TabViewItem	*tabitem;
	Toolbar		*toolbar;
	int gadgetClass=NSPeerGadgetClass(peer);
	id handle=NSPeerNativeHandle(peer);

	switch (gadgetClass){
	case GADGET_LISTBOX:
		listbox=(ListView*)handle;
		[listbox removeItemAtIndex:index];
		break;
	case GADGET_COMBOBOX:
		combo=(NSComboBox*)handle;
		[combo removeItemAtIndex:index];
		break;
	case GADGET_TABBER:
		tabber=(NSTabView*)handle;
		tabitem=(TabViewItem*)[tabber tabViewItemAtIndex:index];
		[tabber removeTabViewItem:tabitem];
		break;
	case GADGET_TOOLBAR:
		toolbar=(Toolbar*)handle;
		[toolbar removeItemAtIndex:(int)index];
		[toolbar forgetToolbarItemAtIndex:index];
		break;
	}
}

void NSPeerSelectItem(void *peer,int index,int state){
	NSComboBox 		*combo;
	NSTabView			*tabber;
	ListView			*listbox;
	Toolbar			*toolbar;
	NSToolbarItem		*item;
	int gadgetClass=NSPeerGadgetClass(peer);
	id handle=NSPeerNativeHandle(peer);

	switch (gadgetClass){
	case GADGET_LISTBOX:
		listbox=(ListView*)handle;
		if(state) [listbox selectItem:index]; else [listbox deselectItem:index];
		break;
	case GADGET_COMBOBOX:
		combo=(NSComboBox*)handle;
		[combo setDelegate:nil];
		[combo selectItemAtIndex:index];
		[combo setObjectValue:[combo objectValueOfSelectedItem]];
		[combo setDelegate:GlobalApp];
		break;
	case GADGET_TABBER:
		tabber=(NSTabView*)handle;
		[tabber selectTabViewItemAtIndex:index];
		break;
	case GADGET_TOOLBAR:	
		toolbar=(Toolbar*)handle;
		item=[toolbar registeredToolbarItemAtIndex:index];
		if (!item) break;
		BOOL enable=(state&STATE_DISABLED)?false:true;
		[item setEnabled:enable];
		int pressed=(state&STATE_SELECTED)?1:0;
		[item setTag:pressed];
		break;
	}
}

int NSPeerSelectedItem(void *peer,int index){
	NSComboBox		*combo;
	NSTabView			*tabber;
	ListView			*listbox;
	Toolbar			*toolbar;
	NSToolbarItem		*item;
	int				state;
	int gadgetClass=NSPeerGadgetClass(peer);
	id handle=NSPeerNativeHandle(peer);

	state=0;
	switch (gadgetClass){
	case GADGET_LISTBOX:
		listbox=(ListView*)handle;
		if ([[[listbox table] selectedRowIndexes] containsIndex:index]) state|=STATE_SELECTED;
		break;
	case GADGET_COMBOBOX:
		combo=(NSComboBox*)handle;
		if ([combo indexOfSelectedItem]==index) state|=STATE_SELECTED;
		break;
	case GADGET_TABBER:
		tabber=(NSTabView*)handle;
		if ([tabber indexOfTabViewItem:[tabber selectedTabViewItem]]==index) state|=STATE_SELECTED;
		break;
	case GADGET_TOOLBAR:	
		toolbar=(Toolbar*)handle;
		item=[toolbar registeredToolbarItemAtIndex:index];
		if (!item) break;
		if (![item isEnabled]) state|=STATE_DISABLED;
		if ([item tag]!=0) state|=STATE_SELECTED;
		break;
	}
	return state;
}

// treeview commands

int NSPeerCountKids(void *peer){
	TreeView		*treeview;
	NodeItem		*node;
	id handle=NSPeerNativeHandle(peer);

	switch (NSPeerGadgetClass(peer)){
	case GADGET_TREEVIEW:
		treeview=(TreeView*)handle;
		return [treeview count];
	case GADGET_NODE:
		node=(NodeItem*)handle;
		return [node count];
	}
	return 0;
}

id NSPeerSelectedNode(void *peer){
	TreeView		*treeview;

	switch (NSPeerGadgetClass(peer)){
	case GADGET_TREEVIEW:
		treeview=(TreeView*)NSPeerNativeHandle(peer);
		return [treeview selectedNode];		
	}
	return 0;
}

// textarea commands

int LinePos(NSString *text,int pos){
	int			line,i;

	line=0;
	for (i=0;i<pos;i++) {if ([text characterAtIndex:i]=='\n' ) line++;}
	return line;
}

int CharPos(NSString *text,int line){
	int			pos,n;

	pos=0;
	n=[text length];
	while (pos<n && line>0){
		if ([text characterAtIndex:pos]=='\n') line--;
		pos++;
	}
	return pos;
}

NSRange GetRange(NSTextStorage *storage,int pos,int count,int units){
	
	NSString	*text;
	unsigned int max;
	
	if (units==TEXTAREA_LINES){
		text=[storage string];
		if (count==TEXTAREA_ALL)
			count=[storage length];
		else
			count=CharPos(text,pos+count);
		pos=CharPos(text,pos);
		max = [storage length]-pos;
		count-=pos;
	}
	else{
		max = [storage length]-pos;
		if (count==TEXTAREA_ALL) count=max;
	}
	
	if (count > max) count = max;
	if (count<0) count=0;
	
	//NSLog(@"GetRange() pos: %d,  count: %d,  length: %d\n", pos, count, [storage length]);
	
	return NSMakeRange(pos,count);
	
}

void NSPeerReplaceText(void *peer,int pos,int count,BBString *data,int units){
	NSString			*text;
	TextView			*textarea;
	NSRange			range,snap;
	NSTextStorage		*storage;
	unsigned int			size;
	
	text=NSStringFromBBString(data);
	textarea=(TextView*)NSPeerNativeHandle(peer);
	[textarea beginProgrammaticChange];
	
	if(([[textarea string] length] == 0) || ((pos == 0) && (count == TEXTAREA_ALL))){
		
		[textarea setText:text];
		
	} else {
		
		snap=[textarea selectedRange];
		range=GetRange([textarea storage],pos,count,units);
		storage=[textarea storage];
		[storage replaceCharactersInRange:range withString:text];	
		size=[storage length];
		if (snap.location>size) snap.location=size;
		if (snap.location+snap.length>size) snap.length=size-snap.location;	
		[textarea setSelectedRange:snap];
		
	}
	[textarea endProgrammaticChange];
	
}

void NSPeerAddText(void *peer,BBString *data){
	NSString			*text;
	TextView			*textarea;
	NSRange			range;

	text=NSStringFromBBString(data);
	textarea=(TextView*)NSPeerNativeHandle(peer);
	[textarea beginProgrammaticChange];
	[textarea addText:text];
	range=GetRange([textarea textStorage],[[textarea string] length],0,0);
	[textarea setSelectedRange:range];
	[textarea scrollRangeToVisible:range];
	[textarea endProgrammaticChange];
}

BBString *NSPeerAreaText(void *peer,int pos,int length,int units){
	TextView			*textarea;
	NSRange			range;
	NSAttributedString	*astring;
	BBString				*bstring;

	textarea=(TextView*)NSPeerNativeHandle(peer);
	range=GetRange([textarea storage],pos,length,units);
	astring=[[textarea storage] attributedSubstringFromRange:range];	
	bstring=bbStringFromNSString([astring string]);
	return bstring;
}

int NSPeerAreaLen(void *peer,int units){
	TextView			*textarea;
	NSTextStorage		*storage;
	unsigned			ulen;

	textarea=(TextView*)NSPeerNativeHandle(peer);
	storage=[textarea storage];
	ulen=[storage length];
	if (units==TEXTAREA_LINES) ulen=LinePos([storage string],ulen)+1;
	return ulen;	
}

void NSPeerSetSelection(void *peer,int pos,int length,int units){
	TextView			*textarea;
	NSRange			range;

	textarea=(TextView*)NSPeerNativeHandle(peer);
	[textarea beginProgrammaticChange];
	range=GetRange([textarea textStorage],pos,length,units);
	[textarea setSelectedRange:range];
	if( !textarea->lockedNest ) [textarea scrollRangeToVisible:range];
	[textarea endProgrammaticChange];
}

void NSPeerLockText(void *peer){
	TextView			*textarea;

	textarea=(TextView*)NSPeerNativeHandle(peer);
	
	if( !textarea->lockedNest ){
		textarea->lockedRange=[textarea selectedRange];
		[textarea->storage beginEditing];
	}

	++textarea->lockedNest;
}

void NSPeerUnlockText(void *peer){
	TextView			*textarea;
	
	textarea=(TextView*)NSPeerNativeHandle(peer);
	
	if( textarea->lockedNest<=0 ) return;
	--textarea->lockedNest;

	if( !textarea->lockedNest ){
		NSRange range=textarea->lockedRange;
		[textarea->storage endEditing];
		if( range.location+range.length>[textarea->storage length] ) range=NSMakeRange( 0,0 );
		[textarea beginProgrammaticChange];
		[textarea setSelectedRange:range];
		[textarea endProgrammaticChange];
	}
}

void NSPeerSetTabs(void *peer,int tabwidth){
	TextView *textarea;
	textarea=(TextView*)NSPeerNativeHandle(peer);
	[textarea setTabs:tabwidth];
}

void NSPeerSetMargins(void *peer,int leftmargin){
	TextView *textarea;
	textarea=(TextView*)NSPeerNativeHandle(peer);
	[textarea setMargins:leftmargin];
}

int NSPeerCharAt(void *peer,int line){
	TextView		*textarea;
	NSString		*text;
	int				n,i;

	textarea=(TextView*)NSPeerNativeHandle(peer);
	text=[[textarea storage] string];
	n=[text length];i=0;
	while (line){
		if (i==n) break;
		if ([text characterAtIndex:i]=='\n' ) line--;
		i++;
	}
	return i;
}

int NSPeerLineAt(void *peer,int pos){
	TextView			*textarea;
	textarea=(TextView*)NSPeerNativeHandle(peer);
	return LinePos([[textarea storage] string],pos);
}

int NSPeerCharX(void *peer,int pos){
	NSUInteger rectCount;
	NSRectArray rectArray;
	TextView	*textarea = (TextView*)NSPeerNativeHandle(peer);
	NSRange range = GetRange([textarea textStorage],pos,0,TEXTAREA_CHARS);
	rectArray = [[textarea layoutManager] rectArrayForCharacterRange:range withinSelectedCharacterRange:range inTextContainer: [textarea textContainer] rectCount:&rectCount];
	if(rectCount > 0) return (int)(((NSRect)rectArray[0]).origin.x-([textarea visibleRect].origin.x-[textarea textContainerOrigin].x));
	return 0;
}

int NSPeerCharY(void *peer,int pos){
	NSUInteger rectCount;
	NSRectArray rectArray;
	TextView	*textarea = (TextView*)NSPeerNativeHandle(peer);
	NSRange range = GetRange([textarea textStorage],pos,0,TEXTAREA_CHARS);
	rectArray = [[textarea layoutManager] rectArrayForCharacterRange:range withinSelectedCharacterRange:range inTextContainer: [textarea textContainer] rectCount:&rectCount];
	if(rectCount > 0) return (int)(((NSRect)rectArray[0]).origin.y-([textarea visibleRect].origin.y-[textarea textContainerOrigin].y));
	return 0;
}

int NSPeerGetCursorPos(void *peer,int units){
	TextView			*textarea;
	NSRange			range;

	textarea=(TextView*)NSPeerNativeHandle(peer);
	range=[textarea selectedRange];
	if (units==TEXTAREA_LINES) return NSPeerLineAt(peer,range.location);
	return range.location;
}

int NSPeerGetSelectionLength(void *peer,int units){
	TextView			*textarea;
	NSRange			range;

	textarea=(TextView*)NSPeerNativeHandle(peer);
	range=[textarea selectedRange];
	if (range.length == 0) return 0;
	if (units == TEXTAREA_LINES){
		int l0=NSPeerLineAt(peer,range.location);
		int l1=NSPeerLineAt(peer,range.location+range.length-1);
		return (l1-l0+1);
	}
	return range.length;
}

void NSPeerSetTextColor(void *peer,int r,int g,int b){
	NSColor *textColor=MaxGUIRGBColor(r,g,b);
	int gadgetClass=NSPeerGadgetClass(peer);
	int gadgetStyle=NSPeerGadgetStyle(peer);
	id handle=NSPeerNativeHandle(peer);
	NSPeerStoreTextColor(peer,textColor);
	
	switch (gadgetClass){
	case GADGET_LABEL:
		switch (gadgetStyle&3) {
			case LABEL_SEPARATOR:
				return;
		}
	case GADGET_TEXTFIELD:
	case GADGET_LISTBOX:
	case GADGET_TREEVIEW:
	case GADGET_TEXTAREA:
		[handle setTextColor:textColor];
		break;
	default:
		NSPeerSetText(peer, NSPeerGetText(peer));	//Attempt to reset text with NSAttributedString
		break;
	}
}

void NSPeerSetStyle(void *peer,int r,int g,int b,int flags,int pos,int length,int units){
	TextView			*textarea;
	NSRange			_range;
	NSColor				*color;
	int traits = 0;

	textarea=(TextView*)NSPeerNativeHandle(peer);
	_range=GetRange([textarea storage],pos,length,units);
	color=MaxGUIRGBColor(r,g,b);
	
	[[textarea storage] removeAttribute:NSLinkAttributeName range:_range];
	[[textarea storage] addAttribute:NSForegroundColorAttributeName value:color range:_range];
	[[textarea storage] addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:(flags & 4)?NSUnderlineStyleSingle:NSUnderlineStyleNone] range:_range];
	[[textarea storage] addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:(flags & 8)?NSUnderlineStyleSingle:NSUnderlineStyleNone] range:_range];

	traits |= (flags & 1)?NSBoldFontMask:NSUnboldFontMask;
	traits |= (flags & 2)?NSItalicFontMask:NSUnitalicFontMask;

	[[textarea storage] applyFontTraits: traits range:_range];
}

void NSPeerSetValue(void *peer,float value){
	NSProgressIndicator	*progbar;
	
	switch (NSPeerGadgetClass(peer)){
	case GADGET_PROGBAR:
		progbar=(NSProgressIndicator*)NSPeerNativeHandle(peer);
		[progbar setDoubleValue:value];
		break;
	}
}

// slider / scrollbar

void NSPeerSetSlider(void *peer,double value,double small,double big){
	NSScroller		*scroller;
	NSSlider			*slider;
	NSStepper			*stepper;
	id handle=NSPeerNativeHandle(peer);
	
	switch (NSPeerGadgetStyle(peer)&12){
	case SLIDER_SCROLLBAR:
		scroller=(NSScroller*)handle;
		if(value > (big-small))
			value = 1.0L;
		else if(big-small)
			value/=(big-small);
		else
			value = 0.0L;
		[scroller setKnobProportion:(small/big)];
		[scroller setDoubleValue:value];
		break;
	case SLIDER_TRACKBAR:
	case SLIDER_DIAL:
		slider=(NSSlider*)handle;
		[slider setMinValue:small];
		[slider setMaxValue:big];
		[slider setDoubleValue:value];
		break;
	case SLIDER_STEPPER:
		stepper=(NSStepper*)handle;
		[stepper setMinValue:small];
		[stepper setMaxValue:big];
		[stepper setDoubleValue:value];
		break;
	}
}

double NSPeerGetSlider(void *peer){
	NSControl	*control;
	control = (NSControl*)NSPeerNativeHandle(peer);
	return [control doubleValue];
}


NSCursor* NSCursorCreateStock(short sIndex)
{

    // Adapted from wxWidgets - if you believe this contravenes wxWidget's licensing
    // agreements, please let the BRL team know and it will be removed.
    
    int i;
    ArrayCursor* tmpCursor = &arrCursors[sIndex];
    NSImage *tmpImage = [[NSImage alloc] initWithSize:NSMakeSize(16.0,16.0)];
    
    NSBitmapImageRep *tmpRep = [[NSBitmapImageRep alloc]
        initWithBitmapDataPlanes: NULL
        pixelsWide: 16
        pixelsHigh: 16
        bitsPerSample: 1
        samplesPerPixel: 2
        hasAlpha: YES
        isPlanar: YES
        colorSpaceName: NSCalibratedWhiteColorSpace
        bytesPerRow: 2
        bitsPerPixel: 1];
    
    unsigned char *planes[5];
    [tmpRep getBitmapDataPlanes:planes];
    
    for(i=0; i<16; ++i)
    {
        planes[0][2*i  ] = (~tmpCursor->bits[i] & tmpCursor->mask[i]) >> 8 & 0xff;
        planes[1][2*i  ] = tmpCursor->mask[i] >> 8 & 0xff;
        planes[0][2*i+1] = (~tmpCursor->bits[i] & tmpCursor->mask[i]) & 0xff;
        planes[1][2*i+1] = tmpCursor->mask[i] & 0xff;
    }
    
    [tmpImage addRepresentation:tmpRep];
    
    NSCursor* tmpNSCursor =  [[NSCursor alloc]  initWithImage:tmpImage hotSpot:NSMakePoint(tmpCursor->hitpoint[1], tmpCursor->hitpoint[0])];
    
    [tmpRep release];[tmpImage release];
    
    return tmpNSCursor;
}

void NSSetPointer(int shape){
	NSCursor *cursor;
	cursor=[NSCursor arrowCursor];
	
	switch (shape){
//	case POINTER_DEFAULT:cursor=[NSCursor ];break;
	case POINTER_ARROW:cursor=[NSCursor arrowCursor];break;
	case POINTER_IBEAM:cursor=[NSCursor IBeamCursor];break;
//	case POINTER_WAIT:cursor=[NSCursor ];break;
	case POINTER_CROSS:cursor=[NSCursor crosshairCursor];break;
	case POINTER_UPARROW:cursor=[NSCursor resizeUpCursor];break;
	case POINTER_SIZENWSE:cursor=NSCursorCreateStock(curNWSE);break;
	case POINTER_SIZENESW:cursor=NSCursorCreateStock(curNESW);break;
	case POINTER_SIZEWE:cursor=[NSCursor resizeLeftRightCursor];break;
	case POINTER_SIZENS:cursor=[NSCursor resizeUpDownCursor];break;
	case POINTER_SIZEALL:cursor=NSCursorCreateStock(curSizeAll);break;
	case POINTER_NO:cursor=NSCursorCreateStock(curNoEntry);break;
	case POINTER_HAND:cursor=[NSCursor pointingHandCursor];break;
//	case POINTER_APPSTARTING:cursor=[NSCursor ];break;
	case POINTER_HELP:cursor=NSCursorCreateStock(curHelp);break;
	}
	[cursor set];
}

typedef struct bbpixmap bbpixmap;

struct bbpixmap{
// BBObject
	void		*class;
//	int		refs;
// pixmap
	unsigned char *pixels;
	int		width,height,pitch,format,capacity;
	void *source;
};


#define PF_I8 1
#define PF_A8 2
#define PF_BGR888 3
#define PF_RGB888 4
#define PF_BGRA8888 5
#define PF_RGBA8888 6
#define PF_STDFORMAT PF_RGBA8888

const static char BytesPerPixel[]={0,1,1,3,3,4,4};
const static char BitsPerPixel[]={0,8,8,24,24,32,32};
const static char RedBitsPerPixel[]={0,0,0,8,8,8,8};
const static char GreenBitsPerPixel[]={0,0,0,8,8,8,8};
const static char BlueBitsPerPixel[]={0,0,0,8,8,8,8};
const static char AlphaBitsPerPixel[]={0,0,8,0,0,8,8};

NSImage *NSPixmapImage(bbpixmap *pix){
	NSImage *image;
	NSBitmapImageRep *bitmap;
	int spp,bpp,i;
	int bytesperrow;
	BOOL	alpha;
	unsigned char * data;
		
	alpha=AlphaBitsPerPixel[pix->format]?YES:NO;
	spp=BytesPerPixel[pix->format];
	bpp=BitsPerPixel[pix->format];
	bytesperrow=pix->width*spp;
	
	bitmap=[[[NSBitmapImageRep alloc] 
		initWithBitmapDataPlanes:NULL
		pixelsWide:pix->width
		pixelsHigh:pix->height
		bitsPerSample:8 
		samplesPerPixel:spp 
		hasAlpha:alpha 
		isPlanar:NO 
		colorSpaceName:NSDeviceRGBColorSpace 
//		bitmapFormat:NSAlphaNonpremultipliedBitmapFormat
		bytesPerRow:bytesperrow 
		bitsPerPixel:bpp] autorelease];
		
	data = [bitmap bitmapData];
	
	for( i = 0; i < pix->height; i++) {
		memcpy( data + ( i * bytesperrow ), pix->pixels + ( i * pix->pitch ), bytesperrow );
	}

	image=[[NSImage alloc] initWithSize:NSMakeSize(pix->width,  pix->height)];
	[image addRepresentation:bitmap];
	[image autorelease];
	return image;
}

void NSPeerSetImage(void *peer,NSImage *image,int flags){
	PanelView *panel;
	NSButton *button;
	NSMenuItem *menu;
	int gadgetClass=NSPeerGadgetClass(peer);
	int gadgetStyle=NSPeerGadgetStyle(peer);
	id handle=NSPeerNativeHandle(peer);
	
	switch (gadgetClass){
	case GADGET_PANEL:
		panel=(PanelView*)handle;
		[panel setImage:image withFlags:flags];
		break;
	case GADGET_BUTTON:
		if ((flags & GADGETPIXMAP_ICON) && (gadgetStyle <= BUTTON_PUSH)){
			button=(NSButton *)handle;
			[button setImage:image];
			if (flags & GADGETPIXMAP_NOTEXT) {
				[button setImagePosition:NSImageOnly];
			} else {
				[button setImagePosition:NSImageLeft];
			}
		}
		break; 
	case GADGET_MENUITEM:
		if (flags & GADGETPIXMAP_ICON){
			menu=(NSMenuItem*)handle;
			[menu setImage:image];
		}
		break;
	}
}

void NSPeerSetIcon(void *peer,NSImage *image){
	NodeItem	*node;
		
	switch (NSPeerGadgetClass(peer)){
	case GADGET_NODE:
		node=(NodeItem*)NSPeerNativeHandle(peer);
		[node setIcon:image];
		break;
	}
}

void NSPeerSetNextView(void *peer,void *nextPeer){
	NSView		*view,*nextview;
	view=(NSView*)NSPeerNativeHandle(peer);
	nextview=(NSView*)NSPeerNativeHandle(nextPeer);
	[view setNextKeyView:nextview];
}

static int keyToChar( int key ){
	if( key>=KEY_A && key<=KEY_Z ) return key-KEY_A+'a';
	if( key>=KEY_F1 && key<=KEY_F12 ) return key-KEY_F1+NSF1FunctionKey;
	
	switch( key ){
	case KEY_BACKSPACE:return 8;
	case KEY_TAB:return 9;
	case KEY_ESC:return 27;
	case KEY_SPACE:return 32;
	case KEY_PAGEUP:return NSPageUpFunctionKey;
	case KEY_PAGEDOWN:return NSPageDownFunctionKey;
	case KEY_END:return NSEndFunctionKey;
	case KEY_HOME:return NSHomeFunctionKey;
	case KEY_UP:return NSUpArrowFunctionKey;
	case KEY_DOWN:return NSDownArrowFunctionKey;
	case KEY_LEFT:return NSLeftArrowFunctionKey;
	case KEY_RIGHT:return NSRightArrowFunctionKey;
	case KEY_INSERT:return NSInsertFunctionKey;
	case KEY_DELETE:return NSDeleteFunctionKey;
	case KEY_TILDE:return '~';
	case KEY_MINUS:return '-';
	case KEY_EQUALS:return '=';
	case KEY_OPENBRACKET:return '[';
	case KEY_CLOSEBRACKET:return ']';
	case KEY_BACKSLASH:return '\\';
	case KEY_SEMICOLON:return ';';
	case KEY_QUOTES:return '\'';
	case KEY_COMMA:return ',';
	case KEY_PERIOD:return '.';
	case KEY_SLASH:return '/';
	}
	return 0;
}

void NSPeerSetHotKey(void *peer,int key,int modifier){
	int chr;
	unichar uchar[1];
	NSString *keyStr;
	NSEventModifierFlags modMask;
	NSMenuItem *menuItem;
	if( NSPeerGadgetClass(peer)!=GADGET_MENUITEM ) return;
	modMask=0;
	if( modifier & 1 ) modMask|=NSEventModifierFlagShift;
	if( modifier & 2 ) modMask|=NSEventModifierFlagControl;
	if( modifier & 4 ) modMask|=NSEventModifierFlagOption;
	if( modifier & 8 ) modMask|=NSEventModifierFlagCommand;
	menuItem=(NSMenuItem*)NSPeerNativeHandle(peer);
	chr=keyToChar( key );
	if( !chr ) {
		[menuItem setKeyEquivalent:@""];
		[menuItem setKeyEquivalentModifierMask:0];
		return;
	}
	uchar[0]=chr;
	keyStr=[NSString stringWithCharacters:uchar length:1];
	[menuItem setKeyEquivalent:keyStr];
	[menuItem setKeyEquivalentModifierMask:modMask];
}
