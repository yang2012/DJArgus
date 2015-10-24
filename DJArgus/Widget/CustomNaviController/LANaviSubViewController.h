//
//  LANaviSubViewController.h
//  Argus
//
//  Created by chris on 7/24/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJDefinition.h"
#import "LAViewController.h"

@class LANaviBar;

@interface LANaviSubViewController : LAViewController

- (UIButton *)defaultNaviBarLeftButton;
- (UIButton *)defaultNaviBarRightButton;

- (void)setNaviBarLeftViewHidden:(BOOL)hidden;
- (void)setNaviBarRightViewHidden:(BOOL)hidden;

- (void)setNaviBarHidden:(BOOL)hidden withAnimation:(BOOL)animated;

- (LANaviBar *)naviBar;
- (BOOL)isNaviBarHidden;
- (void)replaceNaviBar:(LANaviBar *)naviBar;

- (void)naviBarLeftButtonPressed;
- (void)naviBarRightButtonPressed;

@end
