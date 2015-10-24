//
//  AppDelegate.m
//  DJArgus
//
//  Created by chris on 8/14/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "AppDelegate.h"
#import <DJISDK/DJISDK.h>

#import "DJDefinition.h"

#import "ICSDrawerController.h"

#import "LeftDrawerVC.h"
#import "DrawerConatinerVC.h"
#import "FixedCruiseVC.h"
#import "MyAlbumVC.h"
#import "SettingMainVC.h"
#import "VideoPreviewer.h"


@interface AppDelegate ()<DJIAppManagerDelegate> {
    CLLocationManager *_locationManager;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"default_config" ofType:@"plist"];
    NSDictionary *defConfig = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    [DJIAppManager registerApp:[defConfig objectForKey:@"dji_sdk_key"] withDelegate:self];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor white]];
    
    LeftDrawerVC *leftDrawerVC = [[LeftDrawerVC alloc] init];
    DrawerConatinerVC *containerVC = [[DrawerConatinerVC alloc] initWithRootViewController:[[SettingMainVC alloc] init]];
    ICSDrawerController *drawerController = [[ICSDrawerController alloc] initWithLeftViewController:leftDrawerVC
                                                                               centerViewController:containerVC];
    
    [self.window setRootViewController:drawerController];
    [self.window makeKeyAndVisible];
    
    
    _locationManager = [[CLLocationManager alloc] init];
    if (![CLLocationManager locationServicesEnabled] ||
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_locationManager requestAlwaysAuthorization];
    }
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Logout
    [[AccountManager manager] logout];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
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
}

@end
