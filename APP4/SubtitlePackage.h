//
//  SubtitlePackage.h
//  APP4
//
//  Created by user on 12-11-9.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

//暂时不写NSCoding，等用的时候再说

@interface IndividualSubtitle : NSObject

@property (assign) NSUInteger index;
@property (assign) CMTime startTime;
@property (assign) CMTime endTime;
@property (copy) NSString *EngSubtitle;
@property (copy) NSString *ChiSubtitle;

@end


@interface SubtitlePackage : NSObject

@property (retain) NSMutableArray *subtitleItems;

- (SubtitlePackage *)initWithFile:(NSString *)filePath;
- (NSUInteger)indexOfProperSubtitleWithGivenCMTime:(CMTime)time;


@end
