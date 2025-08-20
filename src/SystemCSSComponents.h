//
//  SystemCSSComponents.h
//  Basic system.css styled components for fader app
//

#import <Cocoa/Cocoa.h>

// System.css color palette
#define SYSTEM_WHITE [NSColor whiteColor]
#define SYSTEM_BLACK [NSColor blackColor]
#define SYSTEM_GRAY [NSColor colorWithCalibratedWhite:0.65 alpha:1.0]
#define SYSTEM_LIGHT_GRAY [NSColor colorWithCalibratedWhite:0.8 alpha:1.0]

// Basic button component
@interface SystemButton : NSButton

+ (instancetype)standardButtonWithTitle:(NSString *)title;
- (instancetype)initStandardButtonWithTitle:(NSString *)title;

@end

// Basic window component
@interface SystemWindow : NSWindow

+ (instancetype)standardWindowWithTitle:(NSString *)title;
- (instancetype)initStandardWindowWithTitle:(NSString *)title;

@end