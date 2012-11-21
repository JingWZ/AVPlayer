//
//  SettingViewController.m
//  APP4
//
//  Created by user on 12-11-15.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "SettingViewController.h"
#import "SubtitlePackage.h"
#import "ImagesPackage.h"
#import "AudiosPackage.h"

//还需要做一个observer，如果音频的时间修改到下一段时间轴，那么要把图片也改到相应的时间轴的第一张图片

#define intervalTime 0.5

@interface SettingViewController ()

@end

@implementation SettingViewController
@synthesize fileName;
@synthesize currentTime, startTime, endTime, totalTime;
@synthesize imageStepperValue, audioStartStepperValue, audioEndStepperValue, audioMergeStepperValue;
@synthesize asset;
@synthesize subtitlePackage;
@synthesize imageView;
@synthesize labelEng;
@synthesize labelChi;
@synthesize imageStepper;

#pragma mark - image

- (IBAction)modifyImage:(id)sender {
    
    CMTime modifiedTime;
    CMTime changedTime=CMTimeMakeWithSeconds(intervalTime, 10);
    
    if (self.imageStepperValue<[(UIStepper *)sender value]) {
        modifiedTime=CMTimeAdd(self.currentTime, changedTime);
    }else{
        modifiedTime=CMTimeSubtract(self.currentTime, changedTime);
    }
    
    //同步截图
    
    ImagesPackage *imagePackage=[[ImagesPackage alloc]initWithAsset:self.asset];
    
    [imagePackage extractImageWithCMTime:modifiedTime];
    
    self.imageView.image=imagePackage.image;
    
    //同步字幕
    
    NSUInteger index=[self.subtitlePackage indexOfProperSubtitleWithGivenCMTime:modifiedTime];
    IndividualSubtitle *currentSubtitle=[self.subtitlePackage.subtitleItems objectAtIndex:index];
    
    self.labelEng.text=currentSubtitle.EngSubtitle;
    self.labelChi.text=currentSubtitle.ChiSubtitle;
    
    //同步时间
    
    self.currentTime=modifiedTime;
    
    self.imageStepperValue=[(UIStepper *)sender value];
}

#pragma mark - audio

- (IBAction)modifyAudioStartTime:(id)sender {

    CMTime modifiedTime;
    CMTime changedTime=CMTimeMakeWithSeconds(intervalTime, 10);
    
    if (self.audioStartStepperValue<[(UIStepper *)sender value]) {
        modifiedTime=CMTimeAdd(self.startTime, changedTime);
    }else{//如果减了之后小于零，怎么做
        modifiedTime=CMTimeSubtract(self.startTime, changedTime);
    }
    
    self.startTime=modifiedTime;
    
    if (CMTIME_COMPARE_INLINE(self.startTime, >=, endTime)) {
        NSLog(@"can't add start time any more");
        self.endTime=self.startTime;
    }
    
    if (CMTIME_COMPARE_INLINE(self.startTime, <=, kCMTimeZero)) {
        NSLog(@"already in the audio start");
        self.startTime=kCMTimeZero;
    }
    
    self.audioStartStepperValue=[(UIStepper *)sender value];

}

- (IBAction)modifyAudioEndTime:(id)sender {
    

    CMTime modifiedTime;
    CMTime changedTime=CMTimeMakeWithSeconds(intervalTime, 10);
    
    if (self.audioEndStepperValue<[(UIStepper *)sender value]) {
        modifiedTime=CMTimeAdd(self.endTime, changedTime);
    }else{
        modifiedTime=CMTimeSubtract(self.endTime, changedTime);
    }
    
    self.endTime=modifiedTime;
    self.audioEndStepperValue=[(UIStepper *)sender value];
}

