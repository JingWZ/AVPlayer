//
//  AudiosPackage.m
//  APP4
//
//  Created by apple on 12-11-11.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "AudiosPackage.h"

@implementation AudiosPackage
@synthesize asset;

-(AudiosPackage *)initWithAsset:(AVAsset *)theAsset{
    
    if (theAsset) {
        self.asset=theAsset;
    }else{
        NSLog(@"no asset, can't init audioPackage!");
    }
    
    return self;
}

-(void)saveAudioWithRange:(CMTimeRange)range inPath:(NSString *)path{
    
    NSString *audioPath=[path stringByAppendingPathExtension:@"m4a"];
    NSURL *pathURL=[NSURL fileURLWithPath:audioPath];
    
    AVAssetExportSession *exportSession=[AVAssetExportSession exportSessionWithAsset:self.asset presetName:AVAssetExportPresetAppleM4A];
    
    exportSession.outputURL=pathURL;
    exportSession.outputFileType=AVFileTypeAppleM4A;
    exportSession.timeRange=range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.status==AVAssetExportSessionStatusFailed) {
            NSLog(@"can't export audio!");
        }
    }];
    
}


@end

