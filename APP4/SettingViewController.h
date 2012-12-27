//
//  SettingViewController.h
//  APP4
//
//  Created by user on 12-11-15.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SubtitlePackage.h"
#import "ImagesPackage.h"
#import "AudiosPackage.h"

@interface SettingViewController : UIViewController <UIActionSheetDelegate>

@property (copy, nonatomic) NSString *videoPath;
@property (copy, nonatomic) NSString *subtitlePath;
@property (copy, nonatomic) NSString *savePath;
@property (copy, nonatomic) NSString *fileName;

@property (strong, nonatomic) AVURLAsset *mAsset;
@property (strong, nonatomic) SubtitlePackage *mSubtitlePackage;

@property (assign, nonatomic) float currentT, startT, endT;
@property (assign, nonatomic) NSInteger mergeStpValue;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textEng;
@property (weak, nonatomic) IBOutlet UITextField *textChi;
@property (weak, nonatomic) IBOutlet UIStepper *imageStp;
@property (weak, nonatomic) IBOutlet UIStepper *startStp;
@property (weak, nonatomic) IBOutlet UIStepper *endStp;
@property (weak, nonatomic) IBOutlet UIStepper *mergeStp;

- (IBAction)modifyImage:(UIStepper *)sender;
- (IBAction)modifyAudioStartTime:(UIStepper *)sender;
- (IBAction)modifyAudioEndTime:(UIStepper *)sender;
- (IBAction)mergeAudio:(UIStepper *)sender;
- (IBAction)finishExitEng:(id)sender;
- (IBAction)finishExitChi:(id)sender;

- (IBAction)saveAndBack:(id)sender;

@end
