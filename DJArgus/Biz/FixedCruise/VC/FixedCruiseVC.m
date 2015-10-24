//
//  FixedCruiseVC.m
//  DJArgus
//
//  Created by chris on 8/19/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "FixedCruiseVC.h"

#import "DrawerConatinerVC.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "CustomAnnotation.h"
#import "LocationEntity.h"
#import "LocationHelper.h"

@interface FixedCruiseVC()<MKMapViewDelegate, CLLocationManagerDelegate, DJIDroneDelegate, DJIMainControllerDelegate, DJINavigationDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIButton *btnLocation;
@property (nonatomic, strong) UILabel *lbGroundStationNum;
@property (nonatomic, strong) UIButton *btnTaskPlay;
@property (nonatomic, strong) UIButton *btnTaskStop;
@property (nonatomic, strong) UIButton *btnTaskUpload;
@property(nonatomic, strong) UIAlertView* uploadProgressView;

@property (nonatomic, copy) NSArray *groundStationLocations;
@property (nonatomic, assign, readonly) CLLocationCoordinate2D safeAreaCenter;
@property (nonatomic, assign, readonly) double safeAreaRadius;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@property (nonatomic, assign) CLLocationCoordinate2D latestDroneLocation;

@property (nonatomic, strong) DJIDrone *drone;
@property (nonatomic, strong) DJIPhantom3ProMainController *mainController;
@property (nonatomic, weak) NSObject<DJINavigation> *navigationManager;
@property (nonatomic, weak) NSObject<DJIWaypointMission> *waypointMission;
@property (nonatomic, strong) DJIMCSystemState *systemState;
@property (nonatomic, strong) DJIWaypointMissionStatus *missionStatus;

@property (nonatomic, strong) MKCircle *areaCircle;
@property (nonatomic, strong) CenterPointAnnotation *centerPointAnnotation;
@property (nonatomic, strong) AircraftAnnotation *aircraftAnnotation;
@property (nonatomic, strong) NSMutableArray *groundStationAnnotations;
@property (nonatomic, strong) NSMutableArray *groundStationLines;

@property (nonatomic, assign) BOOL missionExecuting;

@end

@implementation FixedCruiseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initDrone];
    [self initUI];
    
    [self m_markSafeArea];
    
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:PUSH_SAFE_AREA_CHANGE object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(id x) {
         @strongify(self)
         [self m_markSafeArea];
     }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:PUSH_GROUND_STATION_CHANGE object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSNotification *notification) {
         @strongify(self)
         self.groundStationLocations = notification.object;
         [self m_markFlyLine];
     }];
}

