//
//  UIButton+Util.h
//  Argus
//
//  Created by chris on 7/31/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton(Util)

+ (UIButton *)redButton;

+ (UIButton *)blueButton;

+ (UIButton *)whiteButton;


- (void)setRedStyle;
- (void)setBlueStyle;
- (void)setWhiteStyle;

@end
