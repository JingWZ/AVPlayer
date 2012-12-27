//
//  FileViewController.m
//  APP4
//
//  Created by apple on 12-12-12.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "FileViewController.h"
#import "XXXPlayViewController.h"

@interface FileViewController ()

@end

@implementation FileViewController

#define kDefaultNumber 1111

@synthesize mTableVIew;
@synthesize videoFiles, subtitleFiles;
@synthesize selectedSubtitleNumber,selectedVideoNumber;

#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return self.videoFiles.count;
    } else if (section==1) {
        return self.subtitleFiles.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"video";
    } else if (section==1) {
        return @"subtitle";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellID=@"cellid";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    if (indexPath.section==0) {
        cell.textLabel.text=[self.videoFiles objectAtIndex:indexPath.row];
        if (self.selectedVideoNumber!=kDefaultNumber) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    } else if (indexPath.section==1) {
        cell.textLabel.text=[self.subtitleFiles objectAtIndex:indexPath.row];
        if (self.selectedSubtitleNumber!=kDefaultNumber) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        if (indexPath.row==self.selectedVideoNumber) {
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
            self.selectedVideoNumber=kDefaultNumber;
        }else {
            NSIndexPath *lastIndex=[[NSIndexPath indexPathWithIndex:0] indexPathByAddingIndex:self.selectedVideoNumber];
            [[tableView cellForRowAtIndexPath:lastIndex] setAccessoryType:UITableViewCellAccessoryNone];
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            self.selectedVideoNumber=indexPath.row;
        }
    }else if (indexPath.section==1) {
        if (indexPath.row==self.selectedSubtitleNumber) {
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
            self.selectedSubtitleNumber=kDefaultNumber;
        }else {
            NSIndexPath *lastIndex=[[NSIndexPath indexPathWithIndex:1] indexPathByAddingIndex:self.selectedSubtitleNumber];
            [[tableView cellForRowAtIndexPath:lastIndex] setAccessoryType:UITableViewCellAccessoryNone];
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            self.selectedSubtitleNumber=indexPath.row;
        }
    }

}

#pragma mark - init

- (void)initVideoFiles{
    
    self.videoFiles=[NSMutableArray arrayWithCapacity:0];

    for (NSString *path in [self fileContent]) {
        if ([[path pathExtension] isEqualToString:@"mp4"]) {
            [self.videoFiles addObject:path];
        }
    }
    
}

- (void)initSubtitleFiles{
    
    self.subtitleFiles=[NSMutableArray arrayWithCapacity:0];
    
    for (NSString *path in [self fileContent]) {
        [self.subtitleFiles addObject:path];

//        if ([[path pathExtension] isEqualToString:@"srt"]) {
//            [self.subtitleFiles addObject:path];
//        }
    }

}

- (NSArray *)fileContent{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self userPath] error:nil];
}

- (NSString *)userPath{
    NSString *userPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return userPath;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    if ((self.selectedVideoNumber!=kDefaultNumber) && (self.selectedSubtitleNumber!=kDefaultNumber) ) {

        UIBarButtonItem *playButton=[[UIBarButtonItem alloc] initWithTitle:@"Play" style:UIBarButtonItemStylePlain target:self action:@selector(moveToPlayView)];
        
        [self.navigationItem setRightBarButtonItem:playButton animated:NO];

    }else {
        
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        
    }
    
}

#pragma mark - action

- (void)moveToPlayView{

    NSString *videoName=[self.videoFiles objectAtIndex:self.selectedVideoNumber];
    NSString *subtitleName=[self.subtitleFiles objectAtIndex:self.selectedSubtitleNumber];
    
    XXXPlayViewController *playVC=[[XXXPlayViewController alloc] initWithNibName:@"XXXPlayViewController" bundle:nil];
    
    playVC.videoPath=[[self userPath] stringByAppendingPathComponent:videoName];
    playVC.subtitlePath=[[self userPath] stringByAppendingPathComponent:subtitleName];

    [self.navigationController pushViewController:playVC animated:YES];
    
    [playVC.navigationController setNavigationBarHidden:NO];
    [playVC.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];

}

#pragma mark - defaults

- (void)viewDidDisappear:(BOOL)animated{
    [self removeObserver:self forKeyPath:@"selectedVideoNumber"];
    [self removeObserver:self forKeyPath:@"selectedSubtitleNumber"];

}

- (void)viewDidAppear:(BOOL)animated{
    
    //监控check的情况
    [self addObserver:self forKeyPath:@"selectedVideoNumber" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"selectedSubtitleNumber" options:NSKeyValueObservingOptionNew context:nil];

}

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
    
    [self.navigationItem setTitle:@"文件"];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    
    [self.mTableVIew setDelegate:self];
    [self.mTableVIew setDataSource:self];
    
    //获取文件中的视频和字幕文件名
    [self initVideoFiles];
    [self initSubtitleFiles];
    
    //初始化两个selectedNumber
    self.selectedVideoNumber=kDefaultNumber;
    self.selectedSubtitleNumber=kDefaultNumber;
    
}

- (void)viewDidUnload
{
    [self setMTableVIew:nil];
    self.videoFiles=nil;
    self.subtitleFiles=nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
