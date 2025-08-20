//
//  TrackpadWrapper.h
//  Trackpad wrapper for multi-touch support
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef struct {
    CGFloat x;
    CGFloat y;
} TouchPoint;

@interface TrackpadTouch : NSObject
@property (nonatomic) NSInteger touchID;
@property (nonatomic) TouchPoint normalizedPosition;
@property (nonatomic) CGFloat pressure;
@property (nonatomic) BOOL isActive;
@end

@interface TrackpadClickEvent : NSObject
@property (nonatomic) TouchPoint location;
@property (nonatomic) NSInteger clickCount;
@end

@interface TrackpadScrollEvent : NSObject
@property (nonatomic) CGFloat deltaX;
@property (nonatomic) CGFloat deltaY;
@end

@protocol TrackpadWrapperDelegate <NSObject>
@optional
- (void)trackpadWrapper:(id)wrapper touchesChanged:(NSArray<TrackpadTouch *> *)touches;
- (void)trackpadWrapper:(id)wrapper hoverChanged:(NSArray<TrackpadTouch *> *)hovers;
- (void)trackpadWrapper:(id)wrapper clickDetected:(TrackpadClickEvent *)clickEvent;
- (void)trackpadWrapper:(id)wrapper scrollDetected:(TrackpadScrollEvent *)scrollEvent;
@end

@interface TrackpadWrapper : NSObject
@property (weak, nonatomic) id<TrackpadWrapperDelegate> delegate;
@property (nonatomic) CGFloat clickThreshold;
@property (nonatomic) CGFloat hoverThreshold;

+ (instancetype)sharedWrapper;
- (BOOL)startMonitoring;
- (void)stopMonitoring;
@end