//
//  AudiosPackage.h
//  APP4
//
//  Created by apple on 12-11-11.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@interface IndividualAudio : NSObject

@property (assign) NSUInteger index;
@property (retain) AVMutableComposition *audioComposition;

@end


@interface AudiosPackage : NSObject

@property NSMutableArray *audioItems;
@property AVAssetTrack *audioTrack;

- (AudiosPackage *)initWithAsset:(AVAsset *)asset;
- (void)extractAudioWithStartTime:(CMTime)startTime endTime:(CMTime)endTIme andIndex:(NSUInteger)index;
@end
