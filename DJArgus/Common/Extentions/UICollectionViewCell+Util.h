//
//  UICollectionViewCell+Util.h
//  Argus
//
//  Created by chris on 7/28/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionViewCell(Util)

+ (NSString *)reuseIdentifier;

- (void)setData:(NSObject *)data;

- (CGFloat)heightWithData:(NSDictionary *)data;

@end
