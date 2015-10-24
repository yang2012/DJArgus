//
//  SettingParam.m
//  DJArgus
//
//  Created by Justin Yang on 15/10/3.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import "SettingParam.h"

@implementation SettingParam

+ (CameraPhotoSizeType)photoSize
{
    NSString *psStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"SettingPhotoSizeCell"];
    if ([psStr isEqualToString:@"4384x2922"]) {
        return CameraPhotoSizeSmall;
    } else if ([psStr isEqualToString:@"4384x2466"]) {
        return CameraPhotoSizeMiddle;
    } else if ([psStr isEqualToString:@"4608x3456"]) {
        return CameraPhotoSizeLarge;
    } else {
        return CameraPhotoSizeDefault;
    }
}

+ (VideoQuality)videoQuality
{
    NSString *vqStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"SettingVideoQualityCell"];
    if ([vqStr isEqualToString:@"普通"]) {
        return CameraVideoQualityNormal;
    } else if ([vqStr isEqualToString:@"较好"]) {
        return CameraVideoQualityFine;
    } else if ([vqStr isEqualToString:@"最优"]) {
        return CameraVideoQualityExcellent;
    } else {
        return CameraVideoQualityNormal;
    }
}

+ (CameraISOType)isoType
{
    NSString *itStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"SettingISOCell"];
    if ([itStr isEqualToString:@"ISOAuto"]) {
        return CameraISOAuto;
    } else if ([itStr isEqualToString:@"ISO100"]) {
        return CameraISO100;
    } else if ([itStr isEqualToString:@"ISO200"]) {
        return CameraISO200;
    } else if ([itStr isEqualToString:@"ISO400"]) {
        return CameraISO400;
    } else if ([itStr isEqualToString:@"ISO800"]) {
        return CameraISO800;
    } else if ([itStr isEqualToString:@"ISO1600"]) {
        return CameraISO1600;
    } else if ([itStr isEqualToString:@"ISO3200"]) {
        return CameraISO3200;
    } else {
        return CameraISOAuto;
    }
}

+ (CameraExposureMode)exposureMode
{
    NSString *emStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"SettingExposureCell"];
    if ([emStr isEqualToString:@"程序"]) {
        return CameraExposureModeProgram;
    } else if ([emStr isEqualToString:@"快门"]) {
        return CameraExposureModeShutter;
    } else if ([emStr isEqualToString:@"手动"]) {
        return CameraExposureModeManual;
    } else {
        return CameraExposureModeProgram;
    }
}

+ (CameraWhiteBalanceType)whiteBalanceType
{
    NSString *wbtStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"SettingWhiteBalanceCell"];
    if ([wbtStr isEqualToString:@"自动"]) {
        return CameraWhiteBalanceAuto;
    } else if ([wbtStr isEqualToString:@"日光"]) {
        return CameraWhiteBalanceSunny;
    } else if ([wbtStr isEqualToString:@"多云"]) {
        return CameraWhiteBalanceCloudy;
    } else if ([wbtStr isEqualToString:@"室内"]) {
        return CameraWhiteBalanceIndoor;
    } else {
        return CameraWhiteBalanceAuto;
    }
}

@end
