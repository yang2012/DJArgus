//
//  MediaManager.h
//  DJArgus
//
//  Created by Justin Yang on 15/9/30.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaManager : NSObject

+ (instancetype)manager;

- (void)saveMediaWithName:(NSString *)name data:(NSData *)data;
- (NSString *)pathOfMediaWithName:(NSString *)mediaName;
- (BOOL)existsItemWithName:(NSString *)mediaName;
- (NSData *)readDataOfFileWithName:(NSString *)name;
- (void)deleteMediaWithName:(NSString *)mediaName;


@end
