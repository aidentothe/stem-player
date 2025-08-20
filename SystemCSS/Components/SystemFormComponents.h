//
//  SystemFormComponents.h
//  SystemCSS Component Library
//
//  Recreates the classic Apple System OS form components
//  Includes text fields, radio buttons, checkboxes, and select menus
//

#import <Cocoa/Cocoa.h>
#import "SystemCSSColors.h"

NS_ASSUME_NONNULL_BEGIN

// MARK: - SystemTextField

@interface SystemTextField : NSView <NSTextFieldDelegate>

@property (nonatomic, strong) NSTextField *textField;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *placeholderText;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL isSecure;

- (instancetype)initWithFrame:(NSRect)frameRect secure:(BOOL)secure;
- (instancetype)initStandardTextField;
- (instancetype)initPasswordField;

@end

// MARK: - SystemRadioButton

@protocol SystemRadioButtonDelegate <NSObject>
@optional
- (void)radioButtonSelectionChanged:(id)sender;
@end

@interface SystemRadioButton : NSView

@property (nonatomic, weak) id<SystemRadioButtonDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL enabled;

- (instancetype)initWithTitle:(NSString *)title groupName:(NSString *)groupName;
- (void)setSelected:(BOOL)selected;

@end

// MARK: - SystemCheckbox

@protocol SystemCheckboxDelegate <NSObject>
@optional
- (void)checkboxStateChanged:(id)sender;
@end

@interface SystemCheckbox : NSView

@property (nonatomic, weak) id<SystemCheckboxDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) BOOL enabled;

- (instancetype)initWithTitle:(NSString *)title;
- (void)setChecked:(BOOL)checked;

@end

// MARK: - SystemSelectMenu

@protocol SystemSelectMenuDelegate <NSObject>
@optional
- (void)selectMenuSelectionChanged:(id)sender;
@end

@interface SystemSelectMenu : NSView

@property (nonatomic, weak) id<SystemSelectMenuDelegate> delegate;
@property (nonatomic, strong) NSArray<NSString *> *items;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, readonly) NSString *selectedItem;

- (instancetype)initWithItems:(NSArray<NSString *> *)items;
- (void)setItems:(NSArray<NSString *> *)items;
- (void)selectItemAtIndex:(NSInteger)index;

@end

// MARK: - SystemFieldRow

@interface SystemFieldRow : NSView

@property (nonatomic, strong) NSMutableArray<NSView *> *fieldComponents;

- (instancetype)initWithComponents:(NSArray<NSView *> *)components;
- (void)addComponent:(NSView *)component;
- (void)removeComponent:(NSView *)component;

@end

NS_ASSUME_NONNULL_END