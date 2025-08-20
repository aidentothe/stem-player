//
//  TrackpadFaderAppV3.h
//  System.css styled fader app with proper cursor confinement
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "TrackpadWrapper.h"
#import "SystemCSSComponents.h"

// Configuration
#define MAX_POSSIBLE_FADERS 8  // Maximum possible faders
// Actual fader count will be determined dynamically

// Trackpad zone structure
typedef struct {
    CGFloat startX;
    CGFloat endX;
    NSInteger zoneIndex;
} TrackpadZone;

#pragma mark - System.css Fader Control

@interface SystemCSSFader : NSView

@property (nonatomic) CGFloat value;
@property (nonatomic) CGFloat minValue;
@property (nonatomic) CGFloat maxValue;
@property (nonatomic, strong) NSString *label;
@property (nonatomic) NSInteger faderIndex;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isMuted;
@property (nonatomic, weak) id delegate;

- (instancetype)initWithFrame:(NSRect)frame label:(NSString *)label index:(NSInteger)index;
- (void)setValue:(CGFloat)value animated:(BOOL)animated;
- (void)setActive:(BOOL)active;

@end

@protocol SystemCSSFaderDelegate <NSObject>
@optional
- (void)fader:(SystemCSSFader *)fader valueChanged:(CGFloat)value;
@end

#pragma mark - Main Application Interface

@interface TrackpadFaderAppV3 : NSObject <NSApplicationDelegate, TrackpadWrapperDelegate, SystemCSSFaderDelegate, NSTableViewDelegate, NSTableViewDataSource>

// Window and UI
@property (strong) NSWindow *window;
@property (strong) NSView *faderContainer;
@property (strong) NSMutableArray<SystemCSSFader *> *faders;
@property (nonatomic) NSInteger currentFaderCount;  // Dynamic fader count based on stems
@property (strong) NSTextField *statusLabel;
@property (strong) NSTextField *valuesLabel;
@property (strong) NSTextField *cursorLockIndicator;

// Song Selection Properties
@property (strong) NSView *songSelectionView;
@property (strong) NSTableView *songTableView;
@property (strong) NSMutableArray *songs;
@property (strong) NSMutableDictionary *songMetadata;
@property (strong) NSString *selectedSongPath;
@property (strong) NSButton *playButton;
@property (strong) NSButton *stopButton;
@property (strong) NSTextField *nowPlayingLabel;

// Audio Properties
@property (strong) AVAudioEngine *audioEngine;
@property (strong) NSMutableArray<AVAudioPlayerNode *> *stemPlayers;
@property (strong) NSMutableArray<AVAudioFile *> *stemFiles;
@property (strong) NSMutableArray<NSString *> *stemNames;
@property (nonatomic) BOOL isPlaying;

// Trackpad
@property (strong) TrackpadWrapper *trackpadWrapper;
@property (strong) NSMutableDictionary *activeTouches;
@property (strong) NSMutableDictionary *faderBaseValues;
@property (strong) NSMutableSet *mutedFaders;

// Cursor control
@property (nonatomic) BOOL cursorLocked;
@property (nonatomic) BOOL isInFaderUI;  // Track if we're in fader UI vs song selection
@property (strong) NSTimer *eventTapCheckTimer;
@property (nonatomic) CFMachPortRef eventTap;
@property (nonatomic) CFRunLoopSourceRef runLoopSource;

// Setup methods
- (void)setupApplication;
- (void)setupFaderUI;
- (void)setupTrackpadZones;
- (void)setupTrackpadWrapper;
- (void)setupEventTap;
- (void)setupGlobalKeyMonitor;

// Audio methods
- (void)playAudio;
- (void)pauseAudio;
- (void)stopAudio;

// UI helpers
- (NSButton *)createSystemButton:(NSString *)title action:(SEL)action frame:(NSRect)frame;

// Cursor control
- (void)toggleCursorLock;
- (void)lockCursor;
- (void)unlockCursor;
- (void)emergencyFreeCursor;

// Fader control
- (void)toggleMuteFader:(NSInteger)index;
- (void)resetAllFaders;
- (void)updateValuesDisplay;

// Trackpad zone detection
- (NSInteger)zoneForTrackpadX:(CGFloat)x;

// Search
- (void)searchFieldChanged:(NSSearchField *)searchField;

// Navigation
- (void)backToSongSelection;


@end