//
//  GlossaryPackage.h
//  APP4
//
//  Created by user on 12-11-14.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlossaryPackage : NSObject

@property (strong, nonatomic) NSArray *dataArray;

- (GlossaryPackage *)initWithFile:(NSString *)path;


@end
