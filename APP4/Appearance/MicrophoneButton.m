//
//  MicrophoneButton.m
//  Quartz2DButton
////////////////////
//  Created by apple on 13-1-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "MicrophoneButton.h"
#define kMovingFastest 4
#define kMovingSlowest 16

@interface MicrophoneButton (){
    
    CGFloat viewHeight;
    CGFloat viewWidth;
    CGFloat centerYOfBottom;
    CGFloat centerYOfTop;
    CGFloat radiusSmall;
    CGFloat radiusBig;
    CGFloat bottomHeight;
    CGFloat topBottomDistance;
    CGFloat movingPosition;
    CGFloat movingMinPosition;
    CGFloat movingMaxPosition;
    NSInteger movingReverse;
}

@end

@implementation MicrophoneButton
@synthesize offset;
@synthesize microphoneLineWidth;
@synthesize microphoneLineColor;
@synthesize mainPhoneSize;
@synthesize distanceBetweenPhoneAndHolder;
@synthesize holderExtendingLength;
@synthesize verticalLineLength;
@synthesize horizontalLineLength;

@synthesize colorType;
@synthesize glowingType;
@synthesize colorReverse;
@synthesize currentValueRate, colorCount;

@synthesize movingSpeedRate;
@synthesize moving;
@synthesize movingPointColor;
@synthesize movingPointSize;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        offset=5;
        viewWidth=self.bounds.size.width;
        viewHeight=self.bounds.size.height;
        microphoneLineWidth=2;
        mainPhoneSize.width=viewWidth/7;
        mainPhoneSize.height=viewHeight/2;
        distanceBetweenPhoneAndHolder=mainPhoneSize.width/2;
        verticalLineLength=viewHeight/10;
        horizontalLineLength=mainPhoneSize.width;
        microphoneLineColor=[UIColor blackColor];
        holderExtendingLength=0;
        
        colorType=kColorTypeYellowToRed;
        glowingType=kGlowingDefault;
        colorReverse=NO;
        colorCount=50;
        currentValueRate=0.0;
        movingPosition=0.0;
        moving=NO;
        movingSpeedRate=1;
        movingReverse=1;
        movingPointSize=10;
        movingPointColor=[UIColor redColor];
        
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"currentValueRate" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    
    centerYOfBottom=2.0/2.9*viewHeight-mainPhoneSize.width;
    centerYOfTop=2.0/3*viewHeight-mainPhoneSize.height+mainPhoneSize.width;
    radiusSmall=mainPhoneSize.width;
    radiusBig=mainPhoneSize.width+distanceBetweenPhoneAndHolder;
    bottomHeight=viewHeight-microphoneLineWidth*2;
    topBottomDistance=centerYOfBottom-centerYOfTop+2*radiusSmall;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [self drawMicrophoneInContext:context];
    [self fillMicrophoneInContext:context];
    
    
    if (moving) {
        [self movingThroughHolderInContext:context];
    }
    
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

- (void)drawMicrophoneInContext:(CGContextRef)context{
    
    CGMutablePathRef path=CGPathCreateMutable();
    //下面的小半圆
    CGPathAddArc(path, NULL, viewWidth/2, centerYOfBottom, radiusSmall, 0, M_PI, NO);
    CGPathAddLineToPoint(path, NULL, viewWidth/2-radiusSmall, centerYOfTop);
    //上面的小半圆
    CGPathAddArc(path, NULL, viewWidth/2, centerYOfTop, radiusSmall, M_PI, 2*M_PI, NO);
    CGPathAddLineToPoint(path, NULL, viewWidth/2+radiusSmall, centerYOfBottom);
    //下面的大半圆
    CGPathMoveToPoint(path, NULL, viewWidth/2+radiusBig, centerYOfBottom-holderExtendingLength);
    CGPathAddLineToPoint(path, NULL, viewWidth/2+radiusBig, centerYOfBottom);
    CGPathAddArc(path, NULL, viewWidth/2, centerYOfBottom, radiusBig, 0, M_PI, NO);
    CGPathAddLineToPoint(path, NULL, viewWidth/2-radiusBig, centerYOfBottom-holderExtendingLength);
    CGFloat angle=atan(holderExtendingLength/(viewWidth/2.0));
    if (!moving) {
        movingMaxPosition=2*M_PI+angle;
        movingMinPosition=M_PI-angle;
        movingPosition=movingMinPosition;
    }
    
    //竖线
    CGPathMoveToPoint(path, NULL, viewWidth/2, centerYOfBottom+radiusBig);
    CGPathAddLineToPoint(path, NULL, viewWidth/2, bottomHeight);
    //横线
    CGPathMoveToPoint(path, NULL, viewWidth/2-radiusSmall, bottomHeight);
    CGPathAddLineToPoint(path, NULL, viewWidth/2+radiusSmall, bottomHeight);
    //
    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, microphoneLineWidth);
    CGContextSetStrokeColorWithColor(context, [microphoneLineColor CGColor]);
    CGContextStrokePath(context);
    
    CGPathRelease(path);
    
}

