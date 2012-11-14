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


@interface ImagesPackage : NSObject

@property (retain) UIImage *image;
@property (retain) AVAssetImageGenerator *imageGenerator;

- (ImagesPackage *)initWithAsset:(AVAsset *)asset;

- (void)saveImageWithTime:(CMTime)time inPath:(NSString *)path;

@end