- (void)initUI
{
    [self.view setBackgroundColor:[UIColor common_background]];
    [self setTitle:@"定点巡航"];
    
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 9, 26, 26)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"ic_slide_menu"] forState:UIControlStateNormal];
    [self.naviBar setLeftButton:btnLeft];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, self.naviBarHeight, self.view.width, self.view.height - self.naviBarHeight)];
    [_mapView setDelegate:self];
    
    [self.view addSubview:_mapView];
    
    _btnLocation = [[UIButton alloc] initWithFrame:CGRectMake(25, self.view.height - 60, 30, 30)];
    [_btnLocation setBackgroundImage:[UIImage imageNamed:@"ic_location"] forState:UIControlStateNormal];
    [_btnLocation addTarget:self action:@selector(m_showAircraftLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnLocation];
    
    UIView *groundStationControlPanel = [[UIView alloc] initWithFrame:CGRectMake(self.view.width - 180, self.naviBarHeight + 20, 165, 100)];
    [groundStationControlPanel.layer setBackgroundColor:[UIColor common_background].CGColor];
    [groundStationControlPanel.layer setBorderColor:[UIColor light_red].CGColor];
    [groundStationControlPanel.layer setBorderWidth:0.5f];
    [groundStationControlPanel.layer setCornerRadius:5.f];
    [self.view addSubview:groundStationControlPanel];
    
    _lbGroundStationNum = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 120, 20)];
    [_lbGroundStationNum setFont:[UIFont middle]];
    [_lbGroundStationNum setText:[NSString stringWithFormat:@"当前地面站数: %@", @(self.groundStationLocations.count)]];
    [_lbGroundStationNum setTextColor:[UIColor light_red]];
    [groundStationControlPanel addSubview:_lbGroundStationNum];
    
    UIView *vLine = [[UIView alloc] initWithFrame:CGRectMake(10, 35, 145, 1.f)];
    [vLine setBackgroundColor:[UIColor inner_divider]];
    [groundStationControlPanel addSubview:vLine];
    
    UILabel *lTask = [[UILabel alloc] initWithFrame:CGRectMake(10, vLine.bottom + 5, 100, 20)];
    [lTask setFont:[UIFont middle]];
    [lTask setText:@"任务控制"];
    [lTask setTextColor:[UIColor light_red]];
    [groundStationControlPanel addSubview:lTask];
    
    _btnTaskStop = [[UIButton alloc] initWithFrame:CGRectMake(15, 63, 30, 30)];
    [_btnTaskStop setBackgroundImage:[UIImage imageNamed:@"ic_task_stop"] forState:UIControlStateNormal];
    [_btnTaskStop addTarget:self action:@selector(m_stopMission) forControlEvents:UIControlEventTouchUpInside];
    [groundStationControlPanel addSubview:_btnTaskStop];
    
    _btnTaskPlay = [[UIButton alloc] initWithFrame:CGRectMake(_btnTaskStop.right + 23, 60, 35, 35)];
    [_btnTaskPlay setBackgroundImage:[UIImage imageNamed:@"ic_task_start"] forState:UIControlStateNormal];
    [_btnTaskPlay addTarget:self action:@selector(m_btnTaskPlayAction) forControlEvents:UIControlEventTouchUpInside];
    [groundStationControlPanel addSubview:_btnTaskPlay];
    
    _btnTaskUpload = [[UIButton alloc] initWithFrame:CGRectMake(_btnTaskPlay.right + 16, 60, 35, 35)];
    [_btnTaskUpload setBackgroundImage:[UIImage imageNamed:@"ic_set_ground_station"] forState:UIControlStateNormal];
    [_btnTaskUpload addTarget:self action:@selector(m_btnTaskUploadAction) forControlEvents:UIControlEventTouchUpInside];
    [groundStationControlPanel addSubview:_btnTaskUpload];
}

- (void)initDrone
{
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom3Professional];
    _drone.delegate = self;
    
    _mainController = (DJIPhantom3ProMainController *)_drone.mainController;
    _mainController.mcDelegate = self;
    
    _navigationManager = _drone.mainController.navigationManager;
    _navigationManager.delegate = self;
    
    _waypointMission = _navigationManager.waypointMission;
}

- (void)initData
{
    _userLocation = kCLLocationCoordinate2DInvalid;
    _groundStationLocations = [[TMCache sharedCache] objectForKey:KEY_GROUND_STATUS_LOCATIONS];
    _groundStationAnnotations = [NSMutableArray array];
    _groundStationLines = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self m_startUpdateLocation];
    [self.drone connectToDrone];
    [self.mainController startUpdateMCSystemState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self m_stopUpdateLocation];
    [self.drone disconnectToDrone];
    [self.mainController stopUpdateMCSystemState];
}

- (void)naviBarLeftButtonPressed {
    DrawerConatinerVC *containerVC = (DrawerConatinerVC *)self.navigationController;
    [containerVC.drawer open];
}

#pragma mark - DJINavigationDelegate

- (void)onNavigationMissionStatusChanged:(DJINavigationMissionStatus *)missionStatus
{
    if ([missionStatus isKindOfClass:[DJIWaypointMissionStatus class]]) {
        self.missionStatus = (DJIWaypointMissionStatus *)missionStatus;
    }
}

#pragma mark - DJIMainControllerDelegate

