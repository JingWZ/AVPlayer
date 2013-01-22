//
//  PlayButton.m
//  Quartz2DButton
//
//  Created by apple on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PlayButton.h"

@implementation PlayButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
        offset=15;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGFloat viewWidth=self.bounds.size.width;
    CGFloat viewHeight=self.bounds.size.height;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    //画三角
    CGContextSaveGState(context);
    CGMutablePathRef path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, viewWidth/3, offset);
    CGPathAddLineToPoint(path, NULL, viewWidth/3, viewHeight-offset);
    CGPathAddLineToPoint(path, NULL, viewWidth/3*2, viewHeight/2);
    CGPathCloseSubpath(path);
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGContextFillPath(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    //渐变
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGColorRef startColor=CGColorCreate(colorSpace, (CGFloat[]){0.98, 0.98, 0.98, 1});
    CGColorRef endColor=CGColorCreate(colorSpace, (CGFloat[]){0.53, 0.53, 0.53, 0.16});
    CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault, (const void*[]){startColor,endColor}, 2, nil);
    CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, colorArray, NULL);
    CGPoint center=CGPointMake(viewWidth/3, viewHeight/2);
    CGContextDrawRadialGradient(context, gradient, center, viewHeight/2-offset, center, viewHeight/2, kCGGradientDrawsBeforeStartLocation);
    
    if (self.highlighted) {
        
        CGPoint lightCenter=CGPointMake(viewWidth/2, viewHeight/2);
        
        CGContextRestoreGState(context);
        CGContextDrawRadialGradient(context, gradient, lightCenter, viewHeight/2-offset, lightCenter, viewWidth/2, kCGGradientDrawsBeforeStartLocation);
    }
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self setNeedsDisplay];
}
@end

@implementation PauseButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
        offset=15;
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect{
    
    
    CGFloat viewWidth=self.bounds.size.width;
    CGFloat viewHeight=self.bounds.size.height;
    
    CGFloat rectWidth=5;
    CGFloat rectHeight=20;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    //画三角
    CGContextSaveGState(context);
    
    CGRect rectLeft=CGRectMake((viewWidth-3*rectWidth)/2, offset, rectWidth, rectHeight);
    CGRect rectRight=CGRectMake((viewWidth-3*rectWidth)/2+2*rectWidth, offset, rectWidth, rectHeight);
    CGContextAddRects(context, (const CGRect[]){rectLeft,rectRight}, 2);
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGContextFillPath(context);
    
    CGContextAddRects(context, (const CGRect[]){rectLeft,rectRight}, 2);
    CGContextClip(context);
    
    //渐变
    
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGColorRef startColor=CGColorCreate(colorSpace, (CGFloat[]){0.98, 0.98, 0.98, 1});
    CGColorRef endColor=CGColorCreate(colorSpace, (CGFloat[]){0.53, 0.53, 0.53, 0.26});
    CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault, (const void*[]){startColor,endColor}, 2, nil);
    CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, colorArray, NULL);
    CGPoint center=CGPointMake(viewWidth/3, offset);
    CGContextDrawRadialGradient(context, gradient, center, rectWidth/3, center, viewWidth/2, kCGGradientDrawsBeforeStartLocation);
    
    if (self.highlighted) {
        CGPoint lightCenter=CGPointMake(viewWidth/2, viewHeight/2);
        
        CGContextRestoreGState(context);
        CGContextDrawRadialGradient(context, gradient, lightCenter, rectWidth, lightCenter, viewWidth/2, kCGGradientDrawsBeforeStartLocation);
        
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self setNeedsDisplay];
}
@end

