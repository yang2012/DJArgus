//
//  LocationEntity.h
//  DJArgus
//
//  Created by Justin Yang on 15/10/1.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import "MTLModel.h"

@interface LocationEntity : MTLModel

@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lng;
@property (nonatomic, strong) NSNumber *altitude;

@end
