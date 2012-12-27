//
//  SettingViewController.m
//  APP4
//
//  Created by user on 12-11-15.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "SettingViewController.h"

//还需要做一个observer，如果音频的时间修改到下一段时间轴，那么要把图片也改到相应的时间轴的第一张图片

#define kTimescale 60.0

static NSString *reasonStart=@"已经到达视频起点";
static NSString *reasonEnd=@"已经到达视频终点";

@interface SettingViewController ()

@end

@implementation SettingViewController

@synthesize mAsset;
@synthesize mSubtitlePackage;

@synthesize imageView;
@synthesize textEng;
@synthesize textChi;
@synthesize imageStp;
@synthesize startStp;
@synthesize endStp;
@synthesize mergeStp;




#pragma mark - image

- (IBAction)modifyImage:(UIStepper *)sender {
    
    self.currentT=sender.value;
    
    if (self.currentT<0) {
        self.currentT=0;
        [self showAlertFor:reasonStart];
    }else if (self.currentT>CMTimeGetSeconds([mAsset duration])){
        self.currentT=CMTimeGetSeconds([mAsset duration]);
        [self showAlertFor:reasonEnd];
    }
    
    //同步ImageView
    [self syncImageView:CMTimeMakeWithSeconds(self.currentT, kTimescale)];
    
}

- (void)syncImageView:(CMTime)time{
    
    //同步截图
    
    ImagesPackage *imagePackage=[[ImagesPackage alloc]initWithAsset:mAsset];
    
    [imagePackage extractImageWithCMTime:time];
    
    self.imageView.image=imagePackage.image;
    
    //同步字幕
    
    //NSUInteger index=[self.subtitlePackage indexOfProperSubtitleWithGivenCMTime:time];
    //IndividualSubtitle *currentSubtitle=[self.subtitlePackage.subtitleItems objectAtIndex:index];
    
    //self.labelEng.text=currentSubtitle.EngSubtitle;
    //self.labelChi.text=currentSubtitle.ChiSubtitle;

}

#pragma mark - audio

- (IBAction)modifyAudioStartTime:(UIStepper *)sender {
    
    self.startT=sender.value;
    
    if (self.startT<0) {
        self.startT=0;
        [self showAlertFor:reasonStart];
    }else if (self.startT>CMTimeGetSeconds([mAsset duration])){
        self.startT=CMTimeGetSeconds([mAsset duration]);
        [self showAlertFor:reasonEnd];
    }else if (self.startT>self.endT){
        self.endT=self.startT;
    }else if (self.startT>self.currentT){
        self.currentT=self.startT;
    }
    
}

- (IBAction)modifyAudioEndTime:(UIStepper *)sender {
    
    self.endT=sender.value;
    
    if (self.endT<0) {
        self.endT=0;
        [self showAlertFor:reasonStart];
    }else if (self.endT>CMTimeGetSeconds([mAsset duration])){
        self.endT=CMTimeGetSeconds([mAsset duration]);
        [self showAlertFor:reasonEnd];
    }else if (self.endT<self.startT){
        self.startT=self.endT;
    }
}

- (IBAction)mergeAudio:(UIStepper *)sender {
    
    //用户按加号就是向后合并一句，按减号就是向前合并一句
    if (!mAsset) {
        if (![self initVideoAndSubtitle]) {
            return;
        }
    }
    CMTime end=CMTimeMakeWithSeconds(self.endT, kTimescale);
    CMTime start=CMTimeMakeWithSeconds(self.startT, kTimescale);
    
    if ([sender value]>self.mergeStpValue) {
        
        NSInteger index=[mSubtitlePackage indexOfProperSubtitleWithGivenCMTime:end];
        if (index==[mSubtitlePackage.subtitleItems count]) {
            [self showAlertFor:reasonEnd];
        }else{
            self.endT=CMTimeGetSeconds([[mSubtitlePackage.subtitleItems objectAtIndex:(index+1)] endTime]);
        }

    }else{
        
        NSInteger index=[mSubtitlePackage indexOfProperSubtitleWithGivenCMTime:start];
        if (index==0) {
            [self showAlertFor:reasonStart];
        }else{
            self.startT=CMTimeGetSeconds([[mSubtitlePackage.subtitleItems objectAtIndex:(index-1)] startTime]);
        }
    }
    
    self.mergeStpValue=sender.value;
}

- (IBAction)finishExitEng:(id)sender {
}

- (IBAction)finishExitChi:(id)sender {
}

