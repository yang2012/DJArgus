//
//  MediaPreviewVC.m
//  DJArgus
//
//  Created by chris on 8/21/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "MediaPreviewVC.h"
#import "LAPhotoView.h"
@import MediaPlayer;
#import "MediaManager.h"

@interface MediaPreviewVC ()

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@end

@implementation MediaPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor common_background];
    self.title = self.media.fileName;
    
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 8, 12, 21)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"ic_navi_back"] forState:UIControlStateNormal];
    [self.naviBar setLeftButton:btnLeft];
    [self.naviBar setBackgroundColor:[UIColor translucent]];
    
    if (self.media.mediaType == MediaTypeJPG) {
        [self showImage];
    } else if (self.media.mediaType == MediaTypeM4V || self.media.mediaType == MediaTypeMP4) {
        [self displayVideo];
    }
}

- (void)displayVideo
{
    NSString *pathVideo = [[MediaManager manager] pathOfMediaWithName:self.media.fileName];
    NSURL *movieURL = [NSURL fileURLWithPath:pathVideo];
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    [self.moviePlayer setShouldAutoplay:YES];
    [self.moviePlayer setContentURL:movieURL.absoluteURL];
    [self.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    [self.moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
    [self.moviePlayer setFullscreen:NO];
    [self.moviePlayer setScalingMode:MPMovieScalingModeNone];
    self.moviePlayer.view.frame = self.view.frame;
    [self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer prepareToPlay];
    [self.moviePlayer play];
}

- (void)showImage
{
    NSData *data = [[MediaManager manager] readDataOfFileWithName:self.media.fileName];
    UIImage *image = [UIImage imageWithData:data];
    NSString *msg = [NSString stringWithFormat:@"Image: %@", image.debugDescription];
    [MBProgressHUD dj_showHUDWithMessage:msg fromView:self.view];
    LAPhotoView *photoView = [[LAPhotoView alloc] initWithFrame:self.view.bounds andImage:image];
    photoView.autoresizingMask = (1 << 6) -1;
    [self.view addSubview:photoView];
}

@end
