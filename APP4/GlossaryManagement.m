//
//  GlossaryManagement.m
//  APP4
//
//  Created by apple on 13-1-22.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//

#import "GlossaryManagement.h"

@implementation GlossaryManagement

@synthesize glossaryDefault, glossaryCustom;


#pragma mark - add glossary

- (NSDictionary *)getGlossaryWithIndex:(NSInteger)index glossary:(NSString *)gPath video:(NSString *)vPath subtitle:(NSString *)sPath cards:(NSMutableArray *)cards{
    
    NSString *glossaryIndex=@"glossaryIndex";
    NSString *glossaryPath=@"glossaryPath";
    NSString *videoPath=@"glossaryVideoPath";
    NSString *subtitlePath=@"glossarySubtitlePath";
    NSString *cardsKey=@"glossaryCards";
    
    NSNumber *indexNum=[NSNumber numberWithInteger:index];
    NSDictionary *glossary=[NSDictionary dictionaryWithObjectsAndKeys:
              indexNum, glossaryIndex,
              gPath, glossaryPath,
              vPath, videoPath,
              sPath, subtitlePath,
              cards, cardsKey, nil];
    
    return glossary;
}

- (void)addGlossaryInDefault:(NSDictionary *)glossary{
    [self addGlossary:glossary inKey:kGlossaryDefault];
}

- (void)addGlossaryInCustom:(NSDictionary *)glossary{
    [self addGlossary:glossary inKey:kGlossaryCustom];
}

- (void)addGlossary:(NSDictionary *)glossary inKey:(NSString *)key{
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    
    if ([ud arrayForKey:key]) {
        glossaryDefault=[NSMutableArray arrayWithArray:[ud arrayForKey:key]];
    }else{
        glossaryDefault=[NSMutableArray arrayWithCapacity:0];
    }
    
    [glossaryDefault insertObject:glossaryDefault atIndex:0];
    
    //synchonize the data in userDefault
    [ud setObject:glossaryDefault forKey:key];
    [ud synchronize];
}

#pragma mark - add card



@end
