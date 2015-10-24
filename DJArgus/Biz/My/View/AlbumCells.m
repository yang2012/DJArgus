//
//  AlbumCells.m
//  DJArgus
//
//  Created by chris on 8/21/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "AlbumCells.h"

#import "DJDefinition.h"

#import "MediaLoadingManager.h"

#define DEFAULT_IMAGE [UIImage imageNamed:@"ic_thumb_placeholder"]

@interface AlbumCell() {
    
    UIImageView *_ivThumb, *_ivType;
    UILabel *_lName, *_lSize, *_lDuration, *_lCreateDate;
}

@end

@implementation AlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        NSArray *views = [self.contentView subviews];
        for (UIView *view in views) {
            [view removeFromSuperview];
        }
        
        _ivThumb = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 100, 72)];
        [_ivThumb setImage:[UIImage imageNamed:@"ic_thumb_placeholder"]];
        [self.contentView addSubview:_ivThumb];
        
        _ivType = [[UIImageView alloc] initWithFrame:CGRectMake(40, 23, 26, 26)];
        [_ivType setImage:[UIImage imageNamed:@"ic_video"]];
        [_ivThumb addSubview:_ivType];
        
        _lName = [[UILabel alloc] initWithFrame:CGRectMake(_ivThumb.right + 15, _ivThumb.top + 4, 200, 16)];
        [_lName setFont:[UIFont middle]];
        [_lName setTextAlignment:NSTextAlignmentLeft];
        [_lName setNumberOfLines:1];
        [_lName setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_lName setTextColor:[UIColor deep_blue]];
        [_lName setText:@"DIM-14252-3232.jpg"];
        [self.contentView addSubview:_lName];
        
        _lCreateDate = [[UILabel alloc] initWithFrame:CGRectMake(_lName.left, _lName.bottom + 8, _lName.width, 16)];
        [_lCreateDate setFont:[UIFont small]];
        [_lCreateDate setTextColor:[UIColor deep_grey]];
        [_lCreateDate setText:@"2015-09-08 15:32:45"];
        [self.contentView addSubview:_lCreateDate];
        
        _lSize = [[UILabel alloc] initWithFrame:CGRectMake(_lName.left, _lCreateDate.bottom + 8, _lName.width, 16)];
        [_lSize setFont:[UIFont small]];
        [_lSize setTextColor:[UIColor deep_grey]];
        [_lSize setText:@"1.5M"];
        [self.contentView addSubview:_lSize];
        
        UIButton *btnDelete = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 31, 30, 30)];
        [btnDelete setBackgroundImage:[UIImage imageNamed:@"ic_task_delete"] forState:UIControlStateNormal];
        [btnDelete addTarget:self action:@selector(m_deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btnDelete];
        
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [self.contentView autoresizingMask];
    }
    
    return self;
}

#pragma mark - Action

- (void)m_deleteBtnAction {
    [self.delegate albumCellDidClickDeleteBtn:self];
}

#pragma mark - Setter & Getter

- (void)setMedia:(DJIMedia *)media {
    _media = media;
    if (media) {
        [_ivThumb setImage:media.thumbnail ? : [UIImage imageNamed:@"ic_thumb_placeholder"]];
        [_lName setText:media.fileName];
        [_lCreateDate setText:media.createTime];
        [_lSize setText:[NSString stringWithFormat:@"%0.1fMB", media.fileSize / 1024.0 / 1024.0]];
        if (media.mediaType == MediaTypeJPG) {
            [_ivType setHidden:YES];
        } else {
            [_ivType setHidden:NO];
        }
    }
    else {
        self.textLabel.text = nil;
    }
}


@end
