//
//  LANaviBar.m
//  Argus
//
//  Created by chris on 7/24/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "LANaviBar.h"
#import "DJDefinition.h"

@implementation LANaviBar

- (id)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 40);
        [self setBackgroundColor:[UIColor white]];
        
//        CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        
        // left view init
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, self.height, self.height)];
        [self.leftView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.leftView];
        
        UIImage *backImg = [UIImage imageNamed:@"navibar_back"];
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (self.leftView.height - backImg.size.height) / 2,
                                                                     backImg.size.width, backImg.size.height)];
        [_leftButton setBackgroundImage:[UIImage imageNamed:@"navibar_back"] forState:UIControlStateNormal];
        [_leftButton addTarget:self
                        action:@selector(p_leftButtonClicked:)
              forControlEvents:UIControlEventTouchUpInside];
        [self.leftView addSubview:_leftButton];
        
        // right view init
        self.rightView = [[UIView alloc] initWithFrame:CGRectMake(self.width - self.height - 15, 0,
                                                                  self.height, self.height)];
        [self.rightView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.rightView];
        
        
        self.rightView.hidden = YES;
        
        // center view init
        self.centerView = [[UIView alloc] initWithFrame:CGRectMake(self.leftView.right + 15, 0,
                                                                   self.rightView.left - self.leftView.right - 30,
                                                                   self.height)];
        [self.centerView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.centerView];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.centerView.width, self.centerView.height)];
        [self.titleLabel setFont:[UIFont large]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setTextColor:[UIColor light_red]];
        [self.centerView addSubview:self.titleLabel];
        
        
        
        UIView *vSep = [[UIView alloc] initWithFrame:CGRectMake(0, self.bottom, self.width, 0.5f)];
        [vSep setBackgroundColor:[UIColor inner_divider]];
        [self addSubview:vSep];
    }
    return self;
}

- (void)setCenterView:(UIView *)centerView {
    if (_centerView) {
        [_centerView removeFromSuperview];
        _centerView = nil;
    }
    
    _centerView = centerView;
    centerView.center = CGPointMake(self.width / 2, self.height / 2);
    [self addSubview:centerView];
}

- (void)setLeftButton:(UIButton *)leftButton {
    if (_leftButton) {
        [_leftButton removeFromSuperview];
        _leftButton = nil;
    }
    if (leftButton) {
        [self.leftView setHidden:NO];
    }
    
    _leftButton = leftButton;
    [_leftButton addTarget:self
                    action:@selector(p_leftButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.leftView addSubview:_leftButton];
}

- (void)setRightButton:(UIButton *)rightButton {
    if (_rightButton) {
        [_rightButton removeFromSuperview];
        _rightButton = nil;
    }
    if (rightButton) {
        [self.rightView setHidden:NO];
    }
    
    _rightButton = rightButton;
    [_rightButton addTarget:self
                     action:@selector(p_rightButtonClicked:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.rightView addSubview:_rightButton];
}


#pragma mark -
#pragma mark self define mthods 

- (void)p_leftButtonClicked:(id)sender {
    if (self.leftButtonClickedHandler) {
        self.leftButtonClickedHandler();
    } else {
        
    }
}

- (void)p_rightButtonClicked:(id)sender {
    if (self.rightButtonClickedHandler) {
        self.rightButtonClickedHandler();
    } else {
        
    }
}

@end