- (void)mainController:(DJIMainController *)mc didUpdateSystemState:(DJIMCSystemState *)state
{
    self.systemState = state;
    
    if (!state.isMultipleFlightModeOpen) {
        [self.mainController setMultipleFlightModeOpen:YES withResult:nil];
    }
    
    if (state.flightMode == MainControllerFlightModeAutoLanding) {
        self.missionExecuting = NO;
    }
    
    if (!state.isFlying) {
        if (CLLocationCoordinate2DIsValid(self.latestDroneLocation)) {
            if (fabs(self.latestDroneLocation.latitude - state.droneLocation.latitude) > 0.000001
                || fabs(self.latestDroneLocation.longitude - state.droneLocation.longitude) > 0.000001) {
                self.latestDroneLocation = state.droneLocation;
                [self m_markFlyLine];
            }
        } else {
            self.latestDroneLocation = state.droneLocation;
            [self m_markFlyLine];
        }
    }
    
    [self m_updateAircraftLocation:state.droneLocation];
    
    double radianYaw = (state.attitude.yaw * M_PI / 180);
    [self m_updateAircraftHeading:radianYaw];
}

#pragma mark - DJIDroneDelegate

- (void)droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if (status == ConnectionSucceeded) {
        if (!self.navigationManager.isNavigationMode) {
            [self enterNavigationMode];
        }
    }
}

- (void)enterNavigationMode
{
    @weakify(self)
    [self.navigationManager enterNavigationModeWithResult:^(DJIError *error) {
        @strongify(self)
        if (error.errorCode != ERR_Succeeded) {
            NSString* message = [NSString stringWithFormat:@"Enter navigation mode failed:%@", error.errorDescription];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Enter Navigation Mode" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重试", nil];
            [alertView.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
                if (buttonIndex.integerValue == 1) {
                    [self enterNavigationMode];
                }
            }];
            [alertView show];
        }
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    CLLocationCoordinate2D latestCoordinate = location.coordinate;
    
    if (!CLLocationCoordinate2DIsValid(self.userLocation)) {
        self.userLocation = latestCoordinate;
        MKCoordinateRegion region = {0};
        region.center = [LocationHelper transformFromWGSToGCJ:latestCoordinate];
        region.span.latitudeDelta = 0.005;
        region.span.longitudeDelta = 0.005;
        [_mapView setRegion:region animated:NO];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"无法取得您当前位置"
                               message:nil
                               delegate:nil
                               cancelButtonTitle:@"好的"
                               otherButtonTitles:nil];
    [errorAlert show];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *av = nil;
    if ([annotation isMemberOfClass:[GroundStationAnnotation class]]) {
        av = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"GroundStationAnnotation"];
        if (!av) {
            av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"GroundStationAnnotation"];
            av.canShowCallout = YES;
            av.image = [UIImage imageNamed:@"ic_ground_station_def"];
        }
    } else if ([annotation isKindOfClass:[AircraftAnnotation class]]) {
        AircraftAnnotationView *annoView = [[AircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AircraftAnnotation"];
        ((AircraftAnnotation *)annotation).annotationView = annoView;
        av = annoView;
    } else if ([annotation isMemberOfClass:[CenterPointAnnotation class]]) {
        av = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CenterPointAnnotation"];
        if (!av) {
            MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CenterPointAnnotation"];
            pinView.pinColor = MKPinAnnotationColorPurple;
            av = pinView;
        }
    }
    return av;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKOverlayPathRenderer *renderer;
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        renderer.strokeColor = [[UIColor deep_blue] colorWithAlphaComponent:0.8];
        renderer.lineWidth = 5;
    } else if ([overlay isKindOfClass:[MKCircle class]]) {
        renderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        renderer.strokeColor = [[UIColor light_red] colorWithAlphaComponent:0.8];
        renderer.lineDashPattern = @[@4, @4];
        renderer.lineWidth = 1;
    }
    return renderer;
}

#pragma mark - Location

- (void)m_startUpdateLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务不可用"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)m_stopUpdateLocation {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - UI

