//
//  CruiseLineVC.m
//  DJArgus
//
//  Created by Justin Yang on 15/10/1.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import "CruiseLineVC.h"
#import "DrawerConatinerVC.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotation.h"
#import "LocationEntity.h"
#import "LocationHelper.h"

static const double EARTH_RADIUS = 6378137.0;
static const NSInteger MAX_GROUND_NUM = 4;

static const int TAG_BTN_LOCATION = 1;
static const int TAG_BTN_SET_GROUND_STATION = 2;
static const int TAG_BTN_TASK_DELETE = 3;

typedef NS_ENUM(NSInteger, GroundStationStatus) {
    GroundStationStatusFinish,   // 完成
    GroundStationStatusEdit,    // 编辑
};

@interface CruiseLineVC() <MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIButton *btnLocation;
@property (nonatomic, strong) UIButton *btnSetGroundStation;
@property (nonatomic, strong) UILabel *lbGroundStationNum;
@property (nonatomic, strong) UIButton *btnTaskDelete;

@property (nonatomic, assign) CLLocationCoordinate2D myLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, assign) GroundStationStatus groundStationStatus;

@property (nonatomic, strong) MyLocationAnnotation *myLocationAnnotation;
@property (nonatomic, strong) NSMutableArray *groundStationAnnotations;
@property (nonatomic, strong) NSMutableArray *overlays;

@property (nonatomic, strong) NSMutableArray *tmpLocations;
@property (nonatomic, assign, readonly) CLLocationCoordinate2D centerPoint;
@property (nonatomic, strong, readonly) NSNumber *safeAreaRadius;

@property (nonatomic, strong) NSNumber *defaultFlyHeight;
@property (nonatomic, strong) NSNumber *maxFlyHeight;

@end

