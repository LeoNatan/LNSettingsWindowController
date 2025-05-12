//
//  LNSettingsWindowController.h
//  LNSettingsWindowController
//
//  Created by Léo Natan on 12/05/2025.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LNSettingsWindowControllerDataSource <NSObject>

@property (nonatomic, copy, readonly) NSString* settingsTitle;
@property (nonatomic, copy, readonly) NSString* settingsIdentifier;
@property (nonatomic, copy, readonly) NSImage* settingsToolbarIcon;

@optional
@property (nonatomic, copy, readonly, nullable) NSString* settingsToolbarToolTip;

@end

@interface LNSettingsWindowController : NSWindowController

#pragma mark Settings Window Behavior

@property (copy, nonatomic) NSString* titleOverride;
@property (nonatomic) BOOL animatesContentTransition;

/** @name Preferences Window Behaviour */

/**
 Boolean property that defines the window level.
 
 If set to `YES`, the window is on top of all other windows even when you change focus to another app.<br />
 If set to `NO`, the window will only stay on top until you bring another window to front.
 
 The default is `NO`.
 */
@property (assign, nonatomic) BOOL keepWindowAlwaysOnTop;

/**
 Boolean property that defines whether the title is shown or not.
 
 If set to `YES`, the title is shown and with it the title bar.<br />
 If set to `NO`, title and title bar is hidden.
 
 The default is `YES`.
 */

@property (assign, nonatomic, getter=isTitleVisible) BOOL titleVisible;

/**
 This is a forwarder for the used window.
 
 When `YES`, the titlebar doesn't draw its background, allowing all buttons to show through, and "click through" to happen. In general, this is only useful when `NSFullSizeContentViewWindowMask` is set.
 The default is `NO`.
 */
@property (assign, nonatomic) BOOL titlebarAppearsTransparent;

/**
 This is a forwarder for the toolbar.
 
 Use this API to hide the baseline `NSToolbar` draws between itself and the main window contents.
 The default is `YES`. This method should only be used before the toolbar is attached to its window (`- [NSWindow setToolbar:]`).
 */
@property (assign, nonatomic) BOOL showToolbarSeparator;

/**
 Boolean property that indicates whether the toolbar is visible with a single preferenceViewController or not.
 
 If set to `YES`, the toolbar is always visible. Otherwise the toolbar will only be shown if there are more than one prefereceViewController.
 
 The default is `YES`.
 */
@property (assign, nonatomic) BOOL showToolbarWithSingleViewController;

/**
 Boolean property that defines the contentView presentation.
 
 If set to `YES`, the contentView will be embedded in a `NSVisualEffectView` using blending mode `NSVisualEffectBlendingModeBehindWindow`.
 
 The default is `NO`.
 */
@property (assign, nonatomic) BOOL allowsVibrancy;


#pragma mark View Controllers

/// Settings view controllers
@property (nonatomic, copy) NSArray<NSViewController<LNSettingsWindowControllerDataSource>*>* viewControllers;


#pragma mark Show/Hide Settings Window

/// Show the settings window.
- (void)showSettingsWindow;

/// Hides the settings window.
- (void)hideSettingsWindow;

/// Activates the specified settings controller.
///
/// `identifier` must be a valid  exist in the `viewControllers` array.
- (void)activateSettingsControllerWithIdentifier:(NSString*)settingsIdentifier animate:(BOOL)animate;

@end


NS_ASSUME_NONNULL_END
