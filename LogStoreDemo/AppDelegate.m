//  Created by dasdom on 14.06.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import "AppDelegate.h"

#import "LogStore.h"

@implementation AppDelegate

- (UIWindow *)window {
    if (!_window) {
        _window = [LogStore shakeableWindow];
    }
    return _window;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

@end
