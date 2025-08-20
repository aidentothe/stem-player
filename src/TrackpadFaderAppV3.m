//
//  TrackpadFaderAppV3.m
//  System.css styled fader app with proper cursor confinement
//

#import "TrackpadFaderAppV3.h"
#import <Carbon/Carbon.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

// MAX_FADERS is now replaced with dynamic _currentFaderCount

#pragma mark - System.css Window

@interface SystemFaderWindow : NSWindow
@property (weak) TrackpadFaderAppV3 *faderApp;
@property (nonatomic) BOOL isTracking;
@end

@implementation SystemFaderWindow

- (instancetype)initWithContentRect:(NSRect)contentRect 
                          styleMask:(NSWindowStyleMask)style 
                            backing:(NSBackingStoreType)backingStoreType 
                              defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect 
                             styleMask:style 
                               backing:backingStoreType 
                                 defer:flag];
    if (self) {
        self.acceptsMouseMovedEvents = YES;
        self.movableByWindowBackground = NO; // Prevent window movement during cursor lock
    }
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)canBecomeMainWindow {
    return YES;
}

- (void)sendEvent:(NSEvent *)event {
    if (event.type == NSEventTypeKeyDown) {
        unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
        
        // ESC key - always free cursor
        if (key == 27 || event.keyCode == 53) {
            [self.faderApp emergencyFreeCursor];
            return;
        }
        
        // Only handle fader-specific keys when we're in the fader view (not song selection)
        // Check if the fader container exists and is visible
        if (self.faderApp.faderContainer && self.faderApp.faderContainer.superview) {
            // Space - toggle play/pause
            if (key == ' ') {
                if (self.faderApp.isPlaying) {
                    [self.faderApp pauseAudio];
                } else {
                    [self.faderApp playAudio];
                }
                return;
            }
            
            // Number keys 1-5 for fader control
            if (key >= '1' && key <= '5') {
                NSInteger faderIndex = key - '1';
                [self.faderApp toggleMuteFader:faderIndex];
                return;
            }
            
            // R - reset all faders (only in fader view)
            if (key == 'r' || key == 'R') {
                [self.faderApp resetAllFaders];
                return;
            }
        }
    }
    
    [super sendEvent:event];
}

- (void)resignKeyWindow {
    [super resignKeyWindow];
    // Auto-release cursor when window loses focus
    if (self.faderApp.cursorLocked) {
        [self.faderApp emergencyFreeCursor];
    }
}

@end

#pragma mark - Custom Table Row View

@interface CustomTableRowView : NSTableRowView
@end

@implementation CustomTableRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
        NSRect selectionRect = self.bounds;
        // Use a light gray for selection instead of dark blue/black
        [[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] setFill];
        NSRectFill(selectionRect);
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setNeedsDisplay:YES];
}

@end

#pragma mark - System.css Fader Control

@implementation SystemCSSFader {
    NSRect _knobRect;
    NSRect _trackRect;
    NSTrackingArea *_trackingArea;
    BOOL _isDragging;
    CGFloat _lastMouseY;
}

- (instancetype)initWithFrame:(NSRect)frame label:(NSString *)label index:(NSInteger)index {
    self = [super initWithFrame:frame];
    if (self) {
        _label = [label copy];
        _faderIndex = index;
        _minValue = 0.0;
        _maxValue = 100.0;
        _value = 50.0;
        _isActive = NO;
        _isMuted = NO;
        
        [self setupTrackingArea];
    }
    return self;
}

- (void)setupTrackingArea {
    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
    }
    
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                 options:(NSTrackingActiveInKeyWindow | 
                                                        NSTrackingMouseEnteredAndExited | 
                                                        NSTrackingMouseMoved)
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    [self setupTrackingArea];
}

- (void)setValue:(CGFloat)value animated:(BOOL)animated {
    CGFloat clampedValue = MIN(MAX(value, _minValue), _maxValue);
    
    if (animated) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.15;
            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [[self animator] setValue:clampedValue];
        }];
    } else {
        _value = clampedValue;
        [self setNeedsDisplay:YES];
    }
    
    if ([_delegate respondsToSelector:@selector(fader:valueChanged:)]) {
        [_delegate fader:self valueChanged:_value];
    }
}

- (void)setActive:(BOOL)active {
    _isActive = active;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect bounds = self.bounds;
    CGFloat margin = 10.0;
    CGFloat labelHeight = 20.0;
    CGFloat knobHeight = 14.0;
    CGFloat knobWidth = bounds.size.width - (margin * 2);
    
    // System.css window frame style
    [[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] setFill];
    NSRectFill(bounds);
    
    // Draw border
    [[NSColor blackColor] setStroke];
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:NSInsetRect(bounds, 0.5, 0.5)];
    [borderPath setLineWidth:2.0];
    [borderPath stroke];
    
    // Draw inner border (system.css double border effect)
    [[NSColor whiteColor] setStroke];
    NSBezierPath *innerBorder = [NSBezierPath bezierPathWithRect:NSInsetRect(bounds, 2.5, 2.5)];
    [innerBorder setLineWidth:1.0];
    [innerBorder stroke];
    
    // Calculate track rect
    _trackRect = NSMakeRect(margin, labelHeight + margin, 
                           knobWidth, bounds.size.height - labelHeight - (margin * 2));
    
    // Draw track background (system.css style)
    [[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] setFill];
    NSRectFill(_trackRect);
    
    // Draw track inset border
    [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] setStroke];
    NSBezierPath *trackBorder = [NSBezierPath bezierPathWithRect:_trackRect];
    [trackBorder setLineWidth:1.0];
    [trackBorder stroke];
    
    // Draw track groove
    NSRect grooveRect = NSInsetRect(_trackRect, 2, 2);
    [[NSColor whiteColor] setFill];
    NSRectFill(grooveRect);
    
    // Draw value fill (system.css progress bar style)
    CGFloat valueRatio = (_value - _minValue) / (_maxValue - _minValue);
    CGFloat fillHeight = grooveRect.size.height * valueRatio;
    NSRect fillRect = NSMakeRect(grooveRect.origin.x, 
                                grooveRect.origin.y,
                                grooveRect.size.width, 
                                fillHeight);
    
    NSColor *fillColor;
    if (_isMuted) {
        fillColor = [NSColor colorWithCalibratedWhite:0.5 alpha:1.0];  // Gray for muted
    } else if (_isActive) {
        fillColor = [NSColor blackColor];  // Black for active
    } else {
        fillColor = [NSColor colorWithCalibratedWhite:0.3 alpha:1.0];  // Dark gray for normal
    }
    [fillColor setFill];
    NSRectFill(fillRect);
    
    // Draw tick marks
    [[NSColor colorWithCalibratedWhite:0.3 alpha:1.0] setStroke];
    for (int i = 0; i <= 10; i++) {
        CGFloat y = grooveRect.origin.y + (grooveRect.size.height * i / 10.0);
        NSBezierPath *tick = [NSBezierPath bezierPath];
        [tick moveToPoint:NSMakePoint(grooveRect.origin.x - 3, y)];
        [tick lineToPoint:NSMakePoint(grooveRect.origin.x, y)];
        [tick setLineWidth:1.0];
        [tick stroke];
    }
    
    // Calculate knob position
    CGFloat knobY = _trackRect.origin.y + (_trackRect.size.height - knobHeight) * valueRatio;
    _knobRect = NSMakeRect(_trackRect.origin.x, knobY, knobWidth, knobHeight);
    
    // Draw knob (system.css button style)
    // Shadow
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.3] setFill];
    NSRect shadowRect = NSOffsetRect(_knobRect, 1, -1);
    NSRectFill(shadowRect);
    
    // Knob background
    NSColor *knobColor;
    if (_isMuted) {
        knobColor = [NSColor colorWithCalibratedWhite:0.6 alpha:1.0];  // Light gray for muted
    } else if (_isActive) {
        knobColor = [NSColor blackColor];  // Black for active
    } else {
        knobColor = [NSColor colorWithCalibratedWhite:0.9 alpha:1.0];  // White for normal
    }
    [knobColor setFill];
    NSRectFill(_knobRect);
    
    // Knob border
    [[NSColor blackColor] setStroke];
    NSBezierPath *knobBorder = [NSBezierPath bezierPathWithRect:_knobRect];
    [knobBorder setLineWidth:2.0];
    [knobBorder stroke];
    
    // Knob highlight (system.css 3D effect)
    [[NSColor whiteColor] setFill];
    NSRect highlightRect = NSMakeRect(_knobRect.origin.x + 2, 
                                     _knobRect.origin.y + 2,
                                     _knobRect.size.width - 4, 2);
    NSRectFill(highlightRect);
    
    // Draw label
    NSString *labelText;
    NSDictionary *labelAttrs;
    
    if (_isMuted) {
        labelText = [NSString stringWithFormat:@"%@ [MUTE]", _label];
        labelAttrs = @{
            NSFontAttributeName: [NSFont boldSystemFontOfSize:10],
            NSForegroundColorAttributeName: [NSColor darkGrayColor]
        };
    } else {
        labelText = [NSString stringWithFormat:@"%@ (%.0f%%)", _label, _value];
        labelAttrs = @{
            NSFontAttributeName: [NSFont systemFontOfSize:10],
            NSForegroundColorAttributeName: [NSColor blackColor]
        };
    }
    
    NSSize labelSize = [labelText sizeWithAttributes:labelAttrs];
    NSPoint labelPoint = NSMakePoint((bounds.size.width - labelSize.width) / 2, 2);
    [labelText drawAtPoint:labelPoint withAttributes:labelAttrs];
    
    // Draw keyboard shortcut hint
    NSString *shortcutText = [NSString stringWithFormat:@"[%ld]", (long)_faderIndex + 1];
    NSDictionary *shortcutAttrs = @{
        NSFontAttributeName: [NSFont boldSystemFontOfSize:8],
        NSForegroundColorAttributeName: _isActive ? [NSColor blackColor] : [NSColor grayColor]
    };
    [shortcutText drawAtPoint:NSMakePoint(2, bounds.size.height - 12) withAttributes:shortcutAttrs];
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint localPoint = [self convertPoint:event.locationInWindow fromView:nil];
    
    if (NSPointInRect(localPoint, _knobRect) || NSPointInRect(localPoint, _trackRect)) {
        _isDragging = YES;
        _lastMouseY = localPoint.y;
        _isActive = YES;
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseDragged:(NSEvent *)event {
    if (!_isDragging) return;
    
    NSPoint localPoint = [self convertPoint:event.locationInWindow fromView:nil];
    
    // Calculate value based on position in track
    CGFloat normalizedY = (localPoint.y - _trackRect.origin.y) / _trackRect.size.height;
    normalizedY = MIN(MAX(normalizedY, 0.0), 1.0);
    
    CGFloat newValue = normalizedY * (_maxValue - _minValue) + _minValue;
    [self setValue:newValue animated:NO];
}

- (void)mouseUp:(NSEvent *)event {
    _isDragging = NO;
}

- (void)mouseEntered:(NSEvent *)event {
    [[NSCursor pointingHandCursor] push];
}

- (void)mouseExited:(NSEvent *)event {
    [NSCursor pop];
    if (!_isDragging) {
        _isActive = NO;
        [self setNeedsDisplay:YES];
    }
}

@end

#pragma mark - Main Application Implementation

// Global callback for CGEventTap
static CGEventRef MouseEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *userInfo) {
    TrackpadFaderAppV3 *app = (__bridge TrackpadFaderAppV3 *)userInfo;
    
    // Handle event tap being disabled by the system
    if (type == kCGEventTapDisabledByTimeout || type == kCGEventTapDisabledByUserInput) {
        // Re-enable the event tap
        if (app.cursorLocked && app.eventTap) {
            CGEventTapEnable(app.eventTap, true);
            NSLog(@"Event tap was disabled, re-enabling...");
        }
        return event;
    }
    
    if (!app.cursorLocked || !app.window.isKeyWindow) {
        return event;
    }
    
    if (type == kCGEventMouseMoved || 
        type == kCGEventLeftMouseDragged || 
        type == kCGEventRightMouseDragged) {
        
        NSRect windowFrame = [app.window frame];
        NSRect screenFrame = [[NSScreen mainScreen] frame];
        
        // Convert window frame to screen coordinates
        NSRect bounds = NSMakeRect(
            windowFrame.origin.x,
            screenFrame.size.height - windowFrame.origin.y - windowFrame.size.height,
            windowFrame.size.width,
            windowFrame.size.height
        );
        
        CGPoint location = CGEventGetLocation(event);
        
        // Check if cursor is within window bounds
        BOOL inBounds = (location.x >= bounds.origin.x && 
                        location.x <= bounds.origin.x + bounds.size.width &&
                        location.y >= bounds.origin.y && 
                        location.y <= bounds.origin.y + bounds.size.height);
        
        if (!inBounds) {
            // Clamp to window bounds
            CGFloat clampedX = MIN(MAX(location.x, bounds.origin.x), 
                                  bounds.origin.x + bounds.size.width - 1);
            CGFloat clampedY = MIN(MAX(location.y, bounds.origin.y), 
                                  bounds.origin.y + bounds.size.height - 1);
            
            // Warp cursor back to bounds
            CGWarpMouseCursorPosition(CGPointMake(clampedX, clampedY));
            
            // Modify event to reflect clamped position
            CGEventSetLocation(event, CGPointMake(clampedX, clampedY));
        }
    }
    
    return event;
}

