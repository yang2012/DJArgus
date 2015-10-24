//
//  AircraftAnnotationView.h
//  DJArgus
//
//  Created by Justin Yang on 15/10/2.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface AircraftAnnotationView : MKAnnotationView

- (void)updateHeading:(float)heading;

@end
