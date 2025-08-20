//
//  SystemCSSComponents.m
//  SystemCSS Component Library
//

#import "SystemCSSComponents.h"

// MARK: - Helper Classes

/**
 * Wrapper to bridge SystemButton delegate pattern with target-action pattern
 */
@interface SystemButtonTargetWrapper : NSObject <SystemButtonDelegate>
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
- (instancetype)initWithTarget:(id)target action:(SEL)action;
@end

@implementation SystemButtonTargetWrapper

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        _target = target;
        _action = action;
    }
    return self;
}

- (void)systemButtonWasClicked:(SystemButton *)sender {
    if (self.target && self.action && [self.target respondsToSelector:self.action]) {
        IMP imp = [self.target methodForSelector:self.action];
        void (*func)(id, SEL, id) = (void *)imp;
        func(self.target, self.action, sender);
    }
}

@end

// MARK: - SystemCSSComponents Implementation

@implementation SystemCSSComponents

+ (NSString *)version {
    return @"1.0.0";
}

+ (NSString *)build {
    return @"2024.001";
}

// MARK: - Utility Methods

+ (NSView *)createRetroBackgroundViewWithFrame:(NSRect)frame {
    NSView *backgroundView = [[NSView alloc] initWithFrame:frame];
    
    // Override drawRect to draw the retro grid pattern
    backgroundView = [[NSView alloc] initWithFrame:frame];
    backgroundView.wantsLayer = YES;
    backgroundView.layer.backgroundColor = [SystemCSSColors primaryColor].CGColor;
    
    return backgroundView;
}

+ (void)applyShadowToView:(NSView *)view {
    view.wantsLayer = YES;
    view.shadow = [[NSShadow alloc] init];
    view.shadow.shadowOffset = NSMakeSize([SystemCSSColors boxShadowOffset], -[SystemCSSColors boxShadowOffset]);
    view.shadow.shadowColor = [SystemCSSColors secondaryColor];
    view.shadow.shadowBlurRadius = 0; // Sharp shadows for retro look
}

+ (NSFont *)defaultSystemFont {
    return [SystemCSSColors chicago12Font];
}

+ (NSColor *)defaultTextColor {
    return [SystemCSSColors secondaryColor];
}

+ (NSColor *)defaultBackgroundColor {
    return [SystemCSSColors primaryColor];
}

// MARK: - Factory Methods

+ (SystemButton *)createStandardButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    SystemButton *button = [[SystemButton alloc] initStandardButtonWithTitle:title];
    
    // Create a wrapper for the target-action pattern
    if (target && action) {
        button.delegate = [[SystemButtonTargetWrapper alloc] initWithTarget:target action:action];
    }
    
    return button;
}

+ (SystemButton *)createDefaultButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    SystemButton *button = [[SystemButton alloc] initDefaultButtonWithTitle:title];
    
    if (target && action) {
        button.delegate = [[SystemButtonTargetWrapper alloc] initWithTarget:target action:action];
    }
    
    return button;
}

+ (SystemWindow *)createStandardWindowWithTitle:(NSString *)title size:(NSSize)size {
    NSRect frame = NSMakeRect(0, 0, size.width, size.height);
    SystemWindow *window = [[SystemWindow alloc] initWithFrame:frame 
                                                         style:SystemWindowStyleStandard 
                                                         title:title 
                                                  showControls:YES];
    return window;
}

+ (SystemAlertBox *)createAlertWithMessage:(NSString *)message 
                                      icon:(SystemAlertIcon)icon 
                                   buttons:(NSArray<NSString *> *)buttonTitles {
    SystemAlertBox *alert = [[SystemAlertBox alloc] initWithMessage:message iconType:icon];
    
    // Add buttons
    for (NSString *buttonTitle in buttonTitles) {
        SystemButton *button = [[SystemButton alloc] initStandardButtonWithTitle:buttonTitle];
        [alert addButton:button];
    }
    
    return alert;
}

@end