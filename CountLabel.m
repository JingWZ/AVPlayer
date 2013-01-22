//
//  CountLabel.m
//  APP4
//
//  Created by apple on 13-1-8.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//

#import "CountLabel.h"

@implementation CountLabel

@synthesize offset;
@synthesize lineWidth;
@synthesize textSize;
@synthesize textPointX,textPointY;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        offset=5;
        lineWidth=2;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    
    CGFloat width=self.bounds.size.width;
    CGFloat height=self.bounds.size.height;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSaveGState(context);
    
    //渐变
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGColorRef startColor=CGColorCreate(colorSpace, (CGFloat[]){0.98, 0.98, 0.98, 0.8});
    CGColorRef endColor=CGColorCreate(colorSpace, (CGFloat[]){244/255.0, 244/255.0, 244/255.0, 0.16});
    CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault, (const void*[]){startColor,endColor}, 2, nil);
    CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, colorArray, NULL);
    
    //填充
    CGMutablePathRef path1=CGPathCreateMutable();
    CGPathAddEllipseInRect(path1, NULL, self.bounds);
    CGContextAddPath(context, path1);
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGContextFillPath(context);
    
    //描边
    CGMutablePathRef path2=CGPathCreateMutable();
    CGPathAddEllipseInRect(path2, NULL, CGRectMake(offset, offset, self.bounds.size.width-2*offset, self.bounds.size.height-2*offset));
    CGContextAddPath(context, path2);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetLineWidth(context, lineWidth);
    CGContextStrokePath(context);
    
    //
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGContextAddPath(context, path1);
    CGContextClip(context);
    CGPoint center=CGPointMake(width/2, height/3);
    CGContextDrawRadialGradient(context, gradient, center, 5, center, width/2, kCGGradientDrawsBeforeStartLocation);
    
    //写字
    CGContextRestoreGState(context);
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextSelectFont(context, "Helvetica-Bold", textSize, kCGEncodingMacRoman);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    const char *string=[self.text cStringUsingEncoding:NSUTF8StringEncoding];
    size_t length=[self.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    CGContextShowTextAtPoint(context, textPointX, textPointY, string, length);
    //

    
}

- (void)setTextPointX:(CGFloat)x pointY:(CGFloat)y{
    textPointX=x;
    textPointY=y;
}

@end
