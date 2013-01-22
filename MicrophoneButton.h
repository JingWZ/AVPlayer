//
//  MicrophoneButton.h
//  Quartz2DButton
//
//  Created by apple on 13-1-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    kColorTypeYellowToRed = 0,//R:255,G:255->0,B:0
    kColorTypeCyanToBlue = 1 //R:0,G:255->0,B:255

} ColorType;

typedef enum {
    
    kGlowingDefault = 0,
    kGlowingGradient = 1

} GlowingType;


@interface MicrophoneButton : UIButton

@property (assign, nonatomic) CGFloat offset;//offset to frame, to enable shadow
@property (assign, nonatomic) CGFloat microphoneLineWidth;//stroke width
@property (strong, nonatomic) UIColor *microphoneLineColor;
@property (assign, nonatomic) CGSize mainPhoneSize;//the main ellipse size
@property (assign, nonatomic) CGFloat distanceBetweenPhoneAndHolder;
@property (assign, nonatomic) CGFloat holderExtendingLength;
@property (assign, nonatomic) CGFloat verticalLineLength;
@property (assign, nonatomic) CGFloat horizontalLineLength;

@property (assign, nonatomic) ColorType colorType;
@property (assign, nonatomic) GlowingType glowingType;
@property (assign, nonatomic) BOOL colorReverse;
@property (assign, nonatomic) CGFloat currentValueRate;//0->1
@property (assign, nonatomic) NSInteger colorCount;

@property (assign, nonatomic) NSInteger movingSpeedRate;//0->1
@property (assign, nonatomic, setter = isMoving:) BOOL moving;
@property (strong, nonatomic) UIColor *movingPointColor;
@property (assign, nonatomic) CGFloat movingPointSize;

@end
