//
//  LocationHelper.h
//  DJArgus
//
//  Created by Justin Yang on 15/10/11.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationHelper : NSObject

//判断是否已经超出中国范围
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;

//转GCJ-02
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;

@end