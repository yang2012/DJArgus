//
//  UIColor+Util.h
//  Argus
//
//  Created by chris on 7/14/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (Util)

+ (UIColor *)colorWithHexString:(NSString *)hexColor;

+ (UIColor *)red;
+ (UIColor *)light_red;
+ (UIColor *)deep_red;

+ (UIColor *)blue;
+ (UIColor *)light_blue;
+ (UIColor *)deep_blue;

+ (UIColor *)green;
+ (UIColor *)light_green;
+ (UIColor *)deep_green;

+ (UIColor *)orange;
+ (UIColor *)light_orange;
+ (UIColor *)deep_orange;

+ (UIColor *)grey;
+ (UIColor *)light_grey;
+ (UIColor *)deep_grey;

+ (UIColor *)white;
+ (UIColor *)light_white;
+ (UIColor *)deep_white;

+ (UIColor *)inner_divider;

+ (UIColor *)common_background;

+ (UIColor *)translucent;

@end
