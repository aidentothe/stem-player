//
//  SystemCSSColors.h
//  SystemCSS Component Library
//
//  A unified color scheme and typography system inspired by system.css
//  Recreates the classic Apple System OS aesthetic (1984-1991)
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SystemCSSColors : NSObject

// MARK: - Base Color Tokens
+ (NSColor *)primaryColor;      // White (#FFFFFF)
+ (NSColor *)secondaryColor;    // Black (#000000)
+ (NSColor *)tertiaryColor;     // Grey (#A5A5A5)
+ (NSColor *)disabledColor;     // Dark Grey (#B6B7B8)

// MARK: - Pattern Colors
+ (NSColor *)gridPatternColor;
+ (NSColor *)stripedPatternColor;

// MARK: - Typography
+ (NSFont *)chicagoFont:(CGFloat)size;
+ (NSFont *)chicago12Font;
+ (NSFont *)genevaFont:(CGFloat)size;
+ (NSFont *)geneva9Font;
+ (NSFont *)monacoFont:(CGFloat)size;

// MARK: - Component Styling Constants
+ (CGFloat)boxShadowOffset;
+ (CGFloat)elementSpacing;
+ (CGFloat)groupedElementSpacing;
+ (CGFloat)standardButtonWidth;
+ (CGFloat)standardButtonHeight;
+ (CGFloat)titleBarHeight;
+ (CGFloat)borderWidth;

// MARK: - Drawing Utilities
+ (void)drawRetroBoxShadowForRect:(NSRect)rect inContext:(NSGraphicsContext *)context;
+ (void)drawRacingStripesInRect:(NSRect)rect;
+ (void)drawGridPatternInRect:(NSRect)rect;

@end

NS_ASSUME_NONNULL_END