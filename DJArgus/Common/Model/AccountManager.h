//
//  AccountManager.h
//  DJArgus
//
//  Created by Justin Yang on 15/10/4.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountManager : NSObject

@property (nonatomic, assign, readonly) BOOL logined;
@property (nonatomic, copy, readonly) NSString *currentUsername;
@property (nonatomic, copy, readonly) NSString *currentPassword;

+ (instancetype)manager;

- (BOOL)login:(NSString *)username password:(NSString *)password;

- (void)logout;

@end
