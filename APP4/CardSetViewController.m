//
//  CardSetViewController.m
//  APP4
//
//  Created by apple on 13-3-6.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//

#import "CardSetViewController.h"

#define kTimeScale 60.0

@implementation CardSetViewController{
    
    NSMutableArray *audioPathArray;
    
}



#pragma mark - action

- (IBAction)engModify:(UITextField *)sender {
    
    self.engSubtitle=[sender text];
}

- (IBAction)chiModify:(UITextField *)sender {
    
    self.chiSubtitle=[sender text];
}

- (IBAction)stepperPressed:(UIStepper *)sender {
    
    self.sliderScale=(NSInteger)[sender value];
    [self.slider updateScale:self.sliderScale];
}

- (IBAction)playBack:(id)sender {
    
    //更新图片
    ImagesPackage *imagePackage=[[ImagesPackage alloc] initWithAsset:self.mAsset];
    CMTime imageCMTime=CMTimeMakeWithSeconds(self.slider.middleValue, kTimeScale);
    [imagePackage extractImageWithCMTime:imageCMTime];
    [self.mImageView setImage:imagePackage.image];
    
    //保存音频
    
    NSFileManager *fm=[NSFileManager defaultManager];
    
    //删除上一次试听的文件
    if ([audioPathArray count]) {
        
        [fm removeItemAtPath:[audioPathArray objectAtIndex:0] error:nil];
        [audioPathArray removeObjectAtIndex:0];
    }
    
    NSString *saveName=[self.subtitlePackage makeSaveName:imageCMTime];
    LETGlossaryManagement *gm=[LETGlossaryManagement sharedInstance];
    NSString *glossaryPath=[gm glossaryPathAtGlossaryIndex:self.glossaryIndex];
    NSString *savePath=[glossaryPath stringByAppendingPathComponent:saveName];
    
    CMTime audioStartCMTime=CMTimeMakeWithSeconds(self.slider.leftValue, kTimeScale);
    CMTime audioEndCMTime=CMTimeMakeWithSeconds(self.slider.rightValue, kTimeScale);
    CMTimeRange range=CMTimeRangeFromTimeToTime(audioStartCMTime, audioEndCMTime);
    
    //如果文件名已存在，则在后面加入一个E作为新文件名
    NSString *path=[savePath stringByAppendingPathExtension:@"m4a"];
    NSString *audioPath;
    
    if ([fm fileExistsAtPath:path]) {
        
        audioPath=[[savePath stringByAppendingString:@"e"] stringByAppendingPathExtension:@"m4a"];
        
    }else{
        
        audioPath=path;
    }
    
    //把它存到数组中，以便再用户下一次试听前，删掉之前试听的文件
    if (!audioPathArray) {
        audioPathArray=[NSMutableArray arrayWithCapacity:0];
    }
    [audioPathArray addObject:audioPath];
    
    
    NSURL *audioURL=[NSURL fileURLWithPath:audioPath];
    AVAssetExportSession *exportSession=[AVAssetExportSession exportSessionWithAsset:self.mAsset presetName:AVAssetExportPresetAppleM4A];
    
    exportSession.outputURL=audioURL;
    exportSession.outputFileType=AVFileTypeAppleM4A;
    exportSession.timeRange=range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.status==AVAssetExportSessionStatusFailed) {
            NSLog(@"can't export audio!");
            NSLog(@"%@",[exportSession.error description]);
        }else{
            
            //播放音频
            if (self.mAudioPlayer) {
                self.mAudioPlayer=nil;
            }
            self.mAudioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
            [self.mAudioPlayer prepareToPlay];
            [self.mAudioPlayer play];
        }
        
    }];
    
}

