//
//  ForwardButton.m
//  QuartzButton
//
//  Created by apple on 13-1-29.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "ForwardButton.h"

@implementation ForwardButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    
    [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    
    offset=12;
    
    CGFloat viewWidth=self.bounds.size.width;
    CGFloat viewHeight=self.bounds.size.height;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    //画三角
    CGContextSaveGState(context);
    CGMutablePathRef path=CGPathCreateMutable();
    //左三角
    CGPathMoveToPoint(path, NULL, offset, offset);
    CGPathAddLineToPoint(path, NULL, offset, viewHeight-offset);
    CGPathAddLineToPoint(path, NULL, viewWidth/2.0,viewHeight/2.0);
    CGPathCloseSubpath(path);
    //右三角
    CGPathMoveToPoint(path, NULL, viewWidth/2.0, offset);
    CGPathAddLineToPoint(path, NULL, viewWidth/2.0, viewHeight-offset);
    CGPathAddLineToPoint(path, NULL, viewWidth-offset, viewHeight/2.0);
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
    CGPoint center=CGPointMake(viewWidth/2, viewHeight/2);
    CGContextDrawRadialGradient(context, gradient, center, viewHeight/2-offset, center, viewHeight/2, kCGGradientDrawsBeforeStartLocation);
    
    if (self.highlighted) {
        
        CGPoint lightCenter=CGPointMake(viewWidth/2, viewHeight/2);
        
        CGContextRestoreGState(context);
        CGContextDrawRadialGradient(context, gradient, lightCenter, viewHeight/4.0, lightCenter, viewWidth/2, kCGGradientDrawsBeforeStartLocation);
    }
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self setNeedsDisplay];
}

@end
