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
#import "LETGlossaryManagement.h"
#import "ASIHTTPRequest.h"

@interface GlossaryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UINib *cellNib;

@property (strong, nonatomic) ASIHTTPRequest *aRequest;

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic) IBOutlet GlossaryCell *mGlossaryCell;

@end
