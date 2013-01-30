//
//  SubtitlePackage.h
//  APP4
//
//  Created by user on 12-11-9.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>


@interface IndividualSubtitle : NSObject <NSCoding,NSCopying>
@property (assign) CMTime startTime;
@property (assign) CMTime endTime;
@property (copy) NSString *EngSubtitle;
@property (copy) NSString *ChiSubtitle;
- (void)savesubtitleInPath:(NSString *)path;
- (IndividualSubtitle *)initSubtitle;
@end


@interface SubtitlePackage : NSObject <NSCoding>

@property (retain) NSMutableArray *subtitleItems;

- (SubtitlePackage *)initWithFile:(NSString *)filePath;

- (NSUInteger)indexOfProperSubtitleWithGivenCMTime:(CMTime)time;
- (NSInteger)indexOfBackForWard:(CMTime)time;

- (NSString *)makeSaveName:(CMTime)time;
- (void)saveSubtitleWithTime:(CMTime)time inPath:(NSString *)path;


@end
