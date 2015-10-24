//
//  SettingCells.m
//  DJArgus
//
//  Created by chris on 8/19/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "SettingCells.h"

#import "DJDefinition.h"



#pragma mark -
#pragma mark SettingBaseCell implementation

@interface SettingBaseCell() {
    UIImageView *_ivIcon;
    UILabel *_lTitle;
    UILabel *_lValue;
}

@end

@implementation SettingBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        NSArray *views = [self.contentView subviews];
        for (UIView *view in views) {
            [view removeFromSuperview];
        }
        
        _ivIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
        [self.contentView addSubview:_ivIcon];
        
        _lTitle = [[UILabel alloc] initWithFrame:CGRectMake(_ivIcon.right + 15, 13, 100, 16)];
        [_lTitle setFont:[UIFont middle]];
        [_lTitle setTextColor:[UIColor deep_grey]];
        [self.contentView addSubview:_lTitle];
        
        _lValue = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.width - 140, _lTitle.top, 110, 16)];
        [_lValue setFont:[UIFont small]];
        [_lValue setTextAlignment:NSTextAlignmentRight];
        [_lValue setTextColor:[UIColor deep_blue]];
        [self.contentView addSubview:_lValue];
        
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        [self.contentView autoresizingMask];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setIcon:(NSString *)imageName {
    [_ivIcon setImage:[UIImage imageNamed:imageName]];
}

- (void)setTitle:(NSString *)title {
    [_lTitle setText:title];
}

- (void)setData:(NSString *)data {
    [_lValue setText:data];
}

- (BOOL)needSuperUser {
    return NO;
}

@end


#pragma mark -
#pragma mark SettingAutoReturnCell implementation

@interface SettingAutoReturnCell() {
    UIImageView *_ivIcon;
    UILabel *_lTitle;
    UISwitch *_switcher;
    
    NSUserDefaults *_userDefaults;
}

@end

@implementation SettingAutoReturnCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        
        [self setFrame:CGRectMake(0, 0, self.screenWidth, 44)];
        NSArray *views = [self.contentView subviews];
        for (UIView *view in views) {
            [view removeFromSuperview];
        }
        
        _ivIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
        [_ivIcon setImage:[UIImage imageNamed:@"ic_setting_auto_return"]];
        [self.contentView addSubview:_ivIcon];
        
        _switcher = [[UISwitch alloc] initWithFrame:CGRectMake(self.contentView.width - 65, 7, 50, 30)];
        [_switcher setOn:[_userDefaults getAutoReturn]];
        [_switcher addTarget:self action:@selector(m_switcher:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_switcher];
        
        _lTitle = [[UILabel alloc] initWithFrame:CGRectMake(_ivIcon.right + 10, 10, _switcher.left - _ivIcon.right, 24)];
        [_lTitle setText:@"低电量自动返航"];
        [_lTitle setFont:[UIFont middle]];
        [_lTitle setTextColor:[UIColor deep_grey]];
        [self.contentView addSubview:_lTitle];
        
        [self.contentView autoresizingMask];
        
    }
    return self;
}

- (BOOL)needSuperUser {
    return YES;
}

- (void)m_switcher:(id)sender {
    [_userDefaults setAutoReturn:_switcher.on];
}

@end




#pragma mark -
#pragma mark SettingFlyRadiusCell implementation

@implementation SettingFlyRangeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setIcon:@"ic_setting_fly_radius"];
        [self setTitle:@"安全区域"];
    }
    return self;
}

- (BOOL)needSuperUser {
    return YES;
}

@end


#pragma mark -
#pragma mark SettingFlyLineCell implementation

@implementation SettingFlyLineCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setIcon:@"ic_setting_fly_radius"];
        [self setTitle:@"飞行路径"];
    }
    return self;
}

- (BOOL)needSuperUser {
    return YES;
}

@end


#pragma mark -
#pragma mark SettingFlyRadiusCell implementation

@implementation SettingWhiteBalanceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setIcon:@"ic_setting_white_balance"];
        [self setTitle:@"白平衡"];
    }
    return self;
}

@end


#pragma mark -
#pragma mark SettingFlyRadiusCell implementation

@implementation SettingExposureCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setIcon:@"ic_setting_exposure_mode"];
        [self setTitle:@"感光度"];
    }
    return self;
}

@end



#pragma mark -
#pragma mark SettingPhotoSizeCell implementation

@implementation SettingISOCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setIcon:@"ic_setting_iso"];
        [self setTitle:@"曝光率"];
    }
    return self;
}

@end



#pragma mark -
#pragma mark SettingPhotoSizeCell implementation

@implementation SettingPhotoSizeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setIcon:@"ic_setting_photo_size"];
        [self setTitle:@"照片质量"];
    }
    return self;
}

@end


#pragma mark -
#pragma mark SettingPhotoSizeCell implementation

@implementation SettingVideoQualityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setIcon:@"ic_setting_video_quality"];
        [self setTitle:@"视频质量"];
    }
    return self;
}

@end


