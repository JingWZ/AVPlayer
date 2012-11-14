//
//  XXXViewController.h
//  APP4
//
//  Created by user on 12-10-25.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XXXPlayViewController;
@class GlossaryViewController;

@interface XXXViewController : UIViewController

@property (retain, nonatomic) XXXPlayViewController *playViewController;
@property (retain, nonatomic) GlossaryViewController *glossaryViewController;

- (IBAction)playPressed:(id)sender;
- (IBAction)glossaryPredded:(id)sender;

@end

//需要修正：如果用户按的那个点，恰好没有字幕，那么就不要截图