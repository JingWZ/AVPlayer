//
//  CountLabel.h
//  APP4
//
//  Created by apple on 13-1-8.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountLabel : UILabel

@property (assign, nonatomic) CGFloat offset;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) CGFloat textSize;
@property (assign, nonatomic) CGFloat textPointX;
@property (assign, nonatomic) CGFloat textPointY;

- (void)setTextPointX:(CGFloat)x pointY:(CGFloat)y;

@end