- (void)m_hideProgressView
{
    if (self.uploadProgressView) {
        [self.uploadProgressView dismissWithClickedButtonIndex:-1 animated:YES];
        self.uploadProgressView = nil;
    }
}

- (void)m_showProgressViewWithTitle:(NSString *)title message:(NSString *)message
{
    if (self.uploadProgressView == nil) {
        self.uploadProgressView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [self.uploadProgressView show];
    }
    self.uploadProgressView.title = title;
    self.uploadProgressView.message = message;
}

#pragma mark - GroundStationDelegate

- (void)groundStation:(id<DJIGroundStation>)gs didExecuteWithResult:(GroundStationExecuteResult*)result
{
    if (result.currentAction == GSActionStart) {
        if (result.executeStatus == GSExecStatusFailed) {
            [self m_hideProgressView];
            NSLog(@"Mission Start Failed...");
        }
    }
    if (result.currentAction == GSActionUploadTask) {
        if (result.executeStatus == GSExecStatusFailed) {
            [self m_hideProgressView];
            NSLog(@"Upload Mission Failed");
        }
    }
}

- (void)groundStation:(id<DJIGroundStation>)gs didUploadWaypointMissionWithProgress:(uint8_t)progress
{
    [self m_showProgressViewWithTitle:@"任务上传中" message:[NSString stringWithFormat:@"%d%%", progress]];
}

#pragma mark - Actions

- (void)m_showAircraftLocation {
    if (self.aircraftAnnotation == nil || !CLLocationCoordinate2DIsValid(self.systemState.droneLocation)) return;
    
    MKCoordinateRegion region = {0};
    region.center = self.systemState.droneLocation;
    region.span.latitudeDelta = 0.005;
    region.span.longitudeDelta = 0.005;
    [self.mapView setRegion:region animated:YES];
    [self.mapView selectAnnotation:self.aircraftAnnotation animated:YES];
}

- (void)m_btnTaskPlayAction
{
    if (self.waypointMission.isRunning) {
        if (self.missionExecuting) {
            [self m_pauseMission];
        } else {
            [self m_resumeMission];
        }
    } else {
        [self m_startMission];
    }
}

- (void)m_btnTaskUploadAction
{
    [self m_uploadWaypointMission];
}

#pragma mark - Annotation

- (void)m_markSafeArea {
    if (self.centerPointAnnotation != nil) {
        [self.mapView removeAnnotation:self.centerPointAnnotation];
    }
    
    if (self.areaCircle != nil) {
        [self.mapView removeOverlay:self.areaCircle];
    }
    
    if (!CLLocationCoordinate2DIsValid(self.safeAreaCenter) || self.safeAreaRadius < 0.0001) return;
    
    self.centerPointAnnotation = [[CenterPointAnnotation alloc] init];
    self.centerPointAnnotation.title = @"中心点";
    self.centerPointAnnotation.coordinate = self.safeAreaCenter;
    [self.mapView addAnnotation:self.centerPointAnnotation];
    
    self.areaCircle = [MKCircle circleWithCenterCoordinate:self.safeAreaCenter radius:self.safeAreaRadius];
    [self.mapView addOverlay:self.areaCircle];
}