- (IBAction)mergeAudio:(id)sender {
    
    CMTime modifiedTime;
    CMTime changedTime=CMTimeMakeWithSeconds(intervalTime, 10);
    
    
    if (self.audioMergeStepperValue<[(UIStepper *)sender value]) {
        
        NSInteger index=[self.subtitlePackage indexOfProperSubtitleWithGivenCMTime:self.endTime];
        if (index+1>[self.subtitlePackage.subtitleItems count]) {
            NSLog(@"already the last sentence!");
        }else{
            CMTime nextEnd=[[self.subtitlePackage.subtitleItems objectAtIndex:(index+1)] endTime];
            self.endTime=nextEnd;
        }
    }else{
        NSInteger index=[self.subtitlePackage indexOfProperSubtitleWithGivenCMTime:self.startTime];
        if (index==0) {
            NSLog(@"already the first sentence!");
        }else{
            CMTime nextStart=[[self.subtitlePackage.subtitleItems objectAtIndex:(index-1)] startTime];
            self.startTime=nextStart;
        }
    }
    
    self.audioMergeStepperValue=[(UIStepper *)sender value];
}

#pragma mark - save & back

- (IBAction)saveAndBack:(id)sender {
    
    NSLog(@"---------------------");
    CMTimeShow(self.currentTime);
    CMTimeShow(self.startTime);
    CMTimeShow(self.endTime);
    
    /*
    //getSaveName
    [self makeSubtitleAndImageAndAudioSaveName:self.currentTime];
    
    //save
    CMTimeRange range=CMTimeRangeFromTimeToTime(self.startTime, self.endTime);
    AudiosPackage *audioPackage=[[AudiosPackage alloc]initWithAsset:self.asset];
    //audioPackage saveAudioWithRange:range inPath:
    
    //back
    [self.navigationController popViewControllerAnimated:YES];
    */
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



#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    NSString *filePath=[savePath stringByAppendingString:self.fileName];
    
    //显示截图
    UIImage *image=[UIImage imageWithContentsOfFile:[filePath stringByAppendingPathExtension:@"jpeg"]];
    
    self.imageView=[[UIImageView alloc]initWithImage:image];
    [self.imageView setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, 340, 300)];
    [self.view addSubview:self.imageView];
    [self.view bringSubviewToFront:self.imageStepper];
    
    //显示字幕
    NSData *data=[[NSData alloc]initWithContentsOfFile:filePath];
    NSKeyedUnarchiver *unarchiver=[[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    IndividualSubtitle *subtitle=[unarchiver decodeObjectForKey:@"subtitle"];
    self.labelEng.text=subtitle.EngSubtitle;
    self.labelChi.text=subtitle.ChiSubtitle;
    [self.view bringSubviewToFront:self.labelEng];
    [self.view bringSubviewToFront:self.labelChi];
    
    
    //获得当前截图时间
    [self makeCMTimeWithFileName];
    
    //初始化subtitle
    
    self.subtitlePackage=[[SubtitlePackage alloc]initWithFile:subtitlePath];
    
    
    //初始化AVAsset
    
    NSURL *url=[NSURL URLWithString:videoPath];
    self.asset=[AVURLAsset URLAssetWithURL:url options:nil];
    if (self.asset==nil) {
        NSLog(@"can't find asset file");
        //跳出警告并退出，稍后写
    }

    //初始化startTime和endTime
    
    NSUInteger index=[self.subtitlePackage indexOfProperSubtitleWithGivenCMTime:self.currentTime];
    IndividualSubtitle *currentSubtitle=[self.subtitlePackage.subtitleItems objectAtIndex:index];
    
    self.startTime=currentSubtitle.startTime;
    self.endTime=currentSubtitle.endTime;
    self.totalTime=[asset duration];
        
}


- (void)makeCMTimeWithFileName{
    NSArray *array=[self.fileName componentsSeparatedByString:@"-"];
    
    int hour=[[array objectAtIndex:0] intValue];
    int min=[[array objectAtIndex:1] intValue];
    int sec=[[array objectAtIndex:2] intValue];
    int fra=[[array objectAtIndex:3] intValue];
    
    float seconds=hour*3600+min*60+sec+fra/100.0;
    
    self.currentTime=CMTimeMakeWithSeconds(seconds, 100);
    
}


- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setLabelEng:nil];
    [self setLabelChi:nil];
    [self setImageStepper:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
