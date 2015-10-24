//
//  NSUserDefaults+Utils.h
//  DJArgus
//
//  Created by chris on 8/21/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults(Utils)

- (void)setAutoReturn:(BOOL)autoReturn;
- (BOOL)getAutoReturn;

- (void)setWhiteBalance:(NSString *)value;
- (NSString *)getWhiteBalance;

- (void)setISO:(NSInteger)value;
- (NSString *)getISO;

- (void)setExposure:(NSString *)value;
- (NSString *)getExposure;

- (void)setPhotoSize:(NSString *)value;
- (NSString *)getPhotoSize;

- (void)setVideoQuality:(NSString *)value;
- (NSString *)getVideoQuality;

@end
