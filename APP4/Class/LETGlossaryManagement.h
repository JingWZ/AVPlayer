//
//  LETGlossaryManagement.h
//  LearnEnglishByTVSeries
//
//  Created by apple on 13-2-16.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 
 ****************
 把用户ID在第一次登陆时存到UserDefault里
 ****************
 
 ****************
 Management的操作
 1.创建一个新的Glossary
 2.取得所有的Glossary，显示在MyGlossary页面中，包含 图片、名字、制作者、Card数量、（简介）
 ****************
 
 ****************
 Glossary包含：
 1.GlossaryID，以日期+时间+制作者ID命名
 2.GlossaryName，存入视频名，在使用前加入Document的地址，以便在不同用户设备上使用
 3.VideoPath，存入视频的文件名，以便在setting里调用
 4.SubtitlePath，存入生词本的文件名，以便在setting里调用
 5.Cards，Card做一个单独的类，用一个NSArray来包含所有的Card
 （只有在用视频制作的Glossary里，才能够调用setting功能，在自定义Gloss和下载的Gloss里面不提供该功能）
 6.一个BOOL值，表明该生词本是否能够调用setting
 7.ThumbnailImage，用来显示在MyGlossary中，以第一个Card的图片，以后可以添加自定义该图片功能
 8.GlossaryMaker，存储制作者的ID
 9.CardCount，存储内部包含的卡片数量
 10.一个BOOL值，表明该生词本是否能被改名和改introduction。如果是下载的，为NO，其他为YES
 11.index，表明生词本在所有生词本中的位置
 ****************
 
 ****************
 Card包含：
 1.CardName，图片、音频、字幕用一个文件名，加上不同的后缀，之前加上Glossary的Path
 2.录音次数
 ****************
 */



@interface LETCard : NSObject<NSCoding>
@property (copy, nonatomic) NSString *cardName;
@property (assign, nonatomic) NSInteger cardRecordCount;
@end

@interface LETGlossary : NSObject<NSCoding>
@property (assign, nonatomic) NSInteger glossaryIndex;
@property (copy, nonatomic) NSString *glossaryID;
@property (copy, nonatomic) NSString *glossaryMakerID;
@property (copy, nonatomic) NSString *glossaryName;
//要改成name
@property (copy, nonatomic) NSString *glossaryVideoPath;
@property (copy, nonatomic) NSString *glossarySubtitlePath;
@property (copy, nonatomic) NSString *glossaryThumbnailImage;
@property (strong, nonatomic) NSMutableArray *glossaryCards;
@property (assign, nonatomic) BOOL glossaryAllowRename;
@property (assign, nonatomic) BOOL glossaryAllowSetting;


@end

@interface LETGlossaryManagement : NSObject

+ (LETGlossaryManagement *)sharedInstance;

//存取userID和userPassword=================================================================
- (void)saveUserID:(NSString *)userID andPassword:(NSString *)password;
- (NSString *)userID;
- (NSString *)userPassword;

//glossary=================================================================
//在
- (NSMutableArray *)allGlossaries;
- (LETGlossary *)glossaryAtIndex:(NSInteger)inde;
- (NSString *)glossaryVideoPathAtIndex:(NSInteger)inde;
- (NSString *)glossarySubtitlePathAtIndex:(NSInteger)inde;
//生词本文件的路径名
- (NSString *)glossaryPathAtGlossaryIndex:(NSInteger)inde;
//在添加自定义Gloss时使用
- (LETGlossary *)glossaryWithName:(NSString *)name;
//在通过视频制作Gloss时使用，如果已存在，就返回已存在的，否则创建一个新的返回
- (LETGlossary *)glossaryWithVideoPath:(NSString *)p1 SubtitlePath:(NSString *)p2;

//card=================================================================
- (void)addCardAtIndex:(NSInteger)inde name:(NSString *)name recordCount:(NSInteger)count;

//在Card页中使用
- (NSMutableArray *)allGlossaryCardsAtGlossaryIndex:(NSInteger)inde;
- (LETCard *)cardAtGlossaryIndex:(NSInteger)inde cardIndex:(NSInteger)inde2;
- (NSString *)cardPathAtGlossaryIndex:(NSInteger)inde cardIndex:(NSInteger)inde2;
- (NSString *)cardImagePathAtGlossaryIndex:(NSInteger)inde cardIndex:(NSInteger)inde2;
- (NSString *)cardAudioPathAtGlossaryIndex:(NSInteger)inde cardIndex:(NSInteger)inde2;
- (NSString *)cardSubtitlePathAtGlossaryIndex:(NSInteger)inde cardIndex:(NSInteger)inde2;

@end









