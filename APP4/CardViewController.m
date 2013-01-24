//
//  CardViewController.m
//  APP4
//
//  Created by apple on 12-12-24.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "CardViewController.h"
#import "SubtitlePackage.h"
#import "LabelView.h"

@interface CardViewController ()

@end

@implementation CardViewController

#define kTableViewHeight 400
#define kTimeInterval 0.05

#define kGlossaryCustom @"glossaryCustom"

static NSString *recordBtnNormal=@"microNormal.jpg";
static NSString *recordBtnPressed=@"microPressed.jpg";


@synthesize audioPlayer;
@synthesize audioRecorder;
@synthesize isRecording;

@synthesize mTableView;
@synthesize mCardCell;

@synthesize customBarView;
@synthesize countLbl;

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.contentsData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.view.bounds.size.width;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellID=@"cellid";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellID];
    
    if (cell==nil) {
        [self.cellNib instantiateWithOwner:self options:nil];
        
        NSString *path=[self.contentsData objectAtIndex:indexPath.row];
        //设置图片
        [self.mCardCell.customImageView setBackgroundColor:[UIColor clearColor]];
        [self.mCardCell.customImageView setborderWidth:10];
        [self.mCardCell.customImageView setBorderOffset:5];
        [self.mCardCell.imageView setImage:[self getImage:path]];
        self.mCardCell.subtitleEng.text=[[self getSubtitle:path] EngSubtitle];
        self.mCardCell.subtitleChi.text=[[self getSubtitle:path] ChiSubtitle];
        
        cell=self.mCardCell;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    [cell.contentView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //播放音频
    NSString *path=[self.contentsData objectAtIndex:indexPath.row];
    
    [self playAudio:path];
    /*
     NSURL *url=[[NSURL alloc]initFileURLWithPath:[filePath stringByAppendingPathExtension:@"m4a"]];
     NSError *error;
     
     self.audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
     //self.audioPlayer.delegate=self; (稍后决定是否需要delegate)
     [self.audioPlayer prepareToPlay];
     [self.audioPlayer play];
     */
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth=self.view.bounds.size.width;
    self.currentPage = floor((scrollView.contentOffset.y - pageWidth / 2) / pageWidth) + 1;
    
}


#pragma mark - initData

- (void)initDataSource{
    
    self.contentsData=[NSMutableArray arrayWithCapacity:0];
    self.countOfRecord=[NSMutableArray arrayWithCapacity:0];
    
    NSArray *contents=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.savePath error:nil];
    for (NSString *content in contents) {
        if ([[content pathExtension] isEqualToString:@"jpg"]) {
            //初始化显示数据
            [self.contentsData addObject:[self.savePath stringByAppendingPathComponent:[content stringByDeletingPathExtension]]];
            
            //初始化已录音次数
            NSString *keyStr=[[[self.savePath lastPathComponent] stringByAppendingString:content] stringByDeletingPathExtension];
            NSInteger count=[[NSUserDefaults standardUserDefaults] integerForKey:keyStr];
            [self.countOfRecord addObject:[NSNumber numberWithInteger:count]];
            
        }
    }
    
}

- (UIImage *)getImage:(NSString *)path{
    
    NSString *imagePath=[path stringByAppendingPathExtension:@"jpg"];
    UIImage *image=[UIImage imageWithContentsOfFile:imagePath];
    return image;
}