// Define max faders for stem player (5 stems)
// Removed MAX_FADERS - using dynamic count

@implementation TrackpadFaderAppV3 {
    TrackpadZone _trackpadZones[MAX_POSSIBLE_FADERS];
    id _globalKeyMonitor;
    BOOL _isWindowActive;
    
    // R2 Connection Properties
    NSView *_startingScreen;
    NSProgressIndicator *_connectionSpinner;
    NSTextField *_connectionStatusLabel;
    NSButton *_retryButton;
    NSURLSession *_urlSession;
    BOOL _isConnected;
    
    // XML Parsing
    NSMutableDictionary *_currentElement;
    NSString *_currentElementName;
    NSMutableString *_currentElementValue;
    
    // Search
    NSSearchField *_searchField;
    NSMutableArray *_filteredSongs;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupApplication];
    [self setupStartingScreen];
    [self connectToR2Bucket];
    
    NSLog(@"TrackpadFaderApp V3 started - Connecting to R2 bucket...");
}

- (void)setupApplication {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];
    
    _activeTouches = [NSMutableDictionary dictionary];
    _faderBaseValues = [NSMutableDictionary dictionary];
    _mutedFaders = [NSMutableSet set];
    _isConnected = NO;
    _isInFaderUI = NO;  // Start in song selection
    
    // Setup URL session for R2 connections
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _urlSession = [NSURLSession sessionWithConfiguration:config];
}

#pragma mark - Starting Screen

- (void)setupStartingScreen {
    // Create main window with system.css styling
    NSRect windowFrame = NSMakeRect(200, 200, 600, 500);
    SystemFaderWindow *window = [[SystemFaderWindow alloc] 
        initWithContentRect:windowFrame
                  styleMask:(NSWindowStyleMaskTitled |
                           NSWindowStyleMaskClosable |
                           NSWindowStyleMaskMiniaturizable |
                           NSWindowStyleMaskResizable)
                    backing:NSBackingStoreBuffered
                      defer:NO];
    
    window.faderApp = self;
    window.title = @"TrackpadFader Control Panel - R2 Connection";
    window.backgroundColor = [NSColor colorWithCalibratedWhite:0.95 alpha:1.0];
    window.minSize = NSMakeSize(600, 400);  // Set minimum window size
    window.maxSize = NSMakeSize(FLT_MAX, FLT_MAX);  // Allow maximum resize
    
    _window = window;
    
    // Create starting screen view
    _startingScreen = [[NSView alloc] initWithFrame:windowFrame];
    _startingScreen.wantsLayer = YES;
    _startingScreen.layer.backgroundColor = [NSColor colorWithCalibratedWhite:0.95 alpha:1.0].CGColor;
    
    // Title bar (black and white style)
    NSView *titleBar = [[NSView alloc] initWithFrame:NSMakeRect(0, windowFrame.size.height - 30, 
                                                                windowFrame.size.width, 30)];
    titleBar.wantsLayer = YES;
    titleBar.layer.backgroundColor = [NSColor blackColor].CGColor;
    [_startingScreen addSubview:titleBar];
    
    NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 5, 400, 20)];
    titleLabel.stringValue = @"CLOUDFLARE R2 BUCKET CONNECTION";
    titleLabel.bezeled = NO;
    titleLabel.drawsBackground = NO;
    titleLabel.editable = NO;
    titleLabel.selectable = NO;
    titleLabel.font = [NSFont boldSystemFontOfSize:12];
    titleLabel.textColor = [NSColor whiteColor];
    [titleBar addSubview:titleLabel];
    
    // Connection status container
    NSView *connectionContainer = [[NSView alloc] initWithFrame:NSMakeRect(50, 150, 500, 200)];
    connectionContainer.wantsLayer = YES;
    connectionContainer.layer.backgroundColor = [NSColor whiteColor].CGColor;
    connectionContainer.layer.borderColor = [NSColor blackColor].CGColor;
    connectionContainer.layer.borderWidth = 2.0;
    [_startingScreen addSubview:connectionContainer];
    
    // R2 Bucket Info Display
    NSTextField *bucketInfoLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 150, 460, 30)];
    bucketInfoLabel.stringValue = @"Connecting to Cloudflare R2 Storage";
    bucketInfoLabel.bezeled = NO;
    bucketInfoLabel.drawsBackground = NO;
    bucketInfoLabel.editable = NO;
    bucketInfoLabel.selectable = NO;
    bucketInfoLabel.font = [NSFont boldSystemFontOfSize:14];
    bucketInfoLabel.textColor = [NSColor blackColor];
    bucketInfoLabel.alignment = NSTextAlignmentCenter;
    [connectionContainer addSubview:bucketInfoLabel];
    
    // Bucket details
    NSTextField *bucketDetails = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 100, 460, 40)];
    bucketDetails.stringValue = @"Bucket: stem-player\nEndpoint: Cloudflare R2";
    bucketDetails.bezeled = NO;
    bucketDetails.drawsBackground = NO;
    bucketDetails.editable = NO;
    bucketDetails.selectable = NO;
    bucketDetails.font = [NSFont monospacedSystemFontOfSize:10 weight:NSFontWeightRegular];
    bucketDetails.textColor = [NSColor darkGrayColor];
    bucketDetails.alignment = NSTextAlignmentCenter;
    [connectionContainer addSubview:bucketDetails];
    
    // Connection spinner
    _connectionSpinner = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(220, 60, 60, 60)];
    _connectionSpinner.style = NSProgressIndicatorStyleSpinning;
    _connectionSpinner.controlSize = NSControlSizeRegular;
    [_connectionSpinner startAnimation:nil];
    [connectionContainer addSubview:_connectionSpinner];
    
    // Status label
    _connectionStatusLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 20, 460, 30)];
    _connectionStatusLabel.stringValue = @"Loading song library...";
    _connectionStatusLabel.bezeled = NO;
    _connectionStatusLabel.drawsBackground = NO;
    _connectionStatusLabel.editable = NO;
    _connectionStatusLabel.selectable = NO;
    _connectionStatusLabel.font = [NSFont systemFontOfSize:11];
    _connectionStatusLabel.textColor = [NSColor darkGrayColor];
    _connectionStatusLabel.alignment = NSTextAlignmentCenter;
    [connectionContainer addSubview:_connectionStatusLabel];
    
    // Retry button (hidden initially)
    _retryButton = [self createSystemButton:@"Retry Connection" 
                                      action:@selector(retryConnection) 
                                       frame:NSMakeRect(200, 60, 150, 30)];
    _retryButton.hidden = YES;
    [connectionContainer addSubview:_retryButton];
    
    // Instructions
    NSTextField *instructions = [[NSTextField alloc] initWithFrame:NSMakeRect(50, 50, 500, 60)];
    instructions.stringValue = @"The application is connecting to your Cloudflare R2 storage bucket.\nOnce connected, you can access your stem player files and control faders.\n\nThis may take a few moments...";
    instructions.bezeled = NO;
    instructions.drawsBackground = NO;
    instructions.editable = NO;
    instructions.selectable = NO;
    instructions.font = [NSFont systemFontOfSize:10];
    instructions.textColor = [NSColor grayColor];
    instructions.alignment = NSTextAlignmentCenter;
    [_startingScreen addSubview:instructions];
    
    // Set as content view
    _window.contentView = _startingScreen;
    
    [_window makeKeyAndOrderFront:nil];
    [_window center];
}

#pragma mark - R2 Connection

