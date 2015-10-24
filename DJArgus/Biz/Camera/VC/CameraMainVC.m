//
//  CameraMainVC.m
//  DJArgus
//
//  Created by chris on 8/14/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "CameraMainVC.h"

#import <DJISDK/DJISDK.h>

#import "VideoPreviewer.h"

#import "DrawerConatinerVC.h"
#import "SettingMainVC.h"
#import "SettingParam.h"

static const NSInteger TAG_BTN_SHUTTER = 0;
static const NSInteger TAG_BTN_MODE_SWITCHER = 1;

@interface CameraMainVC () <DJIDroneDelegate, DJICameraDelegate, DJIMainControllerDelegate> {
    UIButton *_btnOpt;
    
    UIImage *_imgPhoto, *_imgVideo;
    UIImage *_imgShutterDef, *_imgShutterStop;
    
    UIButton *_btnModeSwitcher; // camera or video
    UIButton *_btnShutter;
    
    DJIPhantom3ProCamera *_camera;
    UIView *_vPreview;
    
    DJICameraSystemState *_cameraSystemState;
    DJICameraPlaybackState *_cameraPlaybackState;
    
    UILabel *_lRecordingTime;
    
    BOOL _isRecording;
}

@property (nonatomic, strong) DJIDrone *drone;

@end

@implementation CameraMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.naviBar setBackgroundColor:[UIColor translucent]];
    
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 9, 26, 26)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"ic_slide_menu"] forState:UIControlStateNormal];
    [self.naviBar setLeftButton:btnLeft];
    
    _btnOpt = [[UIButton alloc] initWithFrame:CGRectMake(0, 9, 26, 26)];
    [_btnOpt setBackgroundImage:[UIImage imageNamed:@"ic_opt"] forState:UIControlStateNormal];
    [self.naviBar setRightButton:_btnOpt];
    
    _vPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight)];
    [self.view addSubview:_vPreview];
    [self.view sendSubviewToBack:_vPreview];
    _vPreview.backgroundColor = [UIColor blackColor];
    
    _imgPhoto = [UIImage imageNamed:@"ic_switcher_photo"];
    _imgVideo = [UIImage imageNamed:@"ic_switcher_video"];
    _imgShutterDef = [UIImage imageNamed:@"ic_shutter"];
    _imgShutterStop = [UIImage imageNamed:@"ic_shutter_stop"];
    
    _btnModeSwitcher = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 65, self.view.height - 60.f, 40, 40)];
    [_btnModeSwitcher setImage:_imgPhoto forState:UIControlStateNormal];
    [_btnModeSwitcher setTag:TAG_BTN_MODE_SWITCHER];
    [_btnModeSwitcher addTarget:self action:@selector(m_btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnModeSwitcher];
    _isRecording = NO;
    
    _lRecordingTime = [[UILabel alloc] initWithFrame:CGRectMake(15, self.naviBarHeight + 10, 80, 20)];
    [_lRecordingTime setFont:[UIFont middle]];
    [_lRecordingTime setTextColor:[UIColor white]];
    [_lRecordingTime setText:@"01:20:35"];
    [_lRecordingTime setHidden:NO];
    [self.view addSubview:_lRecordingTime];
    
    _btnShutter = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width / 2 - 50, self.view.height - 70.f, 60, 60)];
    [_btnShutter setImage:_imgShutterDef forState:UIControlStateNormal];
    [_btnShutter setTag:TAG_BTN_SHUTTER];
    [_btnShutter setEnabled:!_isRecording];
    [_btnShutter addTarget:self action:@selector(m_btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnShutter];
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom3Professional];
    _drone.delegate = self;
    _drone.mainController.mcDelegate = self;
    
    _camera = (DJIPhantom3ProCamera*)_drone.camera;
    _camera.delegate = self;
    
    [[VideoPreviewer instance] start];
    
    [self m_configureCamera];
    
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:PUSH_CAMERA_SETTING_CHANGE object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self)
        [self m_configureCamera];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[VideoPreviewer instance] setView:_vPreview];
    [[VideoPreviewer instance] setDecoderDataSource:kDJIDecoderDataSourePhantom3Professional];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    _isRecording = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_drone connectToDrone];
    [_drone.camera startCameraSystemStateUpdates];
    [_drone.mainController startUpdateMCSystemState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_drone disconnectToDrone];
    [_drone.camera stopCameraSystemStateUpdates];
    [_drone.mainController stopUpdateMCSystemState];
    [[VideoPreviewer instance] unSetView];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)naviBarLeftButtonPressed {
    DrawerConatinerVC *containerVC = (DrawerConatinerVC *)self.navigationController;
    [containerVC.drawer open];
}

- (void)naviBarRightButtonPressed {
    SettingMainVC *settingMainVC = [[SettingMainVC alloc] init];
    [settingMainVC setLeftButtonType:YES];
    [self.navigationController pushViewController:settingMainVC animated:YES];
}

#pragma mark - DJIDroneDelegate

- (void)droneOnConnectionStatusChanged:(DJIConnectionStatus)status {
    if (status == ConnectionSucceeded) {
        [_camera setCameraWorkMode:CameraWorkModeCapture
                        withResult:nil];
    }
}

#pragma mark - DJICameraDelegate

