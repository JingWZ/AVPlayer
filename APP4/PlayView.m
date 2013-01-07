//
//  PlayView.m
//  APP4
//
//  Created by apple on 13-1-4.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//

#import "PlayView.h"

@implementation PlayView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    return self;
}

+ (Class)layerClass{
	return [AVPlayerLayer class];
}

- (AVPlayer*)player{
	return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player{
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

- (void)setVideoFillMode:(NSString *)fillMode{
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
	playerLayer.videoGravity = fillMode;
}

@end
