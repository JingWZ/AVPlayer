//
//  GlossaryManagement.m
//  APP4
//
//  Created by apple on 13-1-22.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//

#import "GlossaryManagement.h"

@implementation GlossaryManagement

static NSString *glossaryIndex=@"glossaryIndex";
static NSString *glossaryPath=@"glossaryPath";
static NSString *glossaryVideoPath=@"glossaryVideoPath";
static NSString *glossarySubtitlePath=@"glossarySubtitlePath";
static NSString *cardsKey=@"glossaryCards";

static NSString *cardSavePath=@"cardSavePath";
static NSString *cardRecordCount=@"cardRecordCount";
static NSString *cardVideoPath=@"cardVideoPath";
static NSString *cardSubtitlePath=@"cardSubtitlePath";

#pragma mark - add glossary

- (NSDictionary *)getGlossaryWithGlossaryPath:(NSString *)gPath videoPath:(NSString *)vPath subtitlePath:(NSString *)sPath cards:(NSMutableArray *)cards{
    
    NSDictionary *glossary=[NSDictionary dictionaryWithObjectsAndKeys:
                            gPath, glossaryPath,
                            vPath, glossaryVideoPath,
                            sPath, glossarySubtitlePath,
                            cards, cardsKey, nil];
    
    return glossary;
}

- (void)addGlossaryInDefault:(NSDictionary *)glossary{
    [self addGlossary:glossary inKey:kGlossaryDefault];
}

- (void)addGlossaryInCustom:(NSDictionary *)glossary{
    [self addGlossary:glossary inKey:kGlossaryCustom];
}

- (void)updateGlossaryToZeroIndexWithGlossaryPath:(NSString *)path{
        
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    
    NSMutableArray *allGlossaries=[NSMutableArray arrayWithArray:[ud arrayForKey:kGlossaryDefault]];
    
    NSInteger index=[allGlossaries indexOfObjectPassingTest:^BOOL(NSDictionary *glos, NSUInteger idx, BOOL *stop) {
        NSString *glosPath=[glos objectForKey:glossaryPath];
        if ([glosPath isEqualToString:path]) {
            return YES;
        }
        return YES;
    }];
    if (index==NSNotFound) {
        index=0;
    }
    
    //sync all glossaries
    NSDictionary *glossary=[NSDictionary dictionaryWithDictionary:[allGlossaries objectAtIndex:index]];
    [allGlossaries removeObjectAtIndex:index];
    [allGlossaries insertObject:glossary atIndex:0];
    
    //synchonize the data in userDefault
    [ud setObject:allGlossaries forKey:kGlossaryDefault];
    [ud synchronize];
    
}

- (void)addGlossary:(NSDictionary *)glossary inKey:(NSString *)key{
    
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSMutableArray *allGlossaries;
    
    if ([ud arrayForKey:key]) {
        allGlossaries=[NSMutableArray arrayWithArray:[ud arrayForKey:key]];
    }else{
        allGlossaries=[NSMutableArray arrayWithCapacity:0];
    }
    
    [allGlossaries insertObject:glossary atIndex:0];
    
    //synchonize the data in userDefault
    [ud setObject:allGlossaries forKey:key];
    [ud synchronize];
}

#pragma mark - add card

- (void)addCardInDefaultWithSavePath:(NSString *)path recordCount:(NSInteger)count video:(NSString *)vPath subtitle:(NSString *)sPath{
    
    //update eachCard
    NSNumber *recordCount=[NSNumber numberWithInteger:count];
    NSDictionary *eachCard=[NSDictionary dictionaryWithObjectsAndKeys:
                            path, cardSavePath,
                            recordCount, cardRecordCount,
                            vPath, cardVideoPath,
                            sPath, cardSubtitlePath, nil];
    
    //all glossaries
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSMutableArray *allGlossaries=[NSMutableArray arrayWithArray:[ud arrayForKey:kGlossaryDefault]];
    //glossary
    NSMutableDictionary *glossary=[NSMutableDictionary dictionaryWithDictionary:[allGlossaries objectAtIndex:0]];
    
    //update cards
    NSMutableArray *cards=[NSMutableArray arrayWithArray:[glossary objectForKey:cardsKey]];
    [cards addObject:eachCard];
    
    //update glossary
    [glossary setObject:cards forKey:cardsKey];
    
    //update all glossaries
    [allGlossaries removeObjectAtIndex:0];
    [allGlossaries insertObject:glossary atIndex:0];
    
    //update userDefault
    [ud setObject:allGlossaries forKey:kGlossaryDefault];
    
}

#pragma mark - get glossary path

- (NSMutableArray *)getDefaultGlossariesPath{
    
    return [self getGlossariesPathIn:kGlossaryDefault];

}

- (NSMutableArray *)getCustomGlossariesPath{
    
    return [self getGlossariesPathIn:kGlossaryCustom];
    
}

- (NSMutableArray *)getGlossariesPathIn:(NSString *)key{
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSArray *allGlossaries=[ud arrayForKey:key];
    NSMutableArray *glossariesPath=[NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<[allGlossaries count]; i++) {
        NSDictionary *glos=[allGlossaries objectAtIndex:i];
        NSString *path=[glos objectForKey:glossaryPath];
        [glossariesPath addObject:path];
    }
    return glossariesPath;
}

#pragma mark - get glossary name

- (NSMutableArray *)getDefaultGlossariesName{
    return [self getGlossariesNameIn:kGlossaryDefault];
}

- (NSMutableArray *)getCustomGlossariesName{
    return [self getGlossariesNameIn:kGlossaryCustom];
}

- (NSMutableArray *)getGlossariesNameIn:(NSString *)key{
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSArray *allGlossaries=[ud arrayForKey:key];
    NSMutableArray *glossariesName=[NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<[allGlossaries count]; i++) {
        NSDictionary *glos=[allGlossaries objectAtIndex:i];
        NSString *path=[glos objectForKey:glossaryPath];
        NSString *name=[path lastPathComponent];
        [glossariesName addObject:name];
    }
    return glossariesName;
}

@end
