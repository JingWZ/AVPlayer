//
//  PopMenu.h
//  Quartz2DButton
//
//  Created by apple on 13-1-19.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddButton.h"

@interface PopMenu : UIScrollView

@property (assign, nonatomic) CGFloat itemHeight;
@property (assign, nonatomic) CGFloat itemWidth;
@property (assign, nonatomic) CGFloat itemOriginX;
@property (assign, nonatomic) CGFloat itemOriginY;

@property (assign, nonatomic) CGRect addBtnFrame;

@property (strong, nonatomic) NSMutableArray *itemContents;
@property (strong, nonatomic) NSMutableArray *itemBtns;

@property (strong, nonatomic) UIControl *backgroundView;
@property (strong, nonatomic) AddButton *addBtn;
@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) UIColor *itemBtnColor;


- (PopMenu *)initWithFrame:(CGRect)frame Contents:(NSArray *)contents;
- (void)showPopMenuInView:(UIView *)view;

@end
