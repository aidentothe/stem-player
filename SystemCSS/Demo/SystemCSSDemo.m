//
//  SystemCSSDemo.m
//  SystemCSS Component Library Demo
//
//  Demonstration application showcasing all SystemCSS components
//  Recreates the classic Apple System OS aesthetic
//

#import <Cocoa/Cocoa.h>
#import "../SystemCSSComponents.h"

// MARK: - Custom Background View

@interface RetroBackgroundView : NSView
@end

@implementation RetroBackgroundView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Fill with primary color
    [[SystemCSSColors primaryColor] setFill];
    NSRectFill(self.bounds);
    
    // Draw grid pattern
    [SystemCSSColors drawGridPatternInRect:self.bounds];
}

- (BOOL)isFlipped {
    return YES;
}

@end

// MARK: - Demo Application

@interface SystemCSSDemoApp : NSObject <NSApplicationDelegate, 
                                      SystemButtonDelegate, 
                                      SystemWindowDelegate,
                                      SystemMenuBarDelegate,
                                      SystemDialogDelegate,
                                      SystemRadioButtonDelegate,
                                      SystemCheckboxDelegate,
                                      SystemSelectMenuDelegate>

@property (nonatomic, strong) NSWindow *mainWindow;
@property (nonatomic, strong) SystemWindow *demoWindow;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSView *contentView;

@end

@implementation SystemCSSDemoApp

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self createMainWindow];
    [self setupDemoContent];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)createMainWindow {
    NSRect mainFrame = NSMakeRect(100, 100, 900, 700);
    
    self.mainWindow = [[NSWindow alloc] initWithContentRect:mainFrame
                                                  styleMask:(NSWindowStyleMaskTitled | 
                                                            NSWindowStyleMaskClosable | 
                                                            NSWindowStyleMaskMiniaturizable | 
                                                            NSWindowStyleMaskResizable)
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO];
    
    self.mainWindow.title = @"SystemCSS Component Library Demo";
    
    // Create retro background
    NSView *backgroundView = [SystemCSSComponents createRetroBackgroundViewWithFrame:mainFrame];
    backgroundView.wantsLayer = YES;
    backgroundView.layer.backgroundColor = [SystemCSSColors primaryColor].CGColor;
    
    // Draw grid pattern
    backgroundView = [[RetroBackgroundView alloc] initWithFrame:NSMakeRect(0, 0, mainFrame.size.width, mainFrame.size.height)];
    [self.mainWindow.contentView addSubview:backgroundView];
    
    [self.mainWindow makeKeyAndOrderFront:nil];
}

- (void)setupDemoContent {
    // Create main demo window
    NSRect demoFrame = NSMakeRect(50, 50, 800, 600);
    self.demoWindow = [[SystemWindow alloc] initWithFrame:demoFrame 
                                                    style:SystemWindowStyleStandard 
                                                    title:@"SystemCSS Demo - All Components" 
                                             showControls:YES];
    self.demoWindow.delegate = self;
    
    // Create scrollable content
    [self setupScrollableContent];
    
    [self.mainWindow.contentView addSubview:self.demoWindow];
}

- (void)setupScrollableContent {
    // Create content view that will contain all demo components
    self.contentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 750, 1200)]; // Tall for scrolling
    
    CGFloat currentY = 1150; // Start from top
    
    // Title
    [self addSectionTitle:@"SystemCSS Component Library Demo" atY:&currentY];
    
    // Button demonstrations
    [self addSectionTitle:@"Buttons" atY:&currentY];
    [self addButtonDemonstrations:&currentY];
    
    // Form component demonstrations
    [self addSectionTitle:@"Form Components" atY:&currentY];
    [self addFormDemonstrations:&currentY];
    
    // Menu demonstrations
    [self addSectionTitle:@"Menu Components" atY:&currentY];
    [self addMenuDemonstrations:&currentY];
    
    // Dialog demonstrations
    [self addSectionTitle:@"Dialog Components" atY:&currentY];
    [self addDialogDemonstrations:&currentY];
    
    // Window demonstrations
    [self addSectionTitle:@"Window Components" atY:&currentY];
    [self addWindowDemonstrations:&currentY];
    
    // Set the content view
    [self.demoWindow setWindowContent:self.contentView];
}

