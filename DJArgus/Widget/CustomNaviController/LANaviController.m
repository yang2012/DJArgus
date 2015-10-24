//
//  LANaviController.m
//  Argus
//
//  Created by chris on 7/24/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "LANaviController.h"
#import "DJDefinition.h"


@implementation LANaviController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarHidden:NO];
    [self.navigationBar setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)canSwipeBack:(BOOL)enabled {
    if (IPHONE_OS_7()) {
        self.interactivePopGestureRecognizer.enabled = enabled;
    }
}

- (CGFloat)statusBarHeight {
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

- (CGFloat)navBarHeight {
    return self.navigationController.navigationBar.frame.size.height;
}

- (CGFloat)tabBarHeight {
    return self.tabBarController.tabBar.frame.size.height;
}

- (CGFloat)screenWidth {
    return [[UIScreen mainScreen] bounds].size.width;
}

- (CGFloat)screenHeight {
    return [[UIScreen mainScreen] bounds].size.height;
}

- (void)openURLSchema:(NSString *)schema withParams:(NSDictionary *)params {
    
}

@end