#pragma mark - save & back

- (IBAction)saveAndBack:(id)sender {
    
    //储存图片和音频
    
    NSString *saveName=[self makeSaveName];
    NSString *path=[self.savePath stringByAppendingPathComponent:saveName];
    
    CMTime current=CMTimeMakeWithSeconds(self.currentT, kTimescale);
    CMTime start=CMTimeMakeWithSeconds(self.startT, kTimescale);
    CMTime end=CMTimeMakeWithSeconds(self.endT, kTimescale);
    CMTimeRange range=CMTimeRangeFromTimeToTime(start, end);
    
    //储存音频
    AudiosPackage *audioPackage=[[AudiosPackage alloc]initWithAsset:mAsset];
    [audioPackage saveAudioWithRange:range inPath:path];

    //储存字幕
    IndividualSubtitle *subtitle=[[IndividualSubtitle alloc] initSubtitle];;
    subtitle.EngSubtitle=self.textEng.text;
    subtitle.ChiSubtitle=self.textChi.text;
    [subtitle savesubtitleInPath:path];
    
    //储存图片
    ImagesPackage *imagePackage=[[ImagesPackage alloc]initWithAsset:mAsset];
    [imagePackage saveImageWithTime:current inPath:path];
    
#warning doto 删除原来的
    //删除原来的
    
    //返回上一页
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (NSString *)makeSaveName {
    
    float timeInSecond=self.currentT;
    
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

//如果用户只是修改字幕，则不需要启动此项
- (BOOL)initVideoAndSubtitle{
    
    //初始化AVAsset
    
    //如果视频不存在，跳出警告窗
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {
        NSString *reason=@"视频不存在";
        [self showAlertFor:reason];
        return NO;
    }

    NSURL *url=[NSURL fileURLWithPath:self.videoPath];
    mAsset=[AVURLAsset URLAssetWithURL:url options:nil];
    
    if (mAsset==nil) {
        NSString *reason=@"无法打开视频";
        [self showAlertFor:reason];
        return NO;
    }
    
    //初始化subtitle
    mSubtitlePackage=[[SubtitlePackage alloc]initWithFile:self.subtitlePath];
    
    //初始化startTime和endTime
    CMTime current=CMTimeMakeWithSeconds(self.currentT, kTimescale);
    NSUInteger index=[mSubtitlePackage indexOfProperSubtitleWithGivenCMTime:current];
    IndividualSubtitle *currentSubtitle=[mSubtitlePackage.subtitleItems objectAtIndex:index];
    
    self.startT=CMTimeGetSeconds(currentSubtitle.startTime);
    self.endT=CMTimeGetSeconds(currentSubtitle.endTime);
    
    //初始化3个Stepper的值
    [self.imageStp setValue:self.currentT];
    [self.startStp setValue:self.startT];
    [self.endStp setValue:self.endT];
    
    return YES;

}

- (void)makeCMTimeWithFileName{
    
    NSArray *array=[self.fileName componentsSeparatedByString:@"-"];
    
    int hour=[[array objectAtIndex:0] intValue];
    int min=[[array objectAtIndex:1] intValue];
    int sec=[[array objectAtIndex:2] intValue];
    int fra=[[array objectAtIndex:3] intValue];
    
    float seconds=hour*3600+min*60+sec+fra/100.0;
    
    self.currentT=seconds;
}

- (void)showAlertFor:(NSString *)reason{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:reason delegate:self cancelButtonTitle:@"okay!" destructiveButtonTitle:nil otherButtonTitles: nil];
    
    [actionSheet showInView:self.view];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *filePath=[self.savePath stringByAppendingPathComponent:self.fileName];
    
    //显示图片
    UIImage *image=[UIImage imageWithContentsOfFile:[filePath stringByAppendingPathExtension:@"jpg"]];
    [self.imageView setImage:image];
    
    //显示字幕
    NSData *data=[[NSData alloc]initWithContentsOfFile:filePath];
    NSKeyedUnarchiver *unarchiver=[[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    IndividualSubtitle *subtitle=[unarchiver decodeObjectForKey:@"subtitle"];
    self.textEng.text=subtitle.EngSubtitle;
    self.textChi.text=subtitle.ChiSubtitle;
    
    //获得当前截图时间
    [self makeCMTimeWithFileName];
    
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setTextEng:nil];
    [self setTextChi:nil];
    [self setImageStp:nil];
    [self setStartStp:nil];
    [self setEndStp:nil];
    [self setMergeStp:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
