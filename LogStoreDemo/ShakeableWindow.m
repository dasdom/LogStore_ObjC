//  Created by dasdom on 14.06.17.
//  Copyright © 2017 dasdom. All rights reserved.
//
// Inspired by https://github.com/facebook/Tweaks/blob/master/FBTweak/FBTweakShakeWindow.m

#import "ShakeableWindow.h"

#import "LogStore.h"

@implementation ShakeableWindow {
    BOOL _isShaking;
    BOOL _isActive;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self->_isShaking = false;
    self->_isActive = false;
}

- (void)_presentLog {
    UIViewController *visibleViewController = self.rootViewController;
    while (visibleViewController.presentedViewController != nil) {
        visibleViewController = visibleViewController.presentedViewController;
    }
    
    [LogStore presentLogFromViewController:visibleViewController];
}

- (BOOL)_shouldPresentLog {
#if TARGET_IPHONE_SIMULATOR
    return true;
#else
    return _isShaking;
#endif
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        _isShaking = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if ([self _shouldPresentLog]) {
                [self _presentLog];
            }
        });
    }
    [super motionBegan:motion withEvent:event];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        _isShaking = NO;
    }
    [super motionEnded:motion withEvent:event];
}


@end
