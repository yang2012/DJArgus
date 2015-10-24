//
//  DisplayUtil.m
//  Argus
//
//  Created by chris on 7/14/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "DisplayUtil.h"


@implementation DisplayUtil

+ (CGFloat)getScreenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)getScreenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

@end
