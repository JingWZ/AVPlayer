//
//  GlossaryViewController.h
//  APP4
//
//  Created by user on 12-11-12.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXXPlayViewController.h"


//用来存放从文件中读取的每一组 字幕、音频和图片 的路径

//@interface IndividualData : NSObject
//
//
//@end


@interface GlossaryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) UIView *showView;

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;


@end