- (void)fillMicrophoneInContext:(CGContextRef)context{
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    //fill the main microphone ellipse
    CGMutablePathRef path1=CGPathCreateMutable();

    //bottom half-circle
    CGPathAddArc(path1, NULL, viewWidth/2, centerYOfBottom, radiusSmall-microphoneLineWidth/2, 0, M_PI, NO);
    CGPathAddLineToPoint(path1, NULL, viewWidth/2-radiusSmall+microphoneLineWidth/2, centerYOfTop);
    //top half-circle
    CGPathAddArc(path1, NULL, viewWidth/2, centerYOfTop, radiusSmall-microphoneLineWidth/2, M_PI, 2*M_PI, NO);
    CGPathAddLineToPoint(path1, NULL, viewWidth/2+radiusSmall-microphoneLineWidth/2, centerYOfBottom);
    //clip the ellipse
    CGContextAddPath(context, path1);
    CGContextClip(context);
    CGPathRelease(path1);

    

    //synchronize the fill height according to the changing value
    if (currentValueRate>1 || currentValueRate<0) {
        currentValueRate=1;
    }
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    int currentValue=(int)(currentValueRate*colorCount);
    for (int i=0; i<=currentValue; i++) {
        
        CGFloat value=1.0/colorCount*i;
        CGFloat greenColorValue=1.0-value;
        if (colorReverse) {
            greenColorValue=value;
        }
        
        CGColorRef color=nil;
        switch (colorType) {
            case 0: //yellow->red
                color=CGColorCreate(colorSpace, (CGFloat[]){1, greenColorValue, 0, 1});
                break;
            case 1: //cyan->blue
                color=CGColorCreate(colorSpace, (CGFloat[]){0, greenColorValue, 1, 1});
                break;
            default:
                color=CGColorCreate(colorSpace, (CGFloat[]){1, greenColorValue, 0, 1});
                break;
        }
        
        //filling seperate rect
        CGFloat rectY=centerYOfBottom+radiusSmall-topBottomDistance/colorCount*i;
        CGFloat rectX=viewWidth/2-radiusSmall-microphoneLineWidth;
        CGContextSetFillColorWithColor(context, color);
        CGContextFillRect(context, CGRectMake(rectX, rectY, 2*radiusSmall+microphoneLineWidth, topBottomDistance/colorCount+1));
        
        
        //set gleaming in the fill top
        if (i && i==currentValue) {
            CGColorRef endColor=CGColorCreate(colorSpace, (CGFloat[]){1, 1, 1, 0.1});
            CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault, (const void*[]){color,endColor}, 2, nil);
            CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, colorArray, NULL);
            switch (glowingType) {
                case 0:
                    if (currentValueRate==1) {
                        currentValueRate=0;
                        break;
                    }
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(viewWidth/2, rectY), CGPointMake(viewWidth/2, rectY-viewHeight/10), kCGGradientDrawsBeforeStartLocation);
                    break;
                case 1:
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(viewWidth/2, rectY), CGPointMake(viewWidth/2, rectY-viewHeight/10), kCGGradientDrawsAfterEndLocation);
                default:
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(viewWidth/2, rectY), CGPointMake(viewWidth/2, rectY-viewHeight/10), kCGGradientDrawsBeforeStartLocation);
                    break;
            }
         
            CFRelease(colorArray);
            CGGradientRelease(gradient);
            CGColorRelease(endColor);
         
        }
         
        CGColorRelease(color);
    }
    CGColorSpaceRelease(colorSpace);
    
}

- (void)movingThroughHolderInContext:(CGContextRef)context{

    CGFloat pointY=0;
    CGFloat pointX=0;
    
    if (movingPosition>movingMaxPosition) {
        movingPosition=movingMinPosition;
        movingReverse=-movingReverse;
        pointX=viewWidth/2-movingReverse*radiusBig;
        pointY=centerYOfBottom-holderExtendingLength;
    }else if (movingPosition<=M_PI) {
        pointX=viewWidth/2-movingReverse*radiusBig;
        pointY=centerYOfBottom-tan(movingPosition)*radiusBig;
    }else if (M_PI<movingPosition<=2*M_PI){
        pointX=viewWidth/2+movingReverse*cos(movingPosition)*radiusBig;
        pointY=centerYOfBottom-sin(movingPosition)*radiusBig;
    }else if (2*M_PI<movingPosition<movingMaxPosition){
        pointX=viewWidth/2+movingReverse*radiusBig;
        pointY=centerYOfBottom-tan(movingPosition)*radiusBig;
    }

    if (movingSpeedRate>1 || movingSpeedRate<0) {
        movingSpeedRate=1;
    }
    CGFloat singleAngle=M_PI/( (kMovingSlowest-kMovingFastest)*movingSpeedRate+kMovingFastest);
    CGFloat a=movingPosition+singleAngle;
    movingPosition=a;
        
    CGContextRestoreGState(context);
    CGContextSaveGState(context);

    CGFloat r,g,b=0;
    
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGColorRef startColor=CGColorCreateCopy([movingPointColor CGColor]);
    [movingPointColor getRed:&r green:&g blue:&b alpha:nil];
    CGColorRef secondColor=CGColorCreate(colorSpace, (CGFloat[]){r, g, b, 0.46});
    CGColorRef thirdColor=CGColorCreate(colorSpace, (CGFloat[]){1, 1, 1, 0.86});
    CGColorRef endColor=CGColorCreate(colorSpace, (CGFloat[]){1, 1, 1, 0.46});
    const CGFloat locations[]={0,0.2,0.4,1};
    CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault, (const void*[]){startColor, secondColor, thirdColor, endColor}, 4, nil);
    CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, colorArray, locations);
    
    CGContextDrawRadialGradient(context, gradient, CGPointMake(pointX, pointY), movingPointSize/4, CGPointMake(pointX, pointY), movingPointSize, kCGGradientDrawsBeforeStartLocation);
    
    CGColorRelease(startColor);
    CGColorRelease(secondColor);
    CGColorRelease(thirdColor);
    CGColorRelease(endColor);
    CGColorSpaceRelease(colorSpace);
    CFRelease(colorArray);
    CGGradientRelease(gradient);

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

        [self setNeedsDisplay];
    
    
}


@end
