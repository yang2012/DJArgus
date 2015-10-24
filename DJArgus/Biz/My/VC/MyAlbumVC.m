//
//  MyAlbumVC.m
//  DJArgus
//
//  Created by chris on 8/14/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "MyAlbumVC.h"
#import "DrawerConatinerVC.h"
#import "MediaPreviewVC.h"
#import "AlbumCells.h"
#import "MediaManager.h"
#import "VideoPreviewer.h"

@interface MyAlbumVC()<UITableViewDataSource, UITableViewDelegate, AlbumCellDelegate, DJIDroneDelegate, DJICameraDelegate>

@property (nonatomic, strong) UITableView *tvMedias;

@property (nonatomic, assign) BOOL mediasLoaded;
@property (nonatomic, strong) NSMutableArray *mediaList;
@property (nonatomic, assign) int currentMediaIndex;

@property (nonatomic, strong) DJIDrone *drone;
@property (nonatomic, strong) DJIPhantom3ProCamera *camera;

@property(nonatomic, strong) UIAlertView *downloadProgressAlert;
@property(nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation MyAlbumVC

- (id)init {
    if (self = [super init]) {
        _mediaList = [NSMutableArray array];
        
        _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom3Professional];
        _drone.delegate = self;
        
        _camera = (DJIPhantom3ProCamera *)_drone.camera;
        _camera.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor common_background]];
    [self setTitle:@"我的相册"];
    
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 9, 26, 26)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"ic_slide_menu"] forState:UIControlStateNormal];
    [self.naviBar setLeftButton:btnLeft];
    
    UIButton *btnRight = [[UIButton alloc] initWithFrame:CGRectMake(0, 9, 26, 26)];
    [btnRight setBackgroundImage:[UIImage imageNamed:@"ic_drone_media"] forState:UIControlStateNormal];
    [self.naviBar setRightButton:btnRight];
    
    self.tvMedias = [[UITableView alloc] initWithFrame:CGRectMake(0, self.naviBarHeight, self.view.width, self.view.height - self.naviBarHeight)
                                               style:UITableViewStylePlain];
    [self.tvMedias setShowsVerticalScrollIndicator:YES];
    [self.tvMedias setDataSource:self];
    [self.tvMedias setDelegate:self];
    [self.tvMedias registerClass:[AlbumCell class] forCellReuseIdentifier:[AlbumCell reuseIdentifier]];
    [self.view addSubview:self.tvMedias];
    
    UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(m_longPressed:)];
    longPressGesture.minimumPressDuration = 1.0;
    [self.tvMedias addGestureRecognizer:longPressGesture];
    
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:PUSH_REMOTE_MEDIA_DOWNLOADED object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self)
        [self m_reloadMediaList];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.drone connectToDrone];
    [self.drone.camera startCameraSystemStateUpdates];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.drone.camera stopCameraSystemStateUpdates];
    [self.drone disconnectToDrone];
}

- (void)naviBarLeftButtonPressed {
    DrawerConatinerVC *containerVC = (DrawerConatinerVC *)self.navigationController;
    [containerVC.drawer open];
}

- (void)naviBarRightButtonPressed {
    [self m_reloadMediaList];
}

#pragma mark - Progress

- (void)showProgress
{
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.progressHUD show:YES];
    [self.view addSubview:self.progressHUD];
}

- (void)hideProgress
{
    if (self.progressHUD) {
        [self.progressHUD hide:YES];
        [self.progressHUD removeFromSuperview];
        self.progressHUD = nil;
    }
}

#pragma mark - DJIDroneDelegate

- (void)droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    
}

#pragma mark - Media

- (void)m_reloadMediaList
{
    self.mediasLoaded = NO;
    
    [self m_loadMediaList];
}

- (void)m_loadMediaList
{
    if (self.mediasLoaded) return;
    
    self.mediasLoaded = YES;
    
    [self showProgress];
    
    if ([self.drone.camera respondsToSelector:@selector(fetchMediaListWithResultBlock:)]) {
        @weakify(self)
        typedef void (^FetchMediaListHandler)(NSArray*, NSError*);
        FetchMediaListHandler handler = ^(NSArray *mediaList, NSError *error) {
            @strongify(self)
            if (error == nil) {
                [self m_updateMediaList:mediaList];
            } else {
                NSString *msg = [NSString stringWithFormat:@"多媒体资源更新失败: %@", @(error.code)];
                [MBProgressHUD dj_showHUDWithMessage:msg fromView:self.view];
            }
            
            [self hideProgress];
        };
        
        [self.drone.camera performSelector:@selector(fetchMediaListWithResultBlock:) withObject:handler];
    }
}

- (void)m_updateMediaList:(NSArray*)mediaList
{
    [self.mediaList removeAllObjects];
    [self.mediaList addObjectsFromArray:mediaList];
    [self.tvMedias reloadData];
    
    [self m_fetchThumbnailOneByOne];
}

