//
//  MediaManager.m
//  DJArgus
//
//  Created by Justin Yang on 15/9/30.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import "MediaManager.h"
#import "FCFileManager.h"

@implementation MediaManager

+ (instancetype)manager
{
    static MediaManager *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[MediaManager alloc] init];
    });
    return __instance;
}

- (void)saveMediaWithName:(NSString *)name data:(NSData *)data
{
    [FCFileManager writeFileAtPath:name content:data];
}

- (BOOL)existsItemWithName:(NSString *)mediaName
{
    return [FCFileManager existsItemAtPath:mediaName];
}

- (NSString *)pathOfMediaWithName:(NSString *)mediaName
{
    NSArray *paths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    return [documentsDirectory stringByAppendingPathComponent:mediaName];
}

- (NSData *)readDataOfFileWithName:(NSString *)name
{
    return [FCFileManager readFileAtPathAsData:name];
}

- (void)deleteMediaWithName:(NSString *)mediaName
{
    BOOL existed = [self existsItemWithName:mediaName];
    if (existed) {
        [FCFileManager removeItemAtPath:mediaName];
    }
}

@end
