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
@interface LogViewController () <UISearchBarDelegate>
@property (nonatomic, strong) NSArray<NSString *> *logLines;
@property (nonatomic, strong) NSArray<NSString *> *shownLogLines;
@property BOOL hideTimeInfo;
@property (copy) NSString *searchString;
@property UIStackView *searchStackView;
@property UISearchBar *searchBar;
@property NSInteger searchPosition;
@property UIButton *nextButton;
@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    let *log = [LogStore log];
    self.logLines = [log componentsSeparatedByString:@"\n"];
    self.shownLogLines = [self.logLines copy];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    let *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    let *toggleTimeInfoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(toggleTimeInfo)];
    self.navigationItem.leftBarButtonItems = @[dismissButton, toggleTimeInfoButton];
    
    //    var *clearLogButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearLog)];
    //    self.navigationItem.leftBarButtonItem = clearLogButton;
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    self.nextButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    self.nextButton.backgroundColor = [UIColor whiteColor];
    [self.nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    
    self.searchStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.searchBar, self.nextButton]];
    //    stackView.axis = UILayoutConstraintAxisVertical;
    self.searchStackView.spacing = 5;
    self.searchStackView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 40);
    
    [self.tableView addSubview:self.searchStackView];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64+self.searchStackView.frame.size.height, 0, 0, 0);
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
    return self.shownLogLines.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    var *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    var *line = self.shownLogLines[indexPath.row];
    if (line.length > 1) {
        var rangeOfBracket = [line rangeOfString:@"]"];
        if (rangeOfBracket.location == NSNotFound) {
            rangeOfBracket = NSMakeRange(0, 0);
        }
        let rangeOfPrefix = NSMakeRange(0, rangeOfBracket.location+1);
        cell.textLabel.textColor = [UIColor whiteColor];
        if (self.hideTimeInfo) {
            line = [line stringByReplacingCharactersInRange:rangeOfPrefix withString:@""];
            cell.textLabel.text = line;
            cell.textLabel.font = [UIFont fontWithName:@"Menlo" size:10];
        } else {
            var *attributedLine = [[NSMutableAttributedString alloc] initWithString:line attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:10]}];
            [attributedLine addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:rangeOfPrefix];
            if (self.searchString.length > 0) {
                let rangeOfSearchText = [line rangeOfString:self.searchString options:NSCaseInsensitiveSearch];
                if (rangeOfSearchText.location != NSNotFound) {
                    [attributedLine addAttribute:NSForegroundColorAttributeName value:[UIColor cyanColor] range:rangeOfSearchText];
                    [attributedLine addAttribute:NSBackgroundColorAttributeName value:[UIColor grayColor] range:rangeOfSearchText];
                }
            }
            cell.textLabel.attributedText = attributedLine;
        }
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    cell.backgroundColor = [UIColor blackColor];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGRect floatingViewFrame = self.searchStackView.frame;
    floatingViewFrame.origin.y = 64 + scrollView.contentOffset.y;
    self.searchStackView.frame = floatingViewFrame;
}

#pragma mark - <UISearchBarDelegate>
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    self.searchString = searchText;
    self.nextButton.backgroundColor = [UIColor whiteColor];
    
    __block BOOL found = false;
    [self.shownLogLines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.lowercaseString containsString:searchText.lowercaseString]) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:true];
            self.searchPosition = idx;
            [self.tableView reloadData];
            *stop = true;
            found = true;
        }
    }];
    if (!found) {
        self.nextButton.backgroundColor = [UIColor redColor];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.searchPosition = 0;
}

- (void)next {
    [self.searchBar resignFirstResponder];
    
    [self.shownLogLines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx > self.searchPosition) {
            if ([obj.lowercaseString containsString:self.searchString.lowercaseString]) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:true];
                self.searchPosition = idx;
                *stop = true;
            }
        }
    }];
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
    
    self.logRedirectIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 20)];
    self.logRedirectIndicatorView.backgroundColor = [UIColor redColor];
    
    BOOL activeRedirect = [[NSUserDefaults standardUserDefaults] boolForKey:DDHRedirectionActiveKey];
    [self activateLogRedirect:activeRedirect];
    
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
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    return true;
}

@end
