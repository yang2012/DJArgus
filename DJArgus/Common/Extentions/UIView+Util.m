//
//  UIView+Util.m
//  Argus
//
//  Created by chris on 7/22/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "UIView+Util.h"

@implementation UIView(Util)

- (void)setLeft:(CGFloat)left {

}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setTop:(CGFloat)top {
    
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setRight:(CGFloat)right {
    
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setBottom:(CGFloat)bottom {
    
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    [self setFrame:frame];
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    [self setFrame:frame];
}

- (CGFloat)height {
    return self.frame.size.height;
}


- (CGFloat)screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

- (void)setScreenWidth:(CGFloat)screenWidth {
    
}

- (CGFloat)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

- (void)setScreenHeight:(CGFloat)screenHeight {
    
}

- (CGPoint)center {
    return CGPointMake(self.left + self.width / 2, self.top + self.height / 2);
}

@end
