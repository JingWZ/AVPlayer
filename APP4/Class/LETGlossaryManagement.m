//
//  LETGlossaryManagement.m
//  LearnEnglishByTVSeries
//
//  Created by apple on 13-2-16.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "LETGlossaryManagement.h"

@implementation LETGlossaryManagement

static LETGlossaryManagement *gm=nil;

static NSString *kUserID=@"kUserID";
static NSString *kUserPassword=@"kUserPassword";
static NSString *kAllGlossaries=@"kAllGlossaries";

#pragma mark - glossary

- (NSMutableArray *)allGlossaries{
    
    //取出ud中的allGlossaries
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSMutableArray *glossaries=[NSMutableArray arrayWithCapacity:0];
    
    if ([ud arrayForKey:kAllGlossaries]) {
        
        glossaries=[NSMutableArray arrayWithArray:[ud arrayForKey:kAllGlossaries]];
        
    }else{
        
        //如果没有，则创建一个存入userDefault
        [ud setObject:glossaries forKey:kAllGlossaries];
    }
    
    return glossaries;
}

//在添加自定义Gloss时使用
- (LETGlossary *)glossaryWithName:(NSString *)name{
    
    LETGlossary *glossary=[[LETGlossary alloc]init];
    
    glossary.glossaryIndex=0;
    glossary.glossaryID=[gm glossaryID];
    glossary.glossaryMakerID=[gm userID];
    glossary.glossaryName=name;
    glossary.glossaryVideoPath=nil;
    glossary.glossarySubtitlePath=nil;
    glossary.glossaryCards=[NSMutableArray arrayWithCapacity:0];
    glossary.glossaryAllowSetting=NO;
    glossary.glossaryAllowRename=YES;
    
    //更新到userDefault
    [gm saveGlossary:glossary];
    
    return glossary;
}

//在通过视频制作Gloss时使用
- (LETGlossary *)glossaryWithVideoPath:(NSString *)p1 SubtitlePath:(NSString *)p2{
    
    NSUInteger index=[gm checkIfGlossaryAlreadyExist:p1 and:p2];
    
    LETGlossary *glossary;
    
    if (index==NSNotFound) {
        
        //创建一个新的glossary，更新到userDefault
        glossary=[[LETGlossary alloc]init];
        
        glossary.glossaryIndex=0;
        glossary.glossaryID=[gm glossaryID];
        glossary.glossaryMakerID=[gm userID];
        glossary.glossaryName=[p1 stringByDeletingPathExtension];
        glossary.glossaryVideoPath=p1;
        glossary.glossarySubtitlePath=p2;
        glossary.glossaryCards=[NSMutableArray arrayWithCapacity:0];
        glossary.glossaryAllowSetting=YES;
        glossary.glossaryAllowRename=YES;
        
        [gm saveGlossary:glossary];
        
    }else{
        
        //拿到所有生词本中的glossary，更新index
        NSMutableArray *glossaries=[gm allGlossaries];
        NSData *glossData=[glossaries objectAtIndex:index];
        glossary=[NSKeyedUnarchiver unarchiveObjectWithData:glossData];
        glossary.glossaryIndex=0;
        
        //删除原来位置上的glossary，把更新后的插到第一个
        [glossaries removeObjectAtIndex:index];
        NSData *updatedData=[NSKeyedArchiver archivedDataWithRootObject:glossary];
        [glossaries insertObject:updatedData atIndex:0];
        
        //更新到userDefault
        NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
        [ud setObject:glossaries forKey:kAllGlossaries];
        [ud synchronize];
        
    }
    
    return glossary;
}

- (void)saveGlossary:(LETGlossary *)gloss{
    
    NSData *glossaryData=[NSKeyedArchiver archivedDataWithRootObject:gloss];
    
    //拿到所有生词本中的glossary
    NSMutableArray *glossaries=[gm allGlossaries];
    [glossaries insertObject:glossaryData atIndex:0];
 
    //更新到userDefault
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    [ud setObject:glossaries forKey:kAllGlossaries];
    [ud synchronize];
}

- (void)updateGlossary:(LETGlossary *)gloss atIndex:(NSInteger)inde{
    
    //拿到所有生词本中的glossary
    NSMutableArray *glossaries=[gm allGlossaries];
    
    //删除原来位置上的glossary，把更新后的插到第一个
    [glossaries removeObjectAtIndex:inde];
    NSData *updatedData=[NSKeyedArchiver archivedDataWithRootObject:gloss];
    [glossaries insertObject:updatedData atIndex:0];
    
    //更新到userDefault
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    [ud setObject:glossaries forKey:kAllGlossaries];
    [ud synchronize];
    
}

