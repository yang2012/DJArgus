//
//  MediaLoadingManager.h
//  DJArgus
//
//  Created by chris on 8/21/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <DJISDK/DJISDK.h>



typedef void(^MediaLoadingManagerTaskBlock)();


@interface MediaLoadingManager : NSObject

- (id)initWithThreadsForImage:(NSUInteger)imgThreads threadsForVideo:(NSUInteger)videoThreads;
- (void)addTaskForMedia:(DJIMedia *)media withLoadingBlock:(MediaLoadingManagerTaskBlock)block;
- (void)cancelAllTasks;

@end
