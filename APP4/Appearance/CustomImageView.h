//
//  CustomImageView.h
//  Quartz2DButton
//
//  Created by apple on 13-1-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomImageView : UIView{
    
    CGFloat borderOffset;
    CGFloat borderWidth;
    CGColorRef centerBackgroundColor;
}

@property (copy, nonatomic) NSString *imagePath;
@property (assign, nonatomic) CGFloat frameWidth;
@property (assign, nonatomic) CGFloat leftEdge;
@property (assign, nonatomic) CGFloat rightEdge;

- (void)setborderWidth:(CGFloat)width;
- (void)setBorderOffset:(CGFloat)offsets;
- (void)setCenterBackgroundColor:(CGColorRef)color;



@end