- (LETGlossary *)glossaryAtIndex:(NSInteger)inde{
    
    //拿到所有生词本中的glossary，更新index
    NSMutableArray *glossaries=[gm allGlossaries];
    
    NSData *glossaryData=[glossaries objectAtIndex:inde];
    LETGlossary *glossary=[NSKeyedUnarchiver unarchiveObjectWithData:glossaryData];
    
    return glossary;
}

- (NSString *)glossaryVideoPathAtIndex:(NSInteger)inde{
    
    LETGlossary *glossary=[gm glossaryAtIndex:inde];
    NSString *glossaryVideoName=glossary.glossaryVideoPath;
    NSString *documentPath=[gm documentPath];
    
    NSString *glossaryVideoPath=[documentPath stringByAppendingPathComponent:glossaryVideoName];
    
    return glossaryVideoPath;
}

- (NSString *)glossarySubtitlePathAtIndex:(NSInteger)inde{
    
    LETGlossary *glossary=[gm glossaryAtIndex:inde];
    NSString *glossarySubtitleName=glossary.glossarySubtitlePath;
    NSString *documentPath=[gm documentPath];
    
    NSString *glossarySubtitlePath=[documentPath stringByAppendingPathComponent:glossarySubtitleName];
    
    return glossarySubtitlePath;
    
}

- (NSUInteger)checkIfGlossaryAlreadyExist:(NSString *)vPath and:(NSString *)sPath{
    
    NSMutableArray *glossaries=[NSMutableArray arrayWithArray:[gm allGlossaries]];
    
    NSUInteger index=[glossaries indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        LETGlossary *glossary=[NSKeyedUnarchiver unarchiveObjectWithData:obj];
        NSString *videoPath=[NSString stringWithString:glossary.glossaryVideoPath];
        BOOL success=NO;
        
        //如果视频名相同，则判断字幕名
        if ([videoPath isEqualToString:vPath]) {
            
            NSString *subtitlePath=[NSString stringWithString:glossary.glossarySubtitlePath];
            if ([subtitlePath isEqualToString:sPath]) {
                success=YES;
            }
        }
        
        return success;
        
    }];
    
    return index;
    
}

//创建一个glossaryID
- (NSString *)glossaryID{
    
    NSDate *now=[NSDate date];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
    NSString *nowStr=[dateFormatter stringFromDate:now];
    
    NSString *userID=[gm userID];
    
    return [nowStr stringByAppendingString:userID];
}

#pragma mark - card

- (void)addCardAtIndex:(NSInteger)inde name:(NSString *)name recordCount:(NSInteger)count{
    
    //init card
    LETCard *card=[[LETCard alloc] init];
    card.cardName=name;
    card.cardRecordCount=count;
    NSData *cardData=[NSKeyedArchiver archivedDataWithRootObject:card];
    
    //add card to glossary
    LETGlossary *glossary=[gm glossaryAtIndex:inde];
    [glossary.glossaryCards addObject:cardData];
    glossary.glossaryIndex=0;
    
    [gm updateGlossary:glossary atIndex:inde];
    
}

- (NSMutableArray *)allGlossaryCardsAtGlossaryIndex:(NSInteger)inde{
    
    LETGlossary *glossary=[gm glossaryAtIndex:inde];
    NSArray *glossaryCards=glossary.glossaryCards;
    NSMutableArray *cards=[NSMutableArray arrayWithCapacity:0];
    
    for (NSData *cardData in glossaryCards) {
        
        LETCard *card=[NSKeyedUnarchiver unarchiveObjectWithData:cardData];
        [cards addObject:card];
    }
    
    return cards;
}

- (LETCard *)cardAtGlossaryIndex:(NSInteger)inde cardIndex:(NSInteger)inde2{
    
    LETGlossary *glossary=[gm glossaryAtIndex:inde];
    NSData *cardData=[glossary.glossaryCards objectAtIndex:inde2];
    LETCard *card=[NSKeyedUnarchiver unarchiveObjectWithData:cardData];
    
    return card;
}

#pragma mark - singleton

+ (LETGlossaryManagement *)sharedInstance{
    
    if (gm==nil) {
        gm=[[super allocWithZone:NULL] init];
    }
    return gm;
}

#pragma mark - userID & password

//在用户创建账号后，把ID存入UserDefault
- (void)saveUserID:(NSString *)userID andPassword:(NSString *)password{
    
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    [ud setObject:userID forKey:kUserID];
    [ud setObject:password forKey:kUserPassword];
    [ud synchronize];
}

//返回userID
- (NSString *)userID{
    
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    return [ud objectForKey:kUserID];
}

- (NSString *)userPassword{
    
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    return [ud objectForKey:kUserPassword];
}

#pragma mark - path

- (NSString *)documentPath{
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSString *)glossaryPathAtGlossaryIndex:(NSInteger)inde{
    
    LETGlossary *glossary=[gm glossaryAtIndex:inde];
    NSString *glossaryName=glossary.glossaryName;
    
    NSString *documentPath=[gm documentPath];
    
    NSString *glossaryPath=[documentPath stringByAppendingPathComponent:glossaryName];
    
    return glossaryPath;
}

