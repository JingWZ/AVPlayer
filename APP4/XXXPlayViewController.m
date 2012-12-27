//
//  XXXPlayViewController.m
//  APP4
//
//  Created by user on 12-10-25.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//


#import "XXXPlayViewController.h"
#import "MBProgressHUD.h"

#define kTimescale 60.0
#define kHideInterval 5.0
#define kPlayerInfo @"playerInfo"
#define KVGlossaryDefaults @"glossaryDefaults"

@interface XXXPlayViewController ()

- (void)showStopButton;
- (void)showPlayButton;
- (void)syncPlayPauseButtons;
- (void)initDisplayItems;
- (void)syncScrubber;

@end

@interface XXXPlayViewController (Player)

- (BOOL)isPlaying;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;
- (CMTime)playerItemDuration;
- (void)removePlayerTimeObserver;
- (void)playerItemDidReachEnd:(NSNotification *)notification;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end

static void *PlayViewControllerRateObservationContext = &PlayViewControllerRateObservationContext;
static void *PlayViewControllerStatusObservationContext = &PlayViewControllerStatusObservationContext;
static void *PlayViewControllerCurrentItemObservationContext = &PlayViewControllerCurrentItemObservationContext;


@implementation XXXPlayViewController

@synthesize mToolbar, mPlayButton, mPauseButton, mScrubber;
@synthesize displayTimeLabel, displayRemainTime, displayEngLabel, displayChiLabel;
@synthesize mURL, mAsset, mPlayer, mPlayerItem, mPlayView;
@synthesize mSubtitlePackage;
@synthesize videoPath, subtitlePath, playerInfo;
@synthesize timer;

#pragma mark - button

- (IBAction)Play:(id)sender {
    
    if (YES==seekToZeroBeforePlay) {
        seekToZeroBeforePlay=NO;
        [mPlayer seekToTime:kCMTimeZero];
    }
    [mPlayer play];
    [self showStopButton];

}

- (IBAction)Pause:(id)sender {
    [mPlayer pause];
    [self showPlayButton];
}


- (void)showStopButton{
    NSMutableArray *toolbarItems=[NSMutableArray arrayWithArray:[mToolbar items]];
    [toolbarItems replaceObjectAtIndex:0 withObject:mPauseButton];
    mToolbar.items=toolbarItems;
}

-(void)showPlayButton{
    NSMutableArray *toolbarItems=[NSMutableArray arrayWithArray:[mToolbar items]];
    [toolbarItems replaceObjectAtIndex:0 withObject:mPlayButton];
    mToolbar.items=toolbarItems;
}

-(void)syncPlayPauseButtons{
    if ([self isPlaying]) {
        [self showStopButton];
    }else{
        [self showPlayButton];
    }
}

- (void)enablePlayerButtons{
    self.mPlayButton.enabled=YES;
    self.mPauseButton.enabled=YES;
}

- (void)disablePlayerButtons{
    self.mPlayButton.enabled=NO;
    self.mPauseButton.enabled=NO;
}

#pragma mark - display items

//显示进度条，字幕，时间标签
- (void)initDisplayItems{
    
    __block typeof(self) bself = self;
    mTimeObserver=[mPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, kTimescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [bself syncScrubber];
        [bself syncSubtitle];
        [bself syncTimeLabel];
    }];
    
}

- (void)hideDisplayItems{
    
    [timer invalidate];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [mToolbar setHidden:YES];
    [self.displayTimeLabel setHidden:YES];
    [self.displayRemainTime setHidden:YES];
}

- (void)showDisplayItems:(UITapGestureRecognizer *)gesture{
    
    CGPoint point=[gesture locationInView:self.view];
    
    //如果点在上下导航栏上，则显示导航栏；否则截图和音频
    if (point.y<self.navigationController.navigationBar.bounds.size.height || point.y>=(self.view.bounds.size.height-self.mToolbar.bounds.size.height)) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [mToolbar setHidden:NO];
        [self.displayTimeLabel setHidden:NO];
        [self.displayRemainTime setHidden:NO];

        timer=[NSTimer scheduledTimerWithTimeInterval:kHideInterval target:self selector:@selector(hideDisplayItems) userInfo:nil repeats:NO];
    }else{
        [self extractImageAndAudio];
    }

}

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

- (IBAction)Scrub:(id)sender {
    
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
    [self removePlayerTimeObserver];
    
    [timer invalidate];
    
}

- (IBAction)endScrubbing:(id)sender {
    
    if (!mTimeObserver) {
        
        CMTime playerDuration=[self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration=CMTimeGetSeconds(playerDuration);
        if (isfinite(duration)) {
            __block typeof(self) bself = self;
            mTimeObserver=[mPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, kTimescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time){
                [bself syncScrubber];
                [bself syncSubtitle];
                [bself syncTimeLabel];
            }];
        }
    }
    
    if (mRestoreAfterScrubbingRate) {
        [mPlayer setRate:mRestoreAfterScrubbingRate];
        mRestoreAfterScrubbingRate=0.f;
    }
    
    timer=[NSTimer scheduledTimerWithTimeInterval:kHideInterval target:self selector:@selector(hideDisplayItems) userInfo:nil repeats:NO];
}

- (void)enableScrubber{
    self.mScrubber.enabled=YES;
}

- (void)disableScrubber{
    self.mScrubber.enabled=NO;
}

#pragma mark - time label

- (void)syncTimeLabel{
    
    CMTime playerDuration=[self playerItemDuration];
    CMTime currentTime=[self.mPlayer currentTime];
    CMTime remainTime=CMTimeSubtract(playerDuration, currentTime);
    
    self.displayTimeLabel.text=[NSString stringWithFormat:@"%@",[self getTimeStr:currentTime]];
    self.displayRemainTime.text=[NSString stringWithFormat:@"%@",[self getTimeStr:remainTime]];

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

#pragma mark - subtitle

- (void)syncSubtitle{
    
    CMTime currentTime=[self.mPlayer currentTime];
    NSUInteger index=[self.mSubtitlePackage indexOfProperSubtitleWithGivenCMTime:currentTime];
    
    IndividualSubtitle *currentSubtitle=[self.mSubtitlePackage.subtitleItems objectAtIndex:index];
    self.displayEngLabel.text=currentSubtitle.EngSubtitle;
    self.displayChiLabel.text=currentSubtitle.ChiSubtitle;
    
}


#pragma mark - extractImageAndAudio

- (void)extractImageAndAudio {

    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self savePath]]) {
        
        //创建一个以视频名为名的文件夹，存储图片和音频
        [[NSFileManager defaultManager] createDirectoryAtPath:[self savePath] withIntermediateDirectories:NO attributes:nil error:nil];
        
        //把该文件夹的路径存入默认生词本的array，再存入userDefaults，以便在glossaryView里面使用
        NSMutableArray *glossaryDefaults;
        if (![[NSUserDefaults standardUserDefaults] arrayForKey:KVGlossaryDefaults]) {
             glossaryDefaults=[NSMutableArray arrayWithCapacity:0];
        }else{
            glossaryDefaults=[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:KVGlossaryDefaults]];
        }
        [glossaryDefaults addObject:[self savePath]];
        [[NSUserDefaults standardUserDefaults] setObject:glossaryDefaults forKey:KVGlossaryDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];

        
        //把视频路径和字幕路径存入该文件，以便之后在settingView中要修改图片音频时使用
        NSString *saveVideoPath=[[self savePath] stringByAppendingPathComponent:@"videoPath"];
        NSString *saveSubtitlePath=[[self savePath] stringByAppendingPathComponent:@"subtitlePath"];
        
        [self.videoPath writeToFile:saveVideoPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [self.subtitlePath writeToFile:saveSubtitlePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    CMTime currentTime=[self.mPlayer currentTime];
    
    NSString *saveName=[self makeSaveName:currentTime];
    NSString *path=[[self savePath] stringByAppendingPathComponent:saveName];
    
    NSUInteger index=[self.mSubtitlePackage indexOfProperSubtitleWithGivenCMTime:currentTime];
    IndividualSubtitle *currentSubtitle=[self.mSubtitlePackage.subtitleItems objectAtIndex:index];
    
    if (index && (![currentSubtitle.EngSubtitle isEqualToString:@" "])) {//如果没有英文字幕，则不截图
        
        //extract subtitle
        [self.mSubtitlePackage saveSubtitleWithTime:currentTime inPath:path];
        
        //extract image
        ImagesPackage *imagePackage=[[ImagesPackage alloc]initWithAsset:self.mAsset];
        [imagePackage saveImageWithTime:currentTime inPath:path];
        
        //extract audio
        AudiosPackage *audioPackage=[[AudiosPackage alloc]initWithAsset:self.mAsset];
        
        IndividualSubtitle *currentSubtitle=[self.mSubtitlePackage.subtitleItems objectAtIndex:index];
        CMTimeRange range=CMTimeRangeFromTimeToTime(currentSubtitle.startTime, currentSubtitle.endTime);
        
        [audioPackage saveAudioWithRange:range inPath:path];
    }
    
}

- (NSString *)savePath{
    NSString *userPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName=[[self.videoPath lastPathComponent] stringByDeletingPathExtension];
    NSString *savePath=[userPath stringByAppendingPathComponent:fileName];
    return savePath;
}

- (NSString *)makeSaveName:(CMTime)time {
    float timeInSecond=CMTimeGetSeconds(time);
    
    NSString *hour;
    if (timeInSecond/3600>0) {
        hour=[NSString stringWithFormat:@"0%d-",(int)timeInSecond/3600];
    }
    else{
        hour=@"00-";
    }
    
    NSString *min;
    if ((int)timeInSecond%3600/60<10) {
        min=[NSString stringWithFormat:@"0%d-",(int)timeInSecond%3600/60];
    }else{
        min=[NSString stringWithFormat:@"%d-",(int)timeInSecond%3600/60];
    }
    
    
    NSString *sec;
    if ((int)timeInSecond%3600%60<10) {
        sec=[NSString stringWithFormat:@"0%d-",(int)timeInSecond%3600%60];
    }else{
        sec=[NSString stringWithFormat:@"%d-",(int)timeInSecond%3600%60];
    }
    
    float fract=(timeInSecond-(int)timeInSecond)*100;
    NSString *fra;
    if (fract<10) {
        fra=[NSString stringWithFormat:@"0%d",(int)fract];
    }else{
        fra=[NSString stringWithFormat:@"%d",(int)fract];
    }
    
    
    NSString *saveName=[[[hour stringByAppendingString:min] stringByAppendingString:sec] stringByAppendingString:fra];
    return saveName;
}

#pragma mark - action

- (void)backToFileView{
    
    if (CMTIME_IS_VALID(mPlayer.currentTime)) {
        
        [self.playerInfo removeAllObjects];
        
        [self.playerInfo addObject:self.videoPath];
        [self.playerInfo addObject:self.subtitlePath];
        
        //如果视频已经播放到结束，则存入开始时间
        float seconds;
        if (!CMTimeCompare(mPlayerItem.duration, mPlayer.currentTime)) {
            seconds=0.f;
        }else{
            seconds=CMTimeGetSeconds(mPlayer.currentTime);
        }
        [self.playerInfo addObject:[NSNumber numberWithFloat:seconds]];
        
        [self savePlayInfo];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)moveToCardView{
    
    CardViewController *cardVC=[[CardViewController alloc] initWithNibName:@"CardViewController" bundle:nil];
    cardVC.savePath=[self savePath];
    cardVC.videoPath=self.videoPath;
    cardVC.subtitlePath=self.subtitlePath;
    [self.navigationController pushViewController:cardVC animated:YES];
    
}

- (void)savePlayInfo{
    NSUserDefaults *lastPlayInfo=[NSUserDefaults standardUserDefaults];
    [lastPlayInfo setObject:playerInfo forKey:kPlayerInfo];
    [lastPlayInfo synchronize];
}

#pragma mark - view did appear

- (void)initMPlayer{
    
    mURL=[NSURL fileURLWithPath:self.videoPath];
    self.mAsset=[AVURLAsset URLAssetWithURL:mURL options:nil];
    
    NSArray *requestedKeys=[NSArray arrayWithObject:@"tracks"];
    [mAsset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self prepareToPlayAsset:mAsset withKeys:requestedKeys];
        });
    }];
    
    self.mSubtitlePackage=[[SubtitlePackage alloc] initWithFile:self.subtitlePath];
    
    
}


- (void)viewDidAppear:(BOOL)animated{
    
    self.playerInfo=[NSMutableArray arrayWithCapacity:3];
    
    //获得上次播放信息
    if ([[NSUserDefaults standardUserDefaults] arrayForKey:kPlayerInfo]) {
        self.playerInfo=[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:kPlayerInfo]];
    }
    
    //判断之前是否已经播放过
    if (self.playerInfo.count==3) {
        
        NSString *lastVideo=[self.playerInfo objectAtIndex:0];
        NSString *lastSubtitle=[self.playerInfo objectAtIndex:1];
        
        //之前已经播放过，重新载入当时的时间
        if ([self.videoPath isEqualToString:lastVideo] && [self.subtitlePath isEqualToString:lastSubtitle]) {
            
            self.timeToStart=CMTimeMakeWithSeconds([[self.playerInfo objectAtIndex:2] floatValue], kTimescale);
            [self initMPlayer];
            
        }else {
            self.timeToStart=kCMTimeZero;
            [self initMPlayer];
        }
        
    }else{
        
        self.timeToStart=kCMTimeZero;
        [self initMPlayer];
    }
    
    [self initDisplayItems];
    [self syncPlayPauseButtons];
    
    //加入手势识别，以调出上/下导航栏
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDisplayItems:)];
    [self.view addGestureRecognizer:tapGesture];

    
}

- (void)viewWillDisappear:(BOOL)animated{
    [mPlayer pause];
    [super viewWillDisappear:animated];
}

- (void)setviewDisplayName{
    /* Set the view title to the last component of the asset URL. */
    self.title=[[mURL lastPathComponent] stringByDeletingPathExtension];
    
    /* Or if the item has a AVMetadataCommonKeyTitle metadata, use that instead. */
    for (AVMetadataItem *item in ([[[mPlayer currentItem] asset] commonMetadata])){
        NSString *commonKey=[item commonKey];
        if ([commonKey isEqualToString:AVMetadataCommonKeyTitle]) {
            self.title=[item stringValue];
        }
    }
}

#pragma mark - view did load

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mPlayer=nil;
        //[self setWantsFullScreenLayout:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //显示下方的barButton
    UIBarButtonItem *scrubberItem=[[UIBarButtonItem alloc] initWithCustomView:mScrubber];
    UIBarButtonItem *flexItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    mToolbar.items=[NSArray arrayWithObjects:mPlayButton,scrubberItem,flexItem, nil];
    
    //显示上方的barButton
    UIBarButtonItem *doneButton=[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(moveToCardView)];
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backToFileView)];
    
    [self.navigationItem setRightBarButtonItem:doneButton animated:NO];
    [self.navigationItem setLeftBarButtonItem:backButton animated:NO];
    
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [self setMPlayView:nil];
    [self setMToolbar:nil];
    [self setMPlayButton:nil];
    [self setMPauseButton:nil];
    [self setMScrubber:nil];
    [self setDisplayEngLabel:nil];
    [self setDisplayChiLabel:nil];
    [self setDisplayTimeLabel:nil];
    [self setDisplayRemainTime:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

#pragma mark - player

@implementation XXXPlayViewController (Player)

-(BOOL)isPlaying{
    return mRestoreAfterScrubbingRate !=0.f || [mPlayer rate] !=0.f;
}

-(CMTime)playerItemDuration{
    AVPlayerItem *playerItem=[mPlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return ([playerItem duration]);
    }
    return (kCMTimeInvalid);
}

-(void)removePlayerTimeObserver{
    if (mTimeObserver) {
        [mPlayer removeTimeObserver:mTimeObserver];
        mTimeObserver=nil;
    }
}

-(void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys{
    if (self.mPlayerItem) {
        [self.mPlayerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.mPlayerItem];
    }
    
    self.mPlayerItem=[AVPlayerItem playerItemWithAsset:asset];
    [self.mPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:PlayViewControllerStatusObservationContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.mPlayerItem];
    seekToZeroBeforePlay=NO;
    
    if (![self mPlayer]) {
        [self setMPlayer:[AVPlayer playerWithPlayerItem:self.mPlayerItem]];
        [self.mPlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:PlayViewControllerCurrentItemObservationContext];
    }
    
    if (self.mPlayer.currentItem != self.mPlayerItem) {
        [[self mPlayer] replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        [self syncPlayPauseButtons];
    }
    
    [mPlayer play];
    [mPlayer seekToTime:self.timeToStart];
    [self showStopButton];
    
    timer=[NSTimer scheduledTimerWithTimeInterval:kHideInterval target:self selector:@selector(hideDisplayItems) userInfo:nil repeats:NO];
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error{
    
    [self removePlayerTimeObserver];
    [self disableScrubber];
    [self disablePlayerButtons];
    
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:[error localizedDescription] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)playerItemDidReachEnd:(NSNotification *)notification{
    
    [self.playerInfo replaceObjectAtIndex:2 withObject:[NSNumber numberWithFloat:0]];
    [self savePlayInfo];
    [self showPlayButton];
    seekToZeroBeforePlay = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (context==PlayViewControllerStatusObservationContext) {
        [self syncPlayPauseButtons];
        AVPlayerStatus status=[[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self disableScrubber];
                [self disablePlayerButtons];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                [self initDisplayItems];
                [self enablePlayerButtons];
                [self enableScrubber];
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
            [self disablePlayerButtons];
            [self disableScrubber];
        }else{
            [mPlayView setPlayer:mPlayer];
            [self setviewDisplayName];
            [mPlayView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            [self syncPlayPauseButtons];
        }
    }
    
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
