//
//  CustomBottomView.m
//  Quartz2DButton
//
//  Created by apple on 13-1-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CustomBarView.h"

@implementation CustomBarView
@synthesize offset, bottomEdge;
@synthesize sawtoothWidth, sawtoothHeight, sawtoothOffset;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        offset=5;
        sawtoothWidth=10.0;
        sawtoothHeight=6.0;
        sawtoothOffset=5;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    
    offset=5;
    sawtoothWidth=10.0;
    sawtoothHeight=6.0;
    sawtoothOffset=5;
    
    viewHeight=self.bounds.size.height;
    viewWidth=self.bounds.size.width;
    
    
    //计算梯形边长
    [self calculateTrapezoidWidth];
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 5, [[UIColor blackColor] CGColor]);
    CGContextSaveGState(context);
    
    //锯齿
    [self drawSawtoothInContext:context];
    
    //主梯形
    [self drawMainTrapezoidInContext:context];
    
    
}

    
- (void)drawMainTrapezoidInContext:(CGContextRef)context{
    
    CGMutablePathRef path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, trapezoidLineALength, viewHeight);
    CGPathAddLineToPoint(path, NULL, trapezoidLineBLength, offset);
    CGPathAddLineToPoint(path, NULL, viewWidth-trapezoidLineBLength, offset);
    CGPathAddLineToPoint(path, NULL, viewWidth-trapezoidLineALength, viewHeight);
    
    CGContextAddPath(context, path);
    //CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    //CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextFillPath(context);
}

- (void)drawSawtoothInContext:(CGContextRef)context{
    
    int sawtoothCount=ceil(viewWidth/sawtoothWidth);
    
    CGMutablePathRef path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, offset+sawtoothOffset+sawtoothHeight);
    CGFloat currentX = 0.0;
    for (int i=0; i<sawtoothCount; i++) {
        CGPathAddLineToPoint(path, NULL, currentX+sawtoothWidth/2.0, offset+sawtoothOffset);
        CGPathAddLineToPoint(path, NULL, currentX+sawtoothWidth, offset+sawtoothOffset+sawtoothHeight);
        currentX=currentX+sawtoothWidth;
    }
    
    CGPathAddLineToPoint(path, NULL, viewWidth, viewHeight);
    CGPathAddLineToPoint(path, NULL, 0, viewHeight);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGContextFillPath(context);
    //CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    //CGContextStrokePath(context);
}

- (void)calculateTrapezoidWidth{
    //lineA=2/3*lineB
    trapezoidLineBLength=viewWidth/2.0/(5.0/3);
    trapezoidLineALength=2.0/3*trapezoidLineBLength;
}

@end


