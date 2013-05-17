//
//  XXXAppDelegate.h
//  APP4
//
//  Created by user on 12-10-25.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XXXAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@end

//储存结构
/*
把所有的截图/音频/字幕存入生词本，生词本存入Documents下
 一共有两种生词本，一种是播放视频截图后，自动生成的以视频名为名的文件夹；文件夹中还要存入该视频和字幕的path，以便之后在settingView中使用
 还有一种是用户自定义的生词本，文件名由用户输入
在userDefaults中存入最后一次播放的视频/字幕路径，以及时间，以便下次可以重新载入
在userDefaults中存入两种生词本的array，以便初始化glossaryView
*/