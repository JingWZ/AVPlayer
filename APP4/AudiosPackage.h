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


@interface AudiosPackage : NSObject

@property AVAsset *asset;

- (AudiosPackage *)initWithAsset:(AVAsset *)theAsset;

- (void)saveAudioWithRange:(CMTimeRange)range inPath:(NSString *)path;

@end
