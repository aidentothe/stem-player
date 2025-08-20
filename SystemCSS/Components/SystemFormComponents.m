//
//  SystemFormComponents.m
//  SystemCSS Component Library
//

#import "SystemFormComponents.h"

// MARK: - SystemTextField Implementation

@interface SystemTextField ()
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL isFocused;
@end

@implementation SystemTextField

- (instancetype)initWithFrame:(NSRect)frameRect secure:(BOOL)secure {
    self = [super initWithFrame:frameRect];
    if (self) {
        _enabled = YES;
        _isSecure = secure;
        [self setupTextField];
        [self setupTrackingArea];
    }
    return self;
}

- (instancetype)initStandardTextField {
    return [self initWithFrame:NSMakeRect(0, 0, 200, 24) secure:NO];
}

- (instancetype)initPasswordField {
    return [self initWithFrame:NSMakeRect(0, 0, 200, 24) secure:YES];
}

- (void)setupTextField {
    NSRect textFieldFrame = NSInsetRect(self.bounds, 3, 3);
    
    if (self.isSecure) {
        self.textField = [[NSSecureTextField alloc] initWithFrame:textFieldFrame];
    } else {
        self.textField = [[NSTextField alloc] initWithFrame:textFieldFrame];
    }
    
    self.textField.font = [SystemCSSColors chicago12Font];
    self.textField.backgroundColor = [SystemCSSColors primaryColor];
    self.textField.textColor = [SystemCSSColors secondaryColor];
    self.textField.bordered = NO;
    self.textField.delegate = self;
    
    [self addSubview:self.textField];
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

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = self.bounds;
    
    // Draw background
    NSColor *backgroundColor = self.isFocused ? [SystemCSSColors secondaryColor] : [SystemCSSColors primaryColor];
    [backgroundColor setFill];
    NSRectFill(bounds);
    
    // Update text field colors based on focus
    if (self.isFocused) {
        self.textField.backgroundColor = [SystemCSSColors secondaryColor];
        self.textField.textColor = [SystemCSSColors primaryColor];
    } else {
        self.textField.backgroundColor = [SystemCSSColors primaryColor];
        self.textField.textColor = [SystemCSSColors secondaryColor];
    }
    
    // Draw border
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:bounds];
    [borderPath setLineWidth:1.5];
    [borderPath stroke];
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    self.textField.stringValue = text ?: @"";
}

- (void)setPlaceholderText:(NSString *)placeholderText {
    _placeholderText = [placeholderText copy];
    self.textField.placeholderString = placeholderText;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.textField.enabled = enabled;
    [self setNeedsDisplay:YES];
}

- (BOOL)becomeFirstResponder {
    self.isFocused = YES;
    [self setNeedsDisplay:YES];
    return [self.textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    self.isFocused = NO;
    [self setNeedsDisplay:YES];
    return [self.textField resignFirstResponder];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    self.textField.frame = NSInsetRect(self.bounds, 3, 3);
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - SystemRadioButton Implementation

@interface SystemRadioButton ()
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL isHighlighted;
@end

@implementation SystemRadioButton

- (instancetype)initWithTitle:(NSString *)title groupName:(NSString *)groupName {
    // Calculate width based on title
    NSDictionary *attributes = @{NSFontAttributeName: [SystemCSSColors chicago12Font]};
    NSSize textSize = [title sizeWithAttributes:attributes];
    CGFloat width = 20 + 6 + textSize.width; // radio button + spacing + text
    
    self = [super initWithFrame:NSMakeRect(0, 0, width, 20)];
    if (self) {
        _title = [title copy];
        _groupName = [groupName copy];
        _enabled = YES;
        _selected = NO;
        [self setupTrackingArea];
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

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Draw radio button circle
    NSRect radioRect = NSMakeRect(0, 2, 16, 16);
    
    // Draw radio button border
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *radioPath = [NSBezierPath bezierPathWithOvalInRect:radioRect];
    [radioPath setLineWidth:self.isHighlighted ? 2.0 : 1.5];
    [radioPath stroke];
    
    // Draw radio button background
    [[SystemCSSColors primaryColor] setFill];
    [radioPath fill];
    
    // Draw radio dot if selected
    if (self.selected) {
        NSRect dotRect = NSInsetRect(radioRect, 5, 5);
        [[SystemCSSColors secondaryColor] setFill];
        NSBezierPath *dotPath = [NSBezierPath bezierPathWithOvalInRect:dotRect];
        [dotPath fill];
    }
    
    // Draw label
    if (self.title && self.title.length > 0) {
        NSColor *textColor = self.enabled ? [SystemCSSColors secondaryColor] : [SystemCSSColors disabledColor];
        NSDictionary *attributes = @{
            NSFontAttributeName: [SystemCSSColors chicago12Font],
            NSForegroundColorAttributeName: textColor
        };
        
        NSPoint textOrigin = NSMakePoint(22, 4);
        [self.title drawAtPoint:textOrigin withAttributes:attributes];
    }
}

- (void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        _selected = selected;
        
        // Deselect other radio buttons in the same group
        if (selected && self.groupName) {
            [self deselectOtherRadioButtonsInGroup];
        }
        
        [self setNeedsDisplay:YES];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(radioButtonSelectionChanged:)]) {
            [self.delegate radioButtonSelectionChanged:self];
        }
    }
}

