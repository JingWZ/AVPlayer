//
//  ButtonView.m
//  Quartz2DButton
//
//  Created by apple on 13-1-1.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ButtonView.h"

@implementation ButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initBarButtonWithTitle:(NSString *)title{
    if (self) {
        radiusOfArcs=5;
        lineOffset=3;
        lineWidth=2;
        textSize=20;
        textPointX=15;
        textPointY=15;
        buttonText=[NSString stringWithString:title];

        CGColorSpaceRef cs=CGColorSpaceCreateDeviceRGB();
        CGColorRef color=CGColorCreate(cs, (CGFloat[]){200/255.0, 200/255.0, 200/255.0, 1});
        fillColor=CGColorCreateCopy(color);
        
        CGColorSpaceRelease(cs);
        CGColorRelease(color);


    }
}

- (void)drawRect:(CGRect)rect{
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    CGContextSaveGState(context);

    lineColor=[[UIColor blackColor] CGColor];
    
    //填充灰色
    CGMutablePathRef path=CGPathCreateMutable();
    [self rectangleInPath:path WithWidth:self.bounds.size.width Height:self.bounds.size.height Radius:radiusOfArcs Offset:0];
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextFillPath(context);
    CGColorRelease(fillColor);
    CGPathRelease(path);
    
    //画黑边
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGMutablePathRef path2=CGPathCreateMutable();
    [self rectangleInPath:path2 WithWidth:self.bounds.size.width Height:self.bounds.size.height Radius:radiusOfArcs Offset:lineOffset];
    CGContextAddPath(context, path2);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, lineColor);
    CGContextStrokePath(context);
    CGPathRelease(path2);
    
    //写字
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextSelectFont(context, "Helvetica-Bold", textSize, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    const char *string=[buttonText cStringUsingEncoding:NSUTF8StringEncoding];
    size_t length=[buttonText lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    CGContextShowTextAtPoint(context, textPointX, textPointY, string, length);
    
    //渐变
    [self drawGradientInContext:context];
    
}

- (void)drawGradientInContext:(CGContextRef)context{
    
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGColorRef startColor=CGColorCreate(colorSpace, (CGFloat[]){0.98, 0.98, 0.98, 1});
    CGColorRef endColor=CGColorCreate(colorSpace, (CGFloat[]){244/255.0, 244/255.0, 244/255.0, 0.16});
    CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault, (const void*[]){startColor,endColor}, 2, nil);
    CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, colorArray, NULL);
    
    CFRelease(colorArray);
    CGColorRelease(startColor);
    CGColorRelease(endColor);
    CGColorSpaceRelease(colorSpace);
    
    CGMutablePathRef path3=CGPathCreateMutable();
    [self rectangleInPath:path3 WithWidth:self.bounds.size.width Height:self.bounds.size.height Radius:radiusOfArcs Offset:0];
    CGContextAddPath(context, path3);
    CGContextClip(context);
    CGPathRelease(path3);
    
    CGContextDrawRadialGradient(context, gradient, CGPointMake(self.bounds.size.width, self.bounds.size.height), 1, CGPointMake(self.bounds.size.width, self.bounds.size.height), self.bounds.size.height, kCGGradientDrawsAfterEndLocation);
    CGContextDrawRadialGradient(context, gradient, CGPointMake(0, 0), 1, CGPointMake(0,0), self.bounds.size.height/2, kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradient);

}

- (void)rectangleInPath:(CGMutablePathRef)path WithWidth:(CGFloat)width Height:(CGFloat)height Radius:(CGFloat)radius Offset:(CGFloat)offset{
    
    CGPathMoveToPoint(path, NULL, offset, offset+radius);
    CGPathAddArcToPoint(path, NULL, offset, offset, offset+radius, offset, radius);
    CGPathAddLineToPoint(path, NULL, width-radius-offset, offset);
    CGPathAddArcToPoint(path, NULL, width-offset, offset, width-offset, radius+offset, radius);
    CGPathAddLineToPoint(path, NULL, width-offset, height-radius-offset);
    CGPathAddArcToPoint(path, NULL, width-offset, height-offset, width-radius-offset, height-offset, radius);
    CGPathAddLineToPoint(path, NULL, radius+offset, height-offset);
    CGPathAddArcToPoint(path, NULL, offset, height-offset, offset, height-radius-offset, radius);
    CGPathAddLineToPoint(path, NULL, offset, offset+radius);
}

#pragma mark - settings

- (void)setRadiusOfArcs:(CGFloat)radius{
    radiusOfArcs=radius;
}

- (void)setLineOffset:(CGFloat)offset{
    lineOffset=offset;
}

- (void)setLineWidth:(CGFloat)width{
    lineWidth=width;
}

- (void)setFillColor:(CGColorRef)color{
    fillColor=CGColorCreateCopy(color);
}

- (void)setButtonText:(NSString *)text{
    buttonText=[NSString stringWithString:text];
}

- (void)setTextSize:(CGFloat)size{
    textSize=size;
}

- (void)setTextPointX:(CGFloat)x{
    textPointX=x;
}

- (void)setTextPointY:(CGFloat)y{
    textPointY=y;
}

@end
