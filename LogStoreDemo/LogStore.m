//  Created by dasdom on 14.06.17.
//  Copyright © 2017 dasdom. All rights reserved.
//
// Source: https://stackoverflow.com/a/8379047/498796

#import "LogStore.h"

@interface ShakeableWindow : UIWindow
@end

@interface LogViewController : UIViewController
@end

@implementation LogStore

+ (UIWindow *)shakeableWindow {
    return [[ShakeableWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

+ (void)redirectLogToFile {
    [@"" writeToFile:[self filePath] atomically:true encoding:NSASCIIStringEncoding error:NULL];
    freopen([[self filePath] cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

+ (NSString *)filePath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"log_store.txt"];
    return filePath;
}

+ (NSString *)log {    
    NSError *readError;
    NSString *log = [NSString stringWithContentsOfFile:[self filePath] encoding:NSASCIIStringEncoding error:&readError];
    return log;
}

+ (void)presentLogFromViewController:(UIViewController *)viewController {
    LogViewController *logViewController = [[LogViewController alloc] init];
    [viewController presentViewController:[[UINavigationController alloc] initWithRootViewController:logViewController] animated:true completion:nil];
}

@end

// ***********************************************************************
// * LogViewController                                                   *
// ***********************************************************************

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextView *textView = [UITextView new];
    textView.translatesAutoresizingMaskIntoConstraints = false;
    textView.text = [LogStore log];
    
    [self.view addSubview:textView];
    
    [NSLayoutConstraint activateConstraints:@[
                                              [textView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
                                              [textView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
                                              [textView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor],
                                              [textView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor]
                                              ]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = dismissButton;
}

- (void)dismiss {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end


// ***********************************************************************
// * ShakeableWindow                                                     *
// ***********************************************************************
// Inspired by https://github.com/facebook/Tweaks/blob/master/FBTweak/FBTweakShakeWindow.m

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
