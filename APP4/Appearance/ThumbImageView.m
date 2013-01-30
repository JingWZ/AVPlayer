//
//  ThumbImageView.m
//  APP4
//
//  Created by apple on 13-1-5.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//


#import "ThumbImageView.h"

@implementation ThumbImageView

- (UIImage *)getImage{
    [self setBackgroundColor:[UIColor clearColor]];
    UIImage *img=[UIImage imageWithView:self];
    return img;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    
    CGFloat width=self.bounds.size.width;
    CGFloat height=self.bounds.size.height;
    offset=10;
    
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGColorRef fillColor=CGColorCreate(colorSpace, (CGFloat[]){0.8, 0.8, 0.8, 1.0});
    CGColorRef lightColor=CGColorCreate(colorSpace, (CGFloat[]){1, 1, 1, 1.0});
    CGColorRef endColor=CGColorCreate(colorSpace, (CGFloat[]){1, 1, 1, 0.5});
    //CGColorRef shadowColor=CGColorCreate(colorSpace, (CGFloat[]){0, 0, 0, 0.7});
    
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    CGContextSaveGState(context);
    //CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 3, shadowColor);
    
    CGMutablePathRef pathCircle=CGPathCreateMutable();
    CGPathAddEllipseInRect(pathCircle, NULL, CGRectMake(offset, offset, width-2*offset, height-2*offset));
    CGContextAddPath(context, pathCircle);
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextFillPath(context);
    
    
    
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGContextAddPath(context, pathCircle);
    CGContextClip(context);
    CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault, (const void*[]){lightColor, endColor}, 2, nil);
    CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, colorArray, NULL);
    CGPoint center=CGPointMake(width/2, height/2);
    CGContextDrawRadialGradient(context, gradient, center, 1, center, width/2-offset, kCGGradientDrawsBeforeStartLocation);
    
    if (isHighlighted) {
        CGFloat shadowOffset=0;
        CGFloat shadowWidth=4;
        CGContextRestoreGState(context);
        
        CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 10, lightColor);
        
        CGMutablePathRef path1=CGPathCreateMutable();
        CGPathAddEllipseInRect(path1, NULL, CGRectMake(shadowOffset+shadowWidth, shadowOffset+shadowWidth, width-2*shadowOffset-2*shadowWidth, height-2*shadowOffset-2*shadowWidth));
        CGContextAddPath(context, path1);
        CGContextSetLineWidth(context, shadowWidth);
        CGContextSetStrokeColorWithColor(context, endColor);
        CGContextStrokePath(context);
        
    }
    
    
}

- (void)setHighlighted:(BOOL)highlight{
    isHighlighted=highlight;
}

@end

