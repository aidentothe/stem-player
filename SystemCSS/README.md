# SystemCSS Component Library

A comprehensive Objective-C component library that recreates the classic Apple System OS aesthetic (1984-1991). This library provides native macOS NSView-based components that mirror the design patterns and visual style of [system.css](https://github.com/sakofchit/system.css).

## Features

- 🎨 **Retro Computing Aesthetic**: Pixel-perfect recreation of classic Apple System OS
- 🧩 **Comprehensive Components**: Buttons, windows, forms, menus, and dialogs
- 🔧 **Native Objective-C**: Proper NSView-based components with full AppKit integration
- 🎯 **Event Handling**: Complete delegate patterns and mouse/keyboard interactions
- 📱 **Modern Compatibility**: Works with contemporary macOS development
- 🎪 **Memory Management**: Uses ARC for automatic memory management
- 📖 **Well Documented**: Extensive documentation and working demo application

## Components Included

### Buttons (`SystemButton`)
- Standard buttons with proper retro styling
- Default button style with thick border
- Title bar close and resize buttons
- Disabled state support
- Dynamic sizing based on content

### Windows (`SystemWindow`)
- Complete window system with title bars
- Window panes with optional scrolling
- Details bar for status information
- Close and resize button handling
- Active/inactive window states

### Form Components (`SystemFormComponents`)
- Text fields with focus states
- Password fields
- Radio buttons with group management
- Checkboxes with proper styling
- Select menus with dropdown functionality
- Field rows for layout management

### Menus (`SystemMenu`)
- Menu bars with dropdown functionality
- Menu items with submenu support
- Divider support
- Hover and selection states
- Click handling and delegation

### Dialogs (`SystemDialog`)
- Standard dialogs
- Modal dialogs with double borders
- Alert boxes with icon support
- Modeless dialogs
- Configurable button layouts

### Color System (`SystemCSSColors`)
- Unified color palette matching system.css
- Typography system with period-appropriate fonts
- Drawing utilities for patterns and effects
- Consistent spacing and sizing constants

## Quick Start

### Building the Demo

```bash
# Clone or extract the SystemCSS directory
cd SystemCSS

# Build the demo application
make

# Run the demo
make run

# Or build and run the app bundle
make app
make run-app
```

### Using in Your Project

1. Copy the `SystemCSS` directory to your project
2. Add all `.h` and `.m` files to your Xcode project
3. Import the main header:

```objective-c
#import "SystemCSSComponents.h"
```

### Basic Usage Examples

#### Creating a Button
```objective-c
SystemButton *button = [[SystemButton alloc] initStandardButtonWithTitle:@"Click Me"];
button.delegate = self;
[button setFrame:NSMakeRect(10, 10, button.frame.size.width, button.frame.size.height)];
[parentView addSubview:button];

// Handle button clicks
- (void)systemButtonWasClicked:(SystemButton *)sender {
    NSLog(@"Button clicked: %@", sender.title);
}
```

#### Creating a Window
```objective-c
SystemWindow *window = [[SystemWindow alloc] initStandardWindowWithTitle:@"My Window"];
[window setFrame:NSMakeRect(100, 100, 400, 300)];

// Add content to the window
NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 10, 200, 20)];
label.stringValue = @"Hello, System OS!";
[window setWindowContent:label];

[parentView addSubview:window];
```

#### Creating Form Elements
```objective-c
// Text field
SystemTextField *textField = [[SystemTextField alloc] initStandardTextField];
textField.placeholderText = @"Enter text...";

// Radio buttons
SystemRadioButton *radio1 = [[SystemRadioButton alloc] initWithTitle:@"Option 1" groupName:@"options"];
SystemRadioButton *radio2 = [[SystemRadioButton alloc] initWithTitle:@"Option 2" groupName:@"options"];

// Checkbox
SystemCheckbox *checkbox = [[SystemCheckbox alloc] initWithTitle:@"Enable feature"];
checkbox.delegate = self;
```

#### Creating Dialogs
```objective-c
// Alert dialog
SystemAlertBox *alert = [[SystemAlertBox alloc] initWithMessage:@"Are you sure?" 
                                                       iconType:SystemAlertIconCaution];

SystemButton *okButton = [[SystemButton alloc] initStandardButtonWithTitle:@"OK"];
SystemButton *cancelButton = [[SystemButton alloc] initStandardButtonWithTitle:@"Cancel"];

[alert addButton:cancelButton];
[alert addButton:okButton];
```

## Architecture

The library follows a modular architecture with clear separation of concerns:

```
SystemCSS/
├── Components/
│   ├── SystemCSSColors.h/m        # Color system and utilities
│   ├── SystemButton.h/m           # Button components
│   ├── SystemWindow.h/m           # Window system
│   ├── SystemFormComponents.h/m   # Form controls
│   ├── SystemMenu.h/m             # Menu system
│   └── SystemDialog.h/m           # Dialog components
├── Demo/
│   └── SystemCSSDemo.m            # Demonstration application
├── SystemCSSComponents.h/m        # Main library header
├── Makefile                       # Build system
└── README.md                      # This file
```

## Color System

The library implements the exact color palette from system.css:

- **Primary**: White (#FFFFFF) - Main background color
- **Secondary**: Black (#000000) - Text and border color  
- **Tertiary**: Grey (#A5A5A5) - Inactive elements
- **Disabled**: Dark Grey (#B6B7B8) - Disabled text

## Typography

Period-appropriate fonts are used throughout:

- **Chicago**: Primary UI font for buttons and titles
- **Geneva**: Secondary font for body text
- **Monaco**: Monospace font for code/technical content

Fallbacks to system fonts are provided when original fonts aren't available.

## Build System

The included Makefile provides comprehensive build options:

```bash
# Basic building
make          # Build demo application
make app      # Create app bundle
make clean    # Remove build files

# Running
make run      # Build and run demo
make run-app  # Build and run app bundle

# Development
make watch    # Watch for changes and rebuild
make debug-info   # Show build configuration

# Installation
make install    # Install to /Applications (requires sudo)
make uninstall  # Remove from /Applications

# Help
make help     # Show all available targets
```

## Delegate Patterns

All interactive components use proper delegate patterns:

```objective-c
// Button delegate
@protocol SystemButtonDelegate <NSObject>
@optional
- (void)systemButtonWasClicked:(id)sender;
@end

// Window delegate  
@protocol SystemWindowDelegate <NSObject>
@optional
- (void)systemWindowCloseButtonClicked:(id)sender;
- (void)systemWindowResizeButtonClicked:(id)sender;
@end

// Form component delegates
@protocol SystemRadioButtonDelegate <NSObject>
@optional
- (void)radioButtonSelectionChanged:(id)sender;
@end
```

## Compatibility

- **macOS**: 10.12 (Sierra) and later
- **Xcode**: 8.0 and later
- **Language**: Objective-C with ARC
- **Frameworks**: Cocoa, QuartzCore

## Inspiration

This library is inspired by [system.css](https://github.com/sakofchit/system.css) by Sakun Acharige, which recreates the classic Apple System OS aesthetic for web applications. This Objective-C implementation brings that same nostalgic design to native macOS applications.

## Development Notes

### Custom Drawing

Components use custom `drawRect:` implementations to achieve pixel-perfect recreation of the System OS aesthetic:

- Box shadows with 2px offset
- Racing stripe patterns for active title bars
- Proper border styling with CSS-like effects
- Grid patterns for backgrounds

### Event Handling

All components implement proper mouse tracking and event handling:

- Mouse enter/exit for hover states
- Mouse down/up for click detection
- Keyboard focus management
- Proper responder chain participation

### Memory Management

The library uses ARC (Automatic Reference Counting) and follows modern Objective-C best practices:

- Weak references to prevent retain cycles
- Proper cleanup in dealloc methods
- Safe handling of delegates and notifications

## Contributing

This is a demonstration project showcasing how to recreate web design systems in native macOS applications. Feel free to:

- Study the implementation techniques
- Adapt components for your own projects
- Extend the library with additional components
- Improve the existing implementations

## License

This project is created for educational and demonstration purposes. The original system.css design is by Sakun Acharige.

## Demo Application

The included demo application showcases all components in action:

![SystemCSS Demo](screenshot.png)

Run `make run` to see all components in their retro glory!

---

*Bringing the nostalgia of classic computing to modern macOS development.*