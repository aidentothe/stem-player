//
//  SystemDialog.m
//  SystemCSS Component Library
//

#import "SystemDialog.h"

// MARK: - SystemStandardDialog Implementation

@implementation SystemStandardDialog

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
    self = [super initWithFrame:NSMakeRect(0, 0, 300, 150)];
    if (self) {
        _title = [title copy];
        _message = [message copy];
        [self setupContentView];
    }
    return self;
}

- (void)setupContentView {
    // Standard dialog is just a simple text container
    self.contentView = [[NSView alloc] initWithFrame:NSInsetRect(self.bounds, 10, 10)];
    [self addSubview:self.contentView];
}

- (void)setContentView:(NSView *)contentView {
    [self.contentView removeFromSuperview];
    _contentView = contentView;
    [self addSubview:self.contentView];
    [self layoutContent];
}

- (void)layoutContent {
    if (self.contentView) {
        [self.contentView setFrame:NSInsetRect(self.bounds, 10, 10)];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = self.bounds;
    
    // Draw background
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(bounds);
    
    // Draw border with drop shadow
    [SystemCSSColors drawRetroBoxShadowForRect:bounds inContext:[NSGraphicsContext currentContext]];
    
    // Draw main border
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:NSInsetRect(bounds, 0, [SystemCSSColors boxShadowOffset])];
    [borderPath setLineWidth:[SystemCSSColors borderWidth]];
    [borderPath stroke];
    
    // Draw title if present
    if (self.title && self.title.length > 0) {
        NSDictionary *titleAttributes = @{
            NSFontAttributeName: [SystemCSSColors chicago12Font],
            NSForegroundColorAttributeName: [SystemCSSColors secondaryColor]
        };
        
        NSSize titleSize = [self.title sizeWithAttributes:titleAttributes];
        NSPoint titleOrigin = NSMakePoint((bounds.size.width - titleSize.width) / 2, bounds.size.height - 30);
        [self.title drawAtPoint:titleOrigin withAttributes:titleAttributes];
    }
    
    // Draw message if present
    if (self.message && self.message.length > 0) {
        NSDictionary *messageAttributes = @{
            NSFontAttributeName: [SystemCSSColors genevaFont:12.0],
            NSForegroundColorAttributeName: [SystemCSSColors secondaryColor]
        };
        
        NSSize messageSize = [self.message sizeWithAttributes:messageAttributes];
        NSPoint messageOrigin = NSMakePoint((bounds.size.width - messageSize.width) / 2, bounds.size.height - 60);
        [self.message drawAtPoint:messageOrigin withAttributes:messageAttributes];
    }
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    [self layoutContent];
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - SystemModalDialog Implementation

@interface SystemModalDialog () <SystemButtonDelegate>
@end

@implementation SystemModalDialog

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:NSMakeRect(0, 0, 400, 250)];
    if (self) {
        _title = [title copy];
        _buttons = [[NSMutableArray alloc] init];
        [self setupContentView];
    }
    return self;
}

- (void)setupContentView {
    // Leave space for title, content, and buttons
    NSRect contentRect = NSMakeRect(20, 50, self.bounds.size.width - 40, self.bounds.size.height - 100);
    self.contentView = [[NSView alloc] initWithFrame:contentRect];
    [self addSubview:self.contentView];
}

- (void)setContentView:(NSView *)contentView {
    [self.contentView removeFromSuperview];
    _contentView = contentView;
    [self addSubview:self.contentView];
    [self layoutContent];
}

- (void)addButton:(SystemButton *)button {
    button.delegate = self;
    [self.buttons addObject:button];
    [self addSubview:button];
    [self layoutButtons];
}

- (void)removeButton:(SystemButton *)button {
    [self.buttons removeObject:button];
    [button removeFromSuperview];
    [self layoutButtons];
}

- (void)layoutContent {
    if (self.contentView) {
        NSRect contentRect = NSMakeRect(20, 50, self.bounds.size.width - 40, self.bounds.size.height - 100);
        [self.contentView setFrame:contentRect];
    }
}