- (NSString *)cardPathAtGlossaryIndex:(NSInteger)inde cardIndex:(NSInteger)inde2{
    
    NSString *glossaryPath=[gm glossaryPathAtGlossaryIndex:inde];
    
    LETCard *card=[gm cardAtGlossaryIndex:inde cardIndex:inde2];
    NSString *cardName=card.cardName;
    
    NSString *cardPath=[glossaryPath stringByAppendingPathComponent:cardName];
    
    return cardPath;
}


- (NSString *)cardImagePathAtGlossaryIndex:(NSInteger)inde cardIndex:(NSInteger)inde2{
    
    NSString *path=[gm cardPathAtGlossaryIndex:inde cardIndex:inde2];
    NSString *imagePath=[path stringByAppendingPathExtension:@"jpg"];
    
    return imagePath;
}

- (NSString *)cardAudioPathAtGlossaryIndex:(NSInteger)inde cardIndex:(NSInteger)inde2{
    
    NSString *path=[gm cardPathAtGlossaryIndex:inde cardIndex:inde2];
    NSString *audioPath=[path stringByAppendingPathExtension:@"m4a"];
    
    return audioPath;
}

- (NSString *)cardSubtitlePathAtGlossaryIndex:(NSInteger)inde cardIndex:(NSInteger)inde2{
    
    NSString *path=[gm cardPathAtGlossaryIndex:inde cardIndex:inde2];
    NSString *subtitlePath=[path stringByAppendingPathExtension:@"txt"];
    
    return subtitlePath;
}

@end

#pragma mark -

@implementation LETCard

static NSString *kCardName=@"kCardName";
static NSString *kCardRecordCount=@"kCardRecordCount";

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.cardName forKey:kCardName];
    [aCoder encodeInteger:self.cardRecordCount forKey:kCardRecordCount];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    self=[super init];
    
    if (self) {
        
        [self setCardName:[aDecoder decodeObjectForKey:kCardName]];
        [self setCardRecordCount:[aDecoder decodeIntegerForKey:kCardRecordCount]];
        
    }
    return self;
}

@end

@implementation LETGlossary

static NSString *kGlossaryID=@"kGlossaryID";
static NSString *kGlossaryMakerID=@"kGlossaryMakerID";
static NSString *kGlossaryName=@"kGlossaryName";
static NSString *kGlossaryVideoPath=@"kGlossaryVideoPath";
static NSString *kGlossarySubtitlePath=@"kGlossarySubtitlePath";
static NSString *kGlossaryCards=@"kGlossaryCards";
static NSString *kGlossaryAllowSetting=@"kGlossaryAllowSetting";
static NSString *kGlossaryAllowRename=@"kGlossaryAllowRename";
static NSString *kGlossaryThumbnailImage=@"kGlossaryThumbnailImage";

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.glossaryID forKey:kGlossaryID];
    [aCoder encodeObject:self.glossaryMakerID forKey:kGlossaryMakerID];
    [aCoder encodeObject:self.glossaryName forKey:kGlossaryName];
    [aCoder encodeObject:self.glossaryVideoPath forKey:kGlossaryVideoPath];
    [aCoder encodeObject:self.glossarySubtitlePath forKey:kGlossarySubtitlePath];
    [aCoder encodeObject:self.glossaryCards forKey:kGlossaryCards];
    [aCoder encodeObject:self.glossaryThumbnailImage forKey:kGlossaryThumbnailImage];
    [aCoder encodeBool:self.glossaryAllowSetting forKey:kGlossaryAllowSetting];
    [aCoder encodeBool:self.glossaryAllowRename forKey:kGlossaryAllowRename];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    self=[super init];
    if (self) {
        
        //这个方法返回自动释放的对象，所以用这种写法防止dangling pointers
        [self setGlossaryID:[aDecoder decodeObjectForKey:kGlossaryID]];
        [self setGlossaryMakerID:[aDecoder decodeObjectForKey:kGlossaryMakerID]];
        [self setGlossaryName:[aDecoder decodeObjectForKey:kGlossaryName]];
        [self setGlossaryVideoPath:[aDecoder decodeObjectForKey:kGlossaryVideoPath]];
        [self setGlossarySubtitlePath:[aDecoder decodeObjectForKey:kGlossarySubtitlePath]];
        [self setGlossaryCards:[aDecoder decodeObjectForKey:kGlossaryCards]];
        [self setGlossaryAllowSetting:[aDecoder decodeBoolForKey:kGlossaryAllowSetting]];
        [self setGlossaryAllowRename:[aDecoder decodeBoolForKey:kGlossaryAllowRename]];
        [self setGlossaryThumbnailImage:[aDecoder decodeObjectForKey:kGlossaryThumbnailImage]];

    }
    return self;
}

@end
