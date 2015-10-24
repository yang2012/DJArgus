//
//  SettingCells.h
//  DJArgus
//
//  Created by chris on 8/19/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingBaseCell : UITableViewCell

- (void)setIcon:(NSString *)imageName;
- (void)setTitle:(NSString *)title;

- (BOOL)needSuperUser;

@end


// 低电量返航开关
@interface SettingAutoReturnCell : UITableViewCell

@end


// 飞行半径设置
@interface SettingFlyRangeCell : SettingBaseCell

@end

// 航行设置
@interface SettingFlyLineCell : SettingBaseCell

@end


// 白平衡设置
@interface SettingWhiteBalanceCell : SettingBaseCell

@end

// 感光度设置
@interface SettingExposureCell : SettingBaseCell

@end

// 曝光率设置
@interface SettingISOCell : SettingBaseCell

@end

// 照片大小设置
@interface SettingPhotoSizeCell : SettingBaseCell

@end

// 视频质量设置
@interface SettingVideoQualityCell : SettingBaseCell

@end

// 超级账户
@interface SettingSuperUserCell : SettingBaseCell

@end

// 硬件注册
@interface SettingRegisterCell : SettingBaseCell

@end

// 设置参数
@interface SettingParamCell : UITableViewCell

@end

// 超级用户登录
@interface SettingSuperUserLoginCell : UITableViewCell

@end