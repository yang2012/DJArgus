//
//  CustomAnnotation.m
//  DJArgus
//
//  Created by chris on 8/19/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "CustomAnnotation.h"

#pragma mark - GroundStationAnnotation implementation

@implementation MyLocationAnnotation

@end

#pragma mark - GroundStationAnnotation implementation

@implementation GroundStationAnnotation

@end

#pragma mark - CenterPointAnnotation implementation

@implementation CenterPointAnnotation

@end

#pragma mark - AircraftAnnotation implementation

@implementation AircraftAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    
    if (self) {
        _coordinate = coordinate;
    }
    
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

- (void)updateHeading:(float)heading
{
    if (self.annotationView) {
        [self.annotationView updateHeading:heading];
    }
}

@end