//
//  DroneManager.m
//  DJArgus
//
//  Created by Justin Yang on 15/9/20.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import "DroneManager.h"

@interface DroneManager () <DJIAppManagerDelegate>

@property (nonatomic, strong) DJIDrone *drone;

@end

@implementation DroneManager

+ (instancetype)manager
{
    static DroneManager *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [DroneManager new];
    });
    return __instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom3Professional];
    }
    
    return self;
}

#pragma mark - Public Method

- (void)registerApp
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"default_config" ofType:@"plist"];
    NSDictionary *defConfig = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    [DJIAppManager registerApp:[defConfig objectForKey:@"dji_sdk_key"] withDelegate:self];
}

#pragma mark - DJIAppManagerDelegate Method

-(void)appManagerDidRegisterWithError:(int)error {
    NSString* message = @"飞拍注册成功!";
    if (error != RegisterSuccess) {
        message = @"飞拍注册失败";
    } else {
        [self.drone connectToDrone];
        [self.drone.mainController startUpdateMCSystemState];
        [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_APP_REGISTER_SUCCESS object:nil];
    }
}

@end
