//
//  TrackpadWrapper.m
//  Trackpad wrapper implementation
//

#import "TrackpadWrapper.h"

@implementation TrackpadTouch
@end

@implementation TrackpadClickEvent
@end

@implementation TrackpadScrollEvent
@end

@implementation TrackpadWrapper {
    NSTimer *_mockTimer;
    NSMutableArray<TrackpadTouch *> *_currentTouches;
}

+ (instancetype)sharedWrapper {
    static TrackpadWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _clickThreshold = 0.04;
        _hoverThreshold = 0.01;
        _currentTouches = [NSMutableArray array];
    }
    return self;
}

- (BOOL)startMonitoring {
    // For now, just simulate successful start
    // In production, this would interface with actual trackpad APIs
    
    // Start a timer to simulate touch events for testing
    _mockTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(mockTouchUpdate)
                                                userInfo:nil
                                                 repeats:YES];
    
    return YES;
}

- (void)stopMonitoring {
    [_mockTimer invalidate];
    _mockTimer = nil;
    [_currentTouches removeAllObjects];
}

- (void)mockTouchUpdate {
    // This is a placeholder - in production this would receive real trackpad events
    // For now, just clear any simulated touches
    if (_currentTouches.count > 0) {
        [_currentTouches removeAllObjects];
        if ([_delegate respondsToSelector:@selector(trackpadWrapper:touchesChanged:)]) {
            [_delegate trackpadWrapper:self touchesChanged:_currentTouches];
        }
    }
}

@end