@implementation CruiseLineVC

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _defaultFlyHeight = @2;
        _maxFlyHeight = [[NSUserDefaults standardUserDefaults] valueForKey:KEY_SETTING_SAFERANGE_HEIGHT] ? : @200;
        _groundStationStatus = GroundStationStatusFinish;
        _myLocation = kCLLocationCoordinate2DInvalid;
        _groundStationAnnotations = [NSMutableArray arrayWithCapacity:MAX_GROUND_NUM];
        _tmpLocations = [NSMutableArray arrayWithCapacity:MAX_GROUND_NUM];
        _overlays = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor common_background]];
    [self setTitle:@"飞行路径"];
    
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 8, 12, 21)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"ic_navi_back"] forState:UIControlStateNormal];
    [self.naviBar setLeftButton:btnLeft];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, self.naviBarHeight, self.view.width, self.view.height - self.naviBarHeight)];
    [_mapView setDelegate:self];
    
    MKCoordinateRegion region = {0};
    region.center = self.centerPoint;
    region.span.latitudeDelta = 0.005;
    region.span.longitudeDelta = 0.005;
    [_mapView setRegion:region animated:NO];
    
    [self.view addSubview:_mapView];
    
    _btnLocation = [[UIButton alloc] initWithFrame:CGRectMake(25, self.view.height - 60, 30, 30)];
    [_btnLocation setBackgroundImage:[UIImage imageNamed:@"ic_location"] forState:UIControlStateNormal];
    [_btnLocation setTag:TAG_BTN_LOCATION];
    [_btnLocation addTarget:self action:@selector(m_btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnLocation];
    
    UIView *groundStationControlPanel = [[UIView alloc] initWithFrame:CGRectMake(self.view.width - 210, self.naviBarHeight + 20, 200, 40)];
    [groundStationControlPanel.layer setBackgroundColor:[UIColor common_background].CGColor];
    [groundStationControlPanel.layer setBorderColor:[UIColor light_red].CGColor];
    [groundStationControlPanel.layer setBorderWidth:0.5f];
    [groundStationControlPanel.layer setCornerRadius:5.f];
    [self.view addSubview:groundStationControlPanel];
    
    _lbGroundStationNum = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    [_lbGroundStationNum setFont:[UIFont middle]];
    [_lbGroundStationNum setText:@"当前地面站数: 0"];
    [_lbGroundStationNum setTextColor:[UIColor light_red]];
    [groundStationControlPanel addSubview:_lbGroundStationNum];
    
    _btnSetGroundStation = [[UIButton alloc] initWithFrame:CGRectMake(_lbGroundStationNum.right, 5, 30, 30)];
    [_btnSetGroundStation setBackgroundImage:[UIImage imageNamed:@"ic_set_ground_station"] forState:UIControlStateNormal];
    [_btnSetGroundStation setTag:TAG_BTN_SET_GROUND_STATION];
    [_btnSetGroundStation addTarget:self action:@selector(m_btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [groundStationControlPanel addSubview:_btnSetGroundStation];
    
    _btnTaskDelete = [[UIButton alloc] initWithFrame:CGRectMake(_btnSetGroundStation.right + 3, 2, 35, 35)];
    [_btnTaskDelete setBackgroundImage:[UIImage imageNamed:@"ic_task_delete"] forState:UIControlStateNormal];
    [_btnTaskDelete setTag:TAG_BTN_TASK_DELETE];
    [_btnTaskDelete addTarget:self action:@selector(m_btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [groundStationControlPanel addSubview:_btnTaskDelete];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(m_addGroundStation:)];
    [_mapView addGestureRecognizer:tapGestureRecognizer];
    
    [self m_markSafeArea];
    [self m_refreshGroundStationsWithLocations:[[TMCache sharedCache] objectForKey:KEY_GROUND_STATUS_LOCATIONS]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self m_startUpdateLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self m_stopUpdateLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    CLLocationCoordinate2D latestCoordinate = location.coordinate;
    
    if (CLLocationCoordinate2DIsValid(self.myLocation)
        && fabs(self.myLocation.longitude - latestCoordinate.longitude) < 0.01
        && fabs(self.myLocation.latitude - latestCoordinate.latitude) < 0.01) {
        return;
    }
    
    self.myLocation = [LocationHelper transformFromWGSToGCJ:latestCoordinate];
    
    if (self.myLocationAnnotation == nil) {
        self.myLocationAnnotation = [[MyLocationAnnotation alloc] init];
        self.myLocationAnnotation.title = @"我的位置";
    } else {
        [self.mapView removeAnnotation:self.myLocationAnnotation];
    }
    self.myLocationAnnotation.coordinate = self.myLocation;
    [self.mapView addAnnotation:self.myLocationAnnotation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"无法取得您当前位置"
                               message:nil
                               delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
    [errorAlert show];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *av = nil;
    if ([annotation isKindOfClass:[GroundStationAnnotation class]]) {
        av = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"GroundStationAnnotation"];
        if (!av) {
            av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"GroundStationAnnotation"];
            av.canShowCallout = YES;
            av.image = [UIImage imageNamed:@"ic_ground_station_def"];
        }
    } else if ([annotation isKindOfClass:[MyLocationAnnotation class]]) {
        av = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"MyLocationAnnotation"];
        
        if (!av) {
            av = [[MKAnnotationView alloc] initWithAnnotation:self.myLocationAnnotation reuseIdentifier:@"MyLocationAnnotation"];
            av.canShowCallout = YES;
            av.image = [UIImage imageNamed:@"ic_my_location"];
        }
    } else if ([annotation isKindOfClass:[CenterPointAnnotation class]]) {
        av = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CenterPointAnnotation"];
        if (!av) {
            av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CenterPointAnnotation"];
            av.canShowCallout = YES;
            av.image = [UIImage imageNamed:@"ic_ground_station_def"];
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (self.groundStationStatus != GroundStationStatusEdit) return;
    
    id annotation = view.annotation;
    if ([annotation isKindOfClass:[GroundStationAnnotation class]]) {
        GroundStationAnnotation *ga = (GroundStationAnnotation *)annotation;
        [self m_changeFlyHeightOfGroundStationWithIndex:ga.index];
    }
}

#pragma mark - Private Methods

- (void)m_startUpdateLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务不可用"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)m_stopUpdateLocation {
    [self.locationManager stopUpdatingLocation];
}

- (void)m_btnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case TAG_BTN_LOCATION: {
            [self m_showMyLocation];
            break;
        }
        case TAG_BTN_SET_GROUND_STATION: {
            NSString *imgName = self.groundStationStatus == 0 ? @"ic_set_ground_station_done" : @"ic_set_ground_station";
            [self.btnSetGroundStation setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
            self.groundStationStatus = self.groundStationStatus == 0 ? 1 : 0;
            break;
        }
        case TAG_BTN_TASK_DELETE: {
            if (self.groundStationStatus == GroundStationStatusEdit) {
                [self m_clearAllGroundStation];
            }
            break;
        }
        default:
            break;
    }
}

- (void)m_markSafeArea {
    if (self.safeAreaRadius != nil) {
        MKCircle *areaCircle = [MKCircle circleWithCenterCoordinate:self.centerPoint radius:self.safeAreaRadius.doubleValue];
        [self.mapView addOverlay:areaCircle];
        
        CenterPointAnnotation *centerPointAnnotation = [[CenterPointAnnotation alloc] init];
        centerPointAnnotation.coordinate = self.centerPoint;
        centerPointAnnotation.title = @"中心点";
        [self.mapView addAnnotation:centerPointAnnotation];
    }
}

- (void)m_addGroundStation:(UITapGestureRecognizer *)sender {
    if(sender.state != UIGestureRecognizerStateEnded
       || self.groundStationStatus != GroundStationStatusEdit) return;
    
    CGPoint point = [sender locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    if (![self m_isValidCoordination:coordinate]) return;
    
    [self m_confirmAddingGroundStationInCoordinate:coordinate];
}

- (void)m_addGroundStatusAnnotationWithLocation:(LocationEntity *)entity {
    GroundStationAnnotation *annotation = [[GroundStationAnnotation alloc] init];
    annotation.title = [NSString stringWithFormat:@"巡航点%lu", [self.groundStationAnnotations count] + 1];
    annotation.subtitle = [NSString stringWithFormat:@"飞行高度%@m", entity.altitude];
    annotation.coordinate = CLLocationCoordinate2DMake(entity.lat.doubleValue, entity.lng.doubleValue);
    [self.groundStationAnnotations addObject:annotation];
    [self.mapView addAnnotation:annotation];
    
    [self.lbGroundStationNum setText:[NSString stringWithFormat:@"当前地面站数: %lu", self.groundStationAnnotations.count]];

    NSUInteger count = self.groundStationAnnotations.count;
    if (count > 1) {
        GroundStationAnnotation *lstAnnotation = [self.groundStationAnnotations objectAtIndex:count - 2];
        CLLocationCoordinate2D coords[2];
        coords[0] = annotation.coordinate;
        coords[1] = lstAnnotation.coordinate;
        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:2];
        [self.mapView addOverlay:polyline];
        [self.overlays addObject:polyline];
    }
}

- (void)m_refreshGroundStationsWithLocations:(NSArray *)locations {
    if (locations.count == 0) {
        [self.mapView removeAnnotations:self.groundStationAnnotations];
        [self.groundStationAnnotations removeAllObjects];
        [self.mapView removeOverlays:self.overlays];
        [self.overlays removeAllObjects];
        [self.lbGroundStationNum setText:@"当前地面站数: 0"];
    } else {
        for (LocationEntity *entity in locations) {
            [self m_addGroundStatusAnnotationWithLocation:entity];
        }
    }
}

- (BOOL)m_isValidCoordination:(CLLocationCoordinate2D)coordinate {
    if (self.groundStationAnnotations.count >= 4) {
        [MBProgressHUD dj_showHUDWithMessage:@"路径设置点已到最大值" fromView:self.view];
        return NO;
    }
    
    NSUInteger count = self.groundStationAnnotations.count;
    NSUInteger i = count > 1 ? 1 : 0;
    for (; i < count; ++i) {
        GroundStationAnnotation *anno = [self.groundStationAnnotations objectAtIndex:i];
        if ([self distanceFrom:anno.coordinate to:coordinate] < 2) {
            return NO;
        }
    }
    
    if ([self distanceFrom:self.centerPoint to:coordinate] > self.safeAreaRadius.floatValue) {
        [MBProgressHUD dj_showHUDWithMessage:@"航线超过安全边界，请重设" fromView:self.view];
        return NO;
    }
    
    return YES;
}

- (void)m_showMyLocation {
    if (self.myLocationAnnotation == nil) return;
    
    MKCoordinateRegion region = {0};
    region.center = self.myLocation;
    region.span.latitudeDelta = 0.005;
    region.span.longitudeDelta = 0.005;
    [self.mapView setRegion:region animated:YES];
    [self.mapView selectAnnotation:self.myLocationAnnotation animated:YES];
}

- (void)m_beginEdittingGroundStations {
    [self m_clearAllGroundStation];
}

- (void)m_clearAllGroundStation {
    [self.tmpLocations removeAllObjects];
    [self m_refreshGroundStationsWithLocations:nil];
}

- (void)m_endEdittingGroundStations {
    [[TMCache sharedCache] setObject:self.tmpLocations forKey:KEY_GROUND_STATUS_LOCATIONS];
    [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_GROUND_STATION_CHANGE object:self.tmpLocations];
}

- (void)m_confirmAddingGroundStationInCoordinate:(CLLocationCoordinate2D)coordinate {
    NSString *msg = [NSString stringWithFormat:@"飞行高度不可超过%@m", self.maxFlyHeight];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"添加路径点" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = @"飞行高度";
    textField.text = self.defaultFlyHeight.stringValue;
    @weakify(self)
    [[alertView rac_buttonClickedSignal] subscribeNext:^(NSNumber *x) {
        @strongify(self)
        if (x.integerValue != 0) {
            NSString *input = textField.text;
            if ([input integerValue] <= self.maxFlyHeight.integerValue) {
                LocationEntity *entity = [LocationEntity new];
                entity.lat = @(coordinate.latitude);
                entity.lng = @(coordinate.longitude);
                entity.altitude = @(input.integerValue);
                [self.tmpLocations addObject:entity];
                
                [self m_addGroundStatusAnnotationWithLocation:entity];
            } else {
                [MBProgressHUD dj_showHUDWithMessage:@"非法输入" fromView:self.view];
            }
        }
    }];
    [alertView show];
}

- (void)m_changeFlyHeightOfGroundStationWithIndex:(NSInteger)index {
    LocationEntity *entity = self.tmpLocations[index];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"改变路径点的飞行高度" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = @"飞行高度";
    textField.text = entity.altitude.stringValue;
    [[alertView rac_buttonClickedSignal] subscribeNext:^(NSNumber *x) {
        if (x.integerValue != 0) {
            NSString *input = textField.text;
            if ([input integerValue] <= self.maxFlyHeight.integerValue) {
                entity.altitude = @(input.integerValue);
            } else {
                [MBProgressHUD dj_showHUDWithMessage:@"非法输入" fromView:self.view];
            }
        }
    }];
    [alertView show];
}

#pragma mark - Utils

- (CGFloat)distanceFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)dest {
    double lat1Rad = [self deg2rad:from.latitude];
    double lat2Rad = [self deg2rad:dest.latitude];
    double lng1Rad = [self deg2rad:from.longitude];
    double lng2Rad = [self deg2rad:dest.longitude];
    double dlat = lat2Rad - lat1Rad;
    double dlng = lng2Rad - lng1Rad;
    double tmpA = cos(lat1Rad) * cos(lat2Rad) * sin(dlng / 2) * sin(dlng / 2) +
    sin(dlat / 2) * sin(dlat / 2);
    double tmpC = 2.0 * asin(sqrt(tmpA));
    return EARTH_RADIUS * tmpC;
}

- (CGFloat)deg2rad:(CGFloat)deg {
    return deg * M_PI / 180;
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

- (NSNumber *)safeAreaRadius
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:KEY_SETTING_SAFERANGE_RANGE];
}

- (CLLocationCoordinate2D)centerPoint
{
    CLLocationCoordinate2D coordinate;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lat = [userDefaults valueForKey:KEY_SETTING_SAFERANGE_CENTER_POINT_LAT];
    if (lat != nil) {
        NSNumber *lng = [userDefaults valueForKey:KEY_SETTING_SAFERANGE_CENTER_POINT_LNG];
        coordinate = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
    }
    return coordinate;
}

- (void)setGroundStationStatus:(GroundStationStatus)groundStationStatus
{
    _groundStationStatus = groundStationStatus;
    
    if (groundStationStatus == GroundStationStatusEdit) {
        [self m_beginEdittingGroundStations];
    } else {
        [self m_endEdittingGroundStations];
    }
}

@end
