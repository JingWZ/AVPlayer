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


@property (strong, nonatomic) NSMutableArray *glossaryDefault;
@property (strong, nonatomic) NSMutableArray *glossaryCustom;


- (NSDictionary *)getGlossaryWithIndex:(NSInteger)index
                     glossary:(NSString *)gPath
                        video:(NSString *)vPath
                     subtitle:(NSString *)sPath
                        cards:(NSMutableArray *) cards;

- (void)addGlossaryInDefault:(NSDictionary *)glossary;
- (void)addGlossaryInCustom:(NSDictionary *)glossary;

- (void)addCardWithImagePath:(NSString *)iPath recordCount

@end
