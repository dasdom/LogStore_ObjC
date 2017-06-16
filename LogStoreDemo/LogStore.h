//  Created by dasdom on 14.06.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogStore : NSObject
//+ (instancetype)sharedInstance;
//- (void)logString:(NSString *)log;
+ (void)redirectLogToFile;
+ (void)presentLogFromViewController:(UIViewController *)viewController;
+ (NSString *)log;
@end
