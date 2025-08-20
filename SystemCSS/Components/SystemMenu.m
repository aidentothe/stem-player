//
//  SystemMenu.m
//  SystemCSS Component Library
//

#import "SystemMenu.h"

// MARK: - SystemMenuItem Implementation

@interface SystemMenuItem ()
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@end

@implementation SystemMenuItem

- (instancetype)initWithTitle:(NSString *)title {
    // Calculate width based on title
    NSDictionary *attributes = @{NSFontAttributeName: [SystemCSSColors chicago12Font]};
    NSSize textSize = [title sizeWithAttributes:attributes];
    CGFloat width = textSize.width + 20; // 10px padding on each side
    
    self = [super initWithFrame:NSMakeRect(0, 0, width, 24)];
    if (self) {
        _title = [title copy];
        _enabled = YES;
        _hasSubmenu = NO;
        _isDivider = NO;
        [self setupTrackingArea];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title submenuItems:(NSArray<SystemMenuItem *> *)submenuItems {
    self = [self initWithTitle:title];
    if (self) {
        [self setSubmenuItems:submenuItems];
    }
    return self;
}

- (instancetype)initDivider {
    self = [super initWithFrame:NSMakeRect(0, 0, 200, 1)];
    if (self) {
        _isDivider = YES;
        _enabled = NO;
        _title = @"";
    }
    return self;
}

- (void)setupTrackingArea {
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds 
                                                     options:(NSTrackingMouseEnteredAndExited | 
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

- (void)setSubmenuItems:(NSArray<SystemMenuItem *> *)submenuItems {
    _submenuItems = submenuItems;
    _hasSubmenu = (submenuItems.count > 0);
    [self setNeedsDisplay:YES];
}

- (void)addSubmenuItem:(SystemMenuItem *)item {
    if (!self.submenuItems) {
        _submenuItems = @[item];
    } else {
        NSMutableArray *mutableItems = [self.submenuItems mutableCopy];
        [mutableItems addObject:item];
        _submenuItems = [mutableItems copy];
    }
    _hasSubmenu = YES;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (self.isDivider) {
        [self drawDivider];
        return;
    }
    
    NSRect bounds = self.bounds;
    
    // Draw background
    NSColor *backgroundColor = self.isHighlighted ? [SystemCSSColors secondaryColor] : [SystemCSSColors primaryColor];
    [backgroundColor setFill];
    NSRectFill(bounds);
    
    // Draw title
    if (self.title && self.title.length > 0) {
        NSColor *textColor = self.isHighlighted ? [SystemCSSColors primaryColor] : [SystemCSSColors secondaryColor];
        if (!self.enabled) {
            textColor = [SystemCSSColors disabledColor];
        }
        
        NSDictionary *attributes = @{
            NSFontAttributeName: [SystemCSSColors chicago12Font],
            NSForegroundColorAttributeName: textColor
        };
        
        NSSize textSize = [self.title sizeWithAttributes:attributes];
        NSPoint textOrigin = NSMakePoint(10, (bounds.size.height - textSize.height) / 2);
        [self.title drawAtPoint:textOrigin withAttributes:attributes];
    }
    
    // Draw submenu indicator if this item has a submenu
    if (self.hasSubmenu) {
        [self drawSubmenuIndicator];
    }
}

- (void)drawDivider {
    NSRect bounds = self.bounds;
    
    // Draw dotted line
    [[SystemCSSColors secondaryColor] setStroke];
    
    NSBezierPath *dividerPath = [NSBezierPath bezierPath];
    [dividerPath setLineWidth:1.5];
    
    // Create dotted pattern
    CGFloat dashPattern[] = {3.0, 3.0};
    [dividerPath setLineDash:dashPattern count:2 phase:0.0];
    
    [dividerPath moveToPoint:NSMakePoint(bounds.origin.x + 10, bounds.origin.y + bounds.size.height / 2)];
    [dividerPath lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width - 10, bounds.origin.y + bounds.size.height / 2)];
    [dividerPath stroke];
}

- (void)drawSubmenuIndicator {
    // Draw small arrow indicating submenu
    NSRect bounds = self.bounds;
    NSColor *arrowColor = self.isHighlighted ? [SystemCSSColors primaryColor] : [SystemCSSColors secondaryColor];
    [arrowColor setFill];
    
    NSBezierPath *arrowPath = [NSBezierPath bezierPath];
    CGFloat arrowX = bounds.origin.x + bounds.size.width - 15;
    CGFloat arrowY = bounds.origin.y + bounds.size.height / 2;
    
    [arrowPath moveToPoint:NSMakePoint(arrowX, arrowY - 3)];
    [arrowPath lineToPoint:NSMakePoint(arrowX + 6, arrowY)];
    [arrowPath lineToPoint:NSMakePoint(arrowX, arrowY + 3)];
    [arrowPath closePath];
    [arrowPath fill];
}

- (void)mouseDown:(NSEvent *)event {
    if (!self.enabled || self.isDivider) return;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuItemWasClicked:)]) {
        [self.delegate menuItemWasClicked:self];
    }
}

