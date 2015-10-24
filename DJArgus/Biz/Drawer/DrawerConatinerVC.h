//
//  DrawerConatinerVC.h
//  DJArgus
//
//  Created by chris on 8/15/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "LANaviController.h"

#import "DJDefinition.h"

@interface DrawerConatinerVC : LANaviController<ICSDrawerControllerChild, ICSDrawerControllerPresenting>

@property(nonatomic, weak) ICSDrawerController *drawer;

@end
