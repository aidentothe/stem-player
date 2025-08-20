//
//  SystemCSSColors.m
//  SystemCSS Component Library
//

#import "SystemCSSColors.h"

@implementation SystemCSSColors

// MARK: - Base Color Tokens

+ (NSColor *)primaryColor {
    return [NSColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]; // #FFFFFF
}

+ (NSColor *)secondaryColor {
    return [NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]; // #000000
}

+ (NSColor *)tertiaryColor {
    return [NSColor colorWithRed:0.647 green:0.647 blue:0.647 alpha:1.0]; // #A5A5A5
}

+ (NSColor *)disabledColor {
    return [NSColor colorWithRed:0.714 green:0.718 blue:0.722 alpha:1.0]; // #B6B7B8
}

// MARK: - Pattern Colors

+ (NSColor *)gridPatternColor {
    return [NSColor colorWithPatternImage:[self createGridPatternImage]];
}

+ (NSColor *)stripedPatternColor {
    return [NSColor colorWithPatternImage:[self createStripedPatternImage]];
}

// MARK: - Typography

+ (NSFont *)chicagoFont:(CGFloat)size {
    // Try to use system font that resembles Chicago, fallback to system font
    NSFont *font = [NSFont fontWithName:@"Chicago" size:size];
    if (!font) {
        font = [NSFont fontWithName:@"Geneva" size:size];
    }
    if (!font) {
        font = [NSFont boldSystemFontOfSize:size];
    }
    return font;
}

+ (NSFont *)chicago12Font {
    return [self chicagoFont:12.0];
}

+ (NSFont *)genevaFont:(CGFloat)size {
    NSFont *font = [NSFont fontWithName:@"Geneva" size:size];
    if (!font) {
        font = [NSFont systemFontOfSize:size];
    }
    return font;
}

+ (NSFont *)geneva9Font {
    return [self genevaFont:9.0];
}

+ (NSFont *)monacoFont:(CGFloat)size {
    NSFont *font = [NSFont fontWithName:@"Monaco" size:size];
    if (!font) {
        font = [NSFont monospacedSystemFontOfSize:size weight:NSFontWeightRegular];
    }
    return font;
}

// MARK: - Component Styling Constants

+ (CGFloat)boxShadowOffset {
    return 2.0;
}

+ (CGFloat)elementSpacing {
    return 8.0;
}

+ (CGFloat)groupedElementSpacing {
    return 6.0;
}

+ (CGFloat)standardButtonWidth {
    return 59.0;
}

+ (CGFloat)standardButtonHeight {
    return 20.0;
}

+ (CGFloat)titleBarHeight {
    return 19.0;
}

+ (CGFloat)borderWidth {
    return 2.0;
}

// MARK: - Drawing Utilities

+ (void)drawRetroBoxShadowForRect:(NSRect)rect inContext:(NSGraphicsContext *)context {
    [NSGraphicsContext saveGraphicsState];
    
    // Draw shadow at 2px offset
    NSRect shadowRect = NSMakeRect(rect.origin.x + [self boxShadowOffset], 
                                   rect.origin.y - [self boxShadowOffset], 
                                   rect.size.width, 
                                   rect.size.height);
    
    [[self secondaryColor] setFill];
    NSRectFill(shadowRect);
    
    [NSGraphicsContext restoreGraphicsState];
}

+ (void)drawRacingStripesInRect:(NSRect)rect {
    [NSGraphicsContext saveGraphicsState];
    
    // Create racing stripes pattern similar to system.css title bars
    CGFloat stripeWidth = rect.size.width * 0.06666667; // 6.6666666667% from CSS
    CGFloat stripeHeight = rect.size.height * 0.13333333; // 13.3333333333% from CSS
    
    [[self secondaryColor] setFill];
    
    for (CGFloat x = 0; x < rect.size.width; x += stripeWidth * 2) {
        NSRect stripeRect = NSMakeRect(rect.origin.x + x, rect.origin.y, stripeWidth, rect.size.height);
        NSRectFill(stripeRect);
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

+ (void)drawGridPatternInRect:(NSRect)rect {
    [NSGraphicsContext saveGraphicsState];
    
    [[self secondaryColor] setStroke];
    [NSBezierPath setDefaultLineWidth:1.0];
    
    // Draw grid pattern like system.css background
    CGFloat gridSize = 22.0;
    
    // Vertical lines
    for (CGFloat x = 0; x <= rect.size.width; x += gridSize) {
        NSBezierPath *line = [NSBezierPath bezierPath];
        [line moveToPoint:NSMakePoint(rect.origin.x + x, rect.origin.y)];
        [line lineToPoint:NSMakePoint(rect.origin.x + x, rect.origin.y + rect.size.height)];
        [line stroke];
    }
    
    // Horizontal lines
    for (CGFloat y = 0; y <= rect.size.height; y += gridSize) {
        NSBezierPath *line = [NSBezierPath bezierPath];
        [line moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y + y)];
        [line lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + y)];
        [line stroke];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

// MARK: - Private Pattern Creation Methods

+ (NSImage *)createGridPatternImage {
    NSSize patternSize = NSMakeSize(22.0, 22.0);
    NSImage *patternImage = [[NSImage alloc] initWithSize:patternSize];
    
    [patternImage lockFocus];
    
    // Fill with primary color
    [[self primaryColor] setFill];
    NSRectFill(NSMakeRect(0, 0, patternSize.width, patternSize.height));
    
    // Draw grid lines
    [[self secondaryColor] setStroke];
    [NSBezierPath setDefaultLineWidth:1.0];
    
    // Vertical line
    NSBezierPath *vLine = [NSBezierPath bezierPath];
    [vLine moveToPoint:NSMakePoint(21.0, 0)];
    [vLine lineToPoint:NSMakePoint(21.0, 22.0)];
    [vLine stroke];
    
    // Horizontal line
    NSBezierPath *hLine = [NSBezierPath bezierPath];
    [hLine moveToPoint:NSMakePoint(0, 21.0)];
    [hLine lineToPoint:NSMakePoint(22.0, 21.0)];
    [hLine stroke];
    
    [patternImage unlockFocus];
    
    return patternImage;
}

+ (NSImage *)createStripedPatternImage {
    NSSize patternSize = NSMakeSize(4.0, 4.0);
    NSImage *patternImage = [[NSImage alloc] initWithSize:patternSize];
    
    [patternImage lockFocus];
    
    // Fill with primary color
    [[self primaryColor] setFill];
    NSRectFill(NSMakeRect(0, 0, patternSize.width, patternSize.height));
    
    // Draw diagonal stripes
    [[self secondaryColor] setFill];
    
    // Create diagonal pattern
    NSRect stripe1 = NSMakeRect(0, 0, 1, 1);
    NSRect stripe2 = NSMakeRect(2, 2, 1, 1);
    NSRectFill(stripe1);
    NSRectFill(stripe2);
    
    [patternImage unlockFocus];
    
    return patternImage;
}

@end