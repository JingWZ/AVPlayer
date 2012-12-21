//
//  FileViewController.h
//  APP4
//
//  Created by apple on 12-12-12.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//


//获取documents中的文件，在表中分别显示视频和字幕文件
//判断是否选中了视频和字幕，都选中后显示按钮play，以便用户跳到播放界面

#import <UIKit/UIKit.h>

@interface FileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mTableVIew;

@property (strong, nonatomic) NSMutableArray *videoFiles;
@property (strong, nonatomic) NSMutableArray *subtitleFiles;

@property (assign, nonatomic) NSInteger selectedVideoNumber;
@property (assign, nonatomic) NSInteger selectedSubtitleNumber;

@end
