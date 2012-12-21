//
//  Playback.h
//  APP4
//
//  Created by apple on 12-11-21.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "XXXPlayViewController.h"

@interface Playback : NSObject{
    
    NSURL *mURL;
    AVPlayer *mPlayer;
    AVPlayerItem *mPlayerItem;
    AVURLAsset *mAsset;
    SubtitlePackage *mSubtitlePackage;
    
    
    
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    id mTimeObserver;
    id mTimeObserverForSubtitle;
    
    
}

@property (retain, nonatomic) NSURL *mURL;
@property (retain, nonatomic) AVPlayer *mPlayer;
@property (retain, nonatomic) AVPlayerItem *mPlayerItem;
@property (retain, nonatomic) AVURLAsset *mAsset;
@property (retain) SubtitlePackage *mSubtitlePackage;


- (void)initAsset;



@end

