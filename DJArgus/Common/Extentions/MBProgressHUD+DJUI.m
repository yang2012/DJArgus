//
//  MBProgressHUD+DJUI.m
//  DJArgus
//
//  Created by Justin Yang on 15/9/20.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import "MBProgressHUD+DJUI.h"

@implementation MBProgressHUD (DJUI)

+ (instancetype)dj_showHUDWithTitle:(NSString *)title message:(NSString *)message fromView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.detailsLabelText = message;
    hud.margin = 10;
    hud.yOffset = 0;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5f];
    return hud;
}

+ (instancetype)dj_showHUDWithMessage:(NSString *)message fromView:(UIView *)view {
    return [MBProgressHUD dj_showHUDWithTitle:nil message:message fromView:view];
}

@end