- (void)m_fetchThumbnailOneByOne
{
    self.currentMediaIndex = -1;
    [self m_fetchNextThumbnail];
}

- (void)m_fetchNextThumbnail
{
    self.currentMediaIndex++;
    
    if (self.currentMediaIndex < self.mediaList.count) {
        DJIMedia* currentMedia = [self.mediaList objectAtIndex:self.currentMediaIndex];
        if (currentMedia.thumbnail != nil) {
            [self m_fetchNextThumbnail];
        } else {
            @weakify(self)
            [currentMedia fetchThumbnail:^(NSError *error) {
                @strongify(self)
                if (error) {
                    NSLog(@"Error:%@", error);
                }
                [self.tvMedias reloadData];
                [self m_fetchNextThumbnail];
            }];
        }
    }
}

#pragma mark - DJICameraDelegate

- (void)camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length
{
    
}

- (void)camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    if (systemState.workMode != CameraWorkModeDownload2) {
        DJIPhantom3ProCamera* phantom3ProCamera = (DJIPhantom3ProCamera*)self.drone.camera;
        [phantom3ProCamera setCameraWorkMode:CameraWorkModeDownload2 withResult:nil];
    }
    
    if (systemState.workMode == CameraWorkModeDownload2) {
        [self m_loadMediaList];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mediaList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCell* cell = [tableView dequeueReusableCellWithIdentifier:[AlbumCell reuseIdentifier]];
    cell.delegate = self;
    
    if (self.mediaList.count > indexPath.row) {
        DJIMedia* media = self.mediaList[indexPath.row];
        [cell setMedia:media];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 86.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DJIMedia* currentMedia = [self.mediaList objectAtIndex:indexPath.row];
    BOOL existed = [[MediaManager manager] existsItemWithName:currentMedia.fileName];
    if (existed) {
        [self m_showMedia:currentMedia];
    } else {
        [self m_downloadMedia:currentMedia];
    }
}

- (void)m_showMedia:(DJIMedia *)media
{
    MediaPreviewVC *previewController = [[MediaPreviewVC alloc] init];
    previewController.media = media;
    [self.navigationController pushViewController:previewController animated:YES];
}

#pragma mark - AlbumCellDelegate

- (void)albumCellDidClickDeleteBtn:(AlbumCell *)cell
{
    [self m_deleteMedia:cell.media];
}

#pragma mark - Download

- (void)m_downloadMedia:(DJIMedia *)media
{
    if (self.downloadProgressAlert == nil) {
        self.downloadProgressAlert = [[UIAlertView alloc] initWithTitle:@"下载中" message:@"0.0%" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [self.downloadProgressAlert show];
    }
    
    __block int totalDownloadSize = 0;
    __block NSMutableData* downloadData = [[NSMutableData alloc] init];
    
    @weakify(self)
    [media fetchMediaData:^(NSData *data, BOOL *stop, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"文件下载失败: %@", error.description];
                [self.downloadProgressAlert setMessage:msg];
                [self performSelector:@selector(dismissDownloadAlert) withObject:nil afterDelay:1.0];
            } else {
                [downloadData appendData:data];
                totalDownloadSize += data.length;
                float progress = totalDownloadSize * 100.0 / media.fileSize;
                [self.downloadProgressAlert setMessage:[NSString stringWithFormat:@"%0.1f%%", progress]];
                if (totalDownloadSize == media.fileSize) {
                    [[MediaManager manager] saveMediaWithName:media.fileName data:downloadData];
                    [self dismissDownloadAlert];
                    [self m_showMedia:media];
                }
            }
        });
    }];
}

- (void)dismissDownloadAlert
{
    [self.downloadProgressAlert dismissWithClickedButtonIndex:-1 animated:YES];
    self.downloadProgressAlert = nil;
}

#pragma mark - Delete

- (void)m_deleteMedia:(DJIMedia *)media
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"确认要删除该文件？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber *index) {
        if (index.integerValue == 1) {
            [self showProgress];
            
            @weakify(self)
            [self.camera deleteMedias:@[media] withResult:^(NSArray *failureDeletes, DJIError *error) {
                @strongify(self)
                if (failureDeletes.count == 0) {
                    [[MediaManager manager] deleteMediaWithName:media.fileName];
                    [self.mediaList removeObject:media];
                    [self.tvMedias reloadData];
                } else{
                    [MBProgressHUD dj_showHUDWithTitle:@"文件删除失败" message:error.errorDescription fromView:self.view];
                }
                [self hideProgress];
            }];
        }
    }];
    
    [alert show];
}

- (void)m_longPressed:(UILongPressGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:_tvMedias];
        NSIndexPath *indexPath = [_tvMedias indexPathForRowAtPoint:point];
        if(indexPath == nil) return;
        
        DJIMedia *media = self.mediaList[indexPath.row];
        [self m_deleteMedia:media];
    }
}

@end