- (void)m_markFlyLine {
    if (self.groundStationAnnotations.count > 0) {
        [self.mapView removeAnnotations:self.groundStationAnnotations];
        [self.groundStationAnnotations removeAllObjects];
    }
    
    if (self.groundStationLines.count > 0) {
        [self.mapView removeOverlays:self.groundStationLines];
        [self.groundStationLines removeAllObjects];
    }
    
    if (!CLLocationCoordinate2DIsValid(self.systemState.droneLocation) || self.groundStationLocations.count == 0) return;
        
    LocationEntity *userLocation = [LocationEntity new];
    userLocation.lat = @(self.systemState.droneLocation.latitude);
    userLocation.lng = @(self.systemState.droneLocation.longitude);
    userLocation.altitude = @10;
    NSMutableArray *locations = [NSMutableArray arrayWithObject:userLocation];
    [locations addObjectsFromArray:self.groundStationLocations];
    
    NSUInteger count = locations.count;
    for (NSUInteger index = 0; index < count; index++) {
        LocationEntity *entity = locations[index];
        GroundStationAnnotation *annotation = [[GroundStationAnnotation alloc] init];
        annotation.title = (index == 0 ? @"起点" : [NSString stringWithFormat:@"巡航点%lu", index]);
        annotation.subtitle = [NSString stringWithFormat:@"飞行高度%@m", entity.altitude];
        annotation.coordinate = CLLocationCoordinate2DMake(entity.lat.doubleValue, entity.lng.doubleValue);
        [self.mapView addAnnotation:annotation];
        [self.groundStationAnnotations addObject:annotation];
        
        if (index > 0) {
            LocationEntity *preEntity = locations[index - 1];
            CLLocationCoordinate2D coords[2];
            coords[0] = annotation.coordinate;
            coords[1] = CLLocationCoordinate2DMake(preEntity.lat.doubleValue, preEntity.lng.doubleValue);
            MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:2];
            [self.mapView addOverlay:polyline];
            [self.groundStationLines addObject:polyline];
        }
        
        if (index == count - 1 && count > 2) {
            LocationEntity *firstEntity = locations[0];
            CLLocationCoordinate2D coords[2];
            coords[0] = annotation.coordinate;
            coords[1] = CLLocationCoordinate2DMake(firstEntity.lat.doubleValue, firstEntity.lng.doubleValue);
            MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:2];
            [self.mapView addOverlay:polyline];
            [self.groundStationLines addObject:polyline];
        }
    }
}

- (void)m_updateAircraftLocation:(CLLocationCoordinate2D)location
{
    if (!CLLocationCoordinate2DIsValid(location)) return;
    
    if (self.aircraftAnnotation == nil) {
        self.aircraftAnnotation = [[AircraftAnnotation alloc] initWithCoordinate:location];
        [self.mapView addAnnotation:self.aircraftAnnotation];
    }
    
    [self.aircraftAnnotation setCoordinate:location];
}

- (void)m_updateAircraftHeading:(float)heading
{
    if (self.aircraftAnnotation) {
        [self.aircraftAnnotation updateHeading:heading];
    }
}

#pragma mark - WaypointMission

- (void)m_addWayPoints
{
    [self.waypointMission removeAllWaypoints];
    
    for (LocationEntity *location in self.groundStationLocations) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.lat.doubleValue, location.lng.doubleValue);
        if (CLLocationCoordinate2DIsValid(coordinate)) {
            DJIWaypoint *waypoint = [self m_waypointWithCoordinate:coordinate altitude:location.altitude.floatValue];
            [self.waypointMission addWaypoint:waypoint];
        }
    }
    
    DJIWaypoint *homeWaypoint = [self m_waypointWithCoordinate:self.systemState.droneLocation altitude:1];
    [self.waypointMission addWaypoint:homeWaypoint];
}

- (DJIWaypoint *)m_waypointWithCoordinate:(CLLocationCoordinate2D)coordinate altitude:(CGFloat)altitude
{
    DJIWaypoint *waypoint = [[DJIWaypoint alloc] initWithCoordinate:coordinate];
    waypoint.altitude = altitude;
    DJIWaypointAction *action = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionStartTakePhoto param:0];
    [waypoint addAction:action];
    return waypoint;
}

- (void)m_configWaypointMission
{
    self.waypointMission.maxFlightSpeed = 5;
    self.waypointMission.autoFlightSpeed = 2;
    self.waypointMission.headingMode = DJIWaypointMissionHeadingAuto;
    self.waypointMission.finishedAction = DJIWaypointMissionFinishedAutoLand;
}

#pragma mark - WaypointMission

