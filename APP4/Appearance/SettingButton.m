//
//  SettingButton.m
//  Quartz2DButton
//
//  Created by apple on 13-1-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SettingButton.h"

@implementation SettingButton
@synthesize offset;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        offset=5;
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    
    CGFloat viewWidth=self.bounds.size.width;
    CGFloat viewHeight=self.bounds.size.height;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    //画扳手，把去掉offset的距离分为四份，扳手中心在左边第一份位置
    CGContextSaveGState(context);
    CGMutablePathRef path=CGPathCreateMutable();
    
    CGFloat s=(viewWidth-2*offset)/4;
    CGFloat centerX=viewWidth/3;
    CGFloat centerY=viewHeight/3*2;
    CGFloat radiusSmall=s/2.5;
    CGFloat radiusBig=s;
    CGFloat bottomLineAngle=M_PI_4/2;
    CGFloat topLineAngle=M_PI_4/2*3;
    CGFloat length=viewWidth/3;
    
    //小半圆
    CGPathAddArc(path, NULL, centerX, centerY, radiusSmall, M_PI, M_PI*2.5, NO);
    CGPathAddLineToPoint(path, NULL, centerX, centerY+radiusBig);
    //下大半圆
    CGPathAddArc(path, NULL, centerX, centerY, radiusBig, M_PI_2, -M_PI_4/2, YES);
    //下线
    CGPathAddLineToPoint(path, NULL, centerX+cos(bottomLineAngle)*radiusBig+length, centerY-sin(bottomLineAngle)*radiusBig-length);
    //手柄封口
    CGPathAddLineToPoint(path, NULL, centerX+cos(topLineAngle)*radiusBig+length, centerY-sin(topLineAngle)*radiusBig-length);
    //上线
    CGPathAddLineToPoint(path, NULL, centerX+cos(topLineAngle)*radiusBig, centerY-sin(topLineAngle)*radiusBig);
    //上大半圆
    CGPathAddArc(path, NULL, centerX, centerY, radiusBig, M_PI_4*6.5, M_PI, YES);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillPath(context);
    
    /*
    CGContextAddPath(context, path);
    CGContextClip(context);
    //渐变
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGColorRef startColor=CGColorCreate(colorSpace, (CGFloat[]){0.98, 0.98, 0.98, 1});
    CGColorRef endColor=CGColorCreate(colorSpace, (CGFloat[]){0.53, 0.53, 0.53, 0.26});
    CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault, (const void*[]){startColor,endColor}, 2, nil);
    CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, colorArray, NULL);
    CGPoint center=CGPointMake(viewWidth/2, viewHeight/2);
    CGContextDrawRadialGradient(context, gradient, center, viewWidth/10, center, viewWidth, kCGGradientDrawsBeforeStartLocation);
    */
     
    if (self.highlighted) {
        
        CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
        CGColorRef startColor=CGColorCreate(colorSpace, (CGFloat[]){0.98, 0.98, 0.98, 1});
        CGColorRef endColor=CGColorCreate(colorSpace, (CGFloat[]){0.53, 0.53, 0.53, 0.26});
        CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault, (const void*[]){startColor,endColor}, 2, nil);
        CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, colorArray, NULL);
        CGPoint center=CGPointMake(viewWidth/2, viewHeight/2);
        
        CGContextRestoreGState(context);
        CGContextDrawRadialGradient(context, gradient, center, offset, center, viewWidth/2, kCGGradientDrawsBeforeStartLocation);
    }

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self setNeedsDisplay];
}


@end
