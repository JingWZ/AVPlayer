//
//  CardSetViewController.h
//  APP4
//
//  Created by apple on 13-3-6.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LETGlossaryManagement.h"
#import "SubtitlePackage.h"
#import "ImagesPackage.h"
#import "AudiosPackage.h"
#import "MultipleTrackSlider.h"

@interface CardSetViewController : UIViewController

@property (assign, nonatomic) NSInteger glossaryIndex;
@property (assign, nonatomic) NSInteger cardIndex;

@property (copy, nonatomic) NSString *videoPath;
@property (copy, nonatomic) NSString *subtitlePath;

@property (copy, nonatomic) NSString *engSubtitle;
@property (copy, nonatomic) NSString *chiSubtitle;
@property (assign, nonatomic) CGFloat audioStart;
@property (assign, nonatomic) CGFloat audioEnd;
@property (assign, nonatomic) CGFloat imageTime;

@property (strong, nonatomic) AVURLAsset *mAsset;
@property (strong, nonatomic) AVAudioPlayer *mAudioPlayer;

@property (strong, nonatomic) SubtitlePackage *subtitlePackage;

@property (weak, nonatomic) IBOutlet UIImageView *mImageView;
@property (weak, nonatomic) IBOutlet UITextField *engTF;
@property (weak, nonatomic) IBOutlet UITextField *chiTF;
@property (strong, nonatomic) MultipleTrackSlider *slider;
@property (assign, nonatomic) NSInteger sliderScale;

- (IBAction)engModify:(UITextField *)sender;
- (IBAction)chiModify:(UITextField *)sender;
- (IBAction)stepperPressed:(UIStepper *)sender;
- (IBAction)playBack:(id)sender;


@end
