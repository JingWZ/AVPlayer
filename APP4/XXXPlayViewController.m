//
//  XXXPlayViewController.m
//  APP4
//
//  Created by user on 12-10-25.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//


#import "XXXPlayViewController.h"



@interface XXXPlayViewController ()
- (void)showStopButton;
- (void)showPlayButton;
- (void)syncPlayPauseButtons;
- (void)initScrubberTimer;
- (void)syncScrubber;
- (void)initSubtitle;
- (void)syncSubtitle;
- (BOOL)isScrubbing;

-(void)initImageExtractionLayer;

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
@synthesize mToolbar;
@synthesize mPlayButton;
@synthesize mPauseButton;
@synthesize mScrubber;
@synthesize displayTimeLabel;
@synthesize displayEngLabel;
@synthesize displayChiLabel;
@synthesize imageExtractionLayer;
@synthesize mURL, mPlayer, mPlayerItem, mPlayView;
@synthesize mAsset;
@synthesize mSubtitlePackage;

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



- (void)initScrubberTimer{
    double interval=.1f;
    CMTime playDuration=[self playerItemDuration];
    if (CMTIME_IS_INVALID(playDuration)) {
        return;
    }
    double duration = CMTimeGetSeconds(playDuration);
    if (isfinite(duration)) {
        CGFloat width=CGRectGetWidth([mScrubber bounds]);
        interval=0.5f * duration/width;
    }
    
    
    __block typeof(self) bself = self;
    mTimeObserver=[mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [bself syncScrubber];
    }];
}

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
        }
    }
}

- (IBAction)beginScrubbing:(id)sender {
    mRestoreAfterScrubbingRate=[mPlayer rate];
    [mPlayer setRate:0.f];
    [self removePlayerTimeObserver];
}

- (IBAction)endScrubbing:(id)sender {
    if (!mTimeObserver) {
        CMTime playerDuration=[self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        double duration=CMTimeGetSeconds(playerDuration);
        if (isfinite(duration)) {
            CGFloat width=CGRectGetWidth([mScrubber bounds]);
            double tolerance=0.5f*duration/width;
            __block typeof(self) bself = self;
            mTimeObserver=[mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time){
                [bself syncScrubber];
            }];
        }
    }
    
    if (mRestoreAfterScrubbingRate) {
        [mPlayer setRate:mRestoreAfterScrubbingRate];
        mRestoreAfterScrubbingRate=0.f;
    }
}



- (BOOL)isScrubbing{
    return mRestoreAfterScrubbingRate !=0.f;
}

- (void)enableScrubber{
    self.mScrubber.enabled=YES;
}

- (void)disableScrubber{
    self.mScrubber.enabled=NO;
}

#pragma mark - subtitle
-(void)initSubtitle{
    __block typeof(self) bself = self;
    mTimeObserverForSubtitle=[mPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 600) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [bself syncSubtitle];
    }];
}

- (void)syncSubtitle{
    
    CMTime currentTime=[self.mPlayer currentTime];
    
    self.displayTimeLabel.text=[NSString stringWithFormat:@"%@",[self getTimeStr:currentTime]];
    
    NSUInteger index=[self.mSubtitlePackage indexOfProperSubtitleWithGivenCMTime:currentTime];
    IndividualSubtitle *currentSubtitle=[self.mSubtitlePackage.subtitleItems objectAtIndex:index];
    self.displayEngLabel.text=currentSubtitle.EngSubtitle;
    self.displayChiLabel.text=currentSubtitle.ChiSubtitle;
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

#pragma mark - extractImageAndAudio

-(void)initImageExtractionLayer{
    [self.mPlayView addSubview:self.imageExtractionLayer];
}

- (IBAction)extractImageAndAudio:(id)sender {
    
    CMTime currentTime=[self.mPlayer currentTime];
    NSString *saveName=[self makeSubtitleAndImageAndAudioSaveName:currentTime];
    NSString *path=[savePath stringByAppendingString:saveName];
    NSUInteger index=[self.mSubtitlePackage indexOfProperSubtitleWithGivenCMTime:currentTime];
    
    if (index) {//如果没有字幕，则不截图
        
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


- (NSString *)makeSubtitleAndImageAndAudioSaveName:(CMTime)time {
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


#pragma mark - viewLoad


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
    
    mURL=[NSURL URLWithString:videoPath];
    self.mAsset=[AVURLAsset URLAssetWithURL:mURL options:nil];
    NSArray *requestedKeys=[NSArray arrayWithObject:@"tracks"];
    [mAsset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self prepareToPlayAsset:mAsset withKeys:requestedKeys];
        });
    }];
    
    
    
    
    
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *scrubberItem=[[UIBarButtonItem alloc] initWithCustomView:mScrubber];
    UIBarButtonItem *flexItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    mToolbar.items=[NSArray arrayWithObjects:mPlayButton,scrubberItem,flexItem, nil];
    [self initScrubberTimer];
    [self syncPlayPauseButtons];
    [self syncScrubber];
    [self initSubtitle];
    [self syncSubtitle];
    
    self.mSubtitlePackage=[[SubtitlePackage alloc]initWithFile:subtitlePath];
    
    
    self.displayTimeLabel.text=@"";
    
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
    [self setImageExtractionLayer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated{
    [mPlayer pause];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setviewDisplayName{
    /* Set the view title to the last component of the asset URL. */
    self.title=[mURL lastPathComponent];
    
    /* Or if the item has a AVMetadataCommonKeyTitle metadata, use that instead. */
    for (AVMetadataItem *item in ([[[mPlayer currentItem] asset] commonMetadata])){
        NSString *commonKey=[item commonKey];
        if ([commonKey isEqualToString:AVMetadataCommonKeyTitle]) {
            self.title=[item stringValue];
        }
    }
}


@end










@implementation XXXPlayViewController (Player)

-(BOOL)isPlaying{
    //toknow
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
    //    for (NSString *thisKey in requestedKeys){
    //        NSError *error=nil;
    //        AVKeyValueStatus keyStatus=[asset statusOfValueForKey:thisKey error:&error];
    //        if (keyStatus==AVKeyValueStatusFailed) {
    //            [self assetFailedToPrepareForPlayback:error];
    //            return;
    //        }
    //    }
    
    //    if (!asset.playable) {
    //        NSString *localizedDescription=NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
    //        NSString *localizedFailureReason=NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
    //        NSDictionary *errorDict=[NSDictionary dictionaryWithObjectsAndKeys:localizedDescription, NSLocalizedDescriptionKey, localizedFailureReason, NSLocalizedFailureReasonErrorKey, nil];
    //        NSError *assetCannotBePlayedError=[NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
    //        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
    //        return;
    //    }
    
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
        
        //[self.mPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:PlayViewControllerRateObservationContext];
    }
    
    if (self.mPlayer.currentItem != self.mPlayerItem) {
        [[self mPlayer] replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        [self syncPlayPauseButtons];
    }
    [mScrubber setValue:0.0];
    [mPlayer play];
    [self showStopButton];
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error{
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self disableScrubber];
    [self disablePlayerButtons];
    
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:[error localizedDescription] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)playerItemDidReachEnd:(NSNotification *)notification{
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
                [self syncScrubber];
                [self disableScrubber];
                [self disablePlayerButtons];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                [self initScrubberTimer];
                [self initSubtitle];
                [self enablePlayerButtons];
                [self enableScrubber];
                [self initImageExtractionLayer];
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem=(AVPlayerItem *)object;
                //NSLog(@"rr");
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
