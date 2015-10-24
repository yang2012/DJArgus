//
//  MBProgressHUD+DJUI.h
//  DJArgus
//
//  Created by Justin Yang on 15/9/20.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (DJUI)

+ (instancetype)dj_showHUDWithTitle:(NSString *)title message:(NSString *)message fromView:(UIView *)view;

+ (instancetype)dj_showHUDWithMessage:(NSString *)message fromView:(UIView *)view;

@end
