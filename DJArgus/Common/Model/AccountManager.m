//
//  AccountManager.m
//  DJArgus
//
//  Created by Justin Yang on 15/10/4.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import "AccountManager.h"

#define KEY_ACCOUNT_SUPER_USER @"KEY_ACCOUNT_SUPER_USER"

@interface AccountManager ()

@property (nonatomic, assign) BOOL logined;
@property (nonatomic, copy) NSString *currentUsername;
@property (nonatomic, copy) NSString *currentPassword;

@end

@implementation AccountManager

+ (instancetype)manager
{
    static AccountManager *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [AccountManager new];
    });
    return __instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _logined = NO;
        _currentUsername = nil;
        _currentPassword = nil;
    }
    
    return self;
}

- (BOOL)login:(NSString *)username password:(NSString *)password
{
    BOOL success = NO;
    if ([username isEqualToString:@"root"] && [password isEqualToString:@"su"]) {
        self.currentUsername = [username copy];
        self.currentPassword = [password copy];
        [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:KEY_ACCOUNT_SUPER_USER];
        [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_SUPER_USER_STATUS_CHANGE object:@{@"isSuperUser": @YES}];
        self.logined = YES;
        success = YES;
    } else {
        success = NO;
    }
    return success;
}

- (void)logout
{
    self.logined = NO;
    self.currentUsername = nil;
    self.currentPassword = nil;
    
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:KEY_ACCOUNT_SUPER_USER];
    [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_SUPER_USER_STATUS_CHANGE object:@{@"isSuperUser": @YES}];
}

@end
