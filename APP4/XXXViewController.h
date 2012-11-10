//
//  XXXViewController.h
//  APP4
//
//  Created by user on 12-10-25.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XXXPlayViewController;

@interface XXXViewController : UIViewController

@property (retain, nonatomic) XXXPlayViewController *playViewController;

- (IBAction)playPressed:(id)sender;

@end
