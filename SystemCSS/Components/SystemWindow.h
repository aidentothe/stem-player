//
//  SystemWindow.h
//  SystemCSS Component Library
//
//  Recreates the classic Apple System OS window components
//  Includes title bars, window panes, and window controls
//

#import <Cocoa/Cocoa.h>
#import "SystemCSSColors.h"
#import "SystemButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SystemWindowStyle) {
    SystemWindowStyleStandard,
    SystemWindowStyleDialog,
    SystemWindowStyleModeless
};

@protocol SystemWindowDelegate <NSObject>
@optional
- (void)systemWindowCloseButtonClicked:(id)sender;
- (void)systemWindowResizeButtonClicked:(id)sender;
- (void)systemWindowDidBecomeActive:(id)sender;
- (void)systemWindowDidBecomeInactive:(id)sender;
@end

@interface SystemTitleBar : NSView
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL showCloseButton;
@property (nonatomic, assign) BOOL showResizeButton;
@property (nonatomic, weak) id<SystemWindowDelegate> delegate;
@property (nonatomic, strong) SystemButton *closeButton;
@property (nonatomic, strong) SystemButton *resizeButton;

- (instancetype)initWithTitle:(NSString *)title showControls:(BOOL)showControls;
- (void)setActive:(BOOL)active;
@end

@interface SystemWindowPane : NSView
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSView *contentView;
@property (nonatomic, assign) BOOL scrollable;

- (instancetype)initWithScrollable:(BOOL)scrollable;
- (void)setContentView:(NSView *)contentView;
@end

@interface SystemDetailsBar : NSView
@property (nonatomic, strong) NSMutableArray<NSString *> *details;

- (instancetype)initWithDetails:(NSArray<NSString *> *)details;
- (void)addDetail:(NSString *)detail;
- (void)removeAllDetails;
@end

@interface SystemWindow : NSView <SystemButtonDelegate>

@property (nonatomic, weak) id<SystemWindowDelegate> delegate;
@property (nonatomic, assign) SystemWindowStyle windowStyle;
@property (nonatomic, strong) SystemTitleBar *titleBar;
@property (nonatomic, strong, nullable) SystemDetailsBar *detailsBar;
@property (nonatomic, strong) SystemWindowPane *windowPane;
@property (nonatomic, assign) BOOL isActive;

// MARK: - Initializers
- (instancetype)initWithFrame:(NSRect)frameRect 
                        style:(SystemWindowStyle)style 
                        title:(NSString *)title 
                 showControls:(BOOL)showControls;

- (instancetype)initStandardWindowWithTitle:(NSString *)title;
- (instancetype)initDialogWindowWithTitle:(NSString *)title;
- (instancetype)initModelessWindowWithTitle:(NSString *)title;

// MARK: - Configuration
- (void)setTitle:(NSString *)title;
- (void)setActive:(BOOL)active;
- (void)addDetailsBar:(NSArray<NSString *> *)details;
- (void)removeDetailsBar;
- (void)setWindowContent:(NSView *)contentView;

// MARK: - Window Controls
- (void)performClose;
- (void)performResize;

@end

NS_ASSUME_NONNULL_END