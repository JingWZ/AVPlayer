//
//  MultipleTrackSlider.m
//  MultipleTrackSliderDemo
//
//  Created by apple on 13-1-30.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "MultipleTrackSlider.h"

#define kForBackBtnWidth 30.0

@implementation MultipleTrackSlider{
    CGFloat minValue;
    CGFloat maxValue;
    CGFloat totalValue;
    
    BOOL latchLeft;
    BOOL latchRight;
    BOOL latchMiddle;
    
    CGRect sideRect;
    CGRect middleRect;
    
    
}


@synthesize barRect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame leftValue:(CGFloat)left rightValue:(CGFloat)right middleValue:(CGFloat)middle scale:(CGFloat)scale{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        barRect=CGRectMake(0, 70, frame.size.width, 20);
        
        sideRect=CGRectMake(0, 40, 70, 20);
        middleRect=CGRectMake(0, 20, 70, 20);
        
        self.scale=scale;
                
        self.leftValue=left;
        self.rightValue=right;
        self.middleValue=middle;
        
        [self initValuesByLeft:left right:right];
        
        [self initTracks];
        [self initLabels];
        
        }
    return self;
}

- (void)initTracks{
    
    if (!self.leftTrackView) {
        self.leftTrackView=[[UIView alloc] initWithFrame:CGRectMake(20, barRect.origin.y, barRect.size.height, barRect.size.height)];
        [self.leftTrackView setBackgroundColor:[UIColor blackColor]];
        [self.leftTrackView setUserInteractionEnabled:NO];
        [self addSubview:self.leftTrackView];
    }
    
    if (!self.rightTrackView) {
        //init right track
        self.rightTrackView=[[UIView alloc] initWithFrame:CGRectMake(200, barRect.origin.y, barRect.size.height, barRect.size.height)];
        [self.rightTrackView setBackgroundColor:[UIColor blackColor]];
        [self.rightTrackView setUserInteractionEnabled:NO];
        [self addSubview:self.rightTrackView];
    }
    
    if (!self.middleTrackView) {
        //init middle track
        self.middleTrackView=[[UIView alloc] initWithFrame:CGRectMake(80, barRect.origin.y, barRect.size.height, barRect.size.height)];
        [self.middleTrackView setBackgroundColor:[UIColor redColor]];
        [self.middleTrackView setUserInteractionEnabled:NO];
        [self addSubview:self.middleTrackView];
    }
    
    [self updateTracksPosition];
}

- (void)initLabels{
    
    if (!self.leftLbl) {
        self.leftLbl=[[UILabel alloc] initWithFrame:sideRect];
        [self.leftLbl setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.leftLbl];
    }
    
    if (!self.rightLbl) {
        self.rightLbl=[[UILabel alloc] initWithFrame:sideRect];
        [self.rightLbl setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.rightLbl];

    }
    
    if (!self.middleLbl) {
        self.middleLbl=[[UILabel alloc] initWithFrame:middleRect];
        [self.middleLbl setTextColor:[UIColor redColor]];
        [self.middleLbl setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.middleLbl];

    }
    
    [self updateLabelsPosition];
}


/*
- (void)initForBackBtns{
    
    //init forward button
    self.forwardBtn=[[ForwardButton alloc] initWithFrame:CGRectMake(0, 0, kForBackBtnWidth, kForBackBtnWidth)];
    [self.forwardBtn setOffset:5.0];
    [self.forwardBtn addTarget:self action:@selector(forwardBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.forwardBtn];
    [self.forwardBtn setHidden:YES];
    
    //init backward button
    self.backwardBtn=[[BackwardButton alloc] initWithFrame:CGRectMake(0, 0, kForBackBtnWidth, kForBackBtnWidth)];
    [self.backwardBtn setOffset:5.0];
    [self.backwardBtn addTarget:self action:@selector(backwardBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backwardBtn];
    [self.backwardBtn setHidden:YES];
    
}
 
 */

- (void)initValuesByLeft:(CGFloat)left right:(CGFloat)right{

    totalValue=(right-left)*self.scale;
    CGFloat offset=(totalValue-(right-left))/2.0;
    
    minValue=left-offset;
    maxValue=right+offset;
    
    minValue = minValue>0 ? minValue : 0 ;
}

- (void)updateScale:(NSInteger)scale{
    
    self.scale=scale;
    [self initValuesByLeft:self.leftValue right:self.rightValue];
    [self initTracks];
    [self initLabels];
    
    [self setNeedsDisplay];
}

