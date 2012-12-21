//
//  Playback.m
//  APP4
//
//  Created by apple on 12-11-21.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "Playback.h"

static void *PlayViewControllerRateObservationContext = &PlayViewControllerRateObservationContext;
static void *PlayViewControllerStatusObservationContext = &PlayViewControllerStatusObservationContext;
static void *PlayViewControllerCurrentItemObservationContext = &PlayViewControllerCurrentItemObservationContext;

@implementation Playback
@synthesize mURL, mPlayer, mPlayerItem;
@synthesize mAsset;
@synthesize mSubtitlePackage;


#pragma mark - viewLoad

- (void)initAsset
{
    
    mURL=[NSURL URLWithString:videoPath];
    self.mAsset=[AVURLAsset URLAssetWithURL:mURL options:nil];
    NSArray *requestedKeys=[NSArray arrayWithObject:@"tracks"];
    [mAsset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self prepareToPlayAsset:mAsset withKeys:requestedKeys];
        });
    }];
    
    
    
    
    
    // Do any additional setup after loading the view from its nib.
    
}












-(BOOL)isPlaying{
    //toknow
    return mRestoreAfterScrubbingRate !=0.f || [mPlayer rate] !=0.f;
}

-(CMTime)playerItemDuration{
    AVPlayerItem *playerItem=[mPlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return ([playerItem duration]);
    }
    return (kCMTimeInvalid);
}

-(void)removePlayerTimeObserver{
    if (mTimeObserver) {
        [mPlayer removeTimeObserver:mTimeObserver];
        mTimeObserver=nil;
    }
}

-(void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys{
    //    for (NSString *thisKey in requestedKeys){
    //        NSError *error=nil;
    //        AVKeyValueStatus keyStatus=[asset statusOfValueForKey:thisKey error:&error];
    //        if (keyStatus==AVKeyValueStatusFailed) {
    //            [self assetFailedToPrepareForPlayback:error];
    //            return;
    //        }
    //    }
    
    //    if (!asset.playable) {
    //        NSString *localizedDescription=NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
    //        NSString *localizedFailureReason=NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
    //        NSDictionary *errorDict=[NSDictionary dictionaryWithObjectsAndKeys:localizedDescription, NSLocalizedDescriptionKey, localizedFailureReason, NSLocalizedFailureReasonErrorKey, nil];
    //        NSError *assetCannotBePlayedError=[NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
    //        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
    //        return;
    //    }
    
    if (self.mPlayerItem) {
        [self.mPlayerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.mPlayerItem];
    }
    
    self.mPlayerItem=[AVPlayerItem playerItemWithAsset:asset];
    [self.mPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:PlayViewControllerStatusObservationContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.mPlayerItem];
    seekToZeroBeforePlay=NO;
    
    if (![self mPlayer]) {
        [self setMPlayer:[AVPlayer playerWithPlayerItem:self.mPlayerItem]];
        [self.mPlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:PlayViewControllerCurrentItemObservationContext];
        
        //[self.mPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:PlayViewControllerRateObservationContext];
    }
    
    if (self.mPlayer.currentItem != self.mPlayerItem) {
        [[self mPlayer] replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        //[self syncPlayPauseButtons];
    }
    //[mScrubber setValue:0.0];
    [mPlayer play];
    //[self showStopButton];
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error{
    [self removePlayerTimeObserver];
    //[self syncScrubber];
    //[self disableScrubber];
    //[self disablePlayerButtons];
    
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:[error localizedDescription] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)playerItemDidReachEnd:(NSNotification *)notification{
    seekToZeroBeforePlay = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (context==PlayViewControllerStatusObservationContext) {
        //[self syncPlayPauseButtons];
        AVPlayerStatus status=[[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown:
            {
                [self removePlayerTimeObserver];
                //[self syncScrubber];
                //[self disableScrubber];
                //[self disablePlayerButtons];
                NSLog(@"unknow");
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
//                [self initScrubberTimer];
//                [self initSubtitle];
//                [self enablePlayerButtons];
//                [self enableScrubber];
//                [self initImageExtractionLayer];
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem=(AVPlayerItem *)object;
                //NSLog(@"rr");
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
    }
    
    else if (context==PlayViewControllerCurrentItemObservationContext){
        AVPlayerItem *newPlayerItem=[change objectForKey:NSKeyValueChangeNewKey];
        if (newPlayerItem==(id)[NSNull null]) {
            //[self disablePlayerButtons];
            //[self disableScrubber];
        }else{
            //[mPlayView setPlayer:mPlayer];
            //[self setviewDisplayName];
            //[mPlayView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            //[self syncPlayPauseButtons];
        }
    }
    
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}















@end
