//
//  SystemWindow.m
//  SystemCSS Component Library
//

#import "SystemWindow.h"

// MARK: - SystemTitleBar Implementation

@implementation SystemTitleBar

- (instancetype)initWithTitle:(NSString *)title showControls:(BOOL)showControls {
    CGFloat height = [SystemCSSColors titleBarHeight];
    self = [super initWithFrame:NSMakeRect(0, 0, 320, height)];
    if (self) {
        _title = [title copy];
        _isActive = YES;
        _showCloseButton = showControls;
        _showResizeButton = showControls;
        [self setupControls];
    }
    return self;
}

- (void)setupControls {
    if (self.showCloseButton) {
        self.closeButton = [[SystemButton alloc] initTitleBarCloseButton];
        self.closeButton.delegate = self;
        [self addSubview:self.closeButton];
    }
    
    if (self.showResizeButton) {
        self.resizeButton = [[SystemButton alloc] initTitleBarResizeButton];
        self.resizeButton.delegate = self;
        [self addSubview:self.resizeButton];
    }
}

- (void)setActive:(BOOL)active {
    _isActive = active;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = self.bounds;
    
    // Draw background
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(bounds);
    
    // Draw racing stripes pattern if active
    if (self.isActive) {
        [SystemCSSColors drawRacingStripesInRect:NSInsetRect(bounds, 4, 2)];
    }
    
    // Draw title
    if (self.title && self.title.length > 0) {
        NSColor *textColor = self.isActive ? [SystemCSSColors secondaryColor] : [SystemCSSColors tertiaryColor];
        NSDictionary *attributes = @{
            NSFontAttributeName: [SystemCSSColors chicago12Font],
            NSForegroundColorAttributeName: textColor,
            NSBackgroundColorAttributeName: [SystemCSSColors primaryColor]
        };
        
        NSSize textSize = [self.title sizeWithAttributes:attributes];
        NSPoint textOrigin = NSMakePoint((bounds.size.width - textSize.width) / 2,
                                        (bounds.size.height - textSize.height) / 2);
        
        // Draw background for title text
        NSRect textBgRect = NSMakeRect(textOrigin.x - 8, textOrigin.y, textSize.width + 16, textSize.height);
        [[SystemCSSColors primaryColor] setFill];
        NSRectFill(textBgRect);
        
        [self.title drawAtPoint:textOrigin withAttributes:attributes];
    }
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    
    // Position close button
    if (self.closeButton) {
        [self.closeButton setFrame:NSMakeRect(4, (self.bounds.size.height - 20) / 2, 20, 20)];
    }
    
    // Position resize button
    if (self.resizeButton) {
        [self.resizeButton setFrame:NSMakeRect(self.bounds.size.width - 24, 
                                             (self.bounds.size.height - 20) / 2, 20, 20)];
    }
}

