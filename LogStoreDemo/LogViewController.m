//  Created by dasdom on 14.06.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import "LogViewController.h"

#import "LogStore.h"

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