#pragma mark - touch

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if (latchLeft || latchRight || latchMiddle) {
        
        [self.leftTrackView setBackgroundColor:[UIColor blackColor]];
        [self.middleTrackView setBackgroundColor:[UIColor redColor]];
        [self.rightTrackView setBackgroundColor:[UIColor blackColor]];
    }
    
    //clear last touch info
    latchLeft=NO;
    latchRight=NO;
    latchMiddle=NO;
    
    
    CGPoint touchPoint = [touch locationInView:self];
    
    if ( CGRectContainsPoint(self.leftTrackView.frame, touchPoint) ) {
		latchLeft=YES;
	}
	else if ( CGRectContainsPoint(self.rightTrackView.frame, touchPoint) ) {
		latchRight=YES;
	}
    else if ( CGRectContainsPoint(self.middleTrackView.frame, touchPoint)) {
        latchMiddle=YES;
    }
    
    [self updateTrackView];
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
	CGPoint touchPoint = [touch locationInView:self];
    
    //NSLog(@"tPoint(%f,%f)", touchPoint.x,barRect.origin.x);
    
	if ( latchLeft || CGRectContainsPoint(self.leftTrackView.frame, touchPoint) ) {
        
        latchLeft=YES;
        
        //从bar的左边原点x--》右边的track的中点x
        if (touchPoint.x<self.rightTrackView.center.x && touchPoint.x>=barRect.origin.x) {
            self.leftTrackView.center=CGPointMake(touchPoint.x, self.leftTrackView.center.y );
            if (self.leftTrackView.center.x>self.middleTrackView.center.x) {
                self.middleTrackView.center=CGPointMake(self.leftTrackView.center.x, self.middleTrackView.center.y);
            }
        }
        
        //小于bar的左边原点
        else if (touchPoint.x<barRect.origin.x){
            self.leftTrackView.center=CGPointMake(barRect.origin.x, self.leftTrackView.center.y );
        }
        
        //大于右边的track的中点x
        else if (touchPoint.x>self.rightTrackView.center.x){
            latchLeft=NO;
            latchRight=YES;
        }
	}
	
	else if (latchRight || CGRectContainsPoint(self.rightTrackView.frame, touchPoint)){
        
        latchRight=YES;
        
        //左边的track的中点x--》bar的右边原点x
        if (touchPoint.x>self.leftTrackView.center.x && touchPoint.x<=(barRect.origin.x+barRect.size.width)) {
            self.rightTrackView.center=CGPointMake(touchPoint.x, self.rightTrackView.center.y);
            if (self.rightTrackView.center.x<self.middleTrackView.center.x) {
                self.middleTrackView.center=CGPointMake(self.rightTrackView.center.x, self.middleTrackView.center.y);
            }
        }
        
        //大于bar的右边原点
        else if (touchPoint.x>(barRect.origin.x+barRect.size.width)){
            self.rightTrackView.center=CGPointMake(barRect.origin.x+barRect.size.width, self.rightTrackView.center.y);
        }
        
        //小于左边的track的中点x
        else if (touchPoint.x<self.leftTrackView.center.x){
            latchRight=NO;
            latchLeft=YES;
        }
        
    }
    
    else if (latchMiddle || CGRectContainsPoint(self.middleTrackView.frame, touchPoint)){
        
        latchMiddle=YES;
        
        //左边的track的中点x--》右边的track的中点x
        if (touchPoint.x>=self.leftTrackView.center.x && touchPoint.x<=self.rightTrackView.center.x) {
            self.middleTrackView.center=CGPointMake(touchPoint.x, self.middleTrackView.center.y);
        }
        
        //小于左边的track的中点x
        else if (touchPoint.x<self.leftTrackView.center.x){
            self.middleTrackView.center=CGPointMake(self.leftTrackView.center.x, self.middleTrackView.center.y);
            latchMiddle=NO;
            latchLeft=YES;
        }
        
        //大于右边的track的中点x
        else if (touchPoint.x>self.rightTrackView.center.x){
            self.middleTrackView.center=CGPointMake(self.rightTrackView.center.x, self.middleTrackView.center.y);
            latchMiddle=NO;
            latchRight=YES;
        }
        
        
    }
    
    
    
    [self setNeedsDisplay];
    [self updateValues];
    [self updateLabelsPosition];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
	//redraw
	//[self setNeedsDisplay];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    
}

#pragma mark - action

