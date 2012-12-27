//
//  SubtitlePackage.m
//  APP4
//
//  Created by user on 12-11-9.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "SubtitlePackage.h"

@implementation SubtitlePackage
@synthesize subtitleItems;

- (SubtitlePackage *)initWithFile:(NSString *)filePath{
    NSString *context=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    self.subtitleItems=[NSMutableArray arrayWithCapacity:0];
    
    //在subtitleItem的Array索引为0上，创建一个individualSubtitle，在这个里面把中文英文字幕都设置为空。以便在用CMTime检索字幕package时，没检索到时用空白显示
    IndividualSubtitle *blankSubtitle=[IndividualSubtitle new];
    blankSubtitle.EngSubtitle=@" ";
    blankSubtitle.ChiSubtitle=@" ";
    [self.subtitleItems addObject:blankSubtitle];
    
    [self makeIndividualSubtitle:context];
    return self;
}

#pragma mark - make individual subtitle item

- (void)makeIndividualSubtitle:(NSString *)context{
    NSArray *contextLine=[context componentsSeparatedByString:@"\n"];
    
    for (int i=0; i<[contextLine count]; i++)
    {
        NSRange firstCharRange=NSMakeRange(0, 1);
        NSString *lineIndex=[contextLine objectAtIndex:i];
        if ([lineIndex length])  //to skip over blank lines
        {
            if ([[lineIndex substringWithRange:firstCharRange] intValue]>=1 &&
                [[lineIndex substringWithRange:firstCharRange] intValue]<=9) // the index line
            {
                NSString *lineTime=[contextLine objectAtIndex:i+1];
                if ([[lineTime substringWithRange:firstCharRange] isEqualToString:@"0"]) //the time line
                {
                    IndividualSubtitle *subtitle=[IndividualSubtitle new];
                    NSString *lineChi=[contextLine objectAtIndex:i+2];
                    NSString *lineEng=[contextLine objectAtIndex:i+3];
                    
                    subtitle.startTime=[self makeCMTimeStart:lineTime];
                    subtitle.endTime=[self makeCMTimeEnd:lineTime];
                    subtitle.ChiSubtitle=[NSString stringWithString:lineChi];
                    if ([lineEng length]) {
                        subtitle.EngSubtitle=[NSString stringWithString:lineEng];
                    }else{
                        subtitle.EngSubtitle=@" ";
                    }
                    [self.subtitleItems addObject:subtitle];
                }
                else
                {
                    //如果字幕索引下不是时间轴，则出错
                    NSLog(@"subtitle package wrong");
                }
            }
        }
    }
}

#pragma mark - choose proper subtitle by given CMTime

- (NSUInteger)indexOfProperSubtitleWithGivenCMTime:(CMTime)time{
    __block double timeInSeconds=CMTimeGetSeconds(time);
    NSUInteger theIndex=[self.subtitleItems indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if (timeInSeconds>=CMTimeGetSeconds([obj startTime]) && timeInSeconds<=CMTimeGetSeconds([obj endTime])) {
            return YES;
        }else{
            return NO;
        }
    }];
    if (theIndex==NSNotFound) {
        return 0;
    }else{
        return theIndex;
    }
    
}

#pragma mark - save

- (void)saveSubtitleWithTime:(CMTime)time inPath:(NSString *)path{
    
    NSUInteger index=[self indexOfProperSubtitleWithGivenCMTime:time];
    
    IndividualSubtitle *currentSubtitle=[self.subtitleItems objectAtIndex:index];
    
    NSMutableData *data=[[NSMutableData alloc]init];
    NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:currentSubtitle forKey:@"subtitle"];
    [archiver finishEncoding];
    
    [data writeToFile:path atomically:YES];
    
}



#pragma mark - make CMTime from String

- (CMTime)makeCMTimeStart:(NSString *)timeline{
    NSString *startTimeStr=[timeline substringWithRange:NSMakeRange(0, 12)];
    CMTime timeStart=[self makeCMTimeFromSperatedTimeString:startTimeStr];
    return timeStart;
}

- (CMTime)makeCMTimeEnd:(NSString *)timeline{
    NSString *endTimeStr=[timeline substringWithRange:NSMakeRange(17, 12)];
    CMTime timeEnd=[self makeCMTimeFromSperatedTimeString:endTimeStr];
    return timeEnd;
}

- (CMTime)makeCMTimeFromSperatedTimeString:(NSString *)separatedTimeStr{
    NSRange hourRange=NSMakeRange(0, 2);
    NSRange minRange=NSMakeRange(3, 2);
    NSRange secRange=NSMakeRange(6, 2);
    NSRange fraRange=NSMakeRange(9, 3);
    
    int hour=[[separatedTimeStr substringWithRange:hourRange] intValue];
    int min=[[separatedTimeStr substringWithRange:minRange] intValue];
    int sec=[[separatedTimeStr substringWithRange:secRange] intValue];
    int fra=[[separatedTimeStr substringWithRange:fraRange] intValue];
    
    double timeInSeconds=(fra+sec*1000+min*60*1000+hour*60*60*1000)/1000.00*600.00;
    CMTime time=CMTimeMake(timeInSeconds, 600);
    return time;
}



#pragma mark - NSCoding & NSCopying

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:subtitleItems forKey:@"subtitleItems"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self=[super init]) {
        subtitleItems=[aDecoder decodeObjectForKey:@"subtitleItems"];
    }
    return self;
}

@end



#pragma mark -


@implementation IndividualSubtitle
@synthesize startTime, endTime;
@synthesize EngSubtitle, ChiSubtitle;

- (IndividualSubtitle *)initSubtitle{
    IndividualSubtitle *subtitle=[IndividualSubtitle new];
    subtitle.startTime=kCMTimeZero;
    subtitle.endTime=kCMTimeZero;
    return subtitle;
}

- (void)savesubtitleInPath:(NSString *)path{
    
    NSMutableData *data=[[NSMutableData alloc]init];
    NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:@"subtitle"];
    [archiver finishEncoding];
    
    [data writeToFile:path atomically:YES];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeCMTime:startTime forKey:@"startTime"];
    [aCoder encodeCMTime:endTime forKey:@"endTime"];
    [aCoder encodeObject:EngSubtitle forKey:@"EngSubtitle"];
    [aCoder encodeObject:ChiSubtitle forKey:@"ChiSubtitle"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self=[super init]) {
        startTime=[aDecoder decodeCMTimeForKey:@"startTime"];
        endTime=[aDecoder decodeCMTimeForKey:@"endTime"];
        EngSubtitle=[aDecoder decodeObjectForKey:@"EngSubtitle"];
        ChiSubtitle=[aDecoder decodeObjectForKey:@"ChiSubtitle"];
        
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone{
    IndividualSubtitle *copy=[[[self class] allocWithZone:zone]init];
    copy.startTime=self.startTime;
    copy.endTime=self.endTime;
    copy.EngSubtitle=[self.EngSubtitle copyWithZone:zone];
    copy.ChiSubtitle=[self.ChiSubtitle copyWithZone:zone];
    return copy;
}

@end
