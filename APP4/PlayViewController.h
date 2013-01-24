//
//  PlayViewController.h
//  APP4
//
//  Created by apple on 13-1-4.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "PlayView.h"
#import "SubtitlePackage.h"
#import "LabelView.h"
#import "CountLabel.h"
#import "PlayButton.h"

#import "GlossaryManagement.h"

#define kLastPlayInfoKey @"lastPlayInfo"



@interface PlayViewController : UIViewController{
    AVPlayer *mPlayer;
    AVPlayerItem *mPlayerItem;
    AVURLAsset *mAsset;
    SubtitlePackage *mSubtitlePackage;
    
    id mTimeObserver;
    BOOL seekToZeroBeforePlay;
    float mRestoreAfterScrubbingRate;
    float timeOffset;
    UITapGestureRecognizer *tapGesture;
    
}

@property (copy, nonatomic) NSString *videoPath;
@property (copy, nonatomic) NSString *subtitlePath;
@property (strong, nonatomic) NSMutableArray *lastPlayInfo;
@property (assign, nonatomic) CMTime lastStartTime;
@property (strong) NSTimer *timer;
@property (strong) NSTimer *countTimer;
@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) float countAnimationDuration;
@property (assign, nonatomic) NSInteger glossaryIndex;
@property (strong, nonatomic) LabelView *titleView;
@property (strong, nonatomic) PlayButton *playBtn;
@property (strong, nonatomic) PauseButton *pauseBtn;
@property (strong, nonatomic) CountLabel *countLbl;

@property (weak, nonatomic) IBOutlet PlayView *mPlayView;
@property (weak, nonatomic) IBOutlet UILabel *lblEng;
@property (weak, nonatomic) IBOutlet UILabel *lblChi;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *lblRemainTime;

@property (strong, nonatomic) IBOutlet UIView *barBottomView;
@property (weak, nonatomic) IBOutlet UISlider *mScrubber;

- (void)playPressed;
- (void)pausePressed;
- (IBAction)beginScrubbing:(id)sender;
- (IBAction)endScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;

@end
