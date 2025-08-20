//
//  SystemButton.m
//  SystemCSS Component Library
//

#import "SystemButton.h"

@interface SystemButton ()
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@end

@implementation SystemButton

// MARK: - Initializers

- (instancetype)initWithFrame:(NSRect)frameRect style:(SystemButtonStyle)style title:(NSString *)title {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self commonInit];
        _buttonStyle = style;
        _title = [title copy];
        [self updateButtonSize];
    }
    return self;
}

- (instancetype)initStandardButtonWithTitle:(NSString *)title {
    NSRect frame = NSMakeRect(0, 0, [SystemCSSColors standardButtonWidth], [SystemCSSColors standardButtonHeight]);
    return [self initWithFrame:frame style:SystemButtonStyleStandard title:title];
}

- (instancetype)initDefaultButtonWithTitle:(NSString *)title {
    NSRect frame = NSMakeRect(0, 0, [SystemCSSColors standardButtonWidth], [SystemCSSColors standardButtonHeight]);
    return [self initWithFrame:frame style:SystemButtonStyleDefault title:title];
}

- (instancetype)initTitleBarCloseButton {
    NSRect frame = NSMakeRect(0, 0, 20, 20); // Title bar buttons are smaller
    return [self initWithFrame:frame style:SystemButtonStyleTitleBarClose title:@""];
}

- (instancetype)initTitleBarResizeButton {
    NSRect frame = NSMakeRect(0, 0, 20, 20);
    return [self initWithFrame:frame style:SystemButtonStyleTitleBarResize title:@""];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    return [self initWithFrame:frameRect style:SystemButtonStyleStandard title:@"Button"];
}

- (void)commonInit {
    _enabled = YES;
    _isPressed = NO;
    _isHighlighted = NO;
    
    [self setupTrackingArea];
}

- (void)setupTrackingArea {
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds 
                                                     options:(NSTrackingMouseEnteredAndExited | 
                                                             NSTrackingMouseMoved | 
                                                             NSTrackingActiveInKeyWindow) 
                                                       owner:self 
                                                    userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    if (self.trackingArea) {
        [self removeTrackingArea:self.trackingArea];
    }
    [self setupTrackingArea];
}

// MARK: - Configuration

- (void)setButtonStyle:(SystemButtonStyle)style {
    _buttonStyle = style;
    [self updateButtonSize];
    [self setNeedsDisplay:YES];
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    [self updateButtonSize];
    [self setNeedsDisplay:YES];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    [self setNeedsDisplay:YES];
}

- (void)updateButtonSize {
    if (_buttonStyle == SystemButtonStyleStandard || _buttonStyle == SystemButtonStyleDefault) {
        if (_title && _title.length > 0) {
            NSDictionary *attributes = @{NSFontAttributeName: [SystemCSSColors chicago12Font]};
            NSSize textSize = [_title sizeWithAttributes:attributes];
            
            CGFloat minWidth = [SystemCSSColors standardButtonWidth];
            CGFloat width = MAX(minWidth, textSize.width + 40); // 20px padding on each side
            CGFloat height = [SystemCSSColors standardButtonHeight];
            
            NSRect newFrame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, width, height);
            [self setFrame:newFrame];
        }
    }
}

// MARK: - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    switch (self.buttonStyle) {
        case SystemButtonStyleStandard:
            [self drawStandardButton];
            break;
        case SystemButtonStyleDefault:
            [self drawDefaultButton];
            break;
        case SystemButtonStyleTitleBarClose:
            [self drawTitleBarCloseButton];
            break;
        case SystemButtonStyleTitleBarResize:
            [self drawTitleBarResizeButton];
            break;
    }
}

- (void)drawStandardButton {
    NSRect bounds = self.bounds;
    
    // Draw shadow first (bottom-right offset)
    if (!self.isPressed) {
        NSRect shadowRect = NSMakeRect(bounds.origin.x + [SystemCSSColors boxShadowOffset],
                                      bounds.origin.y - [SystemCSSColors boxShadowOffset],
                                      bounds.size.width - [SystemCSSColors boxShadowOffset],
                                      bounds.size.height - [SystemCSSColors boxShadowOffset]);
        [[SystemCSSColors secondaryColor] setFill];
        NSRectFill(shadowRect);
    }
    
    // Draw button background
    NSColor *backgroundColor;
    NSColor *textColor;
    
    if (self.isPressed) {
        backgroundColor = [SystemCSSColors secondaryColor];
        textColor = [SystemCSSColors primaryColor];
    } else {
        backgroundColor = [SystemCSSColors primaryColor];
        textColor = self.enabled ? [SystemCSSColors secondaryColor] : [SystemCSSColors disabledColor];
    }
    
    [backgroundColor setFill];
    NSRect buttonRect = self.isPressed ? bounds : NSMakeRect(bounds.origin.x, 
                                                            bounds.origin.y + [SystemCSSColors boxShadowOffset], 
                                                            bounds.size.width - [SystemCSSColors boxShadowOffset], 
                                                            bounds.size.height - [SystemCSSColors boxShadowOffset]);
    
    if (self.isPressed) {
        // Rounded rect for pressed state
        NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:buttonRect xRadius:6.0 yRadius:6.0];
        [roundedRect fill];
    } else {
        // Draw button border (simulating CSS border-image)
        [self drawButtonBorder:buttonRect];
        NSRectFill(NSInsetRect(buttonRect, [SystemCSSColors borderWidth], [SystemCSSColors borderWidth]));
    }
    
    // Draw button text
    if (self.title && self.title.length > 0) {
        [self drawButtonText:self.title withColor:textColor inRect:buttonRect];
    }
}

