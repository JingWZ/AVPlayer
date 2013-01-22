//
//  CustomBottomView.h
//  Quartz2DButton
//
//  Created by apple on 13-1-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBarView : UIView{
    CGFloat viewHeight;
    CGFloat viewWidth;
    CGFloat trapezoidLineALength;
    CGFloat trapezoidLineBLength;
}

@property (assign, nonatomic) CGFloat offset;
@property (assign, nonatomic) CGFloat sawtoothWidth;
@property (assign, nonatomic) CGFloat sawtoothHeight;
@property (assign, nonatomic) CGFloat sawtoothOffset;
@property (assign, nonatomic) CGFloat bottomEdge;


@end