- (void)systemButtonWasClicked:(SystemButton *)sender {
    if (sender == self.closeButton && self.delegate) {
        [self.delegate systemWindowCloseButtonClicked:self];
    } else if (sender == self.resizeButton && self.delegate) {
        [self.delegate systemWindowResizeButtonClicked:self];
    }
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - SystemDetailsBar Implementation

@implementation SystemDetailsBar

- (instancetype)initWithDetails:(NSArray<NSString *> *)details {
    self = [super initWithFrame:NSMakeRect(0, 0, 320, 24)];
    if (self) {
        _details = [details mutableCopy];
    }
    return self;
}

- (void)addDetail:(NSString *)detail {
    [self.details addObject:detail];
    [self setNeedsDisplay:YES];
}

- (void)removeAllDetails {
    [self.details removeAllObjects];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = self.bounds;
    
    // Draw background
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(bounds);
    
    // Draw borders
    [[SystemCSSColors secondaryColor] setStroke];
    [NSBezierPath setDefaultLineWidth:1.0];
    
    // Top border
    NSBezierPath *topBorder = [NSBezierPath bezierPath];
    [topBorder moveToPoint:NSMakePoint(bounds.origin.x, bounds.origin.y + bounds.size.height)];
    [topBorder lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];
    [topBorder stroke];
    
    // Bottom border
    NSBezierPath *bottomBorder = [NSBezierPath bezierPath];
    [bottomBorder moveToPoint:NSMakePoint(bounds.origin.x, bounds.origin.y)];
    [bottomBorder lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y)];
    [bottomBorder stroke];
    
    // Draw details
    if (self.details.count > 0) {
        NSDictionary *attributes = @{
            NSFontAttributeName: [SystemCSSColors genevaFont:12.0],
            NSForegroundColorAttributeName: [SystemCSSColors secondaryColor]
        };
        
        CGFloat totalWidth = bounds.size.width - 16; // 8px padding on each side
        CGFloat spacing = totalWidth / self.details.count;
        
        for (NSUInteger i = 0; i < self.details.count; i++) {
            NSString *detail = self.details[i];
            NSPoint textOrigin = NSMakePoint(8 + (i * spacing), 
                                           (bounds.size.height - 12) / 2);
            [detail drawAtPoint:textOrigin withAttributes:attributes];
        }
    }
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - SystemWindowPane Implementation

@implementation SystemWindowPane

- (instancetype)initWithScrollable:(BOOL)scrollable {
    self = [super initWithFrame:NSMakeRect(0, 0, 320, 200)];
    if (self) {
        _scrollable = scrollable;
        [self setupContentView];
    }
    return self;
}

- (void)setupContentView {
    if (self.scrollable) {
        self.scrollView = [[NSScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.hasVerticalScroller = YES;
        self.scrollView.hasHorizontalScroller = NO;
        self.scrollView.autohidesScrollers = NO;
        self.scrollView.borderType = NSNoBorder;
        
        // Style scrollbars to match system.css
        [self.scrollView.verticalScroller setControlSize:NSControlSizeRegular];
        
        self.contentView = [[NSView alloc] initWithFrame:self.bounds];
        self.scrollView.documentView = self.contentView;
        
        [self addSubview:self.scrollView];
    } else {
        self.contentView = [[NSView alloc] initWithFrame:self.bounds];
        [self addSubview:self.contentView];
    }
}

- (void)setContentView:(NSView *)contentView {
    if (self.scrollable) {
        self.scrollView.documentView = contentView;
    } else {
        [self.contentView removeFromSuperview];
        self.contentView = contentView;
        [self addSubview:self.contentView];
    }
    _contentView = contentView;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Draw background
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(self.bounds);
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    
    if (self.scrollView) {
        [self.scrollView setFrame:self.bounds];
    } else if (self.contentView) {
        [self.contentView setFrame:self.bounds];
    }
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - SystemWindow Implementation

@implementation SystemWindow

// MARK: - Initializers

- (instancetype)initWithFrame:(NSRect)frameRect 
                        style:(SystemWindowStyle)style 
                        title:(NSString *)title 
                 showControls:(BOOL)showControls {
    self = [super initWithFrame:frameRect];
    if (self) {
        _windowStyle = style;
        _isActive = YES;
        
        [self setupWithTitle:title showControls:showControls];
        [self layoutComponents];
    }
    return self;
}

- (instancetype)initStandardWindowWithTitle:(NSString *)title {
    NSRect frame = NSMakeRect(0, 0, 320, 240);
    return [self initWithFrame:frame style:SystemWindowStyleStandard title:title showControls:YES];
}

- (instancetype)initDialogWindowWithTitle:(NSString *)title {
    NSRect frame = NSMakeRect(0, 0, 300, 150);
    return [self initWithFrame:frame style:SystemWindowStyleDialog title:title showControls:NO];
}

- (instancetype)initModelessWindowWithTitle:(NSString *)title {
    NSRect frame = NSMakeRect(0, 0, 280, 120);
    return [self initWithFrame:frame style:SystemWindowStyleModeless title:title showControls:YES];
}

- (void)setupWithTitle:(NSString *)title showControls:(BOOL)showControls {
    // Create title bar
    self.titleBar = [[SystemTitleBar alloc] initWithTitle:title showControls:showControls];
    self.titleBar.delegate = self;
    [self addSubview:self.titleBar];
    
    // Create window pane
    BOOL scrollable = (self.windowStyle == SystemWindowStyleStandard);
    self.windowPane = [[SystemWindowPane alloc] initWithScrollable:scrollable];
    [self addSubview:self.windowPane];
}

- (void)layoutComponents {
    NSRect bounds = self.bounds;
    CGFloat titleBarHeight = [SystemCSSColors titleBarHeight];
    CGFloat detailsBarHeight = self.detailsBar ? 24 : 0;
    
    // Position title bar
    [self.titleBar setFrame:NSMakeRect(0, 0, bounds.size.width, titleBarHeight)];
    
    // Position details bar if present
    if (self.detailsBar) {
        [self.detailsBar setFrame:NSMakeRect(0, titleBarHeight, bounds.size.width, detailsBarHeight)];
    }
    
    // Position window pane
    CGFloat paneY = titleBarHeight + detailsBarHeight;
    CGFloat paneHeight = bounds.size.height - paneY;
    [self.windowPane setFrame:NSMakeRect(0, paneY, bounds.size.width, paneHeight)];
}

// MARK: - Configuration

- (void)setTitle:(NSString *)title {
    self.titleBar.title = title;
}

- (void)setActive:(BOOL)active {
    _isActive = active;
    [self.titleBar setActive:active];
    [self setNeedsDisplay:YES];
}

- (void)addDetailsBar:(NSArray<NSString *> *)details {
    if (!self.detailsBar) {
        self.detailsBar = [[SystemDetailsBar alloc] initWithDetails:details];
        [self addSubview:self.detailsBar];
        [self layoutComponents];
    }
}

- (void)removeDetailsBar {
    if (self.detailsBar) {
        [self.detailsBar removeFromSuperview];
        self.detailsBar = nil;
        [self layoutComponents];
    }
}

- (void)setWindowContent:(NSView *)contentView {
    [self.windowPane setContentView:contentView];
}

// MARK: - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = self.bounds;
    
    // Draw window background
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(bounds);
    
    // Draw window border
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:bounds];
    [borderPath setLineWidth:[SystemCSSColors borderWidth]];
    [borderPath stroke];
    
    // Draw separator line below title bar
    NSBezierPath *separator = [NSBezierPath bezierPath];
    CGFloat separatorY = [SystemCSSColors titleBarHeight];
    [separator moveToPoint:NSMakePoint(0, separatorY)];
    [separator lineToPoint:NSMakePoint(bounds.size.width, separatorY)];
    [separator stroke];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    [self layoutComponents];
}

// MARK: - Window Controls

- (void)performClose {
    if (self.delegate && [self.delegate respondsToSelector:@selector(systemWindowCloseButtonClicked:)]) {
        [self.delegate systemWindowCloseButtonClicked:self];
    }
}

- (void)performResize {
    if (self.delegate && [self.delegate respondsToSelector:@selector(systemWindowResizeButtonClicked:)]) {
        [self.delegate systemWindowResizeButtonClicked:self];
    }
}

// MARK: - SystemButtonDelegate

- (void)systemButtonWasClicked:(SystemButton *)sender {
    // This will be called by the title bar, which will then call our delegate
}

// MARK: - SystemWindowDelegate (for title bar)

- (void)systemWindowCloseButtonClicked:(id)sender {
    [self performClose];
}

- (void)systemWindowResizeButtonClicked:(id)sender {
    [self performResize];
}

- (BOOL)isFlipped {
    return YES;
}

@end