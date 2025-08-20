//
//  SystemCSSComponents.h
//  SystemCSS Component Library
//
//  A comprehensive Objective-C component library inspired by system.css
//  Recreates the classic Apple System OS aesthetic (1984-1991)
//
//  Copyright (c) 2024 SystemCSS Component Library
//  Based on system.css by Sakun Acharige (https://github.com/sakofchit/system.css)
//

#import <Cocoa/Cocoa.h>

// MARK: - Core Components
#import "Components/SystemCSSColors.h"
#import "Components/SystemButton.h"
#import "Components/SystemWindow.h"
#import "Components/SystemFormComponents.h"
#import "Components/SystemMenu.h"
#import "Components/SystemDialog.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * SystemCSS Component Library
 *
 * A comprehensive collection of UI components that recreate the classic Apple System OS
 * aesthetic from 1984-1991. This library provides native Objective-C NSView-based
 * components that mirror the design patterns and visual style of system.css.
 *
 * Features:
 * - Retro computing aesthetic with pixel-perfect recreation
 * - Unified color scheme and typography system
 * - Proper Objective-C conventions and memory management
 * - Full event handling and delegate patterns
 * - Compatible with modern macOS development
 *
 * Components Included:
 * - SystemButton: Standard, default, and title bar buttons
 * - SystemWindow: Complete window system with title bars and panes
 * - SystemTextField: Classic text input fields
 * - SystemRadioButton: Radio button controls
 * - SystemCheckbox: Checkbox controls
 * - SystemSelectMenu: Dropdown select menus
 * - SystemMenuBar: Menu bars with dropdown menus
 * - SystemDialog: Various dialog types (standard, modal, alert)
 *
 * Usage:
 * Import this header to access all SystemCSS components, or import individual
 * component headers for specific functionality.
 */
@interface SystemCSSComponents : NSObject

/**
 * Library version information
 */
+ (NSString *)version;
+ (NSString *)build;

/**
 * Utility methods for common SystemCSS patterns
 */
+ (NSView *)createRetroBackgroundViewWithFrame:(NSRect)frame;
+ (void)applyShadowToView:(NSView *)view;
+ (NSFont *)defaultSystemFont;
+ (NSColor *)defaultTextColor;
+ (NSColor *)defaultBackgroundColor;

/**
 * Factory methods for common component configurations
 */
+ (SystemButton *)createStandardButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (SystemButton *)createDefaultButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (SystemWindow *)createStandardWindowWithTitle:(NSString *)title size:(NSSize)size;
+ (SystemAlertBox *)createAlertWithMessage:(NSString *)message 
                                      icon:(SystemAlertIcon)icon 
                                   buttons:(NSArray<NSString *> *)buttonTitles;

@end

NS_ASSUME_NONNULL_END