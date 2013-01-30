//
//  GlossaryViewController.h
//  APP4
//
//  Created by apple on 12-12-26.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "CardViewController.h"
#import "GlossaryCell.h"

#import "GlossaryManagement.h"


@interface GlossaryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *glossaryDefaults;
@property (strong, nonatomic) NSMutableArray *glossaryCustom;

@property (strong, nonatomic) UINib *cellNib;


@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic) IBOutlet GlossaryCell *mGlossaryCell;

@end

//section0显示自定义生词本，section1显示默认生词本