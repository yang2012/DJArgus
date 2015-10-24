//
//  UIFont+Util.m
//  Argus
//
//  Created by chris on 7/22/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "UIFont+Util.h"

@implementation UIFont(Util)


+ (UIFont *)fontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Helvetica" size:size];
}

+ (UIFont *)xlarge {
    return [UIFont fontWithSize:20.f];
}

+ (UIFont *)large {
    return [UIFont fontWithSize:16.f];
}

+ (UIFont *)normal {
    return [UIFont fontWithSize:14.f];
}

+ (UIFont *)middle {
    return [UIFont fontWithSize:13.f];
}

+ (UIFont *)small {
    return [UIFont fontWithSize:12.f];
}

+ (UIFont *)xsmall {
    return [UIFont fontWithSize:10.f];
}

+ (UIFont *)xxsmall {
    return [UIFont fontWithSize:8.f];
}

@end
