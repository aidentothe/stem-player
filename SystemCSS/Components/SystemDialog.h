//
//  SystemDialog.h
//  SystemCSS Component Library
//
//  Recreates the classic Apple System OS dialog components
//  Includes standard dialogs, modal dialogs, and alert boxes
//

#import <Cocoa/Cocoa.h>
#import "SystemCSSColors.h"
#import "SystemButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SystemDialogStyle) {
    SystemDialogStyleStandard,
    SystemDialogStyleModal,
    SystemDialogStyleAlert,
    SystemDialogStyleModeless
};

typedef NS_ENUM(NSUInteger, SystemAlertIcon) {
    SystemAlertIconNone,
    SystemAlertIconStop,
    SystemAlertIconCaution,
    SystemAlertIconNote
};

@protocol SystemDialogDelegate <NSObject>
@optional
- (void)systemDialogButtonClicked:(SystemButton *)button dialog:(id)dialog;
- (void)systemDialogWillClose:(id)dialog;
- (void)systemDialogDidClose:(id)dialog;
@end

// MARK: - SystemStandardDialog

@interface SystemStandardDialog : NSView

@property (nonatomic, weak) id<SystemDialogDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSView *contentView;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;
- (void)setContentView:(NSView *)contentView;

@end

// MARK: - SystemModalDialog

@interface SystemModalDialog : NSView

@property (nonatomic, weak) id<SystemDialogDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSView *contentView;
@property (nonatomic, strong) NSMutableArray<SystemButton *> *buttons;

- (instancetype)initWithTitle:(NSString *)title;
- (void)setContentView:(NSView *)contentView;
- (void)addButton:(SystemButton *)button;
- (void)removeButton:(SystemButton *)button;

@end

// MARK: - SystemAlertBox

@interface SystemAlertBox : NSView <SystemButtonDelegate>

@property (nonatomic, weak) id<SystemDialogDelegate> delegate;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) SystemAlertIcon iconType;
@property (nonatomic, strong) NSMutableArray<SystemButton *> *buttons;

- (instancetype)initWithMessage:(NSString *)message iconType:(SystemAlertIcon)iconType;
- (void)addButton:(SystemButton *)button;
- (void)removeButton:(SystemButton *)button;

@end

// MARK: - SystemModelessDialog

@interface SystemModelessDialog : NSView <SystemButtonDelegate>

@property (nonatomic, weak) id<SystemDialogDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSView *contentView;
@property (nonatomic, strong) NSMutableArray<SystemButton *> *buttons;
@property (nonatomic, assign) BOOL showTitleBar;

- (instancetype)initWithTitle:(NSString *)title showTitleBar:(BOOL)showTitleBar;
- (void)setContentView:(NSView *)contentView;
- (void)addButton:(SystemButton *)button;
- (void)removeButton:(SystemButton *)button;

@end

NS_ASSUME_NONNULL_END