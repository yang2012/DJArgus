//
//  UITableViewCell+Util.m
//  Argus
//
//  Created by chris on 7/30/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "UITableViewCell+Util.h"

@implementation UITableViewCell(Util)

+ (NSString *)reuseIdentifier {
    return [NSString stringWithUTF8String:object_getClassName(self)];
}

- (void)setData:(NSObject *)data {
    
}

- (CGFloat)heightWithData:(NSDictionary *)data {
    return 0.f;
}

@end
