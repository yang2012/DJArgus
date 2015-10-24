//
//  AircraftAnnotationView.m
//  DJArgus
//
//  Created by Justin Yang on 15/10/2.
//  Copyright © 2015年 lynxchina. All rights reserved.
//

#import "AircraftAnnotationView.h"

@implementation AircraftAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.enabled = NO;
        self.draggable = NO;
        self.image = [UIImage imageNamed:@"ic_aircraft"];
    }
    
    return self;
}

- (void)updateHeading:(float)heading
{
    self.transform = CGAffineTransformIdentity;
    self.transform = CGAffineTransformMakeRotation(heading);
}

@end
