//
//  NSUserDefaults+Utils.m
//  DJArgus
//
//  Created by chris on 8/21/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "NSUserDefaults+Utils.h"


static NSString *USER_SETTING_AUTO_RETURN = @"user_setting_auto_return";
static NSString *USER_SETTING_WHITE_BALANCE = @"user_setting_white_balance";
static NSString *USER_SETTING_ISO = @"user_setting_iso";
static NSString *USER_SETTING_EXPOSURE = @"user_setting_exposure";
static NSString *USER_SETTING_PHOTO_SIZE = @"user_setting_photo_size";
static NSString *USER_SETTING_VIDEO_QUALITY = @"user_setting_video_quality";


@implementation NSUserDefaults(Utils)


- (void)setAutoReturn:(BOOL)autoReturn {
    [self setBool:autoReturn forKey:USER_SETTING_AUTO_RETURN];
}

- (BOOL)getAutoReturn {
    return [self boolForKey:USER_SETTING_AUTO_RETURN];
}

- (void)setWhiteBalance:(NSString *)value {
    [self setValue:value forKey:USER_SETTING_WHITE_BALANCE];
}

- (NSString *)getWhiteBalance {
    return [self stringForKey:USER_SETTING_WHITE_BALANCE];
}

- (void)setISO:(NSInteger)value {
    [self setInteger:value forKey:USER_SETTING_WHITE_BALANCE];
}

- (NSString *)getISO {
    return [self stringForKey:USER_SETTING_WHITE_BALANCE];
}

- (void)setExposure:(NSString *)value {
    [self setValue:value forKey:USER_SETTING_WHITE_BALANCE];
}

- (NSString *)getExposure {
    return [self stringForKey:USER_SETTING_WHITE_BALANCE];
}

- (void)setPhotoSize:(NSString *)value {
    [self setValue:value forKey:USER_SETTING_WHITE_BALANCE];
}

- (NSString *)getPhotoSize {
    return [self stringForKey:USER_SETTING_WHITE_BALANCE];
}

- (void)setVideoQuality:(NSString *)value {
    [self setValue:value forKey:USER_SETTING_WHITE_BALANCE];
}

- (NSString *)getVideoQuality {
    return [self stringForKey:USER_SETTING_WHITE_BALANCE];
}

@end