- (void)addSectionTitle:(NSString *)title atY:(CGFloat *)currentY {
    NSTextField *titleField = [[NSTextField alloc] initWithFrame:NSMakeRect(20, *currentY, 700, 30)];
    titleField.stringValue = title;
    titleField.font = [SystemCSSColors chicago12Font];
    titleField.textColor = [SystemCSSColors secondaryColor];
    titleField.backgroundColor = [SystemCSSColors primaryColor];
    titleField.bordered = NO;
    titleField.editable = NO;
    titleField.selectable = NO;
    
    [self.contentView addSubview:titleField];
    *currentY -= 40;
}

- (void)addButtonDemonstrations:(CGFloat *)currentY {
    CGFloat x = 20;
    
    // Standard buttons
    SystemButton *standardBtn = [[SystemButton alloc] initStandardButtonWithTitle:@"Standard"];
    standardBtn.delegate = self;
    [standardBtn setFrame:NSMakeRect(x, *currentY, standardBtn.frame.size.width, standardBtn.frame.size.height)];
    [self.contentView addSubview:standardBtn];
    x += standardBtn.frame.size.width + 10;
    
    // Default button
    SystemButton *defaultBtn = [[SystemButton alloc] initDefaultButtonWithTitle:@"Default"];
    defaultBtn.delegate = self;
    [defaultBtn setFrame:NSMakeRect(x, *currentY, defaultBtn.frame.size.width, defaultBtn.frame.size.height)];
    [self.contentView addSubview:defaultBtn];
    x += defaultBtn.frame.size.width + 10;
    
    // Disabled button
    SystemButton *disabledBtn = [[SystemButton alloc] initStandardButtonWithTitle:@"Disabled"];
    disabledBtn.enabled = NO;
    [disabledBtn setFrame:NSMakeRect(x, *currentY, disabledBtn.frame.size.width, disabledBtn.frame.size.height)];
    [self.contentView addSubview:disabledBtn];
    x += disabledBtn.frame.size.width + 10;
    
    // Long button
    SystemButton *longBtn = [[SystemButton alloc] initStandardButtonWithTitle:@"This is a longer button title"];
    longBtn.delegate = self;
    [longBtn setFrame:NSMakeRect(x, *currentY, longBtn.frame.size.width, longBtn.frame.size.height)];
    [self.contentView addSubview:longBtn];
    
    *currentY -= 40;
    
    // Title bar buttons
    SystemButton *closeBtn = [[SystemButton alloc] initTitleBarCloseButton];
    closeBtn.delegate = self;
    [closeBtn setFrame:NSMakeRect(20, *currentY, closeBtn.frame.size.width, closeBtn.frame.size.height)];
    [self.contentView addSubview:closeBtn];
    
    SystemButton *resizeBtn = [[SystemButton alloc] initTitleBarResizeButton];
    resizeBtn.delegate = self;
    [resizeBtn setFrame:NSMakeRect(50, *currentY, resizeBtn.frame.size.width, resizeBtn.frame.size.height)];
    [self.contentView addSubview:resizeBtn];
    
    *currentY -= 50;
}

