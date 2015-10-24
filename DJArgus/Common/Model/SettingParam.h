//
//  SettingParam.h
//  DJArgus
//
//  Created by Justin Yang on 15/10/3.
//  Copyright © 2015年 lynxchina. All rights reserved.
//


@interface SettingParam : NSObject

+ (CameraPhotoSizeType)photoSize;

+ (VideoQuality)videoQuality;

+ (CameraISOType)isoType;

+ (CameraExposureMode)exposureMode;

+ (CameraWhiteBalanceType)whiteBalanceType;

@end
