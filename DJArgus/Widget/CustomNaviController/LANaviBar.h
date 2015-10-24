//
//  LANaviBar.h
//  Argus
//
//  Created by chris on 7/24/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LANaviBarLeftButtonClicked)();
typedef void(^LANaviBarRightButtonClicked)();


@interface LANaviBar : UIView

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UIView *rightView;

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) LANaviBarLeftButtonClicked leftButtonClickedHandler;
@property (nonatomic, copy) LANaviBarRightButtonClicked rightButtonClickedHandler;

@end