- (void)addFormDemonstrations:(CGFloat *)currentY {
    // Text fields
    SystemTextField *textField = [[SystemTextField alloc] initStandardTextField];
    textField.placeholderText = @"Enter text here...";
    [textField setFrame:NSMakeRect(20, *currentY, 200, 24)];
    [self.contentView addSubview:textField];
    
    SystemTextField *passwordField = [[SystemTextField alloc] initPasswordField];
    passwordField.placeholderText = @"Password";
    [passwordField setFrame:NSMakeRect(240, *currentY, 200, 24)];
    [self.contentView addSubview:passwordField];
    
    *currentY -= 40;
    
    // Radio buttons
    SystemRadioButton *radio1 = [[SystemRadioButton alloc] initWithTitle:@"Option 1" groupName:@"demo"];
    radio1.delegate = self;
    [radio1 setFrame:NSMakeRect(20, *currentY, radio1.frame.size.width, radio1.frame.size.height)];
    [self.contentView addSubview:radio1];
    
    SystemRadioButton *radio2 = [[SystemRadioButton alloc] initWithTitle:@"Option 2" groupName:@"demo"];
    radio2.delegate = self;
    [radio2 setFrame:NSMakeRect(150, *currentY, radio2.frame.size.width, radio2.frame.size.height)];
    [self.contentView addSubview:radio2];
    
    SystemRadioButton *radio3 = [[SystemRadioButton alloc] initWithTitle:@"Option 3" groupName:@"demo"];
    radio3.delegate = self;
    [radio3 setFrame:NSMakeRect(280, *currentY, radio3.frame.size.width, radio3.frame.size.height)];
    [self.contentView addSubview:radio3];
    
    *currentY -= 40;
    
    // Checkboxes
    SystemCheckbox *checkbox1 = [[SystemCheckbox alloc] initWithTitle:@"Checkbox 1"];
    checkbox1.delegate = self;
    [checkbox1 setFrame:NSMakeRect(20, *currentY, checkbox1.frame.size.width, checkbox1.frame.size.height)];
    [self.contentView addSubview:checkbox1];
    
    SystemCheckbox *checkbox2 = [[SystemCheckbox alloc] initWithTitle:@"Checkbox 2"];
    checkbox2.delegate = self;
    checkbox2.checked = YES;
    [checkbox2 setFrame:NSMakeRect(150, *currentY, checkbox2.frame.size.width, checkbox2.frame.size.height)];
    [self.contentView addSubview:checkbox2];
    
    *currentY -= 40;
    
    // Select menu
    NSArray *selectItems = @[@"Option A", @"Option B", @"Option C", @"Option D"];
    SystemSelectMenu *selectMenu = [[SystemSelectMenu alloc] initWithItems:selectItems];
    selectMenu.delegate = self;
    [selectMenu setFrame:NSMakeRect(20, *currentY, 160, 24)];
    [self.contentView addSubview:selectMenu];
    
    *currentY -= 50;
}

- (void)addMenuDemonstrations:(CGFloat *)currentY {
    // Create menu items
    SystemMenuItem *fileItem = [[SystemMenuItem alloc] initWithTitle:@"File"];
    SystemMenuItem *newItem = [[SystemMenuItem alloc] initWithTitle:@"New"];
    SystemMenuItem *openItem = [[SystemMenuItem alloc] initWithTitle:@"Open"];
    SystemMenuItem *saveItem = [[SystemMenuItem alloc] initWithTitle:@"Save"];
    SystemMenuItem *divider = [[SystemMenuItem alloc] initDivider];
    SystemMenuItem *quitItem = [[SystemMenuItem alloc] initWithTitle:@"Quit"];
    
    [fileItem setSubmenuItems:@[newItem, openItem, saveItem, divider, quitItem]];
    
    SystemMenuItem *editItem = [[SystemMenuItem alloc] initWithTitle:@"Edit"];
    SystemMenuItem *cutItem = [[SystemMenuItem alloc] initWithTitle:@"Cut"];
    SystemMenuItem *copyItem = [[SystemMenuItem alloc] initWithTitle:@"Copy"];
    SystemMenuItem *pasteItem = [[SystemMenuItem alloc] initWithTitle:@"Paste"];
    
    [editItem setSubmenuItems:@[cutItem, copyItem, pasteItem]];
    
    SystemMenuItem *helpItem = [[SystemMenuItem alloc] initWithTitle:@"Help"];
    
    // Create menu bar
    SystemMenuBar *menuBar = [[SystemMenuBar alloc] initWithMenuItems:@[fileItem, editItem, helpItem]];
    menuBar.delegate = self;
    [menuBar setFrame:NSMakeRect(20, *currentY, menuBar.frame.size.width, menuBar.frame.size.height)];
    [self.contentView addSubview:menuBar];
    
    *currentY -= 50;
}

