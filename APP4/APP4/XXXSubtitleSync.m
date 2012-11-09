//
//  XXXSubtitleSync.m
//  APP4
//
//  Created by user on 12-10-31.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "XXXSubtitleSync.h"

@implementation XXXSubtitleSync

@synthesize timelineArray, subtitleEngArray, subtitleChiArray;

-(void)initSubtitle{
    NSString *subtitlePath=@"/Users/apple/Desktop/APP4/APP4/subtitleFile";
    NSString *context=[NSString stringWithContentsOfFile:subtitlePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *contextLine=[context componentsSeparatedByString:@"\n"];
    timelineArray=[NSMutableArray arrayWithCapacity:0];
    subtitleEngArray=[NSMutableArray arrayWithCapacity:0];
    subtitleChiArray=[NSMutableArray arrayWithCapacity:0];
    
    int count=[contextLine count];
    
    for (int i=0; i<count; i++) {
        NSString *sentence=[contextLine objectAtIndex:i];
        if ([sentence length]) {
            if ([[sentence substringWithRange:NSMakeRange(0, 1)] intValue]>=1 && [[sentence substringWithRange:NSMakeRange(0, 1)] intValue]<=9) {
                if ([[[contextLine objectAtIndex:i+1] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"0"]) {
                    NSString *timeline=[contextLine objectAtIndex:i+1];
                    NSString *ChiSubtitle=[contextLine objectAtIndex:i+2];
                    NSString *EngSubtitle;
                    if ([[contextLine objectAtIndex:i+3] length]) {
                        EngSubtitle=[contextLine objectAtIndex:i+3];
                    }else{
                        EngSubtitle=@" ";
                    }
                    [timelineArray addObject:timeline];
                    [subtitleEngArray addObject:EngSubtitle];
                    [subtitleChiArray addObject:ChiSubtitle];
                }else{
                    NSLog(@"wrong");
                    return;
                }
            }
        }
    }

}


- (CMTime)getCMTimeBegin:(NSString *)timeline{
    NSString *BeginTimeStr=[timeline substringWithRange:NSMakeRange(0, 12)];
    CMTime timeBegin=[self getCMTime:BeginTimeStr];
    return timeBegin;
}

- (CMTime)getCMTimeEnd:(NSString *)timeline{
    NSString *endTimeStr=[timeline substringWithRange:NSMakeRange(17, 12)];
    CMTime timeEnd=[self getCMTime:endTimeStr];
    return timeEnd;
}

- (CMTime)getCMTime:(NSString *)separatedTimeStr{
    NSRange hourRange=NSMakeRange(0, 2);
    NSRange minRange=NSMakeRange(3, 2);
    NSRange secRange=NSMakeRange(6, 2);
    NSRange fraRange=NSMakeRange(9, 3);
    
    int hour=[[separatedTimeStr substringWithRange:hourRange] intValue];
    int min=[[separatedTimeStr substringWithRange:minRange] intValue];
    int sec=[[separatedTimeStr substringWithRange:secRange] intValue];
    int fra=[[separatedTimeStr substringWithRange:fraRange] intValue];
    
    int64_t timeInScale=600*(fra/1000+sec+min*60+hour*60*60);
    CMTime time=CMTimeMake(timeInScale, 600);
    return time;
}


@end
