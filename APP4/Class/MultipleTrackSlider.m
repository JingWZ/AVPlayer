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
}


@synthesize barRect;
@synthesize forBackWardScale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame minValue:(CGFloat)min maxValue:(CGFloat)max{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        barRect=CGRectMake(20, frame.size.height-70, frame.size.width-40, 15);
        forBackWardScale=0.1;
        
        [self setMinValue:min maxValue:max];
        [self initTracks];
        [self initForBackBtns];
        
        self.pinGesture=[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinGestureTouched:)];
        [self addGestureRecognizer:self.pinGesture];
        
        
    }
    return self;
}

- (void)initTracks{
    //init left track
    self.leftTrackView=[[UIView alloc] initWithFrame:CGRectMake(20, barRect.origin.y, barRect.size.height, barRect.size.height)];
    [self.leftTrackView setBackgroundColor:[UIColor blackColor]];
    [self.leftTrackView setUserInteractionEnabled:NO];
    [self addSubview:self.leftTrackView];
    
    //init right track
    self.rightTrackView=[[UIView alloc] initWithFrame:CGRectMake(200, barRect.origin.y, barRect.size.height, barRect.size.height)];
    [self.rightTrackView setBackgroundColor:[UIColor blackColor]];
    [self.rightTrackView setUserInteractionEnabled:NO];
    [self addSubview:self.rightTrackView];
    
    //init middle track
    self.middleTrackView=[[UIView alloc] initWithFrame:CGRectMake(80, barRect.origin.y, barRect.size.height, barRect.size.height)];
    [self.middleTrackView setBackgroundColor:[UIColor redColor]];
    [self.middleTrackView setUserInteractionEnabled:NO];
    [self addSubview:self.middleTrackView];
    
}

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

- (void)setMinValue:(CGFloat)min maxValue:(CGFloat)max{
    minValue = min>max ? max : min ;
    maxValue = min>max ? min : max ;
    totalValue=maxValue-minValue;
}


#pragma mark - touch

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
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
    
    
    [self.backwardBtn setHidden:YES];
    [self.forwardBtn setHidden:YES];
    //[self updateTrackView];
    
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
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
	//redraw
	//[self setNeedsDisplay];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    if (latchLeft || latchMiddle || latchRight) {
        
        CGFloat forBackWardCenterPoint=0.0;
        
        if (latchLeft) forBackWardCenterPoint=self.leftTrackView.center.x;
        if (latchRight) forBackWardCenterPoint=self.rightTrackView.center.x;
        if (latchMiddle) forBackWardCenterPoint=self.middleTrackView.center.x;
        
        //跳出微进按钮
        [self.backwardBtn setFrame:CGRectMake(forBackWardCenterPoint-kForBackBtnWidth*1.5, kForBackBtnWidth+barRect.origin.y, kForBackBtnWidth, kForBackBtnWidth)];
        [self.forwardBtn setFrame:CGRectMake(forBackWardCenterPoint+kForBackBtnWidth*0.5, kForBackBtnWidth+barRect.origin.y, kForBackBtnWidth, kForBackBtnWidth)];
        
        [self.backwardBtn setHidden:NO];
        [self.forwardBtn setHidden:NO];
        
        //[self updateHandleImages];
    }
    
    
}

#pragma mark - action

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

- (void)pinGestureTouched:(UIPinchGestureRecognizer *)gesture{
    
}

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




#pragma mark - appearance

- (void)updateTrackView{
    if (latchLeft) {
        [self.leftTrackView setBackgroundColor:[UIColor greenColor]];
    }
    if (latchRight) {
        [self.rightTrackView setBackgroundColor:[UIColor greenColor]];
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
