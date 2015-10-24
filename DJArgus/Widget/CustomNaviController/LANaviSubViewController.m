//
//  LANaviSubViewController.m
//  Argus
//
//  Created by chris on 7/24/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "LANaviSubViewController.h"

#import "LANaviBar.h"

@interface LANaviSubViewController ()

@property (nonatomic, strong) LANaviBar *defaultNaviBar;
@property (nonatomic, weak) LANaviBar *naviBar;
@property (nonatomic, strong) NSLayoutConstraint *naviBarTopConstraint;

@end

@implementation LANaviSubViewController

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_naviBar) {
        [self.view bringSubviewToFront:_naviBar];
    } else {
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_initDefaultNaviBar];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    if (_defaultNaviBar) {
        _defaultNaviBar.titleLabel.text = title;
    } else {
        
    }
}

- (void)naviBarLeftButtonPressed {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        
    }
}

- (void)naviBarRightButtonPressed {
    
}

- (LANaviBar *)curNaviBar {
    return _naviBar;
}

- (BOOL)isNaviBarHidden {
    BOOL hidden = YES;
    if (_naviBar && _naviBarTopConstraint) {
        hidden = !(_naviBarTopConstraint.constant == 0.f);
    } else {
        
    }
    return hidden;
}

- (void)replaceNaviBar:(LANaviBar *)naviBar {
    if (naviBar) {
        [naviBar removeFromSuperview];
        if (_naviBar) {
            [_naviBar removeFromSuperview];
            _naviBar = nil;
            _naviBarTopConstraint = nil;
        } else {
            
        }
        [self.view addSubview:naviBar];
        _naviBar = naviBar;
        [self p_setNaviBarAutoLayout];
    }
}

- (UIButton *)defaultNaviBarLeftButton {
    if (_defaultNaviBar) {
        return _defaultNaviBar.leftButton;
    } else {
        return nil;
    }
    
}

- (UIButton *)defaultNaviBarRightButton {
    if (_defaultNaviBar) {
        return _defaultNaviBar.rightButton;
    } else {
        return nil;
    }
}

- (void)setNaviBarLeftViewHidden:(BOOL)hidden {
    if (_defaultNaviBar) {
        _defaultNaviBar.leftView.hidden = hidden;
    }
}

- (void)setNaviBarRightViewHidden:(BOOL)hidden {
    if (_defaultNaviBar) {
        _defaultNaviBar.rightView.hidden = hidden;
    }
}

- (void)setNaviBarHidden:(BOOL)hidden withAnimation:(BOOL)animated {
    if (animated) {
        [_naviBar setNeedsLayout];
        [UIView animateWithDuration:.3f
                         animations:^{
                             _naviBarTopConstraint.constant = (hidden ? -1 * _naviBar.height : 0);
                         }
                         completion:nil];
    } else {
        
    }
}

- (CGFloat)naviBarHeight {
    return self.naviBar.height;
}

#pragma mark -
#pragma mark self define method

- (void)p_initDefaultNaviBar {
    NSAssert(!_defaultNaviBar, @"");
    _defaultNaviBar = [[LANaviBar alloc] init];
    _defaultNaviBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_defaultNaviBar];
    
    _naviBar = _defaultNaviBar;
    [self p_setNaviBarAutoLayout];
    
    if (self.navigationController && (self.navigationController.viewControllers.firstObject != self)) {
        _defaultNaviBar.leftView.hidden = NO;
    } else {
        _defaultNaviBar.leftView.hidden = YES;
    }
    
    __weak __typeof(self)weakSelf = self;
    _defaultNaviBar.leftButtonClickedHandler = ^() {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf naviBarLeftButtonPressed];
    };
    
    _defaultNaviBar.rightButtonClickedHandler = ^() {
        __strong __typeof(weakSelf)strongSefl = weakSelf;
        [strongSefl naviBarRightButtonPressed];
    };
}

- (void)p_setNaviBarAutoLayout {
    if (_naviBar) {
        _naviBar.translatesAutoresizingMaskIntoConstraints = NO;
        
        _naviBarTopConstraint = [NSLayoutConstraint constraintWithItem:_naviBar
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:0];
        [self.view addConstraints:@[_naviBarTopConstraint,
                                    [NSLayoutConstraint constraintWithItem:_naviBar
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:0],
                                    [NSLayoutConstraint constraintWithItem:_naviBar
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:0],
                                    ]];

        [_naviBar addConstraint:[NSLayoutConstraint constraintWithItem:_naviBar
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:_naviBar.bounds.size.height]];
        
    } else {
        
    }
}


@end
