//
//  XXXSubtitleSync.h
//  APP4
//
//  Created by user on 12-10-31.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface XXXSubtitleSync : NSObject

@property NSMutableArray *timelineArray;
@property NSMutableArray *subtitleEngArray;
@property NSMutableArray *subtitleChiArray;

- (void)initSubtitle;
- (CMTime)getCMTimeBegin:(NSString *)timeline;
- (CMTime)getCMTimeEnd:(NSString *)timeline;


@end
