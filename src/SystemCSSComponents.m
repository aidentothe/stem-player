//
//  SystemCSSComponents.m
//  Basic system.css styled components implementation
//

#import "SystemCSSComponents.h"

@implementation SystemButton

+ (instancetype)standardButtonWithTitle:(NSString *)title {
    return [[self alloc] initStandardButtonWithTitle:title];
}

- (instancetype)initStandardButtonWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        [self setTitle:title];
        [self setButtonType:NSButtonTypeMomentaryPushIn];
        [self setBordered:YES];
        [self setBezelStyle:NSBezelStyleRegularSquare];
        
        // System.css styling
        self.wantsLayer = YES;
        self.layer.backgroundColor = SYSTEM_WHITE.CGColor;
        self.layer.borderColor = SYSTEM_BLACK.CGColor;
        self.layer.borderWidth = 2.0;
        self.layer.cornerRadius = 0.0;
        
        // Typography
        NSFont *font = [NSFont systemFontOfSize:12];
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [attributedTitle addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, title.length)];
        [attributedTitle addAttribute:NSForegroundColorAttributeName value:SYSTEM_BLACK range:NSMakeRange(0, title.length)];
        [self setAttributedTitle:attributedTitle];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Custom drawing for system.css button style
    NSRect bounds = self.bounds;
    
    // Background
    [SYSTEM_WHITE setFill];
    NSRectFill(bounds);
    
    // Border
    [SYSTEM_BLACK setStroke];
    NSBezierPath *border = [NSBezierPath bezierPathWithRect:bounds];
    [border setLineWidth:2.0];
    [border stroke];
    
    // Button state effects
    if (self.isHighlighted) {
        [[SYSTEM_BLACK colorWithAlphaComponent:0.1] setFill];
        NSRectFill(NSInsetRect(bounds, 2, 2));
    }
    
    [super drawRect:dirtyRect];
}

@end

@implementation SystemWindow

+ (instancetype)standardWindowWithTitle:(NSString *)title {
    return [[self alloc] initStandardWindowWithTitle:title];
}

- (instancetype)initStandardWindowWithTitle:(NSString *)title {
    NSRect frame = NSMakeRect(100, 100, 600, 400);
    self = [super initWithContentRect:frame
                            styleMask:(NSWindowStyleMaskTitled |
                                     NSWindowStyleMaskClosable |
                                     NSWindowStyleMaskMiniaturizable |
                                     NSWindowStyleMaskResizable)
                              backing:NSBackingStoreBuffered
                                defer:NO];
    if (self) {
        [self setTitle:title];
        
        // System.css window styling
        self.backgroundColor = SYSTEM_WHITE;
        
        // Content view styling
        NSView *contentView = self.contentView;
        contentView.wantsLayer = YES;
        contentView.layer.backgroundColor = SYSTEM_WHITE.CGColor;
        contentView.layer.borderColor = SYSTEM_BLACK.CGColor;
        contentView.layer.borderWidth = 2.0;
    }
    return self;
}

@end