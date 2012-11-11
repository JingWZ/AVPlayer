//
//  AudiosPackage.m
//  APP4
//
//  Created by apple on 12-11-11.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "AudiosPackage.h"

@implementation AudiosPackage
@synthesize audioTrack;

-(AudiosPackage *)initWithAsset:(AVAsset *)asset{
    NSArray *audioTracks=[asset tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count) {
        self.audioTrack=[audioTracks objectAtIndex:0];
        self.audioItems=[NSMutableArray arrayWithCapacity:0];
    }else{
        NSLog(@"No audio track found!");
    }
    
    return self;
}

- (void)extractAudioWithStartTime:(CMTime)startTime endTime:(CMTime)endTime andIndex:(NSUInteger)index{
    CMTimeRange extractRange=CMTimeRangeFromTimeToTime(startTime, endTime);
    
    
    IndividualAudio *individualAudio=[IndividualAudio new];
    individualAudio.audioComposition=[AVMutableComposition composition];
    AVMutableCompositionTrack *compositionTrack=[individualAudio.audioComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSError *error;
    [compositionTrack insertTimeRange:extractRange ofTrack:self.audioTrack atTime:kCMTimeZero error:&error];
    
    individualAudio.index=index;
    
    [self.audioItems addObject:individualAudio];
}

/*
 
 保存音频
 
 AVAssetExportSession *exportSession=[AVAssetExportSession exportSessionWithAsset:audioComposition presetName:AVAssetExportPresetMediumQuality];
 [exportSession setOutputFileType:@"com.apple.quicktime-movie"];
 [exportSession setOutputURL:pathurl];
 
 [exportSession exportAsynchronouslyWithCompletionHandler:^{
 if (exportSession.status==AVAssetExportSessionStatusFailed) {
 NSLog(@"failed");
 }else if (exportSession.status==AVAssetExportSessionStatusCompleted){
 NSLog(@"completed");
 }
 }];
 

 
 */

@end


@implementation IndividualAudio

@synthesize index;
@synthesize audioComposition;

@end
