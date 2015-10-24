//
//  SettingMainVC.m
//  DJArgus
//
//  Created by chris on 8/14/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "SettingMainVC.h"

#import <DJISDK/DJISDK.h>

#import "DrawerConatinerVC.h"
#import "SafeRangeVC.h"
#import "CruiseLineVC.h"
#import "SettingCells.h"

static NSString * const kSettingMainVCCellReuseId = @"kSettingMainVCCellReuseId";

@interface SettingMainVC ()<UITableViewDataSource, UITableViewDelegate, DJIAppManagerDelegate> {
    UITableView *_tvSettings, *_tvParamSelect;
    
    NSMutableArray *_settings;
    NSArray *_selectParams;
    
    NSDictionary *_settingParams;
    NSUserDefaults *_userDefaults;
    
    BOOL _isLeftButtonNavi;
    
    NSString *_selectSetting;
    NSInteger _curParamIdx;
    
    NSDictionary *_defConfig;
}

@end


@implementation SettingMainVC


- (id)init {
    if (self = [super init]) {
        _isLeftButtonNavi = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor common_background]];
    [self setTitle:@"设置"];
    
    NSString *imageName = _isLeftButtonNavi ? @"ic_navi_back" : @"ic_slide_menu";
    CGRect btnFrame = _isLeftButtonNavi ? CGRectMake(0, 8, 12, 21) : CGRectMake(0, 9, 26, 26);
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:btnFrame];
    [btnLeft setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.naviBar setLeftButton:btnLeft];
    
    _settings = [[NSMutableArray alloc] initWithCapacity:3];
    NSDictionary *section = @{@"title": @"飞行设置",
                              @"settings": @[[SettingFlyRangeCell reuseIdentifier], [SettingFlyLineCell reuseIdentifier], [SettingAutoReturnCell reuseIdentifier]]};
    [_settings addObject:section];
    
    section = @{@"title": @"照片/视频设置",
                @"settings": @[[SettingWhiteBalanceCell reuseIdentifier],
                               [SettingExposureCell reuseIdentifier],
                               [SettingISOCell reuseIdentifier],
                               [SettingPhotoSizeCell reuseIdentifier],
                               [SettingVideoQualityCell reuseIdentifier]]};
    [_settings addObject:section];
    
    section = @{@"title": @"其他",
                @"settings": @[[SettingSuperUserCell reuseIdentifier], [SettingRegisterCell reuseIdentifier]]};
    [_settings addObject:section];
    
    
    _tvSettings = [[UITableView alloc] initWithFrame:CGRectMake(0, self.naviBarHeight, 320, self.view.height - self.naviBarHeight)
                                               style:UITableViewStylePlain];
    [_tvSettings setShowsVerticalScrollIndicator:YES];
    [_tvSettings setDataSource:self];
    [_tvSettings setDelegate:self];
    
    [_tvSettings registerClass:[SettingFlyRangeCell class] forCellReuseIdentifier:[SettingFlyRangeCell reuseIdentifier]];
    [_tvSettings registerClass:[SettingFlyLineCell class] forCellReuseIdentifier:[SettingFlyLineCell reuseIdentifier]];
    [_tvSettings registerClass:[SettingAutoReturnCell class] forCellReuseIdentifier:[SettingAutoReturnCell reuseIdentifier]];
    
    [_tvSettings registerClass:[SettingWhiteBalanceCell class] forCellReuseIdentifier:[SettingWhiteBalanceCell reuseIdentifier]];
    [_tvSettings registerClass:[SettingExposureCell class] forCellReuseIdentifier:[SettingExposureCell reuseIdentifier]];
    [_tvSettings registerClass:[SettingISOCell class] forCellReuseIdentifier:[SettingISOCell reuseIdentifier]];
    [_tvSettings registerClass:[SettingPhotoSizeCell class] forCellReuseIdentifier:[SettingPhotoSizeCell reuseIdentifier]];
    [_tvSettings registerClass:[SettingVideoQualityCell class] forCellReuseIdentifier:[SettingVideoQualityCell reuseIdentifier]];
    
    [_tvSettings registerClass:[SettingSuperUserCell class] forCellReuseIdentifier:[SettingSuperUserCell reuseIdentifier]];
    [_tvSettings registerClass:[SettingRegisterCell class] forCellReuseIdentifier:[SettingRegisterCell reuseIdentifier]];
    
    [self.view addSubview:_tvSettings];
    
    _tvParamSelect = [[UITableView alloc] initWithFrame:CGRectMake(320, self.naviBarHeight,
                                                                   self.view.width - 320, self.view.height - self.naviBarHeight)
                                               style:UITableViewStylePlain];
    [_tvParamSelect setShowsVerticalScrollIndicator:YES];
    [_tvParamSelect setDataSource:self];
    [_tvParamSelect setDelegate:self];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_tvParamSelect setTableFooterView:view];
    
    [_tvParamSelect registerClass:[SettingParamCell class] forCellReuseIdentifier:[SettingParamCell reuseIdentifier]];
    [_tvParamSelect registerClass:[SettingSuperUserLoginCell class] forCellReuseIdentifier:[SettingSuperUserLoginCell reuseIdentifier]];
    
    [self.view addSubview:_tvParamSelect];
    
    UIView *vSepartor = [[UIView alloc] initWithFrame:CGRectMake(_tvSettings.right, 0, 0.5f, self.view.height)];
    [vSepartor setBackgroundColor:[UIColor inner_divider]];
    [self.view addSubview:vSepartor];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"setting_params" ofType:@"plist"];
    _settingParams = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    plistPath = [[NSBundle mainBundle] pathForResource:@"default_config" ofType:@"plist"];
    _defConfig = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
}

