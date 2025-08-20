//
//  SystemMenu.h
//  SystemCSS Component Library
//
//  Recreates the classic Apple System OS menu components
//  Includes menu bars and dropdown menus
//

#import <Cocoa/Cocoa.h>
#import "SystemCSSColors.h"

NS_ASSUME_NONNULL_BEGIN

@class SystemMenuItem;
@class SystemMenuBar;

// MARK: - SystemMenuItem

@protocol SystemMenuItemDelegate <NSObject>
@optional
- (void)menuItemWasClicked:(SystemMenuItem *)menuItem;
@end

@interface SystemMenuItem : NSView

@property (nonatomic, weak) id<SystemMenuItemDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong, nullable) NSArray<SystemMenuItem *> *submenuItems;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL isDivider;
@property (nonatomic, assign) BOOL hasSubmenu;
@property (nonatomic, assign) BOOL isHighlighted;
@property (nonatomic, weak, nullable) SystemMenuBar *parentMenuBar;

// MARK: - Initializers
- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithTitle:(NSString *)title submenuItems:(NSArray<SystemMenuItem *> *)submenuItems;
- (instancetype)initDivider;

// MARK: - Configuration
- (void)setSubmenuItems:(NSArray<SystemMenuItem *> *)submenuItems;
- (void)addSubmenuItem:(SystemMenuItem *)item;

@end

// MARK: - SystemDropdownMenu

@interface SystemDropdownMenu : NSView

@property (nonatomic, strong) NSArray<SystemMenuItem *> *menuItems;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, weak, nullable) SystemMenuItem *parentMenuItem;

- (instancetype)initWithMenuItems:(NSArray<SystemMenuItem *> *)menuItems;
- (void)showAtPoint:(NSPoint)point;
- (void)hide;

@end

// MARK: - SystemMenuBar

@protocol SystemMenuBarDelegate <NSObject>
@optional
- (void)menuBarItem:(SystemMenuItem *)item wasClicked:(SystemMenuBar *)menuBar;
@end

@interface SystemMenuBar : NSView <SystemMenuItemDelegate>

@property (nonatomic, weak) id<SystemMenuBarDelegate> delegate;
@property (nonatomic, strong) NSMutableArray<SystemMenuItem *> *menuItems;
@property (nonatomic, weak, nullable) SystemDropdownMenu *activeDropdown;

// MARK: - Initializers
- (instancetype)initWithMenuItems:(NSArray<SystemMenuItem *> *)menuItems;

// MARK: - Menu Management
- (void)addMenuItem:(SystemMenuItem *)item;
- (void)removeMenuItem:(SystemMenuItem *)item;
- (void)hideActiveDropdown;

@end

NS_ASSUME_NONNULL_END