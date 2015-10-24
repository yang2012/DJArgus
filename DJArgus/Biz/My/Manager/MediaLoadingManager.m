//
//  MediaLoadingManager.m
//  DJArgus
//
//  Created by chris on 8/21/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "MediaLoadingManager.h"

#import "DJDefinition.h"


@interface MediaContextLoadingTask : NSObject

@property (strong, nonatomic) DJIMedia *media;
@property (copy, nonatomic) MediaLoadingManagerTaskBlock block;

@end


@implementation MediaContextLoadingTask

@end



@interface MediaLoadingManager() {
    NSArray *_operationQueues;
    NSArray *_taskQueues;
    NSUInteger _imageThreads, _videoThreads;
    NSUInteger _mediaIdx;
}

@end


#pragma mark -
#pragma mark MediaLoadingManager Implementation

@implementation MediaLoadingManager

- (id)initWithThreadsForImage:(NSUInteger)imageThreads threadsForVideo:(NSUInteger)videoThreads {
    if (self = [super init]) {
        NSAssert(imageThreads >= 1, @"number of threads for image must be greater than 0.");
        NSAssert(videoThreads >= 1, @"number of threads for video must be greater than 0.");
        
        _imageThreads = imageThreads;
        _videoThreads = videoThreads;
        _mediaIdx = 0;
        
        NSMutableArray *operationQueues = [NSMutableArray arrayWithCapacity:_imageThreads + _videoThreads];
        for (NSUInteger i = 0; i < _imageThreads; i++) {
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue setName:[NSString stringWithFormat:@"MediaDownloadManager image %lu", (unsigned long)i]];
            [queue setMaxConcurrentOperationCount:1];
            [operationQueues addObject:queue];
        }
        
        for (NSUInteger i = 0; i < _videoThreads; i++) {
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue setName:[NSString stringWithFormat:@"MediaDownloadManager video %lu", (unsigned long)i]];
            [queue setMaxConcurrentOperationCount:1];
            [operationQueues addObject:queue];
        }
        
        _operationQueues = operationQueues;
        
        NSMutableArray *taskQueues = [NSMutableArray arrayWithCapacity:_imageThreads + _videoThreads];
        for (NSUInteger i = 0; i < _imageThreads + _videoThreads; i++) {
            [taskQueues addObject:[NSMutableArray array]];
        }
        
        _taskQueues = taskQueues;
    }
    return self;
}

- (void)addTaskForMedia:(DJIMedia *)media withLoadingBlock:(MediaLoadingManagerTaskBlock)block {
    NSUInteger threadIndex;
    if (media.mediaType == MediaTypeJPG) {
        threadIndex = _mediaIdx % _imageThreads;
    }
    else {
        threadIndex = _imageThreads + _mediaIdx % _videoThreads;
    }
    _mediaIdx++;
    
    NSMutableArray *taskQueue = [_taskQueues objectAtIndex:threadIndex];
    @synchronized(taskQueue) {
        MediaContextLoadingTask *task = [[MediaContextLoadingTask alloc] init];
        task.media = media;
        task.block = block;
        
        [taskQueue addObject:task];
    }
    
    NSOperationQueue *operationQueue = [_operationQueues objectAtIndex:threadIndex];
    if (operationQueue.operationCount == 0) {
        [self driveTaskQueue:@(threadIndex)];
    }
}

- (void)driveTaskQueue:(NSNumber *)threadIndex {
    NSMutableArray *taskQueue = [_taskQueues objectAtIndex:threadIndex.integerValue];
    NSOperationQueue *operationQueue = [_operationQueues objectAtIndex:threadIndex.integerValue];
    
    @synchronized(taskQueue) {
        if (taskQueue.count == 0) {
            return;
        }
        
        MediaContextLoadingTask *task = [taskQueue lastObject];
        [taskQueue removeLastObject];
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            task.block();
            [self driveTaskQueue:threadIndex];
        }];
        [operationQueue addOperation:operation];
    }
}

- (void)cancelAllTasks {
    for (NSMutableArray *taskQueue in _taskQueues) {
        @synchronized(taskQueue) {
            [taskQueue removeAllObjects];
        }
    }
    
    for (NSOperationQueue *queue in _operationQueues) {
        [queue cancelAllOperations];
    }
}

@end