- (void)naviBarLeftButtonPressed {
    if (_isLeftButtonNavi) {
        [super naviBarLeftButtonPressed];
    } else {
        DrawerConatinerVC *containerVC = (DrawerConatinerVC *)self.navigationController;
        [containerVC.drawer open];
    }
}

- (void)setLeftButtonType:(BOOL)isNaviBack {
    _isLeftButtonNavi = isNaviBack;
}


#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _tvParamSelect) {
        return 1;
    } else {
        return [_settings count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tvParamSelect) {
        return [_selectParams count];
    } else {
        return [[[_settings objectAtIndex:section] objectForKey:@"settings"] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (tableView == _tvParamSelect) {
        if ([_selectSetting isEqualToString:[SettingSuperUserCell reuseIdentifier]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:[SettingSuperUserLoginCell reuseIdentifier] forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:[SettingParamCell reuseIdentifier] forIndexPath:indexPath];
            [cell.textLabel setFont:[UIFont middle]];
            [cell.textLabel setTextColor:[UIColor deep_grey]];
            [cell.textLabel setText:[_selectParams objectAtIndex:indexPath.row]];
        }
    } else {
        NSArray *settings = [[_settings objectAtIndex:indexPath.section] objectForKey:@"settings"];
        cell = [tableView dequeueReusableCellWithIdentifier:[settings objectAtIndex:indexPath.row] forIndexPath:indexPath];
        [cell setData:[_userDefaults valueForKey:[cell reuseIdentifier]]];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if (tableView == _tvParamSelect) {
        title = @"参数选择";
        if ([_selectSetting isEqualToString:[SettingSuperUserCell reuseIdentifier]]) {
            title = @"登录";
        }
    } else {
        title = [[_settings objectAtIndex:section] objectForKey:@"title"];
    }
    
    UIView *vHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tvSettings.width, 30.f)];
    [vHeader setBackgroundColor:[UIColor common_background]];
    UILabel *lTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 200, 20)];
    [lTitle setFont:[UIFont middle]];
    [lTitle setTextColor:[UIColor deep_blue]];
    [lTitle setText:title];
    [vHeader addSubview:lTitle];
    return vHeader;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tvParamSelect) {
        if ([_selectSetting isEqualToString:[SettingSuperUserCell reuseIdentifier]]) {
            return 160.f;
        }
    }
    
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tvSettings) {
        SettingBaseCell *cell = (SettingBaseCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (![AccountManager manager].logined && [cell needSuperUser]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [hud setMode:MBProgressHUDModeText];
            [hud setLabelText:@"只用超级用户才能使用该功能"];
            [hud setMargin:10.f];
            [hud setYOffset:0.f];
            [hud setRemoveFromSuperViewOnHide:YES];
            [hud hide:YES afterDelay:1.5f];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            return;
        }
        
        _selectSetting = [cell reuseIdentifier];
        _selectParams = [_settingParams objectForKey:[cell reuseIdentifier]];
        [_tvParamSelect reloadData];
        
        if ([cell isKindOfClass:[SettingRegisterCell class]]) {
            [DJIAppManager registerApp:[_defConfig objectForKey:@"dji_sdk_key"] withDelegate:self];
        } else if ([cell isKindOfClass:[SettingFlyRangeCell class]]) {
            [self m_gotoSafeRangeSetting];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else if ([cell isKindOfClass:[SettingFlyLineCell class]]) {
            [self m_gotoFlyLineSetting];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    } else {
        NSIndexPath *selectIdx = [_tvSettings indexPathForSelectedRow];
        UITableViewCell *cell = [_tvSettings cellForRowAtIndexPath:selectIdx];
        [cell setData:[_selectParams objectAtIndex:indexPath.row]];
        [_userDefaults setValue:[_selectParams objectAtIndex:indexPath.row] forKey:[cell reuseIdentifier]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_CAMERA_SETTING_CHANGE object:nil];
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if(indexPath.row == _curParamIdx){
            return;
        }
        
        cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_curParamIdx inSection:0];
        cell = [tableView cellForRowAtIndexPath:oldIndexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        _curParamIdx = indexPath.row;
    }
}


#pragma mark -
#pragma mark DJIAppManagerDelegate Method

-(void)appManagerDidRegisterWithError:(int)error {
    NSString* message = @"飞拍注册成功!";
    if (error != RegisterSuccess) {
        message = @"飞拍注册失败";
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_APP_REGISTER_SUCCESS object:nil];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeText];
    [hud setLabelFont:[UIFont middle]];
    [hud setLabelText:message];
    [hud setMargin:20.f];
    [hud setYOffset:0.f];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud hide:YES afterDelay:1.5f];
}

#pragma mark -
#pragma mark self define method

- (void)m_gotoSafeRangeSetting {
    SafeRangeVC *vc = [[SafeRangeVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)m_gotoFlyLineSetting {
    CruiseLineVC *vc = [[CruiseLineVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
