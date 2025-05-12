//
//  LNSettingsWindowController.m
//  LNSettingsWindowController
//
//  Created by Léo Natan on 12/05/2025.
//

#import "LNSettingsWindowController.h"

static NSString *const LNSettingsToolbarIdentifier = @"CCNPreferencesMainToolbar";
static NSRect LNSettingsDefaultWindowRect;
static unsigned short const CCNEscapeKey = 53;


/**
 ====================================================================================================================
 */
#pragma mark LNSettingsWindow

@interface LNSettingsWindow : NSWindow
@end

#pragma mark LNSettingsWindowController

@interface LNSettingsWindowController() <NSToolbarDelegate, NSWindowDelegate>

@property (strong) NSToolbar* toolbar;
@property (strong) NSArray* toolbarDefaultItemIdentifiers;

@property (strong) NSViewController<LNSettingsWindowControllerDataSource>* activeViewController;

@end

@implementation LNSettingsWindowController

- (instancetype)init
{
	self = [super init];
	if(self)
	{
		[self setupDefaults];
	}
	return self;
}

- (void)setupDefaults
{
	self.viewControllers = @[];
	self.activeViewController = nil;
	self.window = [LNSettingsWindow new];
	self.window.toolbarStyle = NSWindowToolbarStylePreference;
	self.window.styleMask &= ~NSWindowStyleMaskMiniaturizable;
	
	self.showToolbarWithSingleViewController = YES;
	self.animatesContentTransition = NO;
	self.showToolbarSeparator = YES;
	self.allowsVibrancy = NO;
	self.titleVisible = YES;
}

- (void)setupToolbar
{
	self.window.toolbar = nil;
	self.toolbar = nil;
	self.toolbarDefaultItemIdentifiers = nil;
	
	if(self.showToolbarWithSingleViewController || self.viewControllers.count > 1)
	{
		self.toolbar = [[NSToolbar alloc] initWithIdentifier:LNSettingsToolbarIdentifier];
		self.toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
		self.toolbar.allowsUserCustomization = NO;
		self.toolbar.autosavesConfiguration = NO;
		
		self.toolbar.delegate = self;
		self.window.toolbar = self.toolbar;
	}
}

- (void)dealloc
{
	_viewControllers = nil;
	_activeViewController = nil;
	_toolbar = nil;
	_toolbarDefaultItemIdentifiers = nil;
}

#pragma mark API

- (void)setViewControllers:(NSArray<NSViewController<LNSettingsWindowControllerDataSource> *> *)viewControllers
{
	_viewControllers = [viewControllers copy];
	
	[self setupToolbar];
}

- (void)showSettingsWindow
{
	if([self.window isVisible])
	{
		[NSApp activateIgnoringOtherApps:YES];
		[self.window makeKeyAndOrderFront:nil];
		
		return;
	}
	
	if(self.window == nil)
	{
		[self loadWindow];
	}
	
	[NSApp activateIgnoringOtherApps:YES];
	
	self.window.alphaValue = 0.0;
	[self showWindow:self];
	[self.window makeKeyAndOrderFront:self];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	
	NSAssert(_viewControllers.count > 0, @"Settings window must have at least one settings view controller.");
	[self setupToolbar];
	
	[self activateSettingsControllerWithIdentifier:self.viewControllers.firstObject.settingsIdentifier animate:NO];
	if(self.window.toolbar)
	{
		[self.window.toolbar setSelectedItemIdentifier:self.toolbarDefaultItemIdentifiers.firstObject];
	}
	self.window.alphaValue = 1.0;
	
	[self.window center];
}

- (void)hideSettingsWindow
{
	[self close];
}

#pragma mark Custom Accessors

- (void)setKeepWindowAlwaysOnTop:(BOOL)keepWindowAlwaysOnTop
{
	if(_keepWindowAlwaysOnTop != keepWindowAlwaysOnTop)
	{
		self.window.level = NSStatusWindowLevel;
	}
}

- (void)setTitlebarAppearsTransparent:(BOOL)titlebarAppearsTransparent
{
	self.window.titlebarAppearsTransparent = titlebarAppearsTransparent;
}

- (void)setTitleVisible:(BOOL)titleVisible
{
	self.window.titleVisibility = titleVisible ? NSWindowTitleVisible : NSWindowTitleHidden;
}

- (BOOL)isTitleVisible
{
	return self.window.titleVisibility == NSWindowTitleVisible;
}

#pragma mark Helper

- (NSViewController<LNSettingsWindowControllerDataSource>*)viewControllerWithIdentifier:(NSString*)identifier
{
	for (NSViewController<LNSettingsWindowControllerDataSource>* vc in self.viewControllers)
	{
		if([vc.settingsIdentifier isEqualToString:identifier])
		{
			return vc;
		}
	}
	return nil;
}

