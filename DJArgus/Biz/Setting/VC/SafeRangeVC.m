//
//  SafeRangeVC.m
//  DJArgus
//
//  Created by Justin Yang on 15/10/1.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import "SafeRangeVC.h"
#import "DrawerConatinerVC.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotation.h"
#import "LocationHelper.h"

static const double EARTH_RADIUS = 6378137.0;

typedef NS_ENUM(NSInteger, SafeRangeTextFileType) {
    SafeRangeTextFileTypeRadius,
    SafeRangeTextFileTypeHeight
};

@interface SafeRangeVC()<MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIButton *btnLocation;
@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKCircle *areaCircle;

@property (nonatomic, assign) CLLocationCoordinate2D myLocation;
@property (nonatomic, assign) CLLocationCoordinate2D centerPoint;
@property (nonatomic, strong) NSNumber *safeAreaRadius;
@property (nonatomic, strong) NSNumber *safeAreaHeight;

@property (nonatomic, strong) MyLocationAnnotation *myLocationAnnotation;
@property (nonatomic, strong) CenterPointAnnotation *centerPointAnnotation;

@end

@implementation SafeRangeVC

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self m_restoreData];
    }
    
    return self;
}

- (void)m_restoreData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *lat = [userDefaults valueForKey:KEY_SETTING_SAFERANGE_CENTER_POINT_LAT];
    if (lat != nil) {
        NSNumber *lng = [userDefaults valueForKey:KEY_SETTING_SAFERANGE_CENTER_POINT_LNG];
        _centerPoint = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
    } else {
        _centerPoint = kCLLocationCoordinate2DInvalid;
    }
    
    _safeAreaHeight = [userDefaults valueForKey:KEY_SETTING_SAFERANGE_HEIGHT];
    _safeAreaRadius = [userDefaults valueForKey:KEY_SETTING_SAFERANGE_RANGE];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor common_background]];
    [self setTitle:@"安全区域"];
    
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 8, 12, 21)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"ic_navi_back"] forState:UIControlStateNormal];
    [self.naviBar setLeftButton:btnLeft];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, self.naviBarHeight, self.view.width, self.view.height - self.naviBarHeight)];
    [_mapView setDelegate:self];
    
    CLLocationCoordinate2D coordDef;
    coordDef.latitude =31.231889;
    coordDef.longitude = 121.408355;
    MKCoordinateRegion region = {0};
    region.center = coordDef;
    region.span.latitudeDelta = 0.005;
    region.span.longitudeDelta = 0.005;
    [_mapView setRegion:region animated:NO];
    
    [self.view addSubview:_mapView];
    
    _btnLocation = [[UIButton alloc] initWithFrame:CGRectMake(25, self.view.height - 60, 30, 30)];
    [_btnLocation setBackgroundImage:[UIImage imageNamed:@"ic_location"] forState:UIControlStateNormal];
    [_btnLocation addTarget:self action:@selector(m_showMyLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnLocation];
    
    UIView *safeRangeControlPanel = [[UIView alloc] initWithFrame:CGRectMake(self.view.width - 180, self.naviBarHeight + 20, 160, 65)];
    [safeRangeControlPanel.layer setBackgroundColor:[UIColor common_background].CGColor];
    [safeRangeControlPanel.layer setBorderColor:[UIColor light_red].CGColor];
    [safeRangeControlPanel.layer setBorderWidth:0.5f];
    [safeRangeControlPanel.layer setCornerRadius:5.f];
    [self.view addSubview:safeRangeControlPanel];
    
    UILabel *lbRangeRadius = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, 40, 18)];
    lbRangeRadius.backgroundColor = safeRangeControlPanel.backgroundColor;
    lbRangeRadius.text = @"半径";
    lbRangeRadius.textAlignment = NSTextAlignmentRight;
    lbRangeRadius.font = [UIFont systemFontOfSize:16];
    [safeRangeControlPanel addSubview:lbRangeRadius];
    
    UITextField *tfRangeRadius = [[UITextField alloc] initWithFrame:CGRectMake(lbRangeRadius.right + 2, 0, safeRangeControlPanel.width - lbRangeRadius.right - 5, 30)];
    tfRangeRadius.returnKeyType = UIReturnKeyDone;
    tfRangeRadius.placeholder = @"安全区域半径";
    tfRangeRadius.backgroundColor = [UIColor white];
    tfRangeRadius.tag = SafeRangeTextFileTypeRadius;
    tfRangeRadius.text = self.safeAreaRadius.stringValue;
    tfRangeRadius.delegate = self;
    [safeRangeControlPanel addSubview:tfRangeRadius];
    
    UILabel *lbRangeHeight = [[UILabel alloc] initWithFrame:CGRectMake(lbRangeRadius.left, lbRangeRadius.bottom + 12, lbRangeRadius.width, lbRangeRadius.height)];
    lbRangeHeight.backgroundColor = safeRangeControlPanel.backgroundColor;
    lbRangeHeight.text = @"高度";
    lbRangeHeight.textAlignment = NSTextAlignmentRight;
    lbRangeHeight.font = [UIFont systemFontOfSize:16];
    [safeRangeControlPanel addSubview:lbRangeHeight];
    
    UITextField *tfRangeHeight = [[UITextField alloc] initWithFrame:CGRectMake(tfRangeRadius.left, tfRangeRadius.bottom + 2, tfRangeRadius.width, tfRangeRadius.height)];
    tfRangeHeight.backgroundColor = [UIColor white];
    tfRangeHeight.returnKeyType = UIReturnKeyDone;
    tfRangeHeight.delegate = self;
    tfRangeHeight.placeholder = @"飞行高度";
    tfRangeHeight.text = self.safeAreaHeight.stringValue;
    tfRangeHeight.tag = SafeRangeTextFileTypeHeight;
    [safeRangeControlPanel addSubview:tfRangeHeight];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(m_addCenterPoint:)];
    [_mapView addGestureRecognizer:tapGestureRecognizer];
    
    [self m_markSafeArea];
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

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *av = nil;
    if ([annotation isMemberOfClass:[CenterPointAnnotation class]]) {
        av = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CenterPointAnnotation"];
        if (!av) {
            av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CenterPointAnnotation"];
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
    }
    return av;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKOverlayPathRenderer *renderer;
    if ([overlay isKindOfClass:[MKCircle class]]) {
        renderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        renderer.strokeColor = [[UIColor light_red] colorWithAlphaComponent:0.8];
        renderer.lineDashPattern = @[@4, @4];
        renderer.lineWidth = 1;
    }
    return renderer;
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

- (void)m_markSafeArea {
    if (CLLocationCoordinate2DIsValid(self.centerPoint)) {
        if (self.centerPointAnnotation == nil) {
            self.centerPointAnnotation = [[CenterPointAnnotation alloc] init];
            self.centerPointAnnotation.title = @"中心点";
        } else {
            [self.mapView removeAnnotation:self.centerPointAnnotation];
        }
        self.centerPointAnnotation.coordinate = self.centerPoint;
        [self.mapView addAnnotation:self.centerPointAnnotation];
        [self.mapView selectAnnotation:self.centerPointAnnotation animated:YES];
    }
    
    if (self.safeAreaRadius != nil) {
        if (self.areaCircle) {
            [self.mapView removeOverlay:self.areaCircle];
        }
        
        self.areaCircle = [MKCircle circleWithCenterCoordinate:self.centerPoint radius:self.safeAreaRadius.doubleValue];
        [self.mapView addOverlay:self.areaCircle];
    }
}

- (void)m_addCenterPoint:(UITapGestureRecognizer *)sender {
    if(sender.state != UIGestureRecognizerStateEnded) return;
    
    CGPoint point = [sender locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    self.centerPoint = coordinate;
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

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSInteger value = textField.text.integerValue;
    if (textField.tag == SafeRangeTextFileTypeRadius) {
        if (value > 0 && value <= 200) {
            self.safeAreaRadius = @(value);
        } else {
            [MBProgressHUD dj_showHUDWithMessage:@"非法输入" fromView:self.view];
            [textField becomeFirstResponder];
        }
    } else if (textField.tag == SafeRangeTextFileTypeHeight) {
        if (value > 0 && value <= 300) {
            self.safeAreaHeight = @(value);
        } else {
            [MBProgressHUD dj_showHUDWithMessage:@"非法输入" fromView:self.view];
            [textField becomeFirstResponder];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL shouldReturn = YES;
    double value = textField.text.integerValue;
    if (textField.tag == SafeRangeTextFileTypeRadius) {
        if (value > 200) {
            [MBProgressHUD dj_showHUDWithMessage:@"非法输入" fromView:self.view];
            shouldReturn = NO;
        }
    } else if (textField.tag == SafeRangeTextFileTypeHeight) {
        if (value > 300) {
            [MBProgressHUD dj_showHUDWithMessage:@"非法输入" fromView:self.view];
            shouldReturn = NO;
        }
    }
    
    if (shouldReturn) {
        [textField resignFirstResponder];
    }
    
    return shouldReturn;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BOOL shouldEnd = YES;
    NSInteger value = textField.text.integerValue;
    if (textField.tag == SafeRangeTextFileTypeRadius) {
        if (value > 200) {
            [MBProgressHUD dj_showHUDWithMessage:@"非法输入" fromView:self.view];
            shouldEnd = NO;
        }
    } else if (textField.tag == SafeRangeTextFileTypeHeight) {
        if (value > 300) {
            [MBProgressHUD dj_showHUDWithMessage:@"非法输入" fromView:self.view];
            shouldEnd = NO;
        }
    }
    return shouldEnd;
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

- (void)setSafeAreaRadius:(NSNumber *)safeAreaRadius
{
    _safeAreaRadius = safeAreaRadius;
    
    [self m_markSafeArea];
    
    [[NSUserDefaults standardUserDefaults] setValue:safeAreaRadius forKey:KEY_SETTING_SAFERANGE_RANGE];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_SAFE_AREA_CHANGE object:nil];
}

- (void)setCenterPoint:(CLLocationCoordinate2D)centerPoint
{
    _centerPoint = centerPoint;
    
    [self m_markSafeArea];
    
    [[NSUserDefaults standardUserDefaults] setValue:@(centerPoint.latitude) forKey:KEY_SETTING_SAFERANGE_CENTER_POINT_LAT];
    [[NSUserDefaults standardUserDefaults] setValue:@(centerPoint.longitude) forKey:KEY_SETTING_SAFERANGE_CENTER_POINT_LNG];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_SAFE_AREA_CHANGE object:nil];
}

- (void)setSafeAreaHeight:(NSNumber *)safeAreaHeight
{
    _safeAreaHeight = safeAreaHeight;
    
    [[NSUserDefaults standardUserDefaults] setValue:safeAreaHeight forKey:KEY_SETTING_SAFERANGE_HEIGHT];
}

@end
