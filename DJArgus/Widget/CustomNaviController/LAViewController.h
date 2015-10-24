//
//  LAViewController.h
//  Argus
//
//  Created by chris on 7/24/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAViewController : UIViewController

@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, assign) CGFloat statusBarHeight;
@property (nonatomic, assign) CGFloat naviBarHeight;
@property (nonatomic, assign) CGFloat tabBarHeight;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;

@end
