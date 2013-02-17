//
//  MultipleTrackSlider.h
//  MultipleTrackSliderDemo
//
//  Created by apple on 13-1-30.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackwardButton.h"
#import "ForwardButton.h"


@interface MultipleTrackSlider : UIControl

@property (assign, nonatomic) CGRect barRect;

@property (assign, nonatomic) CGFloat leftValue;
@property (assign, nonatomic) CGFloat middleValue;
@property (assign, nonatomic) CGFloat rightValue;

@property (strong, nonatomic) UIView *leftTrackView;
@property (strong, nonatomic) UIView *rightTrackView;
@property (strong, nonatomic) UIView *middleTrackView;

@property (strong, nonatomic) ForwardButton *forwardBtn;
@property (strong, nonatomic) BackwardButton *backwardBtn;
@property (assign, nonatomic) CGFloat forBackWardScale;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinGesture;

- (id)initWithFrame:(CGRect)frame minValue:(CGFloat)min maxValue:(CGFloat)max;
- (void)setMinValue:(CGFloat)min  maxValue:(CGFloat)max;


@end
