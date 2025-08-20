//
//  SystemButton.h
//  SystemCSS Component Library
//
//  Recreates the classic Apple System OS button styles
//  Based on system.css button components
//

#import <Cocoa/Cocoa.h>
#import "SystemCSSColors.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SystemButtonStyle) {
    SystemButtonStyleStandard,
    SystemButtonStyleDefault,
    SystemButtonStyleTitleBarClose,
    SystemButtonStyleTitleBarResize
};

@protocol SystemButtonDelegate <NSObject>
@optional
- (void)systemButtonWasClicked:(id)sender;
@end

@interface SystemButton : NSView

@property (nonatomic, weak) id<SystemButtonDelegate> delegate;
@property (nonatomic, assign) SystemButtonStyle buttonStyle;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL isPressed;
@property (nonatomic, assign) BOOL isHighlighted;

// MARK: - Initializers
- (instancetype)initWithFrame:(NSRect)frameRect style:(SystemButtonStyle)style title:(NSString *)title;
- (instancetype)initStandardButtonWithTitle:(NSString *)title;
- (instancetype)initDefaultButtonWithTitle:(NSString *)title;
- (instancetype)initTitleBarCloseButton;
- (instancetype)initTitleBarResizeButton;

// MARK: - Configuration
- (void)setButtonStyle:(SystemButtonStyle)style;
- (void)setTitle:(NSString *)title;
- (void)setEnabled:(BOOL)enabled;

// MARK: - Actions
- (void)performClick;

@end

NS_ASSUME_NONNULL_END