- (IndividualSubtitle *)getSubtitle:(NSString *)path{
    
    NSData *data=[[NSData alloc]initWithContentsOfFile:path];
    NSKeyedUnarchiver *unarchiver=[[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    IndividualSubtitle *subtitle=[unarchiver decodeObjectForKey:@"subtitle"];
    
    return subtitle;
}

- (void)playAudio:(NSString *)path{
    
    NSURL *url=[[NSURL alloc] initFileURLWithPath:[path stringByAppendingPathExtension:@"m4a"]];
    
    audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
    
    
}


- (void)initAudioRecord{
    
//    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
//    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    [audioSession setActive:YES error:nil];
//    
    NSString *path=[[self.contentsData objectAtIndex:self.currentPage] stringByAppendingString:@"record.m4a"];
    
    NSURL *url=[NSURL fileURLWithPath:path];
    NSDictionary *setting=[NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,
                           [NSNumber numberWithFloat:44100.0],AVSampleRateKey,
                           [NSNumber numberWithInt:1],AVNumberOfChannelsKey, nil];
    
    audioRecorder=[[AVAudioRecorder alloc] initWithURL:url settings:setting error:nil];
    
    [audioRecorder setMeteringEnabled:YES];
    [audioRecorder prepareToRecord];

}

- (void)initAudioPlayer{
    
    //初始化AVAudioPlayer
    NSString *path=[self.contentsData objectAtIndex:0];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:[path stringByAppendingPathExtension:@"m4a"]];
    audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [audioPlayer prepareToPlay];
    
}

//- (void)syncRecordBtn:(NSString *)imageName{
//    //初始化录音按钮
//    UIImage *recordBtnImage=[UIImage imageNamed:imageName];
//    [self.recordBtn setCenter:CGPointMake(self.view.center.x-50, 380)];
//    [self.recordBtn setBounds:CGRectMake(0, 0, 60, 100)];
//    [self.recordBtn setBackgroundImage:recordBtnImage forState:UIControlStateNormal];
//}

- (void)syncCountLbl{
    NSInteger count=[[self.countOfRecord objectAtIndex:self.currentPage] integerValue];
    self.countLbl.text=[NSString stringWithFormat:@"%d",count];
}

- (void)initTableView{
    //让窗口横过来
    [self.mTableView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    [self.mTableView setShowsVerticalScrollIndicator:NO];
    [self.mTableView setShowsHorizontalScrollIndicator:NO];
    //使得用户一次只能拖动一个页面宽度
    //[self.mTableView setAllowsSelection:NO];
    [self.mTableView setPagingEnabled:YES];
    [self.mTableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, kTableViewHeight)];
    [self.view addSubview:self.mTableView];
}

#pragma mark - initBar&Buttons

- (void)initBottomBarItems{
    
    CGFloat viewHeight=70;
    self.customBarView=[[CustomBarView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-viewHeight-20, self.view.bounds.size.width, viewHeight)];
    [self.customBarView setOffset:5];
    [self.customBarView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.customBarView];
    
    self.addBtn=[[AddButton alloc] initWithFrame:CGRectMake(260, 15, 50, 50)];
    [self.addBtn setBackgroundColor:[UIColor clearColor]];
    [self.customBarView addSubview: self.addBtn];
    [self.addBtn addTarget:self action:@selector(addBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.settingBtn=[[SettingButton alloc] initWithFrame:CGRectMake(10, 15, 50, 50)];
    [self.settingBtn setBackgroundColor: [UIColor clearColor]];
    [self.customBarView addSubview:self.settingBtn];
    
    self.microphoneBtn=[[MicrophoneButton alloc] initWithFrame:CGRectMake(125, 0, 70, 70)];
    [self.microphoneBtn setBackgroundColor:[UIColor clearColor]];
    [self.microphoneBtn setMicrophoneLineColor:[UIColor whiteColor]];
    [self.microphoneBtn setMicrophoneLineWidth:4];
    [self.microphoneBtn setMovingPointColor:[UIColor orangeColor]];
    [self.customBarView addSubview:self.microphoneBtn];
    [self.microphoneBtn addTarget:self action:@selector(recordBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.playBtn=[[PlayButton alloc] initWithFrame:CGRectMake(190, 15, 45, 45)];
    [self.customBarView addSubview:self.playBtn];
    [self.playBtn addTarget:self action:@selector(playBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.playBtn setHidden:YES];


}

- (void)initTopBarItems{
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToGlossaryView)];
    [backButton setTintColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    /*
    UIBarButtonItem *addButton=[[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(backToFirstView)];
    [addButton setTintColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]];
    [self.navigationItem setRightBarButtonItem:addButton];
    */
    
    LabelView *titleView=[[LabelView alloc] init];
    [titleView setCenter:CGPointMake(self.view.center.x, 30)];
    [titleView setBounds:CGRectMake(0, 0, 70, 50)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleView setText:@"Card"];
    [titleView setFont:[UIFont boldSystemFontOfSize:24]];
    [titleView setTextColor:[UIColor grayColor]];
    [titleView setTextAlignment:UITextAlignmentCenter];
    [titleView setShadowColor:[UIColor whiteColor]];
    [titleView setShadowOffset:CGSizeMake(0, 0)];
    [titleView setShadowRadius:3];
    
    [self.navigationItem setTitleView: titleView];
}

- (void)initPopMenu{
    
    GlossaryManagement *gm=[[GlossaryManagement alloc] init];
    NSMutableArray *glossariesCustom=[gm getCustomGlossariesName];
        
    self.popMenu=[[PopMenu alloc] initWithFrame:CGRectMake(0, 0, 320, -320) Contents:glossariesCustom];
    [self.view addSubview:self.popMenu];
}



#pragma mark - action

- (void)recordBtnPressed{
    
    if (isRecording) {
        isRecording=NO;
        [audioRecorder stop];
        
        [self.playBtn setHidden:NO];
        
        [self.timer invalidate];
        self.timer=nil;
        
        [self.microphoneBtn isMoving:NO];
        [self.microphoneBtn setCurrentValueRate:0];
        
    }else{
        isRecording=YES;
        [audioRecorder record];
        
        [audioPlayer stop];
        [self.playBtn setHidden:YES];
        
        self.timer=[NSTimer scheduledTimerWithTimeInterval:kTimeInterval target:self selector:@selector(updateValue) userInfo:nil repeats:YES];
        [self.microphoneBtn isMoving:YES];
        
    
        
        //增加录音次数
        NSInteger lastCount=[[self.countOfRecord objectAtIndex:self.currentPage] integerValue];
        [self.countOfRecord replaceObjectAtIndex:self.currentPage withObject:[NSNumber numberWithInteger:(lastCount+1)]];
        self.countLbl.text=[NSString stringWithFormat:@"%d",(lastCount+1)];
        
        NSString *keyStr=[[self.savePath lastPathComponent] stringByAppendingString:[[[self.contentsData objectAtIndex:self.currentPage] lastPathComponent] stringByDeletingPathExtension]];
        NSLog(@"%@,%d",keyStr,lastCount+1);
        [[NSUserDefaults standardUserDefaults] setInteger:(lastCount+1) forKey:keyStr];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
}

- (void)updateValue{
    [audioRecorder updateMeters];
    float volume=[audioRecorder averagePowerForChannel:0];
    float value=(volume+80)/80;
    
    [self.microphoneBtn setCurrentValueRate:value];
}

- (void)addBtnPressed{
    
    [self.popMenu showPopMenuInView:self.view];
    
}

- (void)playBtnPressed {
    
    audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:audioRecorder.url error:nil];
    [audioPlayer play];
    
}

- (void)settingBtnPressed {
    SettingViewController *settingVC=[[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    settingVC.videoPath=self.videoPath;
    settingVC.subtitlePath=self.subtitlePath;
    settingVC.savePath=self.savePath;
    settingVC.fileName=[self.contentsData objectAtIndex:self.currentPage];
    
    [self.navigationController pushViewController:settingVC animated:YES];

}

- (void)backToGlossaryView{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentPage"]) {
        NSInteger count=[[self.countOfRecord objectAtIndex:self.currentPage] integerValue];
        self.countLbl.text=[NSString stringWithFormat:@"%d",count];
    }
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
    [self initAudioRecord];
    [self initAudioPlayer];
    [self initPopMenu];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //self.savePath=@"/Users/apple/Library/Application Support/iPhone Simulator/5.1/Applications/4E945972-1056-4F02-AF91-02C1A9550D4B/Documents/Downton.Abbey.0306";
    //
    //
    
    [self initDataSource];
    [self initTableView];
    [self initBottomBarItems];
    [self initTopBarItems];
    
    [self.mTableView setDataSource:self];
    [self.mTableView setDelegate:self];
    
    self.cellNib=[UINib nibWithNibName:@"CardCell" bundle:nil];
    
    /*
    [self syncRecordBtn:recordBtnNormal];
    
    
    //耳机按钮
    UIImage *earphoneImage=[UIImage imageNamed:@"earphone.jpg"];
    [self.earphoneBtn setCenter:CGPointMake(self.view.center.x+50, 380)];
    [self.earphoneBtn setBounds:CGRectMake(0, 0, 60, 100)];
    [self.earphoneBtn setBackgroundImage:earphoneImage forState:UIControlStateNormal];
    
    //录音次数标签
    [self.countLbl setCenter:self.earphoneBtn.center];
    [self syncCountLbl];
    
    //observer
    [self addObserver:self forKeyPath:@"currentPage" options:NSKeyValueObservingOptionNew context:nil];
*/
}

- (void)viewDidUnload
{
    [self setMTableView:nil];
    [self setMCardCell:nil];
    [self setCountLbl:nil];
    [self setCustomBarView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
