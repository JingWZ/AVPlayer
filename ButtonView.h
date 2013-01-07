//
//  ButtonView.h
//  Quartz2DButton
//
//  Created by apple on 13-1-1.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonView : UIButton{
    CGFloat radiusOfArcs;
    CGFloat lineOffset;
    CGFloat lineWidth;
    CGColorRef lineColor;
    CGColorRef fillColor;
    NSString *buttonText;
    CGFloat textSize;
    CGFloat textPointX;
    CGFloat textPointY;
}

- (void)initBarButtonWithTitle:(NSString *)title;

- (void)setRadiusOfArcs:(CGFloat)radius;
- (void)setButtonText:(NSString *)text;
- (void)setTextSize:(CGFloat)size;
- (void)setTextPointX:(CGFloat)x;
- (void)setTextPointY:(CGFloat)y;
- (void)setLineOffset:(CGFloat)offset;
- (void)setLineWidth:(CGFloat)width;
- (void)setFillColor:(CGColorRef)color;

@end