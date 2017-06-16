//  Created by dasdom on 14.06.17.
//  Copyright © 2017 dasdom. All rights reserved.
//
// Source: https://stackoverflow.com/a/8379047/498796

#import "LogStore.h"

#import "LogViewController.h"

//@interface LogStore ()
//@property (nonatomic, strong) NSMutableString *storedLog;
//@end

@implementation LogStore

//+ (instancetype)sharedInstance {
//    static dispatch_once_t once;
//    static id _sharedInstance = nil;
//    dispatch_once(&once, ^{
//        _sharedInstance = [[self alloc] init];
//    });
//
//    return _sharedInstance;
//}
//
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        _storedLog = [NSMutableString new];
//    }
//    return self;
//}

//- (void)dealloc {
//    [self.log writeToFile:[self filePath] atomically:true encoding:NSASCIIStringEncoding error:NULL];
//}

+ (void)redirectLogToFile {
    [@"" writeToFile:[self filePath] atomically:true encoding:NSASCIIStringEncoding error:NULL];
    freopen([[self filePath] cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

+ (NSString *)filePath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"log_store.txt"];
    return filePath;
}

//- (void)logString:(NSString *)log {
//    [self.storedLog appendString:log];
//}

+ (NSString *)log {
//    [self.storedLog writeToFile:[self filePath] atomically:true encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *readError;
    NSString *log = [NSString stringWithContentsOfFile:[self filePath] encoding:NSASCIIStringEncoding error:&readError];
    return log;
}

+ (void)presentLogFromViewController:(UIViewController *)viewController {
    LogViewController *logViewController = [[LogViewController alloc] init];
    [viewController presentViewController:[[UINavigationController alloc] initWithRootViewController:logViewController] animated:true completion:nil];
}

@end