- (void)connectToR2Bucket {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // R2 Credentials
        NSString *accessKeyId = @"d342b0242e6ba292004fe30a34d3f51f";
        NSString *secretAccessKey = @"dcbf6692c0d4690148065f4f8992867930ebd97d7bcf7a47236e7ec474a0c5b4";
        NSString *endpointUrl = @"https://ac88b7fdb83d78225d35131f5f9fb832.r2.cloudflarestorage.com";
        NSString *bucketName = @"stem-player";
        
        // Fetch metadata folder first (much smaller files)
        NSString *urlString = [NSString stringWithFormat:@"%@/%@?list-type=2&max-keys=5000&prefix=metadata/", endpointUrl, bucketName];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
        
        // Create ISO 8601 timestamp
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        NSString *amzDate = [dateFormatter stringFromDate:[NSDate date]];
        
        NSDateFormatter *datestampFormatter = [[NSDateFormatter alloc] init];
        [datestampFormatter setDateFormat:@"yyyyMMdd"];
        [datestampFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        NSString *datestamp = [datestampFormatter stringFromDate:[NSDate date]];
        
        // Prepare signing components
        NSString *region = @"auto";
        NSString *service = @"s3";
        NSString *signingKey = @"aws4_request";
        
        // Create canonical request
        NSString *canonicalUri = [NSString stringWithFormat:@"/%@", bucketName];
        NSString *canonicalQueryString = @"list-type=2&max-keys=5000&prefix=metadata%2F";
        NSString *payloadHash = [self sha256Hash:@""];  // Empty payload for GET
        
        NSString *canonicalHeaders = [NSString stringWithFormat:@"host:%@.r2.cloudflarestorage.com\nx-amz-content-sha256:%@\nx-amz-date:%@\n",
                                      @"ac88b7fdb83d78225d35131f5f9fb832", payloadHash, amzDate];
        NSString *signedHeaders = @"host;x-amz-content-sha256;x-amz-date";
        
        NSString *canonicalRequest = [NSString stringWithFormat:@"GET\n%@\n%@\n%@\n%@\n%@",
                                      canonicalUri, canonicalQueryString, canonicalHeaders, signedHeaders, payloadHash];
        
        // Create string to sign
        NSString *credentialScope = [NSString stringWithFormat:@"%@/%@/%@/%@", datestamp, region, service, signingKey];
        NSString *stringToSign = [NSString stringWithFormat:@"AWS4-HMAC-SHA256\n%@\n%@\n%@",
                                 amzDate, credentialScope, [self sha256Hash:canonicalRequest]];
        
        // Calculate signature
        NSData *kSecret = [[NSString stringWithFormat:@"AWS4%@", secretAccessKey] dataUsingEncoding:NSUTF8StringEncoding];
        NSData *kDate = [self hmacSHA256:datestamp withKey:kSecret];
        NSData *kRegion = [self hmacSHA256:region withKey:kDate];
        NSData *kService = [self hmacSHA256:service withKey:kRegion];
        NSData *kSigning = [self hmacSHA256:signingKey withKey:kService];
        NSString *signature = [self hexStringFromData:[self hmacSHA256:stringToSign withKey:kSigning]];
        
        // Create authorization header
        NSString *authHeader = [NSString stringWithFormat:@"AWS4-HMAC-SHA256 Credential=%@/%@, SignedHeaders=%@, Signature=%@",
                               accessKeyId, credentialScope, signedHeaders, signature];
        
        // Set headers
        [request setValue:@"ac88b7fdb83d78225d35131f5f9fb832.r2.cloudflarestorage.com" forHTTPHeaderField:@"Host"];
        [request setValue:amzDate forHTTPHeaderField:@"x-amz-date"];
        [request setValue:payloadHash forHTTPHeaderField:@"x-amz-content-sha256"];
        [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        // Execute request
        NSURLSessionDataTask *task = [self->_urlSession dataTaskWithRequest:request 
                                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    NSLog(@"R2 Connection Error: %@", error.localizedDescription);
                    [self handleConnectionError:error];
                } else {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    NSLog(@"R2 Response Status: %ld", (long)httpResponse.statusCode);
                    
                    if (httpResponse.statusCode == 200) {
                        // Parse initial response
                        [self parseBucketContents:data];
                        
                        // Update loading status
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self->_connectionStatusLabel.stringValue = [NSString stringWithFormat:@"Loading songs... (%lu found)", (unsigned long)self->_songs.count];
                        });
                        
                        // Check if there are more results
                        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"Initial load: %lu songs", (unsigned long)self->_songs.count);
                        
                        if ([responseString containsString:@"<IsTruncated>true</IsTruncated>"]) {
                            NSLog(@"More songs available, loading continuation...");
                            [self loadAllSongsWithContinuation:responseString];
                        } else {
                            NSLog(@"No more songs to load");
                            [self handleConnectionSuccess];
                        }
                    } else {
                        NSString *errorBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"R2 Error Response: %@", errorBody);
                        NSError *statusError = [NSError errorWithDomain:@"R2Error" 
                                                                   code:httpResponse.statusCode 
                                                               userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP %ld", (long)httpResponse.statusCode]}];
                        [self handleConnectionError:statusError];
                    }
                }
            });
        }];
        
        [task resume];
    });
}

#pragma mark - Crypto Helpers

- (NSString *)sha256Hash:(NSString *)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSData *)hmacSHA256:(NSString *)data withKey:(NSData *)key {
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char hmac[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, key.bytes, key.length, cData, strlen(cData), hmac);
    
    return [NSData dataWithBytes:hmac length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)hexStringFromData:(NSData *)data {
    const unsigned char *bytes = (const unsigned char *)data.bytes;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:data.length * 2];
    
    for (NSUInteger i = 0; i < data.length; i++) {
        [hexString appendFormat:@"%02x", bytes[i]];
    }
    
    return hexString;
}

- (void)handleConnectionSuccess {
    _isConnected = YES;
    
    [_connectionSpinner stopAnimation:nil];
    _connectionSpinner.hidden = YES;
    
    NSString *statusText = [NSString stringWithFormat:@"✓ Loaded %lu songs from R2 Bucket", (unsigned long)_songs.count];
    _connectionStatusLabel.stringValue = statusText;
    _connectionStatusLabel.textColor = [NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    
    NSLog(@"Connection successful - Total songs: %lu", (unsigned long)_songs.count);
    
    // Show song list
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadSongList];
    });
}

- (void)handleConnectionError:(NSError *)error {
    _isConnected = NO;
    
    [_connectionSpinner stopAnimation:nil];
    _connectionSpinner.hidden = YES;
    _retryButton.hidden = NO;
    
    _connectionStatusLabel.stringValue = [NSString stringWithFormat:@"✗ Connection Failed: %@", 
                                         error.localizedDescription ?: @"Unknown error"];
    _connectionStatusLabel.textColor = [NSColor redColor];
}

- (void)retryConnection {
    _retryButton.hidden = YES;
    _connectionSpinner.hidden = NO;
    [_connectionSpinner startAnimation:nil];
    _connectionStatusLabel.stringValue = @"Retrying connection...";
    _connectionStatusLabel.textColor = [NSColor darkGrayColor];
    
    [self connectToR2Bucket];
}

- (void)transitionToMainUI {
    // Remove song selection screen
    [_songSelectionView removeFromSuperview];
    _songSelectionView = nil;
    
    // Setup main UI with faders
    [self setupFaderUI];
    [self setupTrackpadZones];
    [self setupTrackpadWrapper];
    [self setupEventTap];
    [self setupGlobalKeyMonitor];
    
    _cursorLocked = NO;
    _isWindowActive = YES;
    _isInFaderUI = YES;  // Now in fader UI
    
    // Load stems for selected song
    [self loadStemsForSong:_selectedSongPath];
    
    NSLog(@"Transitioned to fader UI - Loading stems for: %@", _selectedSongPath);
}

#pragma mark - Song Selection UI

- (void)loadSongList {
    // Transition to song selection view
    [_startingScreen removeFromSuperview];
    _startingScreen = nil;
    _isInFaderUI = NO;  // Now in song selection
    
    [self setupSongSelectionUI];
}