- (void)layoutButtons {
    if (self.buttons.count == 0) return;
    
    CGFloat totalButtonWidth = 0;
    for (SystemButton *button in self.buttons) {
        totalButtonWidth += button.frame.size.width;
    }
    totalButtonWidth += (self.buttons.count - 1) * [SystemCSSColors elementSpacing];
    
    CGFloat startX = (self.bounds.size.width - totalButtonWidth) / 2;
    CGFloat currentX = startX;
    CGFloat buttonY = 15;
    
    for (SystemButton *button in self.buttons) {
        NSRect buttonFrame = button.frame;
        buttonFrame.origin.x = currentX;
        buttonFrame.origin.y = buttonY;
        button.frame = buttonFrame;
        
        currentX += buttonFrame.size.width + [SystemCSSColors elementSpacing];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = self.bounds;
    
    // Draw outer border
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *outerBorder = [NSBezierPath bezierPathWithRect:bounds];
    [outerBorder setLineWidth:[SystemCSSColors borderWidth]];
    [outerBorder stroke];
    
    // Draw inner border (double-outline effect)
    NSRect innerRect = NSInsetRect(bounds, 6, 6);
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *innerBorder = [NSBezierPath bezierPathWithRect:innerRect];
    [innerBorder setLineWidth:3.5]; // Thicker inner border
    [innerBorder stroke];
    
    // Fill background
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(NSInsetRect(innerRect, 3.5, 3.5));
    
    // Draw title
    if (self.title && self.title.length > 0) {
        NSDictionary *titleAttributes = @{
            NSFontAttributeName: [SystemCSSColors chicago12Font],
            NSForegroundColorAttributeName: [SystemCSSColors secondaryColor]
        };
        
        NSSize titleSize = [self.title sizeWithAttributes:titleAttributes];
        NSPoint titleOrigin = NSMakePoint((bounds.size.width - titleSize.width) / 2, bounds.size.height - 35);
        [self.title drawAtPoint:titleOrigin withAttributes:titleAttributes];
    }
}

- (void)systemButtonWasClicked:(SystemButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(systemDialogButtonClicked:dialog:)]) {
        [self.delegate systemDialogButtonClicked:sender dialog:self];
    }
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    [self layoutContent];
    [self layoutButtons];
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - SystemAlertBox Implementation

@implementation SystemAlertBox

