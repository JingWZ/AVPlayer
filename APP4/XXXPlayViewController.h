//
//  XXXPlayViewController.h
//  APP4
//
//  Created by user on 12-10-25.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "CardViewController.h"
#import "XXXPlayView.h"
#import "SubtitlePackage.h"
#import "ImagesPackage.h"
#import "AudiosPackage.h"

//#define videoPath @"file:///Users/user/Documents/Downton.Abbey.0306.HDTVx264.mp4"
//#define subtitlePath @"/Users/user/Documents/DowntonSubtitle0306"
//#define savePath @"/Users/user/Documents/save/"

//#define videoPath @"file:///Users/apple/Desktop/Downton.Abbey.0306.HDTVx264.mp4"
//#define subtitlePath @"/Users/apple/Desktop/DowntonSubtitle0306"
//#define savePath @"/Users/apple/Desktop/save/"

@interface XXXPlayViewController : UIViewController{
    
    NSURL *mURL;
    AVPlayer *mPlayer;
    AVPlayerItem *mPlayerItem;
    AVURLAsset *mAsset;
    SubtitlePackage *mSubtitlePackage;
    
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    id mTimeObserver;
    
    IBOutlet XXXPlayView *mPlayView;
}

@property (retain, nonatomic) NSURL *mURL;
@property (retain, nonatomic) AVPlayer *mPlayer;
@property (retain, nonatomic) AVPlayerItem *mPlayerItem;
@property (retain, nonatomic) AVURLAsset *mAsset;
@property (retain) SubtitlePackage *mSubtitlePackage;

@property (assign, nonatomic) CMTime timeToStart;

@property (copy, nonatomic) NSString *videoPath;
@property (copy, nonatomic) NSString *subtitlePath;
@property (strong, nonatomic) NSMutableArray *playerInfo;

@property (strong) NSTimer *timer;

@property (strong, nonatomic) IBOutlet XXXPlayView *mPlayView;

@property (strong, nonatomic) IBOutlet UIToolbar *mToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mPlayButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mPauseButton;
@property (strong, nonatomic) IBOutlet UISlider *mScrubber;

@property (weak, nonatomic) IBOutlet UILabel *displayTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *displayRemainTime;
@property (weak, nonatomic) IBOutlet UILabel *displayEngLabel;
@property (weak, nonatomic) IBOutlet UILabel *displayChiLabel;

@property (strong) AVAssetImageGenerator *imageGenerator;


- (IBAction)Play:(id)sender;
- (IBAction)Pause:(id)sender;
- (IBAction)Scrub:(id)sender;
- (IBAction)beginScrubbing:(id)sender;
- (IBAction)endScrubbing:(id)sender;
- (IBAction)extractImageAndAudio:(id)sender;

@end