- (void)setupSongSelectionUI {
    NSRect windowFrame = _window.frame;
    
    // Create song selection view
    _songSelectionView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, windowFrame.size.width, windowFrame.size.height)];
    _songSelectionView.wantsLayer = YES;
    _songSelectionView.layer.backgroundColor = [NSColor colorWithCalibratedWhite:0.95 alpha:1.0].CGColor;
    _songSelectionView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    // Title bar
    NSView *titleBar = [[NSView alloc] initWithFrame:NSMakeRect(0, windowFrame.size.height - 30, 
                                                                windowFrame.size.width, 30)];
    titleBar.wantsLayer = YES;
    titleBar.layer.backgroundColor = [NSColor blackColor].CGColor;
    titleBar.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    [_songSelectionView addSubview:titleBar];
    
    NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 5, 400, 20)];
    titleLabel.stringValue = @"SELECT A SONG";
    titleLabel.bezeled = NO;
    titleLabel.drawsBackground = NO;
    titleLabel.editable = NO;
    titleLabel.selectable = NO;
    titleLabel.font = [NSFont boldSystemFontOfSize:12];
    titleLabel.textColor = [NSColor whiteColor];
    [titleBar addSubview:titleLabel];
    
    // Search field
    _searchField = [[NSSearchField alloc] initWithFrame:NSMakeRect(20, 440, 560, 30)];
    _searchField.placeholderString = @"Search by artist, album, or song title...";
    _searchField.target = self;
    _searchField.action = @selector(searchFieldChanged:);
    _searchField.continuous = YES;
    _searchField.font = [NSFont systemFontOfSize:13];
    _searchField.wantsLayer = YES;
    _searchField.layer.borderColor = [NSColor blackColor].CGColor;
    _searchField.layer.borderWidth = 2.0;
    
    // Fix text color to black
    NSTextFieldCell *searchFieldCell = (NSTextFieldCell *)_searchField.cell;
    searchFieldCell.textColor = [NSColor blackColor];
    _searchField.textColor = [NSColor blackColor];
    
    [_songSelectionView addSubview:_searchField];
    
    // Song list container
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(20, 80, 560, 350)];
    scrollView.wantsLayer = YES;
    scrollView.layer.borderColor = [NSColor blackColor].CGColor;
    scrollView.layer.borderWidth = 2.0;
    scrollView.hasVerticalScroller = YES;
    scrollView.autohidesScrollers = NO;
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    scrollView.borderType = NSNoBorder;
    scrollView.backgroundColor = [NSColor whiteColor];
    
    // Create table view
    _songTableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 560, 350)];
    _songTableView.delegate = self;
    _songTableView.dataSource = self;
    _songTableView.rowHeight = 40;
    _songTableView.intercellSpacing = NSMakeSize(0, 1);
    _songTableView.backgroundColor = [NSColor whiteColor];
    _songTableView.gridStyleMask = NSTableViewSolidHorizontalGridLineMask;
    _songTableView.gridColor = [NSColor lightGrayColor];
    _songTableView.allowsMultipleSelection = NO;
    _songTableView.usesAlternatingRowBackgroundColors = NO;
    _songTableView.doubleAction = @selector(loadSelectedSong);
    _songTableView.target = self;
    
    // Add columns
    NSTableColumn *artistColumn = [[NSTableColumn alloc] initWithIdentifier:@"artist"];
    artistColumn.title = @"Artist";
    artistColumn.width = 150;
    [_songTableView addTableColumn:artistColumn];
    
    NSTableColumn *albumColumn = [[NSTableColumn alloc] initWithIdentifier:@"album"];
    albumColumn.title = @"Album";
    albumColumn.width = 200;
    [_songTableView addTableColumn:albumColumn];
    
    NSTableColumn *titleColumn = [[NSTableColumn alloc] initWithIdentifier:@"title"];
    titleColumn.title = @"Title";
    titleColumn.width = 210;
    [_songTableView addTableColumn:titleColumn];
    
    scrollView.documentView = _songTableView;
    [_songSelectionView addSubview:scrollView];
    
    // Load button
    NSButton *loadButton = [self createSystemButton:@"Load Song" 
                                             action:@selector(loadSelectedSong) 
                                              frame:NSMakeRect(225, 40, 150, 30)];
    [_songSelectionView addSubview:loadButton];
    
    // Instructions
    NSTextField *instructions = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 10, 560, 20)];
    instructions.stringValue = @"Select a song and click 'Load Song' to begin mixing";
    instructions.bezeled = NO;
    instructions.drawsBackground = NO;
    instructions.editable = NO;
    instructions.selectable = NO;
    instructions.font = [NSFont systemFontOfSize:11];
    instructions.textColor = [NSColor grayColor];
    instructions.alignment = NSTextAlignmentCenter;
    [_songSelectionView addSubview:instructions];
    
    // Set as content view
    _window.contentView = _songSelectionView;
    
    // Initialize filtered songs
    _filteredSongs = nil;
    
    // Reload table with songs
    [_songTableView reloadData];
    
    // Select first song by default
    if (_songs.count > 0) {
        [_songTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
    
    // Focus search field
    [_searchField becomeFirstResponder];
}

- (void)parseBucketContents:(NSData *)xmlData {
    if (!_songs) {
        _songs = [NSMutableArray array];
        _songMetadata = [NSMutableDictionary dictionary];
    }
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    parser.delegate = (id<NSXMLParserDelegate>)self;
    [parser parse];
    
    // Sort songs by artist/album/title
    [_songs sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSString *artist1 = obj1[@"artist"] ?: @"";
        NSString *artist2 = obj2[@"artist"] ?: @"";
        NSComparisonResult result = [artist1 compare:artist2];
        if (result == NSOrderedSame) {
            NSString *album1 = obj1[@"album"] ?: @"";
            NSString *album2 = obj2[@"album"] ?: @"";
            result = [album1 compare:album2];
            if (result == NSOrderedSame) {
                NSString *title1 = obj1[@"title"] ?: @"";
                NSString *title2 = obj2[@"title"] ?: @"";
                result = [title1 compare:title2];
            }
        }
        return result;
    }];
    
    NSLog(@"Total songs loaded: %lu", (unsigned long)_songs.count);
}

- (void)loadAllSongsWithContinuation:(NSString *)previousResponse {
    // Extract continuation token
    NSRange tokenStart = [previousResponse rangeOfString:@"<NextContinuationToken>"];
    NSRange tokenEnd = [previousResponse rangeOfString:@"</NextContinuationToken>"];
    
    if (tokenStart.location == NSNotFound || tokenEnd.location == NSNotFound) {
        NSLog(@"No more continuation tokens, finishing with %lu songs", (unsigned long)_songs.count);
        [self handleConnectionSuccess];
        return;
    }
    
    NSString *continuationToken = [previousResponse substringWithRange:NSMakeRange(
        tokenStart.location + tokenStart.length,
        tokenEnd.location - (tokenStart.location + tokenStart.length)
    )];
    
    NSLog(@"Found continuation token, loading more songs...");
    
    // Load more songs with proper continuation
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadMoreSongsWithContinuation:continuationToken];
    });
}

- (void)loadMoreSongsWithContinuation:(NSString *)continuationToken {
    NSString *endpointUrl = @"https://ac88b7fdb83d78225d35131f5f9fb832.r2.cloudflarestorage.com";
    NSString *bucketName = @"stem-player";
    NSString *accessKeyId = @"d342b0242e6ba292004fe30a34d3f51f";
    NSString *secretAccessKey = @"dcbf6692c0d4690148065f4f8992867930ebd97d7bcf7a47236e7ec474a0c5b4";
    
    // Build query with properly encoded continuation token for metadata
    NSString *encodedToken = [continuationToken stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *queryString = [NSString stringWithFormat:@"list-type=2&max-keys=1000&prefix=metadata/&continuation-token=%@", encodedToken];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?%@", endpointUrl, bucketName, queryString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    // Add timestamp headers
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *amzDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDateFormatter *datestampFormatter = [[NSDateFormatter alloc] init];
    [datestampFormatter setDateFormat:@"yyyyMMdd"];
    [datestampFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *datestamp = [datestampFormatter stringFromDate:[NSDate date]];
    
    // Sign the request properly
    NSString *region = @"auto";
    NSString *service = @"s3";
    NSString *signingKey = @"aws4_request";
    
    // Create canonical request
    NSString *canonicalUri = [NSString stringWithFormat:@"/%@", bucketName];
    // Properly format the canonical query string for metadata
    NSString *canonicalQueryString = [NSString stringWithFormat:@"continuation-token=%@&list-type=2&max-keys=1000&prefix=metadata%%2F", encodedToken];
    NSString *payloadHash = [self sha256Hash:@""];
    
    NSString *canonicalHeaders = [NSString stringWithFormat:@"host:%@.r2.cloudflarestorage.com\nx-amz-content-sha256:%@\nx-amz-date:%@\n",
                                  @"ac88b7fdb83d78225d35131f5f9fb832", payloadHash, amzDate];
    NSString *signedHeaders = @"host;x-amz-content-sha256;x-amz-date";
    
    NSString *canonicalRequest = [NSString stringWithFormat:@"GET\n%@\n%@\n%@\n%@\n%@",
                                  canonicalUri, canonicalQueryString, canonicalHeaders, signedHeaders, payloadHash];
    
    // Create string to sign
    NSString *credentialScope = [NSString stringWithFormat:@"%@/%@/%@/%@", datestamp, region, service, signingKey];
    NSString *stringToSign = [NSString stringWithFormat:@"AWS4-HMAC-SHA256\n%@\n%@\n%@",
                             amzDate, credentialScope, [self sha256Hash:canonicalRequest]];
    
    // Calculate signature
    NSData *kSecret = [[NSString stringWithFormat:@"AWS4%@", secretAccessKey] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *kDate = [self hmacSHA256:datestamp withKey:kSecret];
    NSData *kRegion = [self hmacSHA256:region withKey:kDate];
    NSData *kService = [self hmacSHA256:service withKey:kRegion];
    NSData *kSigning = [self hmacSHA256:signingKey withKey:kService];
    NSString *signature = [self hexStringFromData:[self hmacSHA256:stringToSign withKey:kSigning]];
    
    // Create authorization header
    NSString *authHeader = [NSString stringWithFormat:@"AWS4-HMAC-SHA256 Credential=%@/%@, SignedHeaders=%@, Signature=%@",
                           accessKeyId, credentialScope, signedHeaders, signature];
    
    // Set headers
    [request setValue:@"ac88b7fdb83d78225d35131f5f9fb832.r2.cloudflarestorage.com" forHTTPHeaderField:@"Host"];
    [request setValue:amzDate forHTTPHeaderField:@"x-amz-date"];
    [request setValue:payloadHash forHTTPHeaderField:@"x-amz-content-sha256"];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    // Execute request
    NSURLSessionDataTask *task = [self->_urlSession dataTaskWithRequest:request 
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error loading more songs: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleConnectionSuccess];
            });
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self parseBucketContents:data];
                    
                    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if ([responseString containsString:@"<IsTruncated>true</IsTruncated>"]) {
                        NSLog(@"More songs available, continuing...");
                        [self loadAllSongsWithContinuation:responseString];
                    } else {
                        NSLog(@"All songs loaded!");
                        [self handleConnectionSuccess];
                    }
                });
            } else {
                NSLog(@"HTTP Error %ld while loading more songs", (long)httpResponse.statusCode);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handleConnectionSuccess];
                });
            }
        }
    }];
    
    [task resume];
}

#pragma mark - NSXMLParser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"Contents"]) {
        _currentElement = [NSMutableDictionary dictionary];
    }
    _currentElementName = elementName;
    _currentElementValue = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_currentElementValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"Key"]) {
        NSString *key = [_currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Parse metadata/ folder structure: metadata/artist/album/song_hash.json
        if ([key hasPrefix:@"metadata/"] && [key hasSuffix:@".json"]) {
            NSArray *components = [key componentsSeparatedByString:@"/"];
            if (components.count >= 4) {
                NSString *artist = components[1];
                NSString *album = components[2];
                NSString *filenameWithHash = [components[3] stringByDeletingPathExtension]; // Remove .json
                
                // Extract song title (everything before the last underscore and hash)
                NSRange lastUnderscore = [filenameWithHash rangeOfString:@"_" options:NSBackwardsSearch];
                NSString *songTitle = filenameWithHash;
                if (lastUnderscore.location != NSNotFound) {
                    songTitle = [filenameWithHash substringToIndex:lastUnderscore.location];
                }
                
                NSString *songKey = [NSString stringWithFormat:@"%@/%@/%@", artist, album, songTitle];
                
                // Create song entry
                if (!_songMetadata[songKey]) {
                    _songMetadata[songKey] = [NSMutableDictionary dictionaryWithDictionary:@{
                        @"artist": artist,
                        @"album": album,
                        @"title": songTitle,
                        @"path": [NSString stringWithFormat:@"separated/%@/%@/%@", artist, album, songTitle],
                        @"metadata_path": key,
                        @"stems": [NSMutableArray arrayWithObjects:@"drums.mp3", @"bass.mp3", @"vocals.mp3", @"other.mp3", nil]
                    }];
                    [_songs addObject:_songMetadata[songKey]];
                }
            }
        }
    }
    
    _currentElementValue = nil;
}

