//
//  UIButton+Util.m
//  Argus
//
//  Created by chris on 7/31/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "UIButton+Util.h"

#import "DJDefinition.h"

@implementation UIButton(Util)


+ (UIButton *)redButton {
    UIButton *btn = [[UIButton alloc] init];
    [btn.titleLabel setTextColor:[UIColor white]];
    [btn.titleLabel setFont:[UIFont normal]];
    [btn setRedStyle];
    return btn;
}

+ (UIButton *)blueButton {
    UIButton *btn = [[UIButton alloc] init];
    [btn.titleLabel setTextColor:[UIColor white]];
    [btn.titleLabel setFont:[UIFont normal]];
    [btn setBlueStyle];
    return btn;
}

+ (UIButton *)whiteButton {
    UIButton *btn = [[UIButton alloc] init];
    [btn.titleLabel setTextColor:[UIColor deep_grey]];
    [btn.titleLabel setFont:[UIFont normal]];
    [btn setTitleColor:[UIColor deep_grey] forState:UIControlStateNormal];
    [btn setWhiteStyle];
    return btn;
}

- (void)setRedStyle {
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor light_red]] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor red]] forState:UIControlStateHighlighted | UIControlStateSelected];
}

- (void)setBlueStyle {
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor blue]] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor deep_blue]] forState:UIControlStateHighlighted | UIControlStateSelected];
}

- (void)setWhiteStyle {
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor white]] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor light_white]] forState:UIControlStateHighlighted | UIControlStateSelected];
}

@end