- (void)mouseEntered:(NSEvent *)event {
    if (!self.enabled || self.isDivider) return;
    
    self.isHighlighted = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event {
    if (!self.enabled || self.isDivider) return;
    
    self.isHighlighted = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - SystemDropdownMenu Implementation

@interface SystemDropdownMenu () <SystemMenuItemDelegate>
@property (nonatomic, strong) NSView *overlayView;
@end

@implementation SystemDropdownMenu

- (instancetype)initWithMenuItems:(NSArray<SystemMenuItem *> *)menuItems {
    CGFloat width = 200;
    CGFloat height = menuItems.count * 24 + 4; // 24px per item + padding
    
    self = [super initWithFrame:NSMakeRect(0, 0, width, height)];
    if (self) {
        _menuItems = [menuItems copy];
        _isVisible = NO;
        [self setupMenuItems];
    }
    return self;
}

- (void)setupMenuItems {
    CGFloat currentY = 2;
    
    for (SystemMenuItem *item in self.menuItems) {
        item.delegate = self;
        
        // Adjust item width to match dropdown width
        NSRect itemFrame = item.frame;
        itemFrame.size.width = self.bounds.size.width - 4;
        itemFrame.origin.x = 2;
        itemFrame.origin.y = currentY;
        item.frame = itemFrame;
        
        [self addSubview:item];
        currentY += item.frame.size.height;
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
    [borderPath setLineWidth:1.0];
    [borderPath stroke];
    
    // Draw drop shadow
    NSRect shadowRect = NSMakeRect(bounds.origin.x + [SystemCSSColors boxShadowOffset],
                                  bounds.origin.y - [SystemCSSColors boxShadowOffset],
                                  bounds.size.width,
                                  bounds.size.height);
    [[SystemCSSColors secondaryColor] setFill];
    NSRectFill(shadowRect);
    
    // Draw vertical separator line (system.css style)
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *separatorPath = [NSBezierPath bezierPath];
    [separatorPath moveToPoint:NSMakePoint(28, bounds.origin.y)];
    [separatorPath lineToPoint:NSMakePoint(28, bounds.origin.y + bounds.size.height)];
    [separatorPath setLineWidth:2.0];
    [separatorPath stroke];
}

- (void)showAtPoint:(NSPoint)point {
    if (self.isVisible) return;
    
    // Find the main window or application window to add this dropdown to
    NSWindow *window = [NSApp mainWindow];
    if (!window) {
        window = [[NSApp windows] firstObject];
    }
    
    if (window) {
        NSView *contentView = window.contentView;
        
        // Convert point to content view coordinates
        NSPoint convertedPoint = [contentView convertPoint:point fromView:nil];
        
        // Adjust position to ensure dropdown is visible
        NSRect dropdownFrame = self.frame;
        dropdownFrame.origin = convertedPoint;
        
        // Ensure dropdown doesn't go off screen
        NSRect contentBounds = contentView.bounds;
        if (dropdownFrame.origin.x + dropdownFrame.size.width > contentBounds.size.width) {
            dropdownFrame.origin.x = contentBounds.size.width - dropdownFrame.size.width;
        }
        if (dropdownFrame.origin.y - dropdownFrame.size.height < 0) {
            dropdownFrame.origin.y = dropdownFrame.size.height;
        } else {
            dropdownFrame.origin.y -= dropdownFrame.size.height;
        }
        
        self.frame = dropdownFrame;
        [contentView addSubview:self];
        
        self.isVisible = YES;
    }
}

- (void)hide {
    if (!self.isVisible) return;
    
    [self removeFromSuperview];
    self.isVisible = NO;
}

- (void)menuItemWasClicked:(SystemMenuItem *)menuItem {
    // Hide dropdown when item is clicked
    [self hide];
    
    // Forward to parent menu item's delegate if needed
    if (self.parentMenuItem && self.parentMenuItem.delegate) {
        [self.parentMenuItem.delegate menuItemWasClicked:menuItem];
    }
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - SystemMenuBar Implementation

@interface SystemMenuBar () <SystemMenuItemDelegate>
@end

@implementation SystemMenuBar

- (instancetype)initWithMenuItems:(NSArray<SystemMenuItem *> *)menuItems {
    // Calculate total width needed
    CGFloat totalWidth = 0;
    for (SystemMenuItem *item in menuItems) {
        totalWidth += item.frame.size.width;
    }
    
    self = [super initWithFrame:NSMakeRect(0, 0, totalWidth, 24)];
    if (self) {
        _menuItems = [menuItems mutableCopy];
        [self setupMenuItems];
    }
    return self;
}

- (void)setupMenuItems {
    CGFloat currentX = 0;
    
    for (SystemMenuItem *item in self.menuItems) {
        item.delegate = self;
        item.parentMenuBar = self;
        
        NSRect itemFrame = item.frame;
        itemFrame.origin.x = currentX;
        itemFrame.origin.y = 0;
        itemFrame.size.height = self.bounds.size.height;
        item.frame = itemFrame;
        
        [self addSubview:item];
        currentX += itemFrame.size.width;
    }
}

- (void)addMenuItem:(SystemMenuItem *)item {
    [self.menuItems addObject:item];
    item.delegate = self;
    item.parentMenuBar = self;
    
    // Reposition all items
    [self setupMenuItems];
    
    // Update menu bar width
    CGFloat totalWidth = 0;
    for (SystemMenuItem *menuItem in self.menuItems) {
        totalWidth += menuItem.frame.size.width;
    }
    
    NSRect newFrame = self.frame;
    newFrame.size.width = totalWidth;
    self.frame = newFrame;
}

- (void)removeMenuItem:(SystemMenuItem *)item {
    [self.menuItems removeObject:item];
    [item removeFromSuperview];
    [self setupMenuItems];
}

- (void)hideActiveDropdown {
    if (self.activeDropdown) {
        [self.activeDropdown hide];
        self.activeDropdown = nil;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Draw menu bar background
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(self.bounds);
}

- (void)menuItemWasClicked:(SystemMenuItem *)menuItem {
    // Hide any active dropdown first
    [self hideActiveDropdown];
    
    // If this item has a submenu, show it
    if (menuItem.hasSubmenu && menuItem.submenuItems.count > 0) {
        SystemDropdownMenu *dropdown = [[SystemDropdownMenu alloc] initWithMenuItems:menuItem.submenuItems];
        dropdown.parentMenuItem = menuItem;
        
        // Calculate position for dropdown
        NSPoint dropdownPoint = NSMakePoint(menuItem.frame.origin.x, 
                                          menuItem.frame.origin.y + menuItem.frame.size.height);
        dropdownPoint = [self convertPoint:dropdownPoint toView:nil];
        
        [dropdown showAtPoint:dropdownPoint];
        self.activeDropdown = dropdown;
    }
    
    // Notify delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuBarItem:wasClicked:)]) {
        [self.delegate menuBarItem:menuItem wasClicked:self];
    }
}

- (void)mouseDown:(NSEvent *)event {
    // Hide dropdown if clicking outside of menu items
    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
    
    BOOL hitMenuItem = NO;
    for (SystemMenuItem *item in self.menuItems) {
        if (NSPointInRect(location, item.frame)) {
            hitMenuItem = YES;
            break;
        }
    }
    
    if (!hitMenuItem) {
        [self hideActiveDropdown];
    }
}

- (BOOL)isFlipped {
    return YES;
}

@end