#pragma mark - NSTableView DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _filteredSongs ? _filteredSongs.count : _songs.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *currentSongs = _filteredSongs ?: _songs;
    if (row >= currentSongs.count) return nil;
    
    NSDictionary *song = currentSongs[row];
    NSString *identifier = tableColumn.identifier;
    
    // Create text field for cell
    NSTextField *cellView = [[NSTextField alloc] init];
    cellView.bezeled = NO;
    cellView.drawsBackground = NO;
    cellView.editable = NO;
    cellView.selectable = NO;
    cellView.font = [NSFont systemFontOfSize:12];
    cellView.textColor = [NSColor blackColor];
    
    if ([identifier isEqualToString:@"artist"]) {
        cellView.stringValue = song[@"artist"] ?: @"Unknown Artist";
    } else if ([identifier isEqualToString:@"album"]) {
        cellView.stringValue = song[@"album"] ?: @"Unknown Album";
    } else if ([identifier isEqualToString:@"title"]) {
        cellView.stringValue = song[@"title"] ?: @"Unknown Title";
        cellView.font = [NSFont boldSystemFontOfSize:12];
    }
    
    return cellView;
}

#pragma mark - NSTableView Delegate

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    CustomTableRowView *rowView = [[CustomTableRowView alloc] init];
    
    // All rows have white background
    rowView.backgroundColor = [NSColor whiteColor];
    
    return rowView;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return YES;
}

- (void)loadSelectedSong {
    NSInteger selectedRow = _songTableView.selectedRow;
    NSArray *currentSongs = _filteredSongs ?: _songs;
    
    if (selectedRow < 0 || selectedRow >= currentSongs.count) {
        NSBeep();
        return;
    }
    
    NSDictionary *song = currentSongs[selectedRow];
    _selectedSongPath = song[@"path"];
    
    NSLog(@"Loading song: %@ - %@ - %@", song[@"artist"], song[@"album"], song[@"title"]);
    
    [self transitionToMainUI];
}

#pragma mark - Search

- (void)searchFieldChanged:(NSSearchField *)searchField {
    NSString *searchText = searchField.stringValue.lowercaseString;
    
    if (searchText.length == 0) {
        _filteredSongs = nil;
    } else {
        _filteredSongs = [NSMutableArray array];
        
        for (NSDictionary *song in _songs) {
            NSString *artist = [song[@"artist"] lowercaseString] ?: @"";
            NSString *album = [song[@"album"] lowercaseString] ?: @"";
            NSString *title = [song[@"title"] lowercaseString] ?: @"";
            
            if ([artist containsString:searchText] || 
                [album containsString:searchText] || 
                [title containsString:searchText]) {
                [_filteredSongs addObject:song];
            }
        }
    }
    
    [_songTableView reloadData];
    
    // Auto-select first result
    if (_filteredSongs.count > 0 || (_filteredSongs == nil && _songs.count > 0)) {
        [_songTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
}

- (void)rebuildFadersForStemCount:(NSInteger)stemCount {
    // Clear existing faders
    for (SystemCSSFader *fader in _faders) {
        [fader removeFromSuperview];
    }
    [_faders removeAllObjects];
    
    // Calculate layout for new fader count
    CGFloat containerWidth = 560;
    CGFloat faderWidth = 100;
    CGFloat totalFaderWidth = faderWidth * stemCount;
    CGFloat spacing = (containerWidth - totalFaderWidth) / (stemCount + 1);
    
    // Create new faders
    for (NSInteger i = 0; i < stemCount; i++) {
        NSString *label = (i < _stemNames.count) ? _stemNames[i] : [NSString stringWithFormat:@"Track %ld", (long)i + 1];
        CGFloat x = spacing + i * (faderWidth + spacing);
        
        SystemCSSFader *fader = [[SystemCSSFader alloc] 
            initWithFrame:NSMakeRect(x, 10, faderWidth, 200)
                    label:label
                    index:i];
        fader.delegate = self;
        [_faderContainer addSubview:fader];
        [_faders addObject:fader];
    }
    
    // Update trackpad zones for new fader count
    [self setupTrackpadZonesForCount:stemCount];
    
    // Update values display
    [self updateValuesDisplay];
}

- (void)setupTrackpadZonesForCount:(NSInteger)faderCount {
    for (NSInteger i = 0; i < faderCount; i++) {
        _trackpadZones[i].startX = (CGFloat)i / faderCount;
        _trackpadZones[i].endX = (CGFloat)(i + 1) / faderCount;
        _trackpadZones[i].zoneIndex = i;
    }
}

- (void)setupFaderUI {
    // Reuse existing window instead of creating a new one
    if (!_window) {
        NSLog(@"Error: Window not initialized");
        return;
    }
    
    // Update window title for fader mode
    _window.title = @"TrackpadFader Control Panel";
    
    // Get window frame for layout calculations
    NSRect windowFrame = _window.frame;
    
    // Clear existing content and create new content view
    NSView *contentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, windowFrame.size.width, windowFrame.size.height)];
    contentView.wantsLayer = YES;
    contentView.layer.backgroundColor = [NSColor colorWithCalibratedWhite:0.95 alpha:1.0].CGColor;
    _window.contentView = contentView;
    
    // Title bar (black and white style)
    NSView *titleBar = [[NSView alloc] initWithFrame:NSMakeRect(0, windowFrame.size.height - 30, 
                                                                windowFrame.size.width, 30)];
    titleBar.wantsLayer = YES;
    titleBar.layer.backgroundColor = [NSColor blackColor].CGColor;
    [contentView addSubview:titleBar];
    
    NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 5, 300, 20)];
    titleLabel.stringValue = @"TRACKPAD FADER CONTROL";
    titleLabel.bezeled = NO;
    titleLabel.drawsBackground = NO;
    titleLabel.editable = NO;
    titleLabel.selectable = NO;
    titleLabel.font = [NSFont boldSystemFontOfSize:12];
    titleLabel.textColor = [NSColor whiteColor];
    [titleBar addSubview:titleLabel];
    
    // Status display
    _statusLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, windowFrame.size.height - 60, 560, 20)];
    _statusLabel.stringValue = @"Initializing trackpad...";
    _statusLabel.bezeled = NO;
    _statusLabel.drawsBackground = NO;
    _statusLabel.editable = NO;
    _statusLabel.selectable = NO;
    _statusLabel.font = [NSFont systemFontOfSize:11];
    _statusLabel.textColor = [NSColor darkGrayColor];
    _statusLabel.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    [contentView addSubview:_statusLabel];
    
    // Cursor lock indicator
    _cursorLockIndicator = [[NSTextField alloc] initWithFrame:NSMakeRect(400, windowFrame.size.height - 60, 180, 20)];
    _cursorLockIndicator.stringValue = @"Cursor: FREE";
    _cursorLockIndicator.bezeled = NO;
    _cursorLockIndicator.drawsBackground = NO;
    _cursorLockIndicator.editable = NO;
    _cursorLockIndicator.selectable = NO;
    _cursorLockIndicator.font = [NSFont boldSystemFontOfSize:11];
    _cursorLockIndicator.textColor = [NSColor blackColor];
    _cursorLockIndicator.alignment = NSTextAlignmentRight;
    _cursorLockIndicator.autoresizingMask = NSViewMinXMargin | NSViewMinYMargin;
    [contentView addSubview:_cursorLockIndicator];
    
    // Create fader container (adjusted position now that spectrograms are removed)
    _faderContainer = [[NSView alloc] initWithFrame:NSMakeRect(20, 120, 560, 220)];
    _faderContainer.wantsLayer = YES;
    _faderContainer.layer.backgroundColor = [NSColor whiteColor].CGColor;
    _faderContainer.layer.borderColor = [NSColor blackColor].CGColor;
    _faderContainer.layer.borderWidth = 2.0;
    _faderContainer.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [contentView addSubview:_faderContainer];
    
    // Initialize with empty faders array - will be populated when stems are loaded
    _faders = [NSMutableArray array];
    _stemNames = [NSMutableArray arrayWithObjects:@"Drums", @"Bass", @"Vocals", @"Guitar", @"Other", @"Track 6", @"Track 7", @"Track 8", nil];
    
    // Don't create faders here - wait for stems to be loaded
    _currentFaderCount = 0;
    
    // Values display
    _valuesLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 90, 560, 20)];
    _valuesLabel.bezeled = NO;
    _valuesLabel.drawsBackground = NO;
    _valuesLabel.editable = NO;
    _valuesLabel.selectable = NO;
    _valuesLabel.font = [NSFont monospacedDigitSystemFontOfSize:10 weight:NSFontWeightMedium];
    _valuesLabel.textColor = [NSColor blackColor];
    _valuesLabel.autoresizingMask = NSViewWidthSizable | NSViewMaxYMargin;
    [contentView addSubview:_valuesLabel];
    
    // Control buttons (system.css style)
    // Add now playing label
    _nowPlayingLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(240, 50, 340, 25)];
    _nowPlayingLabel.stringValue = @"";
    _nowPlayingLabel.bezeled = NO;
    _nowPlayingLabel.drawsBackground = NO;
    _nowPlayingLabel.editable = NO;
    _nowPlayingLabel.selectable = NO;
    _nowPlayingLabel.font = [NSFont boldSystemFontOfSize:11];
    _nowPlayingLabel.textColor = [NSColor blackColor];
    _nowPlayingLabel.alignment = NSTextAlignmentRight;
    [contentView addSubview:_nowPlayingLabel];
    
    // Control buttons
    _playButton = [self createSystemButton:@"Play" 
                                      action:@selector(playAudio) 
                                       frame:NSMakeRect(20, 50, 60, 25)];
    [contentView addSubview:_playButton];
    
    _stopButton = [self createSystemButton:@"Stop" 
                                      action:@selector(stopAudio) 
                                       frame:NSMakeRect(90, 50, 60, 25)];
    _stopButton.enabled = NO;
    [contentView addSubview:_stopButton];
    
    NSButton *resetButton = [self createSystemButton:@"Reset" 
                                             action:@selector(resetAllFaders) 
                                              frame:NSMakeRect(160, 50, 70, 25)];
    [contentView addSubview:resetButton];
    
    NSButton *cursorLockButton = [self createSystemButton:@"Lock Cursor [Space]" 
                                                   action:@selector(toggleCursorLock) 
                                                    frame:NSMakeRect(240, 50, 140, 25)];
    [contentView addSubview:cursorLockButton];
    
    NSButton *backButton = [self createSystemButton:@"← Back to Songs" 
                                              action:@selector(backToSongSelection) 
                                               frame:NSMakeRect(390, 50, 120, 25)];
    [contentView addSubview:backButton];
    
    // Instructions
    NSTextField *instructions = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 10, 560, 30)];
    instructions.stringValue = @"Keys: 1-5 mute/unmute stems | Space play/pause | R reset all\nTouch trackpad zones to control stem volumes";
    instructions.bezeled = NO;
    instructions.drawsBackground = NO;
    instructions.editable = NO;
    instructions.selectable = NO;
    instructions.font = [NSFont systemFontOfSize:9];
    instructions.textColor = [NSColor grayColor];
    instructions.maximumNumberOfLines = 2;
    [contentView addSubview:instructions];
    
    // Window is already visible, no need to show it again
    
    [self updateValuesDisplay];
}