- (void)camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length {
    uint8_t* pBuffer = (uint8_t*)malloc(length);
    memcpy(pBuffer, videoBuffer, length);
    [[VideoPreviewer instance].dataQueue push:pBuffer length:length];
}

- (void)camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState {
    _cameraSystemState = systemState;
    if (systemState.workMode == CameraWorkModeCapture) {
        [_btnModeSwitcher setImage:_imgPhoto forState:UIControlStateNormal];
    } else if (systemState.workMode == CameraWorkModeRecord) {
        [_btnModeSwitcher setImage:_imgVideo forState:UIControlStateNormal];
    }
    
    _isRecording = systemState.isRecording;
    [_lRecordingTime setHidden:!_isRecording];
    [_lRecordingTime setText:[self m_dateFormat:systemState.currentRecordingTime]];
    
    if (_isRecording) {
        [_btnShutter setImage:_imgShutterStop forState:UIControlStateNormal];
    } else {
        [_btnShutter setImage:_imgShutterDef forState:UIControlStateNormal];
    }
    [_btnModeSwitcher setEnabled:!_isRecording];
}

- (void)camera:(DJICamera *)camera didGeneratedNewMedia:(DJIMedia *)newMedia {
    NSLog(@"GenerateNewMedia:%@",newMedia.mediaURL);
}


#pragma mark -  DJIMainControllerDelegate

- (void)mainController:(DJIMainController*)mc didMainControlError:(MCError)error {
    
}

- (void)mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state {
    
}


#pragma mark - self define method

- (void)m_leftButtonClicked:(id)sender {
    DrawerConatinerVC *containerVC = (DrawerConatinerVC *)self.navigationController;
    [containerVC.drawer open];
}

- (void)m_btnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    @weakify(self)
    switch (btn.tag) {
        case TAG_BTN_MODE_SWITCHER:
        {
            CameraWorkMode mode = _cameraSystemState.workMode == CameraWorkModeRecord ? CameraWorkModeCapture : CameraWorkModeRecord;
            [_camera setCameraWorkMode:mode withResult:^(DJIError *error) {
                @strongify(self)
                if (error.errorCode != ERR_Succeeded) {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Set CameraWorkModeRecord Failed"
                                                                         message:error.errorDescription
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                    [errorAlert show];
                }
                
            }];
            break;
            
        }
        case TAG_BTN_SHUTTER: {
            switch (_cameraSystemState.workMode) {
                case CameraWorkModeCapture: {
                    
                    [_camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
                        if (error.errorCode != ERR_Succeeded) {
                            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Take Photo Error"
                                                                                 message:error.errorDescription
                                                                                delegate:self
                                                                       cancelButtonTitle:@"OK"
                                                                       otherButtonTitles:nil];
                            [errorAlert show];
                        }
                    }];
                    break;
                    
                }
                case CameraWorkModeRecord: {
                    
                    if (_isRecording) {
                        [_camera stopRecord:^(DJIError *error) {
                            @strongify(self)
                            if (error.errorCode != ERR_Succeeded) {
                                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Stop Record Error"
                                                                                     message:error.errorDescription
                                                                                    delegate:self
                                                                           cancelButtonTitle:@"OK"
                                                                           otherButtonTitles:nil];
                                [errorAlert show];
                            }
                        }];
                    } else {
                        [_camera startRecord:^(DJIError *error) {
                            @strongify(self)
                            if (error.errorCode != ERR_Succeeded) {
                                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Start Record Error"
                                                                                     message:error.errorDescription
                                                                                    delegate:self
                                                                           cancelButtonTitle:@"OK"
                                                                           otherButtonTitles:nil];
                                [errorAlert show];
                            }
                        }];
                    }
                    break;
                    
                }
                default:
                    break;
            }
        
            break;
            
        }
        default:
            break;
    }
}

- (NSString *)m_dateFormat:(int)seconds {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSString *formattedTimeString = [formatter stringFromDate:date];
    return formattedTimeString;
}

- (void)m_configureCamera
{
    if ([_camera respondsToSelector:@selector(setCameraVideoQuality:withResult:)]) {
        [_camera setCameraVideoQuality:[SettingParam videoQuality] withResult:nil];
    }
    
    if ([_camera respondsToSelector:@selector(setCameraPhotoSize:andRatio:withResult:)]) {
        [_camera setCameraPhotoSize:[SettingParam photoSize] andRatio:CameraPhotoRatio4_3 withResult:nil];
    }

// Will Crash, maybe is the problem of SDK
//    if ([_camera respondsToSelector:@selector(setCameraExposureMode:withResult:)]) {
//        [_camera setCameraExposureMode:CameraExposureModeProgram withResult:nil];
//    }

    if ([_camera respondsToSelector:@selector(setCameraWhiteBalance:withResultBlock:)]) {
        [_camera setCameraWhiteBalance:[SettingParam whiteBalanceType] withResultBlock:nil];
    }
    
    if ([_camera respondsToSelector:@selector(setCameraISO:withResultBlock:)]) {
        [_camera setCameraISO:[SettingParam isoType] withResultBlock:nil];
    }
    
    if ([_camera respondsToSelector:@selector(setCameraVideoStorageFormat:withResult:)]) {
        [_camera setCameraVideoStorageFormat:CameraVideoStorageFormatMP4 withResult:nil];
    }
}

@end
