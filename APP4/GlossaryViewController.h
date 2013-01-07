//
//  GlossaryViewController.h
//  APP4
//
//  Created by apple on 12-12-26.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#warning TODO 在cell前放置图片，在cell后显示生词本中数量

#import <UIKit/UIKit.h>
#import "CardViewController.h"

@interface GlossaryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *glossaryDefaults;
@property (strong, nonatomic) NSMutableArray *glossaryCustom;

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

//section0显示自定义生词本，section1显示默认生词本