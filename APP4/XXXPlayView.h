//
//  XXXPlayView.h
//  APP4
//
//  Created by user on 12-10-25.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AVPlayer;

@interface XXXPlayView : UIView

@property (nonatomic, retain) AVPlayer *player;

- (void)setPlayer:(AVPlayer *)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
