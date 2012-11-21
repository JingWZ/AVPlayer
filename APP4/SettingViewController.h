//
//  SettingViewController.h
//  APP4
//
//  Created by user on 12-11-15.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "GlossaryViewController.h"

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController <UIActionSheetDelegate>

@property (copy, nonatomic) NSString *fileName;

@property (assign, nonatomic) CMTime currentTime;
@property (assign, nonatomic) CMTime startTime;
@property (assign, nonatomic) CMTime endTime;
@property (assign, nonatomic) CMTime totalTime;

@property (strong, nonatomic) AVURLAsset *asset;

@property (strong, nonatomic) SubtitlePackage *subtitlePackage;


//必须要用这个方法，才可以不断同步当前的CMTime
@property (assign, nonatomic) NSInteger imageStepperValue;
@property (assign, nonatomic) NSInteger audioStartStepperValue;
@property (assign, nonatomic) NSInteger audioEndStepperValue;
@property (assign, nonatomic) NSInteger audioMergeStepperValue;


@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *labelEng;

@property (weak, nonatomic) IBOutlet UILabel *labelChi;

@property (weak, nonatomic) IBOutlet UIStepper *imageStepper;


- (IBAction)modifyImage:(UIStepper *)sender;
- (IBAction)modifyAudioStartTime:(UIStepper *)sender;
- (IBAction)modifyAudioEndTime:(UIStepper *)sender;
- (IBAction)mergeAudio:(UIStepper *)sender;


- (IBAction)saveAndBack:(id)sender;

@end