- (NSButton *)createSystemButton:(NSString *)title action:(SEL)action frame:(NSRect)frame {
    NSButton *button = [[NSButton alloc] initWithFrame:frame];
    button.title = title;
    button.bezelStyle = NSBezelStyleRounded;
    button.target = self;
    button.action = action;
    
    // System.css button styling - ensure text is visible
    button.wantsLayer = YES;
    button.layer.backgroundColor = [NSColor colorWithCalibratedWhite:0.85 alpha:1.0].CGColor;
    button.layer.borderColor = [NSColor blackColor].CGColor;
    button.layer.borderWidth = 2.0;
    
    // Force black text color
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] 
        initWithString:title 
        attributes:@{
            NSForegroundColorAttributeName: [NSColor blackColor],
            NSFontAttributeName: [NSFont systemFontOfSize:11]
        }];
    button.attributedTitle = attrTitle;
    
    return button;
}

- (void)setupTrackpadZones {
    // Initial setup - will be reconfigured when stems are loaded
    NSInteger defaultCount = 5;
    for (NSInteger i = 0; i < defaultCount; i++) {
        _trackpadZones[i].startX = (CGFloat)i / defaultCount;
        _trackpadZones[i].endX = (CGFloat)(i + 1) / defaultCount;
        _trackpadZones[i].zoneIndex = i;
    }
}

- (void)setupTrackpadWrapper {
    _trackpadWrapper = [TrackpadWrapper sharedWrapper];
    _trackpadWrapper.delegate = self;
    _trackpadWrapper.clickThreshold = 0.04;
    _trackpadWrapper.hoverThreshold = 0.01;
    
    if ([_trackpadWrapper startMonitoring]) {
        _statusLabel.stringValue = @"Press Space to lock cursor and enable fader control";
        _statusLabel.textColor = [NSColor blackColor];
    } else {
        _statusLabel.stringValue = @"Error: Could not start trackpad monitoring";
        _statusLabel.textColor = [NSColor redColor];
    }
}

- (void)setupEventTap {
    // Create event tap for mouse movement monitoring
    // Include tap disabled events so we can re-enable if needed
    CGEventMask eventMask = (1 << kCGEventMouseMoved) | 
                           (1 << kCGEventLeftMouseDragged) | 
                           (1 << kCGEventRightMouseDragged) |
                           CGEventMaskBit(kCGEventTapDisabledByTimeout) |
                           CGEventMaskBit(kCGEventTapDisabledByUserInput);
    
    _eventTap = CGEventTapCreate(kCGSessionEventTap,
                                 kCGHeadInsertEventTap,
                                 kCGEventTapOptionDefault,
                                 eventMask,
                                 MouseEventCallback,
                                 (__bridge void *)self);
    
    if (_eventTap) {
        _runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, _eventTap, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), _runLoopSource, kCFRunLoopCommonModes);
        CGEventTapEnable(_eventTap, false); // Start disabled
    } else {
        NSLog(@"Warning: Could not create event tap for cursor confinement");
        NSLog(@"You may need to grant Accessibility permissions in System Preferences");
    }
}

- (void)setupGlobalKeyMonitor {
    // Global key monitor for cursor lock/unlock
    _globalKeyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyDown
                                                               handler:^(NSEvent *event) {
        if (event.keyCode == 53) { // ESC key
            dispatch_async(dispatch_get_main_queue(), ^{
                [self emergencyFreeCursor];
            });
        } else if (event.keyCode == 49 && _isInFaderUI) { // Space key - only in fader UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self toggleCursorLock];
            });
        }
    }];
    
    // Also monitor local key events
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown
                                          handler:^NSEvent *(NSEvent *event) {
        if (event.keyCode == 49 && _isInFaderUI) { // Space key - only in fader UI
            [self toggleCursorLock];
            return nil; // Consume the event
        }
        return event;
    }];
}

#pragma mark - Cursor Control

- (void)toggleCursorLock {
    if (_cursorLocked) {
        [self unlockCursor];
    } else {
        [self lockCursor];
    }
}

- (void)lockCursor {
    if (!_window.isKeyWindow) {
        [_window makeKeyAndOrderFront:nil];
    }
    
    _cursorLocked = YES;
    
    // Enable event tap for cursor confinement
    if (_eventTap) {
        CGEventTapEnable(_eventTap, true);
    }
    
    // Hide cursor
    CGDisplayHideCursor(kCGDirectMainDisplay);
    
    // Update UI
    _cursorLockIndicator.stringValue = @"Cursor: LOCKED";
    _cursorLockIndicator.textColor = [NSColor redColor];
    _statusLabel.stringValue = @"Cursor locked to window - Press ESC or Space to unlock";
    
    // Start a timer to periodically check if event tap is still enabled
    if (_eventTapCheckTimer) {
        [_eventTapCheckTimer invalidate];
    }
    _eventTapCheckTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                          target:self
                                                        selector:@selector(checkEventTapStatus)
                                                        userInfo:nil
                                                         repeats:YES];
    
    NSLog(@"Cursor locked to window bounds");
}

- (void)checkEventTapStatus {
    // If cursor is locked but event tap is disabled, re-enable it
    if (_cursorLocked && _eventTap) {
        Boolean tapEnabled = CGEventTapIsEnabled(_eventTap);
        if (!tapEnabled) {
            CGEventTapEnable(_eventTap, true);
            NSLog(@"Re-enabled event tap from timer");
        }
    }
}

- (void)unlockCursor {
    _cursorLocked = NO;
    
    // Stop the timer
    if (_eventTapCheckTimer) {
        [_eventTapCheckTimer invalidate];
        _eventTapCheckTimer = nil;
    }
    
    // Disable event tap
    if (_eventTap) {
        CGEventTapEnable(_eventTap, false);
    }
    
    // Show cursor
    CGDisplayShowCursor(kCGDirectMainDisplay);
    
    // Update UI
    _cursorLockIndicator.stringValue = @"Cursor: FREE";
    _cursorLockIndicator.textColor = [NSColor blackColor];
    _statusLabel.stringValue = @"Press Space to lock cursor and enable fader control";
    
    NSLog(@"Cursor unlocked");
}

- (void)emergencyFreeCursor {
    if (_cursorLocked) {
        [self unlockCursor];
        NSLog(@"Emergency cursor release activated");
    }
}

#pragma mark - Fader Control

- (void)toggleMuteFader:(NSInteger)index {
    if (index < 0 || index >= _currentFaderCount) return;
    
    SystemCSSFader *fader = _faders[index];
    
    if ([_mutedFaders containsObject:@(index)]) {
        [_mutedFaders removeObject:@(index)];
        fader.isMuted = NO;
        
        // Unmute audio channel
        if (_audioEngine && index < _stemPlayers.count) {
            AVAudioPlayerNode *player = _stemPlayers[index];
            float volume = fader.value / 100.0;
            player.volume = volume;
        }
        
        NSLog(@"Unmuted %@", _stemNames[index]);
    } else {
        [_mutedFaders addObject:@(index)];
        fader.isMuted = YES;
        
        // Mute audio channel
        if (_audioEngine && index < _stemPlayers.count) {
            AVAudioPlayerNode *player = _stemPlayers[index];
            player.volume = 0.0;
        }
        
        NSLog(@"Muted %@", _stemNames[index]);
    }
    
    [fader setNeedsDisplay:YES];
    [self updateValuesDisplay];
}

- (void)resetAllFaders {
    for (SystemCSSFader *fader in _faders) {
        [fader setValue:50.0 animated:YES];
        fader.isActive = NO;
        fader.isMuted = NO;
        [fader setNeedsDisplay:YES];
    }
    [_mutedFaders removeAllObjects];
    [self updateValuesDisplay];
    NSLog(@"All faders reset");
}

- (void)updateValuesDisplay {
    NSMutableString *values = [NSMutableString string];
    for (NSInteger i = 0; i < _faders.count; i++) {
        SystemCSSFader *fader = _faders[i];
        NSString *status = fader.isMuted ? @"MUTE" : [NSString stringWithFormat:@"%3.0f%%", fader.value];
        [values appendFormat:@"F%ld: %@  ", (long)i + 1, status];
    }
    _valuesLabel.stringValue = values;
}

#pragma mark - TrackpadWrapperDelegate

- (NSInteger)zoneForTrackpadX:(CGFloat)x {
    for (NSInteger i = 0; i < _currentFaderCount; i++) {
        if (x >= _trackpadZones[i].startX && x < _trackpadZones[i].endX) {
            return i;
        }
    }
    return (x >= 1.0) ? _currentFaderCount - 1 : -1;
}

