//
//  LeftDrawerVC.h
//  DJArgus
//
//  Created by chris on 8/14/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DJDefinition.h"

@interface LeftDrawerVC : UIViewController<ICSDrawerControllerChild, ICSDrawerControllerPresenting>


@property(nonatomic, weak) ICSDrawerController *drawer;

@end
