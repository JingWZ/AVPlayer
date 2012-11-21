//
//  GlossaryViewController.m
//  APP4
//
//  Created by user on 12-11-12.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "GlossaryViewController.h"

#define showViewWidth 390
#define showViewHeight 300

@interface GlossaryViewController ()

@end

@implementation GlossaryViewController
@synthesize tableview;
@synthesize dataArray;
@synthesize showView;
//用来存放从文件中的字幕、音频和图片，每个打包为一组

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellID=@"cellid";
    UITableViewCell *cell=[self.tableview dequeueReusableCellWithIdentifier:CellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    NSString *content=[self.dataArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:content];
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    return cell;
}

#pragma mark - row selected

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    SettingViewController *settingViewController=[[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    settingViewController.fileName=[self.dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:settingViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index=indexPath.row;
    NSString *fileName=[self.dataArray objectAtIndex:index];
    NSString *filePath=[savePath stringByAppendingString:fileName];
    
    if (self.showView) {
        [self.showView removeFromSuperview];
    }
    //创建showView
    self.showView=[[UIView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width, self.view.bounds.origin.y, showViewWidth, showViewWidth)];

    
    //显示图片
    UIImage *image=[UIImage imageWithContentsOfFile:[filePath stringByAppendingPathExtension:@"jpeg"]];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:image];
    [imageView setFrame:self.showView.bounds];
    [self.showView addSubview:imageView];
    
    //显示字幕，待解决：字幕显示不完全
    UILabel *labelEng=[[UILabel alloc]initWithFrame:CGRectMake(20, 220, 350, 20)];
    UILabel *labelChi=[[UILabel alloc]initWithFrame:CGRectMake(20, 240, 350, 20)];
    
    NSData *data=[[NSData alloc]initWithContentsOfFile:filePath];
    NSKeyedUnarchiver *unarchiver=[[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    IndividualSubtitle *subtitle=[unarchiver decodeObjectForKey:@"subtitle"];
    
    labelEng.text=subtitle.EngSubtitle;
    labelChi.text=subtitle.ChiSubtitle;
    
    [labelEng setBackgroundColor:[UIColor clearColor]];
    [labelChi setBackgroundColor:[UIColor clearColor]];
    
    [labelEng setShadowColor:[UIColor whiteColor]];
    [labelChi setShadowColor:[UIColor whiteColor]];
    
    [labelEng setTextAlignment:UITextAlignmentCenter];
    [labelChi setTextAlignment:UITextAlignmentCenter];
    
//    [labelEng setNumberOfLines:2];
//    [labelEng setAdjustsFontSizeToFitWidth:YES];
//    [labelEng setMinimumFontSize:4];
    
    [self.showView addSubview:labelEng];
    [self.showView addSubview:labelChi];
    
    
    
    
    //播放音频
    
    NSURL *url=[[NSURL alloc]initFileURLWithPath:[filePath stringByAppendingPathExtension:@"m4a"]];
    NSError *error;
    
    self.audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    //self.audioPlayer.delegate=self; (稍后决定是否需要delegate)
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    

    
    
    //显示view
    [UIView beginAnimations:@"switch" context:nil];
    [UIView setAnimationDuration:.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [self.showView setFrame:CGRectMake(self.view.bounds.size.width-showViewWidth, self.view.bounds.origin.y, showViewWidth, showViewHeight)];
    
    [self.view addSubview:self.showView];
    
    [UIView commitAnimations];
    
    
    
    
    
}


#pragma mark - view did load

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
    
    [self.tableview setDelegate:self];
    [self.tableview setDataSource:self];
    
    
    if (self.dataArray==nil) {
        self.dataArray=[NSMutableArray arrayWithCapacity:0];
        NSArray *contentArray=[[NSFileManager defaultManager]contentsOfDirectoryAtPath:savePath error:nil];
        for (NSString *fileName in contentArray){
            if ([[fileName pathExtension] isEqualToString:@"jpeg"]) {
                [self.dataArray addObject:[fileName stringByDeletingPathExtension]];
            }
        }
        

    }
    
}

- (void)viewDidUnload
{
    [self setTableview:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


@end