- (void)trackpadWrapper:(TrackpadWrapper *)wrapper touchesChanged:(NSArray<TrackpadTouch *> *)touches {
    // Only process touches if cursor is locked
    if (!_cursorLocked) {
        return;
    }
    
    // Track current touch IDs
    NSMutableSet *currentTouchIDs = [NSMutableSet set];
    
    // Process active touches
    for (TrackpadTouch *touch in touches) {
        if (!touch.isActive) continue;
        
        NSString *touchKey = [@(touch.touchID) stringValue];
        [currentTouchIDs addObject:touchKey];
        
        NSInteger zone = [self zoneForTrackpadX:touch.normalizedPosition.x];
        if (zone < 0 || zone >= _currentFaderCount) continue;
        
        SystemCSSFader *fader = _faders[zone];
        
        // Check if this fader is muted
        if ([_mutedFaders containsObject:@(zone)]) {
            fader.isActive = YES;
            continue;
        }
        
        BOOL isNewTouch = (_activeTouches[touchKey] == nil);
        
        if (isNewTouch) {
            // Store the initial Y position and current fader value
            _activeTouches[touchKey] = @(touch.normalizedPosition.y);
            _faderBaseValues[touchKey] = @(fader.value);
        } else {
            // Calculate relative movement
            CGFloat initialY = [_activeTouches[touchKey] floatValue];
            CGFloat baseValue = [_faderBaseValues[touchKey] floatValue];
            CGFloat deltaY = touch.normalizedPosition.y - initialY;
            
            // Convert delta to value change (down = increase value)
            CGFloat valueRange = fader.maxValue - fader.minValue;
            CGFloat deltaValue = deltaY * valueRange;  // Positive for normal direction
            CGFloat newValue = baseValue + deltaValue;
            
            // Clamp to valid range
            newValue = fmax(fader.minValue, fmin(fader.maxValue, newValue));
            
            [fader setValue:newValue animated:NO];
        }
        
        fader.isActive = YES;
    }
    
    // Clean up ended touches
    NSMutableArray *keysToRemove = [NSMutableArray array];
    for (NSString *touchKey in _activeTouches) {
        if (![currentTouchIDs containsObject:touchKey]) {
            [keysToRemove addObject:touchKey];
        }
    }
    for (NSString *key in keysToRemove) {
        [_activeTouches removeObjectForKey:key];
        [_faderBaseValues removeObjectForKey:key];
    }
    
    // Deactivate faders with no active touches
    if (touches.count == 0 || currentTouchIDs.count == 0) {
        for (SystemCSSFader *fader in _faders) {
            fader.isActive = NO;
        }
    }
    
    [self updateValuesDisplay];
}

- (void)trackpadWrapper:(TrackpadWrapper *)wrapper hoverChanged:(NSArray<TrackpadTouch *> *)hovers {
    // Optional hover handling
}

- (void)trackpadWrapper:(TrackpadWrapper *)wrapper clickDetected:(TrackpadClickEvent *)clickEvent {
    // Only process clicks if cursor is locked
    if (!_cursorLocked) {
        return;
    }
    
    NSInteger zone = [self zoneForTrackpadX:clickEvent.location.x];
    if (zone >= 0 && zone < _currentFaderCount) {
        [self toggleMuteFader:zone];
    }
}

- (void)trackpadWrapper:(TrackpadWrapper *)wrapper scrollDetected:(TrackpadScrollEvent *)scrollEvent {
    // Optional scroll handling
}

#pragma mark - SystemCSSFaderDelegate

- (void)fader:(SystemCSSFader *)fader valueChanged:(CGFloat)value {
    [self updateValuesDisplay];
    
    // Update audio volume if playing
    if (_isPlaying && fader.faderIndex < _stemPlayers.count) {
        AVAudioPlayerNode *player = _stemPlayers[fader.faderIndex];
        if (player && !fader.isMuted) {
            // Convert percentage to volume (0.0 to 1.0)
            float volume = value / 100.0;
            player.volume = volume;
        }
    }
}

#pragma mark - Audio Playback

- (void)loadStemsForSong:(NSString *)songPath {
    NSLog(@"Loading stems for: %@", songPath);
    
    // Initialize audio engine
    _audioEngine = [[AVAudioEngine alloc] init];
    _stemPlayers = [NSMutableArray array];
    _stemFiles = [NSMutableArray array];
    
    // Expected stem file names matching what's in R2
    NSArray *stemFileNames = @[@"drums.mp3", @"bass.mp3", @"vocals.mp3", @"other.mp3"];
    
    // Update now playing label
    NSArray *pathComponents = [songPath componentsSeparatedByString:@"/"];
    if (pathComponents.count >= 3) {
        NSString *artist = pathComponents[1];
        NSString *title = pathComponents[3];
        _nowPlayingLabel.stringValue = [NSString stringWithFormat:@"%@ - %@", artist, title];
    }
    
    // Show download progress
    _statusLabel.stringValue = @"Downloading stems from R2...";
    _playButton.enabled = NO;
    
    // Create progress indicator
    NSProgressIndicator *downloadProgress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(240, 52, 100, 20)];
    downloadProgress.style = NSProgressIndicatorStyleBar;
    downloadProgress.indeterminate = NO;
    downloadProgress.minValue = 0;
    downloadProgress.maxValue = 4; // 4 stems
    downloadProgress.doubleValue = 0;
    [_window.contentView addSubview:downloadProgress];
    
    // Download stems from R2 bucket
    [self downloadStemsForPath:songPath withStems:stemFileNames progressIndicator:downloadProgress];
}

- (void)downloadStemsForPath:(NSString *)songPath withStems:(NSArray *)stemNames progressIndicator:(NSProgressIndicator *)progress {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // First, try to get metadata for accurate stem paths
        NSString *metadataPath = nil;
        for (NSDictionary *song in self->_songs) {
            if ([song[@"path"] isEqualToString:songPath]) {
                metadataPath = song[@"metadata_path"];
                break;
            }
        }
        
        NSMutableArray *actualStemNames = [NSMutableArray arrayWithArray:stemNames];
        
        if (metadataPath) {
            // Download and parse metadata JSON
            NSData *metadataData = [self downloadMetadataFromR2:metadataPath];
            if (metadataData) {
                NSError *jsonError;
                NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:metadataData options:0 error:&jsonError];
                if (metadata && !jsonError) {
                    // Extract actual stem filenames from metadata
                    NSDictionary *stems = metadata[@"stems"];
                    if (stems && [stems isKindOfClass:[NSDictionary class]]) {
                        [actualStemNames removeAllObjects];
                        if (stems[@"drums"]) [actualStemNames addObject:@"drums.mp3"];
                        if (stems[@"bass"]) [actualStemNames addObject:@"bass.mp3"];
                        if (stems[@"vocals"]) [actualStemNames addObject:@"vocals.mp3"];
                        if (stems[@"other"]) [actualStemNames addObject:@"other.mp3"];
                        if (stems[@"guitar"]) [actualStemNames addObject:@"guitar.mp3"];
                        NSLog(@"Using stem names from metadata: %@", actualStemNames);
                    }
                }
            }
        }
        
        NSString *tempDir = NSTemporaryDirectory();
        NSString *songTempDir = [tempDir stringByAppendingPathComponent:@"stem-player-cache"];
        NSString *songCacheDir = [songTempDir stringByAppendingPathComponent:[songPath stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
        
        // Create cache directory for this specific song
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:songCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSMutableArray *downloadedPaths = [NSMutableArray array];
        BOOL allDownloaded = YES;
        
        for (NSString *stemName in actualStemNames) {
            NSString *stemPath = [NSString stringWithFormat:@"%@/%@", songPath, stemName];
            NSString *localPath = [songCacheDir stringByAppendingPathComponent:stemName];
            
            // Check if file already exists (caching)
            if ([fileManager fileExistsAtPath:localPath]) {
                NSLog(@"Using cached stem: %@", stemName);
                [downloadedPaths addObject:localPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress.doubleValue = progress.doubleValue + 1;
                    self->_statusLabel.stringValue = [NSString stringWithFormat:@"Loading cached: %@...", stemName];
                });
                continue;
            }
            
            // Download stem file from R2
            if ([self downloadFileFromR2:stemPath toPath:localPath]) {
                [downloadedPaths addObject:localPath];
                NSLog(@"Downloaded: %@", stemName);
                
                // Update progress on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress.doubleValue = progress.doubleValue + 1;
                    self->_statusLabel.stringValue = [NSString stringWithFormat:@"Downloading: %@...", stemName];
                });
            } else {
                NSLog(@"Failed to download: %@", stemName);
                allDownloaded = NO;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Remove progress indicator
            [progress removeFromSuperview];
            
            if (allDownloaded && downloadedPaths.count > 0) {
                [self setupAudioWithStemPaths:downloadedPaths];
                _playButton.enabled = YES;
                _statusLabel.stringValue = [NSString stringWithFormat:@"✓ Loaded %lu stems - Ready to play", (unsigned long)downloadedPaths.count];
                _statusLabel.textColor = [NSColor blackColor];
            } else {
                _statusLabel.stringValue = @"Failed to download some stems";
                _statusLabel.textColor = [NSColor redColor];
            }
        });
    });
}