- (instancetype)initWithMessage:(NSString *)message iconType:(SystemAlertIcon)iconType {
    self = [super initWithFrame:NSMakeRect(0, 0, 350, 120)];
    if (self) {
        _message = [message copy];
        _iconType = iconType;
        _buttons = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addButton:(SystemButton *)button {
    button.delegate = self;
    [self.buttons addObject:button];
    [self addSubview:button];
    [self layoutButtons];
}

- (void)removeButton:(SystemButton *)button {
    [self.buttons removeObject:button];
    [button removeFromSuperview];
    [self layoutButtons];
}

- (void)layoutButtons {
    if (self.buttons.count == 0) return;
    
    CGFloat totalButtonWidth = 0;
    for (SystemButton *button in self.buttons) {
        totalButtonWidth += button.frame.size.width;
    }
    totalButtonWidth += (self.buttons.count - 1) * [SystemCSSColors elementSpacing];
    
    CGFloat startX = self.bounds.size.width - totalButtonWidth - 20;
    CGFloat currentX = startX;
    CGFloat buttonY = 15;
    
    for (SystemButton *button in self.buttons) {
        NSRect buttonFrame = button.frame;
        buttonFrame.origin.x = currentX;
        buttonFrame.origin.y = buttonY;
        button.frame = buttonFrame;
        
        currentX += buttonFrame.size.width + [SystemCSSColors elementSpacing];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = self.bounds;
    
    // Draw outer border
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *outerBorder = [NSBezierPath bezierPathWithRect:bounds];
    [outerBorder setLineWidth:[SystemCSSColors borderWidth]];
    [outerBorder stroke];
    
    // Draw inner border
    NSRect innerRect = NSInsetRect(bounds, 6, 6);
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *innerBorder = [NSBezierPath bezierPathWithRect:innerRect];
    [innerBorder setLineWidth:3.5];
    [innerBorder stroke];
    
    // Fill background
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(NSInsetRect(innerRect, 3.5, 3.5));
    
    // Draw icon placeholder (square)
    if (self.iconType != SystemAlertIconNone) {
        NSRect iconRect = NSMakeRect(20, bounds.size.height - 70, 32, 32);
        [[SystemCSSColors secondaryColor] setStroke];
        NSBezierPath *iconBorder = [NSBezierPath bezierPathWithRect:iconRect];
        [iconBorder setLineWidth:2.0];
        [iconBorder stroke];
        
        // Draw icon based on type
        [self drawAlertIcon:self.iconType inRect:iconRect];
    }
    
    // Draw message
    if (self.message && self.message.length > 0) {
        NSDictionary *messageAttributes = @{
            NSFontAttributeName: [SystemCSSColors genevaFont:12.0],
            NSForegroundColorAttributeName: [SystemCSSColors secondaryColor]
        };
        
        // Text area starts after icon
        CGFloat textX = (self.iconType != SystemAlertIconNone) ? 65 : 20;
        NSRect textRect = NSMakeRect(textX, bounds.size.height - 85, bounds.size.width - textX - 20, 60);
        
        [self.message drawInRect:textRect withAttributes:messageAttributes];
    }
}

- (void)drawAlertIcon:(SystemAlertIcon)iconType inRect:(NSRect)rect {
    [[SystemCSSColors secondaryColor] setStroke];
    [NSBezierPath setDefaultLineWidth:2.0];
    
    switch (iconType) {
        case SystemAlertIconStop:
            // Draw stop sign (octagon)
            [self drawStopIconInRect:rect];
            break;
        case SystemAlertIconCaution:
            // Draw triangle with exclamation
            [self drawCautionIconInRect:rect];
            break;
        case SystemAlertIconNote:
            // Draw note/info icon
            [self drawNoteIconInRect:rect];
            break;
        case SystemAlertIconNone:
        default:
            break;
    }
}

- (void)drawStopIconInRect:(NSRect)rect {
    // Draw simple circle for stop icon
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(rect, 4, 4)];
    [circlePath stroke];
    
    // Draw X inside
    NSBezierPath *xPath = [NSBezierPath bezierPath];
    CGFloat inset = 8;
    [xPath moveToPoint:NSMakePoint(rect.origin.x + inset, rect.origin.y + inset)];
    [xPath lineToPoint:NSMakePoint(rect.origin.x + rect.size.width - inset, rect.origin.y + rect.size.height - inset)];
    [xPath moveToPoint:NSMakePoint(rect.origin.x + rect.size.width - inset, rect.origin.y + inset)];
    [xPath lineToPoint:NSMakePoint(rect.origin.x + inset, rect.origin.y + rect.size.height - inset)];
    [xPath stroke];
}

- (void)drawCautionIconInRect:(NSRect)rect {
    // Draw triangle
    NSBezierPath *trianglePath = [NSBezierPath bezierPath];
    [trianglePath moveToPoint:NSMakePoint(rect.origin.x + rect.size.width / 2, rect.origin.y + 4)];
    [trianglePath lineToPoint:NSMakePoint(rect.origin.x + 4, rect.origin.y + rect.size.height - 4)];
    [trianglePath lineToPoint:NSMakePoint(rect.origin.x + rect.size.width - 4, rect.origin.y + rect.size.height - 4)];
    [trianglePath closePath];
    [trianglePath stroke];
    
    // Draw exclamation mark
    CGFloat centerX = rect.origin.x + rect.size.width / 2;
    NSBezierPath *exclamationPath = [NSBezierPath bezierPath];
    [exclamationPath moveToPoint:NSMakePoint(centerX, rect.origin.y + 10)];
    [exclamationPath lineToPoint:NSMakePoint(centerX, rect.origin.y + 20)];
    [exclamationPath stroke];
    
    // Dot
    NSRect dotRect = NSMakeRect(centerX - 1, rect.origin.y + 24, 2, 2);
    [[SystemCSSColors secondaryColor] setFill];
    NSRectFill(dotRect);
}

- (void)drawNoteIconInRect:(NSRect)rect {
    // Draw circle
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(rect, 4, 4)];
    [circlePath stroke];
    
    // Draw 'i' inside
    CGFloat centerX = rect.origin.x + rect.size.width / 2;
    
    // Dot
    NSRect dotRect = NSMakeRect(centerX - 1, rect.origin.y + 8, 2, 2);
    [[SystemCSSColors secondaryColor] setFill];
    NSRectFill(dotRect);
    
    // Vertical line
    NSBezierPath *linePath = [NSBezierPath bezierPath];
    [linePath moveToPoint:NSMakePoint(centerX, rect.origin.y + 14)];
    [linePath lineToPoint:NSMakePoint(centerX, rect.origin.y + 26)];
    [linePath stroke];
}

- (void)systemButtonWasClicked:(SystemButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(systemDialogButtonClicked:dialog:)]) {
        [self.delegate systemDialogButtonClicked:sender dialog:self];
    }
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    [self layoutButtons];
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - SystemModelessDialog Implementation

@interface SystemModelessDialog () <SystemButtonDelegate>
@end

@implementation SystemModelessDialog