- (void)addDialogDemonstrations:(CGFloat *)currentY {
    // Standard dialog
    SystemStandardDialog *standardDialog = [[SystemStandardDialog alloc] initWithTitle:@"Standard Dialog" 
                                                                               message:@"This is a standard dialog message"];
    [standardDialog setFrame:NSMakeRect(20, *currentY, 300, 100)];
    [self.contentView addSubview:standardDialog];
    
    *currentY -= 120;
    
    // Modal dialog
    SystemModalDialog *modalDialog = [[SystemModalDialog alloc] initWithTitle:@"Modal Dialog"];
    SystemButton *okBtn = [[SystemButton alloc] initStandardButtonWithTitle:@"OK"];
    SystemButton *cancelBtn = [[SystemButton alloc] initStandardButtonWithTitle:@"Cancel"];
    [modalDialog addButton:cancelBtn];
    [modalDialog addButton:okBtn];
    [modalDialog setFrame:NSMakeRect(20, *currentY, 350, 120)];
    [self.contentView addSubview:modalDialog];
    
    *currentY -= 140;
    
    // Alert box
    SystemAlertBox *alertBox = [[SystemAlertBox alloc] initWithMessage:@"This is an alert message with an icon." 
                                                              iconType:SystemAlertIconCaution];
    SystemButton *alertOK = [[SystemButton alloc] initStandardButtonWithTitle:@"OK"];
    SystemButton *alertCancel = [[SystemButton alloc] initStandardButtonWithTitle:@"Cancel"];
    [alertBox addButton:alertCancel];
    [alertBox addButton:alertOK];
    [alertBox setFrame:NSMakeRect(20, *currentY, 350, 100)];
    [self.contentView addSubview:alertBox];
    
    *currentY -= 120;
}

- (void)addWindowDemonstrations:(CGFloat *)currentY {
    // Small demo window
    SystemWindow *miniWindow = [[SystemWindow alloc] initStandardWindowWithTitle:@"Mini Window"];
    [miniWindow setFrame:NSMakeRect(20, *currentY, 250, 150)];
    
    // Add some content to the mini window
    NSTextField *windowContent = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 10, 200, 60)];
    windowContent.stringValue = @"This is content inside a SystemWindow component.";
    windowContent.font = [SystemCSSColors genevaFont:12.0];
    windowContent.backgroundColor = [SystemCSSColors primaryColor];
    windowContent.bordered = NO;
    windowContent.editable = NO;
    windowContent.selectable = NO;
    [miniWindow setWindowContent:windowContent];
    
    [self.contentView addSubview:miniWindow];
    
    // Dialog-style window
    SystemWindow *dialogWindow = [[SystemWindow alloc] initDialogWindowWithTitle:@"Dialog Window"];
    [dialogWindow setFrame:NSMakeRect(290, *currentY, 200, 100)];
    [self.contentView addSubview:dialogWindow];
    
    *currentY -= 170;
}

// MARK: - Delegate Methods

- (void)systemButtonWasClicked:(SystemButton *)sender {
    NSLog(@"Button clicked: %@", sender.title);
    
    if ([sender.title isEqualToString:@"Standard"]) {
        [self showDemoAlert:@"Standard button was clicked!"];
    } else if ([sender.title isEqualToString:@"Default"]) {
        [self showDemoAlert:@"Default button was clicked!"];
    } else if ([sender.title containsString:@"longer"]) {
        [self showDemoAlert:@"Long button was clicked!"];
    }
}

- (void)radioButtonSelectionChanged:(SystemRadioButton *)sender {
    NSLog(@"Radio button selected: %@", sender.title);
}

- (void)checkboxStateChanged:(SystemCheckbox *)sender {
    NSLog(@"Checkbox %@: %@", sender.title, sender.checked ? @"checked" : @"unchecked");
}

- (void)selectMenuSelectionChanged:(SystemSelectMenu *)sender {
    NSLog(@"Select menu changed to: %@", sender.selectedItem);
}

- (void)menuBarItem:(SystemMenuItem *)item wasClicked:(SystemMenuBar *)menuBar {
    NSLog(@"Menu item clicked: %@", item.title);
    [self showDemoAlert:[NSString stringWithFormat:@"Menu item '%@' was clicked!", item.title]];
}

- (void)systemWindowCloseButtonClicked:(id)sender {
    NSLog(@"Window close button clicked");
    [self showDemoAlert:@"Window close button clicked!"];
}

- (void)systemWindowResizeButtonClicked:(id)sender {
    NSLog(@"Window resize button clicked");
    [self showDemoAlert:@"Window resize button clicked!"];
}

- (void)systemDialogButtonClicked:(SystemButton *)button dialog:(id)dialog {
    NSLog(@"Dialog button clicked: %@", button.title);
    [self showDemoAlert:[NSString stringWithFormat:@"Dialog button '%@' was clicked!", button.title]];
}

- (void)showDemoAlert:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"SystemCSS Demo";
    alert.informativeText = message;
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

@end

// MARK: - Main Function

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        SystemCSSDemoApp *delegate = [[SystemCSSDemoApp alloc] init];
        app.delegate = delegate;
        
        [app run];
    }
    return 0;
}