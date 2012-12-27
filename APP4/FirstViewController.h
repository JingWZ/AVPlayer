//
//  FirstViewController.h
//  APP4
//
//  Created by apple on 12-12-20.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//


//设置两个同心圆，在圆周上等间距位置显示海报
//通过手势识别启动动画
//启用NSTimer，计算每一个时间点，所有海报的位置

#import <UIKit/UIKit.h>


@interface FirstViewController : UIViewController

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@property (strong, nonatomic) NSMutableArray *postersName;
@property (strong, nonatomic) NSMutableArray *posters;
@property (strong, nonatomic) NSMutableArray *postersCenterY;

@property (assign, nonatomic) float currentTime;
@property (strong) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UIView *menuView;

- (IBAction)playPressed:(id)sender;
- (IBAction)glossaryPressed:(id)sender;



@end