#pragma mark -
#pragma mark SettingSuperUserCell implementation

@implementation SettingSuperUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setIcon:@"ic_setting_super_user"];
        [self setTitle:@"超级用户登录"];
    }
    return self;
}

@end


#pragma mark -
#pragma mark SettingRegisterCell implementation

@implementation SettingRegisterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setIcon:@"ic_setting_register"];
        [self setTitle:@"设备连接"];
    }
    return self;
}

@end


#pragma mark -
#pragma mark SettingParamCell implementation

@interface SettingParamCell() {
    
}

@end

@implementation SettingParamCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //    [super setSelected:selected animated:animated];
}

@end



#pragma mark -
#pragma mark SettingParamCell implementation

@interface SettingSuperUserLoginCell() {
    UIImageView *_ivUser, *_ivKey;
    UITextField *_tfUser, *_tfKey;
    UIButton *_btnLogin;
}

@end

@implementation SettingSuperUserLoginCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        AccountManager *ac = [AccountManager manager];
                
        _ivUser = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 16, 16)];
        [_ivUser setImage:[UIImage imageNamed:@"ic_setting_login_user"]];
        [self.contentView addSubview:_ivUser];
        
        _tfUser = [[UITextField alloc] initWithFrame:CGRectMake(_ivUser.right + 15, _ivUser.top - 7, 190, 30)];
        _tfUser.text = ac.currentUsername;
        [_tfUser setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_tfUser setAutocorrectionType:UITextAutocorrectionTypeNo];
        [_tfUser setKeyboardType:UIKeyboardTypeURL];
        [_tfUser setReturnKeyType:UIReturnKeyNext];
        [_tfUser addTarget:self action:@selector(m_done:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [self.contentView addSubview:_tfUser];
        
        UIView *vSeperator = [[UIView alloc] initWithFrame:CGRectMake(_tfUser.left, _tfUser.bottom, _tfUser.width, .5f)];
        [vSeperator setBackgroundColor:[UIColor inner_divider]];
        [self.contentView addSubview:vSeperator];
        
        _ivKey = [[UIImageView alloc] initWithFrame:CGRectMake(_ivUser.left, _ivUser.bottom + 30, 16, 16)];
        [_ivKey setImage:[UIImage imageNamed:@"ic_setting_login_key"]];
        [self.contentView addSubview:_ivKey];
        
        _tfKey = [[UITextField alloc] initWithFrame:CGRectMake(_ivKey.right + 15, _ivKey.top - 7, 190, 30)];
        _tfKey.text = ac.currentPassword;
        [_tfKey setKeyboardType:UIKeyboardTypeURL];
        [_tfKey setReturnKeyType:UIReturnKeyDone];
        [_tfKey setSecureTextEntry:YES];
        [_tfKey addTarget:self action:@selector(m_done:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [self.contentView addSubview:_tfKey];
        
        vSeperator = [[UIView alloc] initWithFrame:CGRectMake(_tfKey.left, _tfKey.bottom, _tfKey.width, .5f)];
        [vSeperator setBackgroundColor:[UIColor inner_divider]];
        [self.contentView addSubview:vSeperator];
        
        _btnLogin = [UIButton blueButton];
        [_btnLogin setFrame:CGRectMake(15, _ivKey.bottom + 20, 220, 30)];
        [_btnLogin setTitle:ac.logined ? @"退出" : @"登录" forState:UIControlStateNormal];
        if (ac.logined) {
            [_btnLogin setRedStyle];
        } else {
            [_btnLogin setBlueStyle];
        }
        [_btnLogin addTarget:self action:@selector(m_login:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnLogin];
        
        [self.contentView autoresizingMask];
        
        [self setSelectedBackgroundView:nil];
    }
    return self;
}

- (void)m_done:(id)sender {
    if (sender == _tfUser) {
        [_tfKey becomeFirstResponder];
    } else {
        [sender resignFirstResponder];
    }
}

- (void)m_login:(id)sender {
    AccountManager *am = [AccountManager manager];
    if (am.logined) {
        [am logout];
        
        [_tfUser setText:@""];
        [_tfUser setEnabled:YES];
        [_tfKey setText:@""];
        [_tfKey setEnabled:YES];
        [_btnLogin setTitle:@"登录" forState:UIControlStateNormal];
        [_btnLogin setBlueStyle];
        return;
    } else {
        BOOL success = [am login:_tfKey.text password:_tfUser.text];
        if (success) {
            [_tfUser setEnabled:NO];
            [_tfKey setEnabled:NO];
            [_btnLogin setTitle:@"退出" forState:UIControlStateNormal];
            [_btnLogin setRedStyle];
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
            [hud setMode:MBProgressHUDModeText];
            [hud setLabelText:@"登录失败" ];
            [hud setDetailsLabelText:@"请输入正确的用户名/密码"];
            [hud setMargin:10.f];
            [hud setYOffset:0.f];
            [hud setRemoveFromSuperViewOnHide:YES];
            [hud hide:YES afterDelay:1.5f];
        }
    }
}

@end
