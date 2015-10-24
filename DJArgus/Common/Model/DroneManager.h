//
//  DroneManager.h
//  DJArgus
//
//  Created by Justin Yang on 15/9/20.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DroneManager : NSObject

@property (nonatomic, strong, readonly) DJIDrone *drone;

+ (instancetype)manager;

- (void)registerApp;

@end
