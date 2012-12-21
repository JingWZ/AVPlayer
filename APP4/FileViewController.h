//
//  FileViewController.h
//  APP4
//
//  Created by apple on 12-12-12.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mTableVIew;

@property (strong, nonatomic) NSMutableArray *videoFiles;
@property (strong, nonatomic) NSMutableArray *subtitleFiles;

@property (strong, nonatomic) NSMutableArray *isCheckingOfSectionOne, *isCheckingOfSectionTwo;
@property (assign, nonatomic) NSInteger checkingNumOfSectionOne, checkingNumOfSectionTwo;

@property (assign) NSInteger checkNum;


@end
