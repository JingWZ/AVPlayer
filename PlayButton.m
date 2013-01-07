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
    CGFloat width=self.bounds.size.width;
    CGFloat height=self.bounds.size.height;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    //画三角
    CGContextSaveGState(context);
    CGMutablePathRef path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, width/3, offset);
    CGPathAddLineToPoint(path, NULL, width/3, height-offset);
    CGPathAddLineToPoint(path, NULL, width/3*2, height/2);
    CGPathCloseSubpath(path);
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGContextFillPath(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    //渐变
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGColorRef startColor=CGColorCreate(colorSpace, (CGFloat[]){0.98, 0.98, 0.98, 1});
    CGColorRef endColor=CGColorCreate(colorSpace, (CGFloat[]){0.53, 0.53, 0.53, 0.26});
    CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault, (const void*[]){startColor,endColor}, 2, nil);
    CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, colorArray, NULL);
    CGPoint center=CGPointMake(width/3, height/2);
    CGContextDrawRadialGradient(context, gradient, center, 5, center, width/2, kCGGradientDrawsBeforeStartLocation);
    
    if (self.highlighted) {
        
        CGFloat shadowOffset=0;
        CGFloat shadowWidth=5;
        CGContextRestoreGState(context);
        CGColorRef shadowColor=CGColorCreate(colorSpace, (CGFloat[]){0.98, 0.98, 0.98, 0.7});
        
        CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 5, shadowColor);
        
        CGMutablePathRef path1=CGPathCreateMutable();
        CGPathAddEllipseInRect(path1, NULL, CGRectMake(shadowOffset+shadowWidth, shadowOffset+shadowWidth, width-2*shadowOffset-2*shadowWidth, height-2*shadowOffset-2*shadowWidth));
        CGContextAddPath(context, path1);
        CGContextSetLineWidth(context, shadowWidth);
        CGContextSetStrokeColorWithColor(context, shadowColor);
        CGContextStrokePath(context);
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
    
    
    CGFloat width=self.bounds.size.width;
    CGFloat height=self.bounds.size.height;
    
    CGFloat rectWidth=5;
    CGFloat rectHeight=20;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    //画三角
    CGContextSaveGState(context);
    
    CGRect rectLeft=CGRectMake((width-3*rectWidth)/2, offset, rectWidth, rectHeight);
    CGRect rectRight=CGRectMake((width-3*rectWidth)/2+2*rectWidth, offset, rectWidth, rectHeight);
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
    CGPoint center=CGPointMake(width/3, offset);
    CGContextDrawRadialGradient(context, gradient, center, 9, center, width/2, kCGGradientDrawsBeforeStartLocation);
    
    if (self.highlighted) {
        
        CGFloat shadowOffset=0;
        CGFloat shadowWidth=5;
        CGContextRestoreGState(context);
        CGColorRef shadowColor=CGColorCreate(colorSpace, (CGFloat[]){0.98, 0.98, 0.98, 0.7});
        
        CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 5, shadowColor);
        
        CGMutablePathRef path1=CGPathCreateMutable();
        CGPathAddEllipseInRect(path1, NULL, CGRectMake(shadowOffset+shadowWidth, shadowOffset+shadowWidth, width-2*shadowOffset-2*shadowWidth, height-2*shadowOffset-2*shadowWidth));
        CGContextAddPath(context, path1);
        CGContextSetLineWidth(context, shadowWidth);
        CGContextSetStrokeColorWithColor(context, shadowColor);
        CGContextStrokePath(context);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self setNeedsDisplay];
}
@end