/*
- (void)forwardBtnPressed{
    
    if (latchLeft) {
        self.leftValue=self.leftValue+forBackWardScale;
        if (self.leftValue<minValue) self.leftValue=minValue;
        if (self.leftValue>maxValue-forBackWardScale) self.leftValue=maxValue-forBackWardScale;
        if (self.leftValue>self.rightValue) self.rightValue=self.leftValue+forBackWardScale;
        if (self.leftValue>self.middleValue) self.middleValue=self.leftValue;
        
    }
    if (latchRight) {
        self.rightValue=self.rightValue+forBackWardScale;
        if (self.rightValue<minValue+forBackWardScale) self.rightValue=minValue+forBackWardScale;
        if (self.rightValue>maxValue) self.rightValue=maxValue;
        if (self.rightValue<self.leftValue) self.leftValue=self.rightValue-forBackWardScale;
        if (self.rightValue<self.middleValue) self.middleValue=self.rightValue;
    }
    if (latchMiddle) {
        self.middleValue=self.middleValue+forBackWardScale;
        if (self.middleValue<minValue) self.middleValue=minValue;
        if (self.middleValue>maxValue) self.middleValue=maxValue;
        if (self.middleValue<self.leftValue) self.leftValue=self.middleValue;
        if (self.middleValue>self.rightValue) self.rightValue=self.middleValue;
    }
    
    [self updateTracksPosition];
    [self setNeedsDisplay];
}

- (void)backwardBtnPressed{
    
    if (latchLeft) {
        self.leftValue=self.leftValue-forBackWardScale;
        if (self.leftValue<minValue) self.leftValue=minValue;
        if (self.leftValue>maxValue-forBackWardScale) self.leftValue=maxValue-forBackWardScale;
        if (self.leftValue>self.rightValue) self.rightValue=self.leftValue+forBackWardScale;
        if (self.leftValue>self.middleValue) self.middleValue=self.leftValue;
        
    }
    if (latchRight) {
        self.rightValue=self.rightValue-forBackWardScale;
        if (self.rightValue<minValue+forBackWardScale) self.rightValue=minValue+forBackWardScale;
        if (self.rightValue>maxValue) self.rightValue=maxValue;
        if (self.rightValue<self.leftValue) self.leftValue=self.rightValue-forBackWardScale;
        if (self.rightValue<self.middleValue) self.middleValue=self.rightValue;
    }
    if (latchMiddle) {
        self.middleValue=self.middleValue-forBackWardScale;
        if (self.middleValue<minValue) self.middleValue=minValue;
        if (self.middleValue>maxValue) self.middleValue=maxValue;
        if (self.middleValue<self.leftValue) self.leftValue=self.middleValue;
        if (self.middleValue>self.rightValue) self.rightValue=self.middleValue;
    }
    
    [self updateTracksPosition];
    [self setNeedsDisplay];
    
}
 
 */



#pragma mark - update values

- (void)updateValues{
    
    self.leftValue=minValue+(self.leftTrackView.center.x-barRect.origin.x)/barRect.size.width*totalValue;
    self.rightValue=minValue+(self.rightTrackView.center.x-barRect.origin.x)/barRect.size.width*totalValue;
    self.middleValue=minValue+(self.middleTrackView.center.x-barRect.origin.x)/barRect.size.width*totalValue;
    
    //NSLog(@"left:%f,middle:%f,right:%f", self.leftValue, self.middleValue, self.rightValue);
    
}

- (void)updateTracksPosition{
    
    self.leftTrackView.center=CGPointMake((self.leftValue-minValue)/totalValue*barRect.size.width+barRect.origin.x, self.leftTrackView.center.y);
    self.rightTrackView.center=CGPointMake((self.rightValue-minValue)/totalValue*barRect.size.width+barRect.origin.x, self.rightTrackView.center.y);
    self.middleTrackView.center=CGPointMake((self.middleValue-minValue)/totalValue*barRect.size.width+barRect.origin.x, self.middleTrackView.center.y);
}

- (void)updateLabelsPosition{
    
    NSString *leftText=[NSString stringWithFormat:@"%.2f", self.leftValue];
    NSString *rightText=[NSString stringWithFormat:@"%.2f", self.rightValue];
    NSString *middleText=[NSString stringWithFormat:@"%.2f", self.middleValue];
    
    [self.leftLbl setText:leftText];
    [self.rightLbl setText:rightText];
    [self.middleLbl setText:middleText];
    
    self.leftLbl.center=CGPointMake(self.leftTrackView.center.x-self.leftLbl.bounds.size.width/2.0, sideRect.origin.y);
    self.rightLbl.center=CGPointMake(self.rightTrackView.center.x+self.rightLbl.bounds.size.width/2.0, sideRect.origin.y);
    self.middleLbl.center=CGPointMake(self.middleTrackView.center.x, middleRect.origin.y);
}



#pragma mark - appearance

- (void)updateTrackView{
    if (latchLeft) {
        [self.leftTrackView setBackgroundColor:[UIColor greenColor]];
        
    }else if (latchRight) {
        [self.rightTrackView setBackgroundColor:[UIColor greenColor]];
        
    }else if (latchMiddle){
        [self.middleTrackView setBackgroundColor:[UIColor greenColor]];
        
    }
}

- (void)drawRect:(CGRect)rect{
    
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGColorRef barColor=CGColorCreate(colorSpace, (CGFloat[]){150/255.0, 150/255.0, 150/255.0, 1});
    CGColorRef valueColor=CGColorCreate(colorSpace, (CGFloat[]){240/255.0, 240/255.0, 240/255.0, 1});
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, barColor);
    CGContextFillRect(context, barRect);
    
    CGContextRestoreGState(context);
    CGRect valueRect=CGRectMake(self.leftTrackView.center.x, barRect.origin.y, (self.rightTrackView.center.x-self.leftTrackView.center.x), barRect.size.height);
    CGContextSetFillColorWithColor(context, valueColor);
    CGContextFillRect(context, valueRect);
    
    CGColorSpaceRelease(colorSpace);
    CGColorRelease(barColor);
    CGColorRelease(valueColor);
    
    
}

@end
