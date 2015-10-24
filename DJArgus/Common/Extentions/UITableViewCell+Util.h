//
//  UITableViewCell+Util.h
//  Argus
//
//  Created by chris on 7/30/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell(Util)

+ (NSString *)reuseIdentifier;

- (void)setData:(NSObject *)data;

- (CGFloat)heightWithData:(NSDictionary *)data;

@end
