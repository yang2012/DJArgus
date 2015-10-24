//
//  UICollectionViewCell+Util.m
//  Argus
//
//  Created by chris on 7/28/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "UICollectionViewCell+Util.h"

@implementation UICollectionViewCell(Util)


+ (NSString *)reuseIdentifier {
    return [NSString stringWithUTF8String:object_getClassName(self)];
}

- (void)setData:(NSObject *)data {
    
}

- (CGFloat)heightWithData:(NSDictionary *)data {
    return 0.f;
}

@end