- (void)deselectOtherRadioButtonsInGroup {
    NSView *superview = self.superview;
    if (!superview) return;
    
    for (NSView *subview in superview.subviews) {
        if ([subview isKindOfClass:[SystemRadioButton class]] && subview != self) {
            SystemRadioButton *otherRadio = (SystemRadioButton *)subview;
            if ([otherRadio.groupName isEqualToString:self.groupName]) {
                otherRadio->_selected = NO;
                [otherRadio setNeedsDisplay:YES];
            }
        }
    }
}

- (void)mouseDown:(NSEvent *)event {
    if (!self.enabled) return;
    
    [self setSelected:YES];
}

- (void)mouseEntered:(NSEvent *)event {
    if (!self.enabled) return;
    
    self.isHighlighted = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event {
    if (!self.enabled) return;
    
    self.isHighlighted = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - SystemCheckbox Implementation

@interface SystemCheckbox ()
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL isHighlighted;
@end

@implementation SystemCheckbox

- (instancetype)initWithTitle:(NSString *)title {
    // Calculate width based on title
    NSDictionary *attributes = @{NSFontAttributeName: [SystemCSSColors chicago12Font]};
    NSSize textSize = [title sizeWithAttributes:attributes];
    CGFloat width = 20 + 6 + textSize.width; // checkbox + spacing + text
    
    self = [super initWithFrame:NSMakeRect(0, 0, width, 20)];
    if (self) {
        _title = [title copy];
        _enabled = YES;
        _checked = NO;
        [self setupTrackingArea];
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

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Draw checkbox square
    NSRect checkboxRect = NSMakeRect(0, 2, 16, 16);
    
    // Draw checkbox background
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(checkboxRect);
    
    // Draw checkbox border
    [[SystemCSSColors secondaryColor] setStroke];
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:checkboxRect];
    [borderPath setLineWidth:self.isHighlighted ? 2.0 : 1.5];
    [borderPath stroke];
    
    // Draw checkmark if checked
    if (self.checked) {
        [[SystemCSSColors secondaryColor] setStroke];
        NSBezierPath *checkPath = [NSBezierPath bezierPath];
        [checkPath setLineWidth:2.0];
        
        // Draw checkmark
        [checkPath moveToPoint:NSMakePoint(checkboxRect.origin.x + 3, checkboxRect.origin.y + 8)];
        [checkPath lineToPoint:NSMakePoint(checkboxRect.origin.x + 7, checkboxRect.origin.y + 12)];
        [checkPath lineToPoint:NSMakePoint(checkboxRect.origin.x + 13, checkboxRect.origin.y + 4)];
        [checkPath stroke];
    }
    
    // Draw label
    if (self.title && self.title.length > 0) {
        NSColor *textColor = self.enabled ? [SystemCSSColors secondaryColor] : [SystemCSSColors disabledColor];
        NSDictionary *attributes = @{
            NSFontAttributeName: [SystemCSSColors chicago12Font],
            NSForegroundColorAttributeName: textColor
        };
        
        NSPoint textOrigin = NSMakePoint(22, 4);
        [self.title drawAtPoint:textOrigin withAttributes:attributes];
    }
}

- (void)setChecked:(BOOL)checked {
    if (_checked != checked) {
        _checked = checked;
        [self setNeedsDisplay:YES];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(checkboxStateChanged:)]) {
            [self.delegate checkboxStateChanged:self];
        }
    }
}

- (void)mouseDown:(NSEvent *)event {
    if (!self.enabled) return;
    
    [self setChecked:!self.checked];
}

