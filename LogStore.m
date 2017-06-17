//  Created by dasdom on 14.06.17.
//  Copyright © 2017 dasdom. All rights reserved.
//
// Source: https://stackoverflow.com/a/8379047/498796

#import "LogStore.h"

#define let __auto_type const
#define var __auto_type

@interface ShakeableWindow : UIWindow
@end

@interface LogViewController : UITableViewController
@end

@implementation LogStore

+ (UIWindow *)shakeableWindow {
    return [[ShakeableWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

+ (FILE *)redirectLogToFile {
    return freopen([[self filePath] cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

+ (void)stopRedirectToFile:(FILE *)file {
    fclose(file);
}

+ (void)clearLog {
    [@"" writeToFile:[self filePath] atomically:true encoding:NSASCIIStringEncoding error:NULL];
}

+ (NSString *)filePath {
    let *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    return [documentsPath stringByAppendingPathComponent:@"log_store.txt"];
}

+ (NSString *)log {    
    NSError *readError;
    var *log = [NSString stringWithContentsOfFile:[self filePath] encoding:NSASCIIStringEncoding error:&readError];
    return log;
}

+ (void)presentLogFromViewController:(UIViewController *)viewController {
    var *logViewController = [[LogViewController alloc] init];
    [viewController presentViewController:[[UINavigationController alloc] initWithRootViewController:logViewController] animated:true completion:nil];
}

@end

// ***********************************************************************
// * LogViewController                                                   *
// ***********************************************************************
@interface LogViewController ()
@property (nonatomic, strong) NSArray<NSString *> *logLines;
@property BOOL hideTimeInfo;
@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    let *log = [LogStore log];
    self.logLines = [log componentsSeparatedByString:@"\n"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    let *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    let *toggleTimeInfoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(toggleTimeInfo)];
    self.navigationItem.rightBarButtonItems = @[dismissButton, toggleTimeInfoButton];
    
//    var *clearLogButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearLog)];
//    self.navigationItem.leftBarButtonItem = clearLogButton;
}

- (void)dismiss {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)toggleTimeInfo {
    self.hideTimeInfo = !self.hideTimeInfo;
    [self.tableView reloadData];
}

//- (void)clearLog {
//    [LogStore clearLog];
//    [LogStore redirectLogToFile];
//    self.logLines = [NSArray new];
//    [self.tableView reloadData];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logLines.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    var *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    var *line = self.logLines[indexPath.row];
    if (line.length > 1) {
        let rangeOfBracket = [line rangeOfString:@"]"];
        let rangeOfPrefix = NSMakeRange(0, rangeOfBracket.location+1);
        cell.textLabel.textColor = [UIColor whiteColor];
        if (self.hideTimeInfo) {
            line = [line stringByReplacingCharactersInRange:rangeOfPrefix withString:@""];
            cell.textLabel.text = line;
            cell.textLabel.font = [UIFont fontWithName:@"Menlo" size:10];
        } else {
            var *attributedLine = [[NSMutableAttributedString alloc] initWithString:line attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:10]}];
            [attributedLine addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:rangeOfPrefix];
            cell.textLabel.attributedText = attributedLine;
        }
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    cell.backgroundColor = [UIColor blackColor];
    
    return cell;
}

@end


// ***********************************************************************
// * ShakeableWindow                                                     *
// ***********************************************************************
// Inspired by https://github.com/facebook/Tweaks/blob/master/FBTweak/FBTweakShakeWindow.m

#import <CoreMotion/CoreMotion.h>

static NSString *DDHRedirectionActiveKey = @"DDHRedirectionActiveKey";

@interface ShakeableWindow ()
@property CMMotionManager *motionManager;
@property UIView *logRedirectIndicatorView;
@property FILE *logFilePointer;
@end

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
    
    __weak __auto_type weakSelf = self;
    self.motionManager = [CMMotionManager new];
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        
        // Inspiration from http://nshipster.com/cmdevicemotion/
        if (motion.userAcceleration.x < -5) {
            if ([weakSelf _shouldPresentLog]) {
                [weakSelf _presentLog];
            } else {
                [weakSelf activateLogRedirect:true];
            }
        } else if (motion.userAcceleration.x > 5) {
            [weakSelf activateLogRedirect:false];
        }
    }];
    
    self.logRedirectIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 20)];
    self.logRedirectIndicatorView.backgroundColor = [UIColor redColor];
    
    BOOL activeRedirect = [[NSUserDefaults standardUserDefaults] boolForKey:DDHRedirectionActiveKey];
    [self activateLogRedirect:activeRedirect];
}

- (void)activateLogRedirect:(BOOL)activate {
    if (activate) {
        [self addSubview:self.logRedirectIndicatorView];
        self.logFilePointer = [LogStore redirectLogToFile];
    } else {
        [self.logRedirectIndicatorView removeFromSuperview];
        [LogStore stopRedirectToFile:self.logFilePointer];
        [LogStore clearLog];
    }
    [[NSUserDefaults standardUserDefaults] setBool:activate forKey:DDHRedirectionActiveKey];
}

- (void)didAddSubview:(UIView *)subview {
    if (self.logRedirectIndicatorView.superview && ![subview isEqual:self.logRedirectIndicatorView]) {
        [self bringSubviewToFront:self.logRedirectIndicatorView];
    }
}

- (void)_presentLog {
    UIViewController *visibleViewController = self.rootViewController;
    while (visibleViewController.presentedViewController != nil) {
        visibleViewController = visibleViewController.presentedViewController;
    }
    
    if ([visibleViewController isKindOfClass:[UINavigationController class]]) {
        if (![((UINavigationController*)visibleViewController).viewControllers.firstObject isKindOfClass:[LogViewController class]]) {
            [LogStore presentLogFromViewController:visibleViewController];
        }
    } else {
        [LogStore presentLogFromViewController:visibleViewController];
    }
}

- (BOOL)_shouldPresentLog {
    if (!self.logRedirectIndicatorView.superview) {
        return false;
    }
//#if TARGET_IPHONE_SIMULATOR
//    return true;
//#else
//    return _isShaking;
//#endif
    return true;
}

//- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
//    if (motion == UIEventSubtypeMotionShake) {
//        NSLog(@"event: %@", event);
//        _isShaking = YES;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            if ([self _shouldPresentLog]) {
//                [self _presentLog];
//            }
//        });
//    }
//    [super motionBegan:motion withEvent:event];
//}
//
//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
//    if (motion == UIEventSubtypeMotionShake) {
//        _isShaking = NO;
//    }
//    [super motionEnded:motion withEvent:event];
//}


@end
