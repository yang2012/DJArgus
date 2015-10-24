//
//  LAViewController.m
//  Argus
//
//  Created by chris on 7/24/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "LAViewController.h"

@interface LAViewController () {
    
}

@end

@implementation LAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