- (instancetype)initWithTitle:(NSString *)title showTitleBar:(BOOL)showTitleBar {
    self = [super initWithFrame:NSMakeRect(0, 0, 300, 150)];
    if (self) {
        _title = [title copy];
        _showTitleBar = showTitleBar;
        _buttons = [[NSMutableArray alloc] init];
        [self setupContentView];
    }
    return self;
}

- (void)setupContentView {
    CGFloat topOffset = self.showTitleBar ? 40 : 10;
    NSRect contentRect = NSMakeRect(10, 40, self.bounds.size.width - 20, self.bounds.size.height - topOffset - 50);
    self.contentView = [[NSView alloc] initWithFrame:contentRect];
    [self addSubview:self.contentView];
}

- (void)setContentView:(NSView *)contentView {
    [self.contentView removeFromSuperview];
    _contentView = contentView;
    [self addSubview:self.contentView];
    [self layoutContent];
}

- (void)addButton:(SystemButton *)button {
    button.delegate = self;
    [self.buttons addObject:button];
    [self addSubview:button];
    [self layoutButtons];
}

- (void)removeButton:(SystemButton *)button {
    [self.buttons removeObject:button];
    [button removeFromSuperview];
    [self layoutButtons];
}

- (void)layoutContent {
    if (self.contentView) {
        CGFloat topOffset = self.showTitleBar ? 40 : 10;
        NSRect contentRect = NSMakeRect(10, 40, self.bounds.size.width - 20, self.bounds.size.height - topOffset - 50);
        [self.contentView setFrame:contentRect];
    }
}

- (void)layoutButtons {
    if (self.buttons.count == 0) return;
    
    CGFloat totalButtonWidth = 0;
    for (SystemButton *button in self.buttons) {
        totalButtonWidth += button.frame.size.width;
    }
    totalButtonWidth += (self.buttons.count - 1) * [SystemCSSColors elementSpacing];
    
    CGFloat startX = self.bounds.size.width - totalButtonWidth - 15;
    CGFloat currentX = startX;
    CGFloat buttonY = 10;
    
    for (SystemButton *button in self.buttons) {
        NSRect buttonFrame = button.frame;
        buttonFrame.origin.x = currentX;
        buttonFrame.origin.y = buttonY;
        button.frame = buttonFrame;
        
        currentX += buttonFrame.size.width + [SystemCSSColors elementSpacing];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = self.bounds;
    
    // Draw background
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(bounds);
    
    // Draw border
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:bounds];
    [borderPath setLineWidth:[SystemCSSColors borderWidth]];
    [borderPath stroke];
    
    // Draw title bar if enabled
    if (self.showTitleBar) {
        NSRect titleBarRect = NSMakeRect(0, bounds.size.height - 25, bounds.size.width, 25);
        
        // Draw title bar background with racing stripes
        [SystemCSSColors drawRacingStripesInRect:NSInsetRect(titleBarRect, 2, 2)];
        
        // Draw title
        if (self.title && self.title.length > 0) {
            NSDictionary *titleAttributes = @{
                NSFontAttributeName: [SystemCSSColors chicago12Font],
                NSForegroundColorAttributeName: [SystemCSSColors secondaryColor],
                NSBackgroundColorAttributeName: [SystemCSSColors primaryColor]
            };
            
            NSSize titleSize = [self.title sizeWithAttributes:titleAttributes];
            NSPoint titleOrigin = NSMakePoint((bounds.size.width - titleSize.width) / 2, bounds.size.height - 20);
            
            // Draw background for title text
            NSRect titleBgRect = NSMakeRect(titleOrigin.x - 4, titleOrigin.y - 2, titleSize.width + 8, titleSize.height + 4);
            [[SystemCSSColors primaryColor] setFill];
            NSRectFill(titleBgRect);
            
            [self.title drawAtPoint:titleOrigin withAttributes:titleAttributes];
        }
        
        // Draw separator line
        [[SystemCSSColors secondaryColor] setStroke];
        NSBezierPath *separatorPath = [NSBezierPath bezierPath];
        [separatorPath moveToPoint:NSMakePoint(0, bounds.size.height - 25)];
        [separatorPath lineToPoint:NSMakePoint(bounds.size.width, bounds.size.height - 25)];
        [separatorPath stroke];
    }
}

- (void)systemButtonWasClicked:(SystemButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(systemDialogButtonClicked:dialog:)]) {
        [self.delegate systemDialogButtonClicked:sender dialog:self];
    }
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    [self layoutContent];
    [self layoutButtons];
}

- (BOOL)isFlipped {
    return YES;
}

@end