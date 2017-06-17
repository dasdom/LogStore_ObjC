//  Created by dasdom on 14.06.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogStore : NSObject
+ (UIWindow *)shakeableWindow;
+ (FILE *)redirectLogToFile;
+ (void)presentLogFromViewController:(UIViewController *)viewController;
+ (NSString *)log;
@end
