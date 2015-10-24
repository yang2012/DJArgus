//
//  DJDefinition.h
//  DJArgus
//
//  Created by chris on 8/14/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#pragma mark - Util Begin

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#pragma mark -----------------

#pragma mark - Notification Begin

// 超级用户状态变化
#define PUSH_SUPER_USER_STATUS_CHANGE  @"PUSH_SUPER_USER_STATUS_CHANGE"

// 应用注册成功
#define PUSH_APP_REGISTER_SUCCESS @"PUSH_APP_REGISTER_SUCCESS"

// 相机参数变化
#define PUSH_CAMERA_SETTING_CHANGE @"PUSH_CAMERA_SETTING_CHANGE"

// 多媒体资源下载
#define PUSH_REMOTE_MEDIA_DOWNLOADED @"PUSH_REMOTE_MEDIA_DOWNLOADED"

// 安全区域发生变化
#define PUSH_SAFE_AREA_CHANGE @"PUSH_SAFE_ARE_CHANGE"

// 地面站变化
#define PUSH_GROUND_STATION_CHANGE @"PUSH_GROUND_STATION_CHANGE"

#pragma mark -----------------

#pragma mark - Cache Begin

// 安全区域中点精度
#define KEY_SETTING_SAFERANGE_CENTER_POINT_LAT @"KEY_SETTING_SAFERANGE_CENTER_POINT_LAT"

// 安全区域中点维度
#define KEY_SETTING_SAFERANGE_CENTER_POINT_LNG @"KEY_SETTING_SAFERANGE_CENTER_POINT_LNG"

// 安全区域半径
#define KEY_SETTING_SAFERANGE_RANGE @"KEY_SETTING_SAFERANGE_RANGE"

// 安全区域飞行高度
#define KEY_SETTING_SAFERANGE_HEIGHT @"KEY_SETTING_SAFERANGE_HEIGHT"

// 地面站
#define KEY_GROUND_STATUS_LOCATIONS @"KEY_GROUND_STATUS_LOCATIONS"

#pragma mark -----------------