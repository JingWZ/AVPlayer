//
//  PlayViewController.m
//  APP4
//
//  Created by apple on 13-1-4.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//

#import "PlayViewController.h"
#import "CardViewController.h"
#import "ImagesPackage.h"
#import "AudiosPackage.h"
#import "MBProgressHUD.h"


#define kTimeScale 60.0
#define kIntervalToHide 10.0
#define kHeightToShowButtons 80.0
#define kLastPlayInfoKey @"lastPlayInfo"
#define kGlossaryCatalog @"glossaryCatalog"

@interface PlayViewController ()

@end

static void *PlayViewControllerStatusObservationContext = &PlayViewControllerStatusObservationContext;
static void *PlayViewControllerCurrentItemObservationContext = &PlayViewControllerCurrentItemObservationContext;

@implementation PlayViewController
@synthesize mPlayView;
@synthesize lblEng;
@synthesize lblChi;
@synthesize lblCurrentTime;
@synthesize lblRemainTime;
@synthesize barBottomView;
@synthesize mScrubber;
@synthesize timer;

#pragma mark - scrubber

-(void)syncScrubber{
    
    CMTime playerDuration=[self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        mScrubber.minimumValue=0.0;
        return;
    }
    double duration=CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        float minValue=[mScrubber minimumValue];
        float maxValue=[mScrubber maximumValue];
        double time=CMTimeGetSeconds([mPlayer currentTime]);
        [mScrubber setValue:(maxValue-minValue)*time/duration+minValue];
    }
}

- (IBAction)scrub:(id)sender {
    
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider *slider=sender;
        CMTime playerDuration=[self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        double duration=CMTimeGetSeconds(playerDuration);
        if (isfinite(duration)) {
            float minValue=[slider minimumValue];
            float maxValue=[slider maximumValue];
            float value=[slider value];
            double time=duration * (value-minValue)/(maxValue-minValue);
            [mPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
            [self syncTimeLabel];
            [self syncSubtitle];
        }
    }
}

- (IBAction)beginScrubbing:(id)sender {
    
    mRestoreAfterScrubbingRate=[mPlayer rate];
    [mPlayer setRate:0.f];
    [self removeTimeObserver];
    
    [self.timer invalidate];
    
}

- (IBAction)endScrubbing:(id)sender {
    
    if (!mTimeObserver) {
        CMTime playerDuration=[self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        double duration=CMTimeGetSeconds(playerDuration);
        if (isfinite(duration)) {
            [self syncDisplayItems];
        }
    }
    
    if (mRestoreAfterScrubbingRate) {
        [mPlayer setRate:mRestoreAfterScrubbingRate];
        mRestoreAfterScrubbingRate=0.f;
    }
    
    self.timer=[NSTimer scheduledTimerWithTimeInterval:kIntervalToHide target:self selector:@selector(hideBarItems) userInfo:nil repeats:NO];
    
}

#pragma mark - time label

- (void)syncTimeLabel{
    
    CMTime playerDuration=[self playerItemDuration];
    CMTime currentTime=[mPlayer currentTime];
    CMTime remainTime=CMTimeSubtract(playerDuration, currentTime);
    
    self.lblCurrentTime.text=[NSString stringWithFormat:@"%@",[self getTimeStr:currentTime]];
    self.lblRemainTime.text=[NSString stringWithFormat:@"%@",[self getTimeStr:remainTime]];
    
}

- (NSString *)getTimeStr:(CMTime)time{
    int timeInSecond=(int)CMTimeGetSeconds(time);
    
    NSString *hour;
    if (timeInSecond/3600>0)
        hour=[NSString stringWithFormat:@"%d:",timeInSecond/3600];
    else
        hour=@" ";
    
    NSString *min=[NSString stringWithFormat:@"%d:",timeInSecond%3600/60];
    
    NSString *sec;
    if (timeInSecond%3600%60<10)
        sec=[NSString stringWithFormat:@"0%d",timeInSecond%3600%60];
    else
        sec=[NSString stringWithFormat:@"%d",timeInSecond%3600%60];
    
    NSString *timeStr=[[hour stringByAppendingString:min] stringByAppendingString:sec];
    return timeStr;
}


#pragma mark - action

- (void)playPressed{
    if (YES==seekToZeroBeforePlay) {
        seekToZeroBeforePlay=NO;
        [mPlayer seekToTime:kCMTimeZero];
    }
    [mPlayer play];
    [self.pauseBtn setHidden:NO];
    [self.playBtn setHidden:YES];
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer=[NSTimer scheduledTimerWithTimeInterval:kIntervalToHide target:self selector:@selector(hideBarItems) userInfo:nil repeats:NO];

}

- (void)pausePressed{
    [mPlayer pause];
    [self.playBtn setHidden:NO];
    [self.pauseBtn setHidden:YES];
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer=nil;
    }
}

- (void)backToFileView{
    
    if (CMTIME_IS_VALID(mPlayer.currentTime)) {
        [self.lastPlayInfo removeAllObjects];
        [self.lastPlayInfo addObject:self.videoPath];
        [self.lastPlayInfo addObject:self.subtitlePath];
        
        //if video reaches the end, save the kCMTimeZero
        float seconds;
        if (!CMTimeCompare(mPlayerItem.duration, mPlayer.currentTime)) {
            seconds=0.f;
        }else{
            seconds=CMTimeGetSeconds(mPlayer.currentTime);
        }
        [self.lastPlayInfo addObject:[NSNumber numberWithFloat:seconds]];
        [self saveLastPlayInfo];
    }
    [mPlayer pause];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moveToCardView{
    
    CardViewController *cardVC=[[CardViewController alloc] initWithNibName:@"CardViewController" bundle:nil];
    cardVC.savePath=[self savePath];
    cardVC.videoPath=self.videoPath;
    cardVC.subtitlePath=self.subtitlePath;
    [self.navigationController pushViewController:cardVC animated:YES];
    [mPlayer pause];
}



- (void)actWhenTap:(UITapGestureRecognizer *)gesture{
    
    CGPoint point=[gesture locationInView:self.view];
    
    //if tap on the top or bottom of the view, show the buttons. otherwise extract the image
    if (point.y<kHeightToShowButtons || point.y>=(self.view.bounds.size.height-kHeightToShowButtons)) {
        [self showBarItems];
    }else{
        [self extractImageAndAudio];
    }
    
}

#pragma mark - synchronize

- (void)showBarItems{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.barBottomView setFrame:CGRectMake(0, self.view.bounds.size.height-kHeightToShowButtons, self.view.bounds.size.width, kHeightToShowButtons)];
    [self.titleView setText:[self systemTime]];
    self.timer=[NSTimer scheduledTimerWithTimeInterval:kIntervalToHide target:self selector:@selector(hideBarItems) userInfo:nil repeats:NO];
}

- (void)hideBarItems{
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.barBottomView setFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, kHeightToShowButtons)];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer=nil;
    }
}

- (void)syncDisplayItems{
    __block typeof(self) bself = self;
    mTimeObserver=[mPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, kTimeScale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [bself syncSubtitle];
        [bself syncTimeLabel];
        [bself syncScrubber];
        
    }];
}


- (void)syncSubtitle{
    
    CMTime currentTime=[mPlayer currentTime];
    NSUInteger index=[mSubtitlePackage indexOfProperSubtitleWithGivenCMTime:currentTime];
    
    IndividualSubtitle *currentSubtitle=[mSubtitlePackage.subtitleItems objectAtIndex:index];
    self.lblEng.text=currentSubtitle.EngSubtitle;
    self.lblChi.text=currentSubtitle.ChiSubtitle;
    
}

- (NSString *)systemTime{
    
    NSDate *now=[NSDate date];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *nowStr=[dateFormatter stringFromDate:now];
    
    return nowStr;
}

#pragma mark - save

- (void)extractImageAndAudio {
    
    [self createSaveFile];
    
    CMTime currentTime=[mPlayer currentTime];
    NSString *saveName=[mSubtitlePackage makeSaveName:currentTime];
    NSString *path=[[self savePath] stringByAppendingPathComponent:saveName];
    
    NSUInteger index=[mSubtitlePackage indexOfProperSubtitleWithGivenCMTime:currentTime];
    IndividualSubtitle *currentSubtitle=[mSubtitlePackage.subtitleItems objectAtIndex:index];
    
    //if there is no English subtitle, do not extract the image
    if (index && (![currentSubtitle.EngSubtitle isEqualToString:@" "])) {
        //extract subtitle
        [mSubtitlePackage saveSubtitleWithTime:currentTime inPath:path];
        //extract image
        ImagesPackage *imagePackage=[[ImagesPackage alloc]initWithAsset:mAsset];
        [imagePackage saveImageWithTime:currentTime inPath:path];
        //extract audio
        AudiosPackage *audioPackage=[[AudiosPackage alloc]initWithAsset:mAsset];
        IndividualSubtitle *currentSubtitle=[mSubtitlePackage.subtitleItems objectAtIndex:index];
        CMTimeRange range=CMTimeRangeFromTimeToTime(currentSubtitle.startTime, currentSubtitle.endTime);
        [audioPackage saveAudioWithRange:range inPath:path];
        //show icon to show that successfully save the extracted things
        
    }
}

- (void)createSaveFile{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self savePath]]) {
        //create a file, save images, audios and subtitles
        [[NSFileManager defaultManager] createDirectoryAtPath:[self savePath] withIntermediateDirectories:NO attributes:nil error:nil];
        //save this file path to userDefaults, to restore it in GlossaryView
        NSMutableArray *glossaryCatalog;
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        if ([userDefaults arrayForKey:kGlossaryCatalog]) {
            glossaryCatalog=[NSMutableArray arrayWithArray:[userDefaults arrayForKey:kGlossaryCatalog]];
        }else{
            glossaryCatalog=[NSMutableArray arrayWithCapacity:0];
        }
        [glossaryCatalog addObject:[self savePath]];
        [userDefaults setObject:glossaryCatalog forKey:kGlossaryCatalog];
        [userDefaults synchronize];
        
        //save video&subtitle path in this file, to use it in SettingView
        NSString *saveVideoPath=[[self savePath] stringByAppendingPathComponent:@"videoPath"];
        NSString *saveSubtitlePath=[[self savePath] stringByAppendingPathComponent:@"subtitlePath"];
        
        [self.videoPath writeToFile:saveVideoPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [self.subtitlePath writeToFile:saveSubtitlePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
}

- (NSString *)savePath{
    
    NSString *userPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName=[[self.videoPath lastPathComponent] stringByDeletingPathExtension];
    NSString *savePath=[userPath stringByAppendingPathComponent:fileName];
    return savePath;
    
}

- (void)saveLastPlayInfo{
    NSUserDefaults *lastPlayInfo=[NSUserDefaults standardUserDefaults];
    [lastPlayInfo setObject:self.lastPlayInfo forKey:kLastPlayInfoKey];
    [lastPlayInfo synchronize];
}

#pragma mark - init

- (void)obtainLastPlayInfo{
    
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    
    //获得上次播放信息
    if ([userDefaults arrayForKey:kLastPlayInfoKey]) {
        self.lastPlayInfo=[NSMutableArray arrayWithArray:[userDefaults arrayForKey:kLastPlayInfoKey]];
    }else{
        self.lastPlayInfo=[NSMutableArray arrayWithCapacity:4];//把照片也存进去，在首页显示
    }
    
    //如果上次播放过，则载入上次播放位置
    if (self.lastPlayInfo.count) {
        NSString *lastVideo=[self.lastPlayInfo objectAtIndex:0];
        NSString *lastSubtitle=[self.lastPlayInfo objectAtIndex:1];
        if ([lastVideo isEqualToString:self.videoPath] && [lastSubtitle isEqualToString:self.subtitlePath]) {
            self.lastStartTime=CMTimeMakeWithSeconds([[self.lastPlayInfo objectAtIndex:2] floatValue], kTimeScale);
        }else{
            self.lastStartTime=kCMTimeZero;
        }
    }else{
        self.lastStartTime=kCMTimeZero;
    }
}

- (void)initAVPlayer{
    NSURL *url=[NSURL fileURLWithPath:self.videoPath];
    mAsset=[AVURLAsset URLAssetWithURL:url options:nil];
    
    NSArray *requestedKey=[NSArray arrayWithObject:@"tracks"];
    [mAsset loadValuesAsynchronouslyForKeys:requestedKey completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self prepareToPlayAsset:mAsset withKeys:requestedKey];
        });
    }];
}

- (void)initButtonsInBottomBar{
    
    self.playBtn=[[PlayButton alloc] initWithFrame:CGRectMake(420, 20, 45, 45)];
    [self.playBtn addTarget:self action:@selector(playPressed) forControlEvents:UIControlEventTouchDown];
    [self.barBottomView addSubview:self.playBtn];
    [self.playBtn setHidden:YES];
    
    self.pauseBtn=[[PauseButton alloc] initWithFrame:CGRectMake(420, 20, 45, 45)];
    [self.barBottomView addSubview:self.pauseBtn];
    [self.pauseBtn addTarget:self action:@selector(pausePressed) forControlEvents:UIControlEventTouchDown];
}

#pragma mark - defaults

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    //get last play info, to load last play time
    [self obtainLastPlayInfo];
    //init AVPlayer
    [self initAVPlayer];
    //init Subtitle
    mSubtitlePackage=[[SubtitlePackage alloc] initWithFile:self.subtitlePath];
    //init top bar and bottom bar
    [self initButtonsInBottomBar];
    [self.barBottomView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
    [self.view addSubview:self.barBottomView];
    [self hideBarItems];
    //add gestureRecognizer
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actWhenTap:)];
    [self.view addGestureRecognizer:tapGesture];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //when load video, show progress in the view
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //init top bar button
    UIColor *buttonColor=[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToFileView)];
    [backButton setTintColor:buttonColor];
    UIBarButtonItem *cardButton=[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(moveToCardView)];
    [cardButton setTintColor:buttonColor];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationItem setRightBarButtonItem:cardButton];
    //init top bar title
    self.titleView=[[LabelView alloc] init];
    [self.titleView setCenter:CGPointMake(self.view.center.x, 30)];
    [self.titleView setBounds:CGRectMake(0, 0, 70, 50)];
    [self.titleView setBackgroundColor:[UIColor clearColor]];
    [self.titleView setText:[self systemTime]];
    [self.titleView setFont:[UIFont boldSystemFontOfSize:20]];
    [self.titleView setTextColor:[UIColor grayColor]];
    [self.titleView setShadowColor:[UIColor whiteColor]];
    [self.titleView setShadowOffset:CGSizeMake(0, 0)];
    [self.titleView setShadowRadius:1];
    [self.navigationItem setTitleView: self.titleView];
    
}

- (void)viewDidUnload
{
    [self setMPlayView:nil];
    [self setLblEng:nil];
    [self setLblChi:nil];
    [self setBarBottomView:nil];
    [self setMScrubber:nil];
    [self setLblCurrentTime:nil];
    [self setLblRemainTime:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - player

- (CMTime)playerItemDuration{
    AVPlayerItem *playerItem=[mPlayer currentItem];
    if (playerItem.status==AVPlayerItemStatusReadyToPlay) {
        return ([playerItem duration]);
    }
    return kCMTimeInvalid;
}

- (void)removeTimeObserver{
    if (mTimeObserver) {
        [mPlayer removeTimeObserver:mTimeObserver];
        mTimeObserver=nil;
    }
}

-(void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys{
    
    if (mPlayerItem) {
        [mPlayerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:mPlayerItem];
    }
    
    mPlayerItem=[AVPlayerItem playerItemWithAsset:asset];
    [mPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:PlayViewControllerStatusObservationContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:mPlayerItem];
    seekToZeroBeforePlay=NO;
    
    if (!mPlayer) {
        mPlayer=[AVPlayer playerWithPlayerItem:mPlayerItem];
        [mPlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:PlayViewControllerCurrentItemObservationContext];
    }
    
    [mPlayer play];
    [mPlayer seekToTime:self.lastStartTime];
    [self syncScrubber];
    
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error{
    
    [self removeTimeObserver];
    //    [self disableScrubber];
    //    [self disablePlayerButtons];
    
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:[error localizedDescription] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)playerItemDidReachEnd:(NSNotification *)notification{
    
    //    [self.playerInfo replaceObjectAtIndex:2 withObject:[NSNumber numberWithFloat:0]];
    //    [self savePlayInfo];
    //    [self showPlayButton];
    seekToZeroBeforePlay = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (context==PlayViewControllerStatusObservationContext) {
        //[self syncPlayPauseButtons];
        AVPlayerStatus status=[[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown:
            {
                [self removeTimeObserver];
                //[self disableScrubber];
                //[self disablePlayerButtons];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                [self syncDisplayItems];
                //[self initDisplayItems];
                //[self enablePlayerButtons];
                //[self enableScrubber];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem=(AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
    }
    
    else if (context==PlayViewControllerCurrentItemObservationContext){
        AVPlayerItem *newPlayerItem=[change objectForKey:NSKeyValueChangeNewKey];
        if (newPlayerItem==(id)[NSNull null]) {
            //[self disablePlayerButtons];
            //[self disableScrubber];
        }else{
            [mPlayView setPlayer:mPlayer];
            //[self setviewDisplayName];
            [mPlayView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            //[self syncPlayPauseButtons];
        }
    }
    
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