- (NSData *)downloadMetadataFromR2:(NSString *)remotePath {
    // R2 Credentials
    NSString *accessKeyId = @"d342b0242e6ba292004fe30a34d3f51f";
    NSString *secretAccessKey = @"dcbf6692c0d4690148065f4f8992867930ebd97d7bcf7a47236e7ec474a0c5b4";
    NSString *endpointUrl = @"https://ac88b7fdb83d78225d35131f5f9fb832.r2.cloudflarestorage.com";
    NSString *bucketName = @"stem-player";
    
    // Don't encode forward slashes, only encode spaces and special characters
    NSMutableString *encodedPath = [NSMutableString string];
    NSArray *pathComponents = [remotePath componentsSeparatedByString:@"/"];
    for (NSInteger i = 0; i < pathComponents.count; i++) {
        NSString *component = pathComponents[i];
        // URL encode each component separately (preserving /)
        NSString *encoded = [component stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [encodedPath appendString:encoded];
        if (i < pathComponents.count - 1) {
            [encodedPath appendString:@"/"];
        }
    }
    
    // Create download URL
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", endpointUrl, bucketName, encodedPath];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSLog(@"Trying URL: %@", urlString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    // Add AWS Signature (simplified for GET request)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *amzDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [request setValue:amzDate forHTTPHeaderField:@"x-amz-date"];
    
    // Synchronous download for simplicity
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if (data && !error) {
        return data;
    }
    
    NSLog(@"Failed to download metadata from: %@, error: %@", remotePath, error);
    return nil;
}

- (BOOL)downloadFileFromR2:(NSString *)remotePath toPath:(NSString *)localPath {
    // R2 Credentials
    NSString *accessKeyId = @"d342b0242e6ba292004fe30a34d3f51f";
    NSString *secretAccessKey = @"dcbf6692c0d4690148065f4f8992867930ebd97d7bcf7a47236e7ec474a0c5b4";
    NSString *endpointUrl = @"https://ac88b7fdb83d78225d35131f5f9fb832.r2.cloudflarestorage.com";
    NSString *bucketName = @"stem-player";
    
    // Don't encode forward slashes, only encode spaces and special characters
    NSMutableString *encodedPath = [NSMutableString string];
    NSArray *pathComponents = [remotePath componentsSeparatedByString:@"/"];
    for (NSInteger i = 0; i < pathComponents.count; i++) {
        NSString *component = pathComponents[i];
        // URL encode each component separately (preserving /)
        NSString *encoded = [component stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [encodedPath appendString:encoded];
        if (i < pathComponents.count - 1) {
            [encodedPath appendString:@"/"];
        }
    }
    
    // Create download URL
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", endpointUrl, bucketName, encodedPath];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSLog(@"Trying URL: %@", urlString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    // Create ISO 8601 timestamp
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *amzDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDateFormatter *datestampFormatter = [[NSDateFormatter alloc] init];
    [datestampFormatter setDateFormat:@"yyyyMMdd"];
    [datestampFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *datestamp = [datestampFormatter stringFromDate:[NSDate date]];
    
    // Prepare signing components
    NSString *region = @"auto";
    NSString *service = @"s3";
    NSString *signingKey = @"aws4_request";
    
    // Create canonical request
    NSString *canonicalUri = [NSString stringWithFormat:@"/%@/%@", bucketName, encodedPath];
    NSString *canonicalQueryString = @"";
    NSString *payloadHash = [self sha256Hash:@""];  // Empty payload for GET
    
    NSString *canonicalHeaders = [NSString stringWithFormat:@"host:%@.r2.cloudflarestorage.com\nx-amz-content-sha256:%@\nx-amz-date:%@\n",
                                  @"ac88b7fdb83d78225d35131f5f9fb832", payloadHash, amzDate];
    NSString *signedHeaders = @"host;x-amz-content-sha256;x-amz-date";
    
    NSString *canonicalRequest = [NSString stringWithFormat:@"GET\n%@\n%@\n%@\n%@\n%@",
                                  canonicalUri, canonicalQueryString, canonicalHeaders, signedHeaders, payloadHash];
    
    // Create string to sign
    NSString *credentialScope = [NSString stringWithFormat:@"%@/%@/%@/%@", datestamp, region, service, signingKey];
    NSString *stringToSign = [NSString stringWithFormat:@"AWS4-HMAC-SHA256\n%@\n%@\n%@",
                             amzDate, credentialScope, [self sha256Hash:canonicalRequest]];
    
    // Calculate signature
    NSData *kSecret = [[NSString stringWithFormat:@"AWS4%@", secretAccessKey] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *kDate = [self hmacSHA256:datestamp withKey:kSecret];
    NSData *kRegion = [self hmacSHA256:region withKey:kDate];
    NSData *kService = [self hmacSHA256:service withKey:kRegion];
    NSData *kSigning = [self hmacSHA256:signingKey withKey:kService];
    NSString *signature = [self hexStringFromData:[self hmacSHA256:stringToSign withKey:kSigning]];
    
    // Create authorization header
    NSString *authHeader = [NSString stringWithFormat:@"AWS4-HMAC-SHA256 Credential=%@/%@, SignedHeaders=%@, Signature=%@",
                           accessKeyId, credentialScope, signedHeaders, signature];
    
    // Set headers
    [request setValue:@"ac88b7fdb83d78225d35131f5f9fb832.r2.cloudflarestorage.com" forHTTPHeaderField:@"Host"];
    [request setValue:amzDate forHTTPHeaderField:@"x-amz-date"];
    [request setValue:payloadHash forHTTPHeaderField:@"x-amz-content-sha256"];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    // Synchronous download for simplicity
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"Response status: %ld", (long)response.statusCode);
    
    if (data && !error && response.statusCode == 200) {
        BOOL success = [data writeToFile:localPath atomically:YES];
        NSLog(@"Downloaded: %@ (%lu bytes)", [[localPath lastPathComponent] stringByDeletingPathExtension], (unsigned long)data.length);
        return success;
    } else if (response.statusCode == 403) {
        NSLog(@"Authentication failed - check AWS signature");
    } else if (response.statusCode == 404) {
        NSLog(@"File not found: %@", remotePath);
    } else {
        NSLog(@"Download failed - Error: %@, Status: %ld", error, (long)response.statusCode);
    }
    
    return NO;
}

- (void)setupAudioWithStemPaths:(NSArray *)stemPaths {
    // If stemPaths is nil, just return (don't clear existing files)
    if (!stemPaths) {
        return;
    }
    
    NSLog(@"Setting up audio with %lu stem paths", (unsigned long)stemPaths.count);
    
    // Update the fader count based on stems
    _currentFaderCount = MIN(stemPaths.count, MAX_POSSIBLE_FADERS);
    
    // Rebuild faders to match stem count
    [self rebuildFadersForStemCount:_currentFaderCount];
    
    // Stop any existing playback
    if (_isPlaying) {
        [self stopAudio];
    }
    
    // Initialize audio engine if not already
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc] init];
    }
    
    // Clear existing nodes
    for (AVAudioPlayerNode *player in _stemPlayers) {
        [_audioEngine detachNode:player];
    }
    
    _stemPlayers = [NSMutableArray array];
    _stemFiles = [NSMutableArray array];
    
    for (NSInteger i = 0; i < stemPaths.count && i < _currentFaderCount; i++) {
        NSString *filePath = stemPaths[i];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        NSLog(@"Loading audio file: %@", filePath);
        
        // Check if file exists
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSLog(@"File does not exist: %@", filePath);
            continue;
        }
        
        NSError *error;
        AVAudioFile *audioFile = [[AVAudioFile alloc] initForReading:fileURL error:&error];
        
        if (audioFile && !error) {
            AVAudioPlayerNode *player = [[AVAudioPlayerNode alloc] init];
            [_stemPlayers addObject:player];
            [_stemFiles addObject:audioFile];
            
            [_audioEngine attachNode:player];
            [_audioEngine connect:player to:_audioEngine.mainMixerNode format:audioFile.processingFormat];
            
            NSLog(@"Successfully loaded stem %ld: %@", (long)i, [[filePath lastPathComponent] stringByDeletingPathExtension]);
            
            // Update fader label based on actual stem
            if (i < _faders.count) {
                NSString *fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
                SystemCSSFader *fader = _faders[i];
                fader.label = [fileName capitalizedString];
                [fader setNeedsDisplay:YES];
            }
        } else {
            NSLog(@"Error loading audio file %@: %@", filePath, error);
        }
    }
    
    // No need for empty players - we only create what we need
    
    NSLog(@"Loaded %lu audio files successfully", (unsigned long)_stemFiles.count);
    
    // Start audio engine
    NSError *error;
    if (![_audioEngine startAndReturnError:&error]) {
        NSLog(@"Failed to start audio engine: %@", error);
        _statusLabel.stringValue = @"Audio engine failed to start";
    } else {
        NSLog(@"Audio engine started successfully with %lu files", (unsigned long)_stemFiles.count);
    }
}

- (void)playAudio {
    if (!_audioEngine || _stemFiles.count == 0) {
        NSLog(@"No audio files loaded");
        _statusLabel.stringValue = @"No audio files loaded";
        return;
    }
    
    if (_isPlaying) {
        [self pauseAudio];
        return;
    }
    
    _isPlaying = YES;
    _playButton.title = @"Pause";
    _stopButton.enabled = YES;
    
    // Schedule and play all stem files
    for (NSInteger i = 0; i < _stemFiles.count && i < _stemPlayers.count; i++) {
        AVAudioPlayerNode *player = _stemPlayers[i];
        AVAudioFile *file = _stemFiles[i];
        
        // Schedule the entire file
        [player scheduleFile:file atTime:nil completionHandler:^{
            // Loop the file when it finishes
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self->_isPlaying) {
                    [player scheduleFile:file atTime:nil completionHandler:nil];
                    [player play];
                }
            });
        }];
        
        [player play];
    }
    
    _statusLabel.stringValue = @"Playing...";
}

- (void)pauseAudio {
    _isPlaying = NO;
    _playButton.title = @"Play";
    
    for (AVAudioPlayerNode *player in _stemPlayers) {
        [player pause];
    }
    
    _statusLabel.stringValue = @"Paused";
}

- (void)stopAudio {
    _isPlaying = NO;
    _playButton.title = @"Play";
    _playButton.enabled = YES;
    _stopButton.enabled = NO;
    
    for (AVAudioPlayerNode *player in _stemPlayers) {
        [player stop];
    }
    
    _statusLabel.stringValue = @"Stopped";
    
    // Don't reset audio files when stopping
    
    // Reset all faders to center
    [self resetAllFaders];
}

#pragma mark - Navigation

- (void)backToSongSelection {
    // Stop any playing audio
    if (_isPlaying) {
        [self stopAudio];
    }
    
    // Clear audio engine
    if (_audioEngine) {
        [_audioEngine stop];
        for (AVAudioPlayerNode *player in _stemPlayers) {
            [_audioEngine detachNode:player];
        }
        _stemPlayers = nil;
        _stemFiles = nil;
    }
    
    // Unlock cursor if it's locked
    if (_cursorLocked) {
        [self unlockCursor];
    }
    
    // Remove fader view
    for (NSView *subview in _window.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    _isInFaderUI = NO;  // Back to song selection
    
    // Show song selection screen again
    [self setupSongSelectionUI];
}

#pragma mark - Visualization


#pragma mark - Application Lifecycle

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self emergencyFreeCursor];
    [_trackpadWrapper stopMonitoring];
    
    if (_globalKeyMonitor) {
        [NSEvent removeMonitor:_globalKeyMonitor];
    }
    
    if (_eventTap) {
        CGEventTapEnable(_eventTap, false);
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _runLoopSource, kCFRunLoopCommonModes);
        CFRelease(_runLoopSource);
        CFRelease(_eventTap);
    }
    
    NSLog(@"TrackpadFaderApp V3 terminated");
}

@end

#pragma mark - Main Entry Point

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        TrackpadFaderAppV3 *delegate = [[TrackpadFaderAppV3 alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}