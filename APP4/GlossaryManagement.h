//
//  GlossaryManagement.h
//  APP4
//
//  Created by apple on 13-1-22.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGlossaryDefault @"glossaryDefault"
#define kGlossaryCustom @"glossaryCustom"

@interface GlossaryManagement : NSObject


//update glossary
- (NSDictionary *)getGlossaryWithGlossaryPath:(NSString *)gPath
                                    videoPath:(NSString *)vPath
                                 subtitlePath:(NSString *)sPath
                                        cards:(NSMutableArray *)cards;
- (void)addGlossaryInDefault:(NSDictionary *)glossary;
- (void)addGlossaryInCustom:(NSDictionary *)glossary;

- (void)updateGlossaryToZeroIndexWithGlossaryPath:(NSString *)path;

//update cards
- (void)addCardInDefaultWithSavePath:(NSString *)iPath
                         recordCount:(NSInteger)count
                               video:(NSString *)vPath
                            subtitle:(NSString *)sPath;
//
- (void)addCardInCustom:(NSDictionary *)glossary
          WithImagePath:(NSString *)iPath
            recordCount:(NSInteger)count
                  video:(NSString *)vPath
               subtitle:(NSString *)sPath;

//modify eachCard

//get glossary path
- (NSMutableArray *)getDefaultGlossariesPath;
- (NSMutableArray *)getCustomGlossariesPath;

//get glossary name
- (NSMutableArray *)getDefaultGlossariesName;
- (NSMutableArray *)getCustomGlossariesName;

@end