- (void)drawDefaultButton {
    // Default button has thicker border
    [self drawStandardButton];
    
    if (!self.isPressed) {
        NSRect bounds = self.bounds;
        NSRect buttonRect = NSMakeRect(bounds.origin.x, 
                                     bounds.origin.y + [SystemCSSColors boxShadowOffset], 
                                     bounds.size.width - [SystemCSSColors boxShadowOffset], 
                                     bounds.size.height - [SystemCSSColors boxShadowOffset]);
        
        // Draw thicker border for default button
        [[SystemCSSColors secondaryColor] setStroke];
        NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:NSInsetRect(buttonRect, -2, -2)];
        [borderPath setLineWidth:4.0];
        [borderPath stroke];
    }
}

- (void)drawTitleBarCloseButton {
    NSRect bounds = self.bounds;
    
    // Draw button background
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(bounds);
    
    // Draw border
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:NSInsetRect(bounds, 2, 2)];
    [borderPath setLineWidth:2.0];
    [borderPath stroke];
    
    // Draw close icon (X) when pressed
    if (self.isPressed) {
        [[SystemCSSColors secondaryColor] setStroke];
        NSBezierPath *crossPath = [NSBezierPath bezierPath];
        [crossPath setLineWidth:2.0];
        
        // Draw X
        CGFloat inset = 6.0;
        [crossPath moveToPoint:NSMakePoint(bounds.origin.x + inset, bounds.origin.y + inset)];
        [crossPath lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width - inset, 
                                          bounds.origin.y + bounds.size.height - inset)];
        [crossPath moveToPoint:NSMakePoint(bounds.origin.x + bounds.size.width - inset, bounds.origin.y + inset)];
        [crossPath lineToPoint:NSMakePoint(bounds.origin.x + inset, 
                                          bounds.origin.y + bounds.size.height - inset)];
        [crossPath stroke];
    }
}

- (void)drawTitleBarResizeButton {
    NSRect bounds = self.bounds;
    
    // Draw button background
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(bounds);
    
    // Draw border
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:NSInsetRect(bounds, 2, 2)];
    [borderPath setLineWidth:2.0];
    [borderPath stroke];
    
    // Draw resize icon (based on system.css resize button)
    if (!self.isPressed) {
        [[SystemCSSColors secondaryColor] setStroke];
        NSBezierPath *resizePath = [NSBezierPath bezierPath];
        [resizePath setLineWidth:2.0];
        
        CGFloat centerX = bounds.origin.x + bounds.size.width * 0.58;
        CGFloat centerY = bounds.origin.y + bounds.size.height * 0.58;
        CGFloat size = bounds.size.width * 0.6;
        
        // Horizontal line
        [resizePath moveToPoint:NSMakePoint(centerX - size/2, centerY)];
        [resizePath lineToPoint:NSMakePoint(centerX + size/2, centerY)];
        
        // Vertical line
        [resizePath moveToPoint:NSMakePoint(centerX, centerY - size/2)];
        [resizePath lineToPoint:NSMakePoint(centerX, centerY + size/2)];
        
        [resizePath stroke];
    }
}

- (void)drawButtonBorder:(NSRect)rect {
    // Simulate CSS border-image effect with simple border for now
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:rect];
    [borderPath setLineWidth:[SystemCSSColors borderWidth]];
    [borderPath stroke];
}

- (void)drawButtonText:(NSString *)text withColor:(NSColor *)color inRect:(NSRect)rect {
    NSDictionary *attributes = @{
        NSFontAttributeName: [SystemCSSColors chicago12Font],
        NSForegroundColorAttributeName: color
    };
    
    NSSize textSize = [text sizeWithAttributes:attributes];
    NSPoint textOrigin = NSMakePoint(rect.origin.x + (rect.size.width - textSize.width) / 2,
                                    rect.origin.y + (rect.size.height - textSize.height) / 2);
    
    [text drawAtPoint:textOrigin withAttributes:attributes];
}

// MARK: - Mouse Events

- (void)mouseDown:(NSEvent *)event {
    if (!self.enabled) return;
    
    self.isPressed = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event {
    if (!self.enabled) return;
    
    BOOL wasPressed = self.isPressed;
    self.isPressed = NO;
    [self setNeedsDisplay:YES];
    
    // Check if mouse is still over button
    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
    if (wasPressed && NSPointInRect(location, self.bounds)) {
        [self performClick];
    }
}

- (void)mouseEntered:(NSEvent *)event {
    if (!self.enabled) return;
    
    self.isHighlighted = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event {
    if (!self.enabled) return;
    
    self.isHighlighted = NO;
    self.isPressed = NO;
    [self setNeedsDisplay:YES];
}

// MARK: - Actions

- (void)performClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(systemButtonWasClicked:)]) {
        [self.delegate systemButtonWasClicked:self];
    }
}

// MARK: - Accessibility

- (BOOL)acceptsFirstResponder {
    return self.enabled;
}

- (BOOL)isFlipped {
    return YES;
}

@end