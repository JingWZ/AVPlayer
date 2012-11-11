//
//  ImagesPackage.h
//  APP4
//
//  Created by apple on 12-11-11.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@interface IndividualImage : NSObject

@property (retain) UIImage *image;
@property (assign) NSUInteger index;

@end



@interface ImagesPackage : NSObject

@property (retain) NSMutableArray *imageItems;
@property (retain) AVAssetImageGenerator *imageGenerator;

- (ImagesPackage *)initWithAsset:(AVAsset *)asset;
- (void)extractImagewithCMTime:(CMTime)time andIndex:(NSUInteger)index;
 //name是视频名字，为每一个视频建立一个存储文件夹，其中包括 字幕文件、截图、音频

@end
