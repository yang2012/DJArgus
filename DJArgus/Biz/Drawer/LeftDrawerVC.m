//
//  LeftDrawerVC.m
//  DJArgus
//
//  Created by chris on 8/14/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "LeftDrawerVC.h"

#import <FLEX/FLEXManager.h>

#import "DJDefinition.h"

#import "DrawerConatinerVC.h"

#import "CameraMainVC.h"
#import "FixedCruiseVC.h"
#import "MyAlbumVC.h"
#import "SettingMainVC.h"

static NSString * const kLeftDrawerVCCellReuseId = @"kLeftDrawerVCCellReuseId";

@interface LeftDrawerVC()<UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tvMenu;
    
    NSArray *_menus;
    NSInteger _previousRow;
}

@property (nonatomic, strong) CameraMainVC *cameraMainVC;
@property (nonatomic, strong) FixedCruiseVC *cruiseVC;
@property (nonatomic, strong) MyAlbumVC *albumVC;
@property (nonatomic, strong) SettingMainVC *settingVC;

@end


@implementation LeftDrawerVC

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _cameraMainVC = [[CameraMainVC alloc] init];
        _cruiseVC = [[FixedCruiseVC alloc] init];
        _albumVC = [[MyAlbumVC alloc] init];
        _settingVC = [[SettingMainVC alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _previousRow = 3;
    
    _tvMenu = [[UITableView alloc] initWithFrame:self.view.bounds];
    [_tvMenu registerClass:[UITableViewCell class] forCellReuseIdentifier:kLeftDrawerVCCellReuseId];
    [_tvMenu setBackgroundColor:[UIColor clearColor]];
    [_tvMenu setDataSource:self];
    [_tvMenu setDelegate:self];
    [_tvMenu setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.view addSubview:_tvMenu];
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_tvMenu setTableFooterView:view];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tvMenu.width, 50)];
    
    UIButton *btnDebug = [[UIButton alloc] initWithFrame:CGRectMake(50, 10, 25, 25)];
    [btnDebug setBackgroundImage:[UIImage imageNamed:@"ic_debug"] forState:UIControlStateNormal];
    [btnDebug addTarget:self action:@selector(m_showDebugPanel) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnDebug];
    [_tvMenu setTableHeaderView:view];
    
    _menus = @[@{@"title": @"拍照/录制视频", @"icon": @"ic_take_photo"},
               @{@"title": @"定点巡航", @"icon": @"ic_fixed_cruise"},
               @{@"title": @"我的相册", @"icon": @"ic_my"},
               @{@"title": @"设置", @"icon": @"ic_setting"}];
}


#pragma mark -
#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menus count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLeftDrawerVCCellReuseId
                                                            forIndexPath:indexPath];
    NSDictionary *dict = [_menus objectAtIndex:indexPath.row];
    NSString *title = [dict objectForKey:@"title"];
    UIImage *icon = [UIImage imageNamed:[dict objectForKey:@"icon"]];
    [cell.textLabel setFont:[UIFont normal]];
    [cell.textLabel setText:title];
    [cell.imageView setFrame:CGRectMake(15, 12, 10, 10)];
    [cell.imageView setImage:icon];
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _previousRow) {
        // Close the drawer without no further actions on the center view controller
        [self.drawer close];
    } else {
        UIViewController *vc = nil;
        switch (indexPath.row) {
            case 0: {
                vc = self.cameraMainVC;
                break;
            }
            case 1: {
                vc = self.cruiseVC;
                break;
            }
            case 2: {
                vc = self.albumVC;
                break;
            }
            case 3: {
                vc = self.settingVC;
                break;
            }
            default:
                break;
        }
        DrawerConatinerVC *containerVC = [[DrawerConatinerVC alloc] initWithRootViewController:vc];
        [self.drawer replaceCenterViewControllerWithViewController:containerVC];
    }
    _previousRow = indexPath.row;
}


#pragma mark -
#pragma mark - ICSDrawerControllerPresenting

- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidOpen:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = YES;
}

- (void)drawerControllerWillClose:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = YES;
}


#pragma mark -
#pragma mark - self define method

- (void)m_showDebugPanel {
    [[FLEXManager sharedManager] showExplorer];
}


@end