- (void)mouseEntered:(NSEvent *)event {
    if (!self.enabled) return;
    
    self.isHighlighted = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event {
    if (!self.enabled) return;
    
    self.isHighlighted = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - SystemSelectMenu Implementation

@interface SystemSelectMenu ()
@property (nonatomic, strong) NSPopUpButton *popUpButton;
@end

@implementation SystemSelectMenu

- (instancetype)initWithItems:(NSArray<NSString *> *)items {
    self = [super initWithFrame:NSMakeRect(0, 0, 160, 24)];
    if (self) {
        _items = [items copy];
        _selectedIndex = 0;
        _enabled = YES;
        [self setupPopUpButton];
    }
    return self;
}

- (void)setupPopUpButton {
    self.popUpButton = [[NSPopUpButton alloc] initWithFrame:self.bounds];
    self.popUpButton.bordered = NO;
    self.popUpButton.font = [SystemCSSColors chicago12Font];
    
    // Style the popup button to match system.css
    [self.popUpButton.cell setBackgroundColor:[SystemCSSColors primaryColor]];
    
    [self updateMenuItems];
    [self addSubview:self.popUpButton];
    
    [self.popUpButton setTarget:self];
    [self.popUpButton setAction:@selector(selectionChanged:)];
}

- (void)updateMenuItems {
    [self.popUpButton removeAllItems];
    
    for (NSString *item in self.items) {
        [self.popUpButton addItemWithTitle:item];
    }
    
    if (self.selectedIndex < self.items.count) {
        [self.popUpButton selectItemAtIndex:self.selectedIndex];
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
    [borderPath setLineWidth:1.5];
    [borderPath stroke];
    
    // Draw drop shadow
    NSRect shadowRect = NSMakeRect(bounds.origin.x + 2, 
                                  bounds.origin.y - 2, 
                                  bounds.size.width, 
                                  bounds.size.height);
    [[SystemCSSColors secondaryColor] setFill];
    NSRectFill(shadowRect);
    
    // Draw dropdown arrow
    NSRect arrowRect = NSMakeRect(bounds.size.width - 20, bounds.origin.y + 6, 12, 12);
    [[SystemCSSColors secondaryColor] setFill];
    
    NSBezierPath *arrowPath = [NSBezierPath bezierPath];
    [arrowPath moveToPoint:NSMakePoint(arrowRect.origin.x, arrowRect.origin.y)];
    [arrowPath lineToPoint:NSMakePoint(arrowRect.origin.x + arrowRect.size.width, arrowRect.origin.y)];
    [arrowPath lineToPoint:NSMakePoint(arrowRect.origin.x + arrowRect.size.width / 2, 
                                      arrowRect.origin.y + arrowRect.size.height)];
    [arrowPath closePath];
    [arrowPath fill];
}

- (void)setItems:(NSArray<NSString *> *)items {
    _items = [items copy];
    [self updateMenuItems];
    [self setNeedsDisplay:YES];
}

- (void)selectItemAtIndex:(NSInteger)index {
    if (index >= 0 && index < self.items.count) {
        _selectedIndex = index;
        [self.popUpButton selectItemAtIndex:index];
        [self setNeedsDisplay:YES];
    }
}

- (NSString *)selectedItem {
    if (self.selectedIndex >= 0 && self.selectedIndex < self.items.count) {
        return self.items[self.selectedIndex];
    }
    return nil;
}

- (void)selectionChanged:(id)sender {
    _selectedIndex = self.popUpButton.indexOfSelectedItem;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectMenuSelectionChanged:)]) {
        [self.delegate selectMenuSelectionChanged:self];
    }
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    self.popUpButton.frame = NSInsetRect(self.bounds, 20, 2); // Leave space for arrow
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - SystemFieldRow Implementation

@implementation SystemFieldRow

- (instancetype)initWithComponents:(NSArray<NSView *> *)components {
    self = [super initWithFrame:NSMakeRect(0, 0, 300, 24)];
    if (self) {
        _fieldComponents = [components mutableCopy];
        [self layoutComponents];
    }
    return self;
}

- (void)addComponent:(NSView *)component {
    [self.fieldComponents addObject:component];
    [self addSubview:component];
    [self layoutComponents];
}

- (void)removeComponent:(NSView *)component {
    [self.fieldComponents removeObject:component];
    [component removeFromSuperview];
    [self layoutComponents];
}

- (void)layoutComponents {
    CGFloat currentX = 0;
    CGFloat spacing = [SystemCSSColors groupedElementSpacing];
    
    for (NSView *component in self.fieldComponents) {
        [self addSubview:component];
        
        NSRect componentFrame = component.frame;
        componentFrame.origin.x = currentX;
        componentFrame.origin.y = (self.bounds.size.height - componentFrame.size.height) / 2;
        component.frame = componentFrame;
        
        currentX += componentFrame.size.width + spacing;
    }
    
    // Update our frame width to fit all components
    if (currentX > spacing) {
        NSRect newFrame = self.frame;
        newFrame.size.width = currentX - spacing;
        self.frame = newFrame;
    }
}

- (BOOL)isFlipped {
    return YES;
}

@end