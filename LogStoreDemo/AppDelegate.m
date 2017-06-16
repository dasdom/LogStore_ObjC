//  Created by dasdom on 14.06.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import "AppDelegate.h"

#import "LogStore.h"
#import "ShakeableWindow.h"

@implementation AppDelegate

- (UIWindow *)window {
    if (!_window) {
        _window = [[ShakeableWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    return _window;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [LogStore redirectLogToFile];
    
    NSLog(@"%d, %s", __LINE__, __func__);
    
    return YES;
}

@end
