//
//  MultipleTrackSlider.h
//  MultipleTrackSliderDemo
//
//  Created by apple on 13-1-30.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultipleTrackSlider : UIControl

@property (assign, nonatomic) CGRect barRect;

@property (assign, nonatomic) CGFloat leftValue;
@property (assign, nonatomic) CGFloat middleValue;
@property (assign, nonatomic) CGFloat rightValue;

@property (strong, nonatomic) UIView *leftTrackView;
@property (strong, nonatomic) UIView *rightTrackView;
@property (strong, nonatomic) UIView *middleTrackView;

@property (strong, nonatomic) UILabel *leftLbl;
@property (strong, nonatomic) UILabel *middleLbl;
@property (strong, nonatomic) UILabel *rightLbl;

@property (assign, nonatomic) NSInteger scale;

- (id)initWithFrame:(CGRect)frame leftValue:(CGFloat)left rightValue:(CGFloat)right middleValue:(CGFloat)middle scale:(CGFloat)scale;
- (void)updateScale:(NSInteger)scale;

@end