- (void)doneBtnPressed{
    
    //删除原来的图片，音频和字幕
    
    LETGlossaryManagement *gm=[LETGlossaryManagement sharedInstance];
    NSString *cardImagePath=[gm cardImagePathAtGlossaryIndex:self.glossaryIndex cardIndex:self.cardIndex];
    NSString *cardSubtitlePath=[gm cardSubtitlePathAtGlossaryIndex:self.glossaryIndex cardIndex:self.cardIndex];
    NSString *cardAudioPath=[gm cardAudioPathAtGlossaryIndex:self.glossaryIndex cardIndex:self.cardIndex];
    
    NSFileManager *fm=[NSFileManager defaultManager];
    [fm removeItemAtPath:cardImagePath error:nil];
    [fm removeItemAtPath:cardSubtitlePath error:nil];
    [fm removeItemAtPath:cardAudioPath error:nil];
    
    //删除上一次试听的文件
    if ([audioPathArray count]) {
        
        [fm removeItemAtPath:[audioPathArray objectAtIndex:0] error:nil];
        [audioPathArray removeObjectAtIndex:0];
    }
    
    //保存图片音频和字幕
    
    CMTime currentTime=CMTimeMakeWithSeconds(self.imageTime, kTimeScale);
    
    NSString *glossaryPath=[gm glossaryPathAtGlossaryIndex:self.glossaryIndex];
    NSString *saveName=[self.subtitlePackage makeSaveName:currentTime];
    NSString *path=[glossaryPath stringByAppendingPathComponent:saveName];
    
    //extract subtitle
    [self.subtitlePackage saveSubtitleWithTime:currentTime inPath:path];
    
    //extract image
    ImagesPackage *imagePackage=[[ImagesPackage alloc] initWithAsset:self.mAsset];
    [imagePackage saveImageWithTime:currentTime inPath:path];
    
    //extract audio
    AudiosPackage *audioPackage=[[AudiosPackage alloc] initWithAsset:self.mAsset];
    
    CMTime audioStartCMTime=CMTimeMakeWithSeconds(self.slider.leftValue, kTimeScale);
    CMTime audioEndCMTime=CMTimeMakeWithSeconds(self.slider.rightValue, kTimeScale);
    CMTimeRange range=CMTimeRangeFromTimeToTime(audioStartCMTime, audioEndCMTime);
    
    [audioPackage saveAudioWithRange:range inPath:path];
    
}


#pragma mark - lifecycle

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
    
    self.sliderScale=2;
    
    //初始化导航栏button
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneBtnPressed)];
    [self.navigationItem setRightBarButtonItem:doneBtn];
    
    //拿到视频和字幕的路径
    LETGlossaryManagement *gm=[LETGlossaryManagement sharedInstance];
    
    NSString *videoP=[gm glossaryVideoPathAtIndex:self.glossaryIndex];
    NSString *subtitleP=[gm glossarySubtitlePathAtIndex:self.glossaryIndex];
    
    [self setVideoPath:videoP];
    [self setSubtitlePath:subtitleP];
    
    //初始化asset
    //if (![[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {}
    NSURL *videoURL=[[NSURL alloc] initFileURLWithPath:self.videoPath];
    self.mAsset=[AVURLAsset URLAssetWithURL:videoURL options:nil];
    
    //显示截图
    NSString *cardImageP=[gm cardImagePathAtGlossaryIndex:self.glossaryIndex cardIndex:self.cardIndex];
    UIImage *image=[UIImage imageWithContentsOfFile:cardImageP];
    [self.mImageView setImage:image];
    
    //显示字幕
    NSString *cardSubtitleP=[gm cardSubtitlePathAtGlossaryIndex:self.glossaryIndex cardIndex:self.cardIndex];
    NSData *data=[[NSData alloc]initWithContentsOfFile:cardSubtitleP];
    NSKeyedUnarchiver *unarchiver=[[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    IndividualSubtitle *subtitle=[unarchiver decodeObjectForKey:@"subtitle"];
    [self.engTF setText:subtitle.EngSubtitle];
    [self.chiTF setText:subtitle.ChiSubtitle];
    
    //初始化音频
    NSString *cardAudioP=[gm cardAudioPathAtGlossaryIndex:self.glossaryIndex cardIndex:self.cardIndex];
    NSURL *audioURL=[[NSURL alloc] initFileURLWithPath:cardAudioP];
    self.mAudioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    [self.mAudioPlayer prepareToPlay];
    
    //初始化slider
    LETCard *card=[gm cardAtGlossaryIndex:self.glossaryIndex cardIndex:self.cardIndex];
    
    NSLog(@"%@",card.cardName);
    self.subtitlePackage=[[SubtitlePackage alloc] initWithFile:self.subtitlePath];
    self.imageTime=[self.subtitlePackage imageTimeWithName:card.cardName];
    self.audioStart=[self.subtitlePackage audioStartTimeWithName:card.cardName];
    self.audioEnd=[self.subtitlePackage audioEndTimeWithName:card.cardName];
    
    self.slider=[[MultipleTrackSlider alloc] initWithFrame:CGRectMake(20, 287, 280, 100) leftValue:self.audioStart rightValue:self.audioEnd middleValue:self.imageTime scale:self.sliderScale];
    [self.slider setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.slider];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMImageView:nil];
    [self setEngTF:nil];
    [self setChiTF:nil];
    [self setSlider:nil];
    [super viewDidUnload];
}

@end
