//
//  AlbumCells.h
//  DJArgus
//
//  Created by chris on 8/21/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaManager.h"

@class AlbumCell;

@protocol AlbumCellDelegate <NSObject>

- (void)albumCellDidClickDeleteBtn:(AlbumCell *)cell;

@end

@interface AlbumCell : UITableViewCell

@property (nonatomic, weak) id<AlbumCellDelegate> delegate;
@property(nonatomic, strong) DJIMedia* media;

@end