- (void)m_uploadWaypointMission
{
    [self m_configWaypointMission];
    [self m_addWayPoints];
    
    if (self.waypointMission.isValid) {
        @weakify(self)
        if (self.uploadProgressView == nil) {
            self.uploadProgressView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [self.uploadProgressView show];
        }
        
        [self.waypointMission setUploadProgressHandler:^(uint8_t progress) {
            [self.uploadProgressView setTitle:@"飞行任务上传中"];
            NSString* message = [NSString stringWithFormat:@"%d%%", progress];
            [self.uploadProgressView setMessage:message];
        }];
        
        [self.waypointMission uploadMissionWithResult:^(DJIError *error) {
            @strongify(self)
            
            if (error.errorCode != ERR_Succeeded) {
                [self.uploadProgressView setTitle:@"任务上传失败"];
                [self.uploadProgressView setMessage:error.errorDescription];
            } else {
                [self.uploadProgressView setTitle:@"任务上传成功"];
            }
            [self performSelector:@selector(m_hideProgressView) withObject:nil afterDelay:2];
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无效的任务" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)m_startMission
{
    @weakify(self)
    [self.mainController setHomePointUsingAircraftCurrentLocationWithResult:^(DJIError *error) {
        @strongify(self)
        if (error.errorCode != ERR_Succeeded) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"设置起始点失败" message:error.errorDescription delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [alertView show];
        } else {
            [self.waypointMission startMissionWithResult:^(DJIError *error) {
                if (error.errorCode != ERR_Succeeded) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务开始失败" message:error.errorDescription delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
                    [alertView show];
                } else {
                    self.missionExecuting = YES;
                }
            }];
        }
    }];
}

- (void)m_pauseMission
{
    [self.waypointMission pauseMissionWithResult:^(DJIError *error) {
        if (error.errorCode != ERR_Succeeded) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务暂停失败" message:error.errorDescription delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [alertView show];
        } else {
            self.missionExecuting = NO;
        }
    }];
}

- (void)m_resumeMission
{
    [self.waypointMission resumeMissionWithResult:^(DJIError *error) {
        if (error.errorCode != ERR_Succeeded) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务恢复失败" message:error.errorDescription delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [alertView show];
        } else {
            self.missionExecuting = YES;
        }
    }];
}

- (void)m_stopMission
{
    [self.waypointMission stopMissionWithResult:^(DJIError *error) {
        if (error.errorCode != ERR_Succeeded) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"任务停止失败" message:error.errorDescription delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [alertView show];
        } else {
            [self.mainController startGoHomeWithResult:^(DJIError *error) {
                if (error.errorCode != ERR_Succeeded) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"返回起始点失败" message:error.errorDescription delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
                    [alertView show];
                } else {
                    self.missionExecuting = NO;
                }
            }];
        }
    }];
}

#pragma mark - Setter & Getter

- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 0.1f;
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationManager requestAlwaysAuthorization];
        }
    }
    return _locationManager;
}

- (CLLocationCoordinate2D)safeAreaCenter
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *lat = [userDefaults valueForKey:KEY_SETTING_SAFERANGE_CENTER_POINT_LAT];
    NSNumber *lng = [userDefaults valueForKey:KEY_SETTING_SAFERANGE_CENTER_POINT_LNG];
    
    CLLocationCoordinate2D centerPoint = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);

    return centerPoint;
}

- (double)safeAreaRadius
{
    NSNumber *range = [[NSUserDefaults standardUserDefaults] valueForKey:KEY_SETTING_SAFERANGE_RANGE];
    return range.doubleValue;
}

- (void)setMissionExecuting:(BOOL)missionExecuting
{
    _missionExecuting = missionExecuting;
    
    [self.btnTaskPlay setBackgroundImage:[UIImage imageNamed:missionExecuting ? @"ic_task_pause" : @"ic_task_start"]
                                forState:UIControlStateNormal];
}

- (void)setGroundStationLocations:(NSArray *)groundStationLocations
{
    _groundStationLocations = [groundStationLocations copy];
    
    [self.lbGroundStationNum setText:[NSString stringWithFormat:@"当前地面站数: %@", @(groundStationLocations.count)]];
}

@end
