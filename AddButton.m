//
//  AddButton.m
//  Quartz2DButton
//
//  Created by apple on 13-1-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "AddButton.h"

@implementation AddButton
@synthesize offset;
@synthesize lineWidth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
        offset=12;
        lineWidth=7;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGFloat viewWidth=self.bounds.size.width;
    CGFloat viewHeight=self.bounds.size.height;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    //画十字
    CGContextSaveGState(context);
    CGMutablePathRef path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, offset, viewHeight/2);
    CGPathAddRect(path, NULL, CGRectMake(offset, viewHeight/2-lineWidth/2, viewWidth-2*offset, lineWidth));
    CGPathAddRect(path, NULL, CGRectMake(viewWidth/2-lineWidth/2, offset, lineWidth, viewHeight-2*offset));
    
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
    CGContextDrawRadialGradient(context, gradient, center, lineWidth/2, center, lineWidth*4, kCGGradientDrawsBeforeStartLocation);
    */
    
    if (self.highlighted) {
        
        CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
        CGColorRef startColor=CGColorCreate(colorSpace, (CGFloat[]){0.98, 0.98, 0.98, 1});
        CGColorRef endColor=CGColorCreate(colorSpace, (CGFloat[]){0.53, 0.53, 0.53, 0.26});
        CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault, (const void*[]){startColor,endColor}, 2, nil);
        CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, colorArray, NULL);
        CGPoint center=CGPointMake(viewWidth/2, viewHeight/2);
        
        CGContextRestoreGState(context);
        CGContextDrawRadialGradient(context, gradient, center, viewWidth/10, center, viewWidth/2, kCGGradientDrawsBeforeStartLocation);
    }
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self setNeedsDisplay];
}
@end

