//
//  CustomImageView.m
//  Quartz2DButton
//
//  Created by apple on 13-1-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CustomImageView.h"

@implementation CustomImageView
@synthesize imagePath;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        borderOffset=5;
        borderWidth=5;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{

//    UIImage *origin=[UIImage imageWithContentsOfFile:imagePath];
//    [origin drawInRect:CGRectMake(borderOffset+borderWidth, borderOffset+borderWidth, self.bounds.size.width-2*(borderOffset+borderWidth), 3/4*(self.bounds.size.width-2*(borderOffset+borderWidth)))];
    
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    //画边框
    [self drawBorderInContext:context];
    

}

- (void)drawBorderInContext:(CGContextRef)context{
    CGFloat awidth=self.bounds.size.width;
    CGFloat aheight=self.bounds.size.height;
    
    //边框阴影
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    CGMutablePathRef path1=CGPathCreateMutable();
    [self rectangleInPath:path1 WithWidth:awidth Height:aheight Radius:borderWidth Offset:borderOffset];
    CGContextAddPath(context, path1);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 5, [[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor]);
    CGContextSetLineWidth(context, borderWidth/2);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] CGColor]);
    CGContextStrokePath(context);
    
    
    
    //clip出边框
    CGMutablePathRef aPath=CGPathCreateMutable();
    [self rectangleInPath:aPath WithWidth:awidth Height:aheight Radius:borderWidth Offset:borderOffset];
    [self rectangleInPath:aPath WithWidth:awidth Height:aheight Radius:0 Offset:borderOffset+borderWidth];
    CGContextAddPath(context, aPath);
    CGContextEOClip(context);
    
    
    //画4个圆角
    CGContextDrawRadialGradient(context, [self gradient], CGPointMake(borderOffset+borderWidth, borderOffset+borderWidth), borderWidth, CGPointMake(borderOffset+borderWidth, borderOffset+borderWidth), 0.001, kCGGradientDrawsAfterEndLocation);
    CGContextDrawRadialGradient(context, [self gradient], CGPointMake(borderOffset+borderWidth, aheight-borderOffset-borderWidth), borderWidth, CGPointMake(borderOffset+borderWidth, aheight-borderOffset-borderWidth), 0.001, 0);
    CGContextDrawRadialGradient(context, [self gradient], CGPointMake(awidth-borderOffset-borderWidth, aheight-borderOffset-borderWidth), borderWidth, CGPointMake(awidth-borderOffset-borderWidth, aheight-borderOffset-borderWidth), 0.001, 0);
    CGContextDrawRadialGradient(context, [self gradient], CGPointMake(awidth-borderOffset-borderWidth, borderOffset+borderWidth), borderWidth, CGPointMake(awidth-borderOffset-borderWidth, borderOffset+borderWidth), 0.001, 0);
    
    
    //画4条直线
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGContextClipToRect(context, CGRectMake(borderOffset+borderWidth, borderOffset, awidth-2*borderOffset-2*borderWidth, borderWidth));
    CGContextDrawLinearGradient(context, [self gradient], CGPointMake(awidth/2, borderOffset), CGPointMake(awidth/2, borderWidth+borderOffset), kCGGradientDrawsBeforeStartLocation);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGContextClipToRect(context, CGRectMake(borderOffset, borderOffset+borderWidth, borderWidth, aheight-2*borderOffset-2*borderWidth));
    CGContextDrawLinearGradient(context, [self gradient], CGPointMake(borderOffset, aheight/2), CGPointMake(borderWidth+borderOffset, aheight/2), kCGGradientDrawsBeforeStartLocation);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGContextClipToRect(context, CGRectMake(borderOffset+borderWidth, aheight-borderOffset-borderWidth, awidth-2*borderOffset-2*borderWidth, borderWidth));
    CGContextDrawLinearGradient(context, [self gradient], CGPointMake(awidth/2, aheight-borderOffset), CGPointMake(awidth/2, aheight-borderOffset-borderWidth), kCGGradientDrawsBeforeStartLocation);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGContextClipToRect(context, CGRectMake(awidth-borderWidth-borderOffset, borderOffset+borderWidth, borderWidth, aheight-2*borderOffset-2*borderWidth));
    CGContextDrawLinearGradient(context, [self gradient], CGPointMake(awidth-borderOffset, aheight/2), CGPointMake(awidth-borderOffset-borderWidth, aheight/2), kCGGradientDrawsBeforeStartLocation);
    
//    //填充中心区域黑色
//    CGContextRestoreGState(context);
//    CGMutablePathRef path2=CGPathCreateMutable();
//    [self rectangleInPath:path2 WithWidth:awidth Height:aheight Radius:0 Offset:borderOffset+borderWidth];
//    CGContextAddPath(context, path2);
//    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
//    CGContextFillPath(context);
    
}

- (CGGradientRef)gradient{
    
    CGColorSpaceRef cs=CGColorSpaceCreateDeviceRGB();
    //42413C
    CGColorRef c1=CGColorCreate(cs, (CGFloat[]){66/255.0, 65/255.0, 60/255.0, 1});
    //DCDDDD
    CGColorRef c2=CGColorCreate(cs, (CGFloat[]){220/255.0, 221/255.0, 221/255.0, 1});
    //FFFFFF
    CGColorRef c3=CGColorCreate(cs, (CGFloat[]){255/255.0, 255/255.0, 255/255.0, 1});
    //BFC0C0
    CGColorRef c4=CGColorCreate(cs, (CGFloat[]){191/255.0, 192/255.0, 192/255.0, 1});
    //000000
    CGColorRef c5=CGColorCreate(cs, (CGFloat[]){0/255.0, 0/255.0, 0/255.0, 1});
    //898989
    CGColorRef c6=CGColorCreate(cs, (CGFloat[]){137/255.0, 137/255.0, 137/255.0, 1});
    //717171
    CGColorRef c7=CGColorCreate(cs, (CGFloat[]){113/255.0, 113/255.0, 113/255.0, 1});
    
    CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault,
                    (const void*[]){c1,c2,c3,c3,c4,c5,c6,c5,c7,c3,c5}, 11, nil);
    const CGFloat locations[]={0,0.06,0.12,0.39,0.54,0.66,0.75,0.80,0.90,0.95,1};
    
    CGGradientRef gradient=CGGradientCreateWithColors(cs, colorArray, locations);
    
    CFRelease(colorArray);
    CGColorRelease(c1);CGColorRelease(c2);CGColorRelease(c3);CGColorRelease(c4);CGColorRelease(c5);CGColorRelease(c6);CGColorRelease(c7);
    CGColorSpaceRelease(cs);
    
    return gradient;
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

- (void)setborderWidth:(CGFloat)width{
    borderWidth=width;
}

-(void)setBorderOffset:(CGFloat)offset{
    borderOffset=offset;
}

- (void)setCenterBackgroundColor:(CGColorRef)color{
    centerBackgroundColor=CGColorCreateCopy(color);
}


@end
