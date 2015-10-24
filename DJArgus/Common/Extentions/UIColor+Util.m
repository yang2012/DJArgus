//
//  UIColor+Util.m
//  Argus
//
//  Created by chris on 7/14/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "UIColor+Util.h"

@implementation UIColor (Util)

+ (UIColor *)colorWithHexString:(NSString *)hexColor {
    NSString *cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString]; //去掉前后空格换行符
    
    // String should be 6 or 8 characters
    //    if ([cString length] < 6) return [UIColor whiteColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    if (cString.length == 3) {
        NSMutableString *rString = [[NSMutableString alloc] initWithCapacity:6];
        [rString appendFormat:@"%C%C%C%C%C%C", [cString characterAtIndex:0], [cString characterAtIndex:0], [cString characterAtIndex:1], [cString characterAtIndex:1], [cString characterAtIndex:2], [cString characterAtIndex:2]];
        cString = [NSString stringWithString:rString];
    }
    else if (cString.length == 4) {
        NSMutableString *rString = [[NSMutableString alloc] initWithCapacity:8];
        [rString appendFormat:@"%C%C%C%C%C%C%C%C", [cString characterAtIndex:0], [cString characterAtIndex:0], [cString characterAtIndex:1], [cString characterAtIndex:1], [cString characterAtIndex:2], [cString characterAtIndex:2], [cString characterAtIndex:3], [cString characterAtIndex:3]];
        cString = [NSString stringWithString:rString];
    }
    
    if ([cString length] != 6 && [cString length] != 8) return [UIColor whiteColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *aString = @"ff";
    if ([cString length] == 8) {
        aString = [cString substringWithRange:range];
        range.location += 2;
    }
    NSString *rString = [cString substringWithRange:range];
    range.location += 2;
    NSString *gString = [cString substringWithRange:range];
    range.location += 2;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned r, g, b, a;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];  //扫描16进制到int
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    
    return [UIColor colorWithRed:r / 255.f green:g / 255.f blue:b / 255.f alpha:a / 255.f];
}

+ (UIColor *)red {
    return [UIColor colorWithHexString:@"#ffff1210"];
}

+ (UIColor *)light_red {
    return [UIColor colorWithHexString:@"#ff6633"];
}

+ (UIColor *)deep_red {
    return [UIColor colorWithHexString:@"#ffd2322d"];
}

+ (UIColor *)blue {
    return [UIColor colorWithHexString:@"#ff35b5e5"];
}

+ (UIColor *)light_blue {
    return [UIColor colorWithHexString:@"#ff80b8ff"];
}

+ (UIColor *)deep_blue {
    return [UIColor colorWithHexString:@"#ff2e94bf"];
}

+ (UIColor *)green {
    return [UIColor colorWithHexString:@"#ff99cc00"];
}

+ (UIColor *)light_green {
    return [UIColor colorWithHexString:@"#ffa7d84c"];
}

+ (UIColor *)deep_green {
    return [UIColor colorWithHexString:@"#ff669900"];
}

+ (UIColor *)orange {
    return [UIColor colorWithHexString:@"#ffeea236"];
}

+ (UIColor *)light_orange {
    return [UIColor colorWithHexString:@"#fff0ad4e"];
}

+ (UIColor *)deep_orange {
    return [UIColor colorWithHexString:@"#ffd58512"];
}

+ (UIColor *)grey {
    return [UIColor colorWithHexString:@"#aeaeae"];
}

+ (UIColor *)light_grey {
    return [UIColor colorWithHexString:@"#cccccc"];
}

+ (UIColor *)deep_grey {
    return [UIColor colorWithHexString:@"#2f2f2f"];
}

+ (UIColor *)white {
    return [UIColor colorWithHexString:@"#ffffff"];
}

+ (UIColor *)light_white {
    return [UIColor colorWithHexString:@"#87ededed"];
}

+ (UIColor *)deep_white {
    return [UIColor colorWithHexString:@"#e1e1e1"];
}

+ (UIColor *)inner_divider {
    return [UIColor colorWithHexString:@"#e8e8e1"];
}

+ (UIColor *)common_background {
    return [UIColor colorWithHexString:@"#f0f0f0"];
}

+ (UIColor *)translucent {
    return [UIColor colorWithHexString:@"#44333333"];
}

@end