- (void)activateSettingsControllerWithIdentifier:(NSString *)settingsIdentifier animate:(BOOL)animate
{
	NSViewController<LNSettingsWindowControllerDataSource>* viewController = [self viewControllerWithIdentifier:settingsIdentifier];
	
	if(viewController == nil)
	{
		return;
	}
	
	NSRect currentWindowFrame = self.window.frame;
	
	CGSize size = viewController.preferredContentSize;
	if(size.width == 0 || size.width == -1)
	{
		size.width = viewController.view.intrinsicContentSize.width;
	}
	if(size.width == 0 || size.width == -1)
	{
		size.width = viewController.view.frame.size.width;
	}
	
	if(size.height == 0 || size.height == -1)
	{
		size.height = viewController.view.intrinsicContentSize.height;
	}
	if(size.height == 0 || size.height == -1)
	{
		size.height = viewController.view.frame.size.height;
	}
	
	NSRect frame = (NSRect){ 0, 0, size };
	viewController.view.frame = frame;
	
	NSRect frameRectForContentRect = [self.window frameRectForContentRect:frame];
	
	CGFloat deltaX = NSWidth(currentWindowFrame) - NSWidth(frameRectForContentRect);
	CGFloat deltaY = NSHeight(currentWindowFrame) - NSHeight(frameRectForContentRect);
	NSRect newWindowFrame = NSMakeRect(NSMinX(currentWindowFrame) + deltaX / 2, NSMinY(currentWindowFrame) + deltaY, NSWidth(frameRectForContentRect), NSHeight(frameRectForContentRect));
	
	self.window.title = viewController.settingsTitle;
	
	viewController.view.alphaValue = 0;
	viewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	
	if(self.allowsVibrancy)
	{
		NSVisualEffectView *effectView = [[NSVisualEffectView alloc] initWithFrame:frame];
		effectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
		[effectView addSubview:viewController.view];
		self.window.contentView = effectView;
	}
	else
	{
		NSView *view = [[NSView alloc] initWithFrame:frame];
		[view addSubview:viewController.view];
		self.window.contentView = view;
	}
	
	if(animate == NO)
	{
		[viewController.view setAlphaValue:1.0];
	}
	
	[self.window setFrame:newWindowFrame display:YES animate:animate];
	
	void (^handler)(void) = ^{
		if(animate)
		{
			[viewController.view setAlphaValue:1.0];
		}
		self.activeViewController = viewController;
	};
	
	if(animate)
	{
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animate * [self.window animationResizeTime:newWindowFrame] * NSEC_PER_SEC)), dispatch_get_main_queue(), handler);
	}
	else
	{
		handler();
	}
}

#pragma mark NSToolbarItem Actions

- (void)toolbarItemAction:(NSToolbarItem *)toolbarItem
{
	if([self.activeViewController.settingsIdentifier isEqualToString:toolbarItem.itemIdentifier] == NO)
	{
		[self activateSettingsControllerWithIdentifier:toolbarItem.itemIdentifier animate:self.animatesContentTransition];
	}
}

#pragma mark NSToolbarDelegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	if([itemIdentifier isEqualToString:NSToolbarFlexibleSpaceItemIdentifier])
	{
		return nil;
	}
	
	NSViewController<LNSettingsWindowControllerDataSource>* vc = [self viewControllerWithIdentifier:itemIdentifier];
	NSString *identifier = vc.settingsIdentifier;
	NSString *label = vc.settingsTitle;
	NSImage *icon = vc.settingsToolbarIcon;
	icon.size = NSMakeSize(28, 28);
	NSString *toolTip = nil;
	if([vc respondsToSelector:@selector(settingsToolbarToolTip)]) {
		toolTip = vc.settingsToolbarToolTip;
	}
	
	NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
	toolbarItem.label = label;
	toolbarItem.paletteLabel = label;
	toolbarItem.image = icon;
	toolbarItem.toolTip = toolTip;
	toolbarItem.target = self;
	toolbarItem.action = @selector(toolbarItemAction:);
	
	return toolbarItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	if(self.toolbarDefaultItemIdentifiers == nil && self.viewControllers.count > 0)
	{
		self.toolbarDefaultItemIdentifiers = [self.viewControllers valueForKey:@"settingsIdentifier"];
	}
	return self.toolbarDefaultItemIdentifiers;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [self toolbarDefaultItemIdentifiers:toolbar];
}

@end

/**
 ====================================================================================================================
 */

#pragma mark LNSettingsWindow

@implementation LNSettingsWindow

+ (void)load
{
	@autoreleasepool
	{
		LNSettingsDefaultWindowRect = NSMakeRect(0, 0, 420, 230);
	}
}

- (instancetype)init
{
	self = [super initWithContentRect:LNSettingsDefaultWindowRect styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskUnifiedTitleAndToolbar) backing:NSBackingStoreBuffered defer:YES];
	
	if(self)
	{
		[self center];
		self.titlebarAppearsTransparent = NO;
	}
	
	return self;
}

- (void)keyDown:(NSEvent *)theEvent
{
	switch(theEvent.keyCode) {
		case CCNEscapeKey:
			[self orderOut:nil];
			[self close];
			break;
		default: [super keyDown:theEvent];
	}
}

@end
