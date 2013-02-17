//
//  FileViewController.m
//  APP4
//
//  Created by apple on 12-12-12.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "FileViewController.h"
#import "PlayViewController.h"
#import "LabelView.h"

#define kDefaultNumber 1111
#define kTableViewHeaderHeight 40;

@interface FileViewController ()

@end

@implementation FileViewController
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
        LabelView *titleView=[[LabelView alloc] init];
        [titleView setFrame:CGRectMake(50, 50, 50, 50)];
        [titleView setBackgroundColor:[UIColor clearColor]];
        [titleView setText:@"  Video"];
        [titleView setFont:[UIFont boldSystemFontOfSize:17]];
        [titleView setTextColor:[UIColor grayColor]];
        [titleView setShadowColor:[UIColor whiteColor]];
        [titleView setShadowOffset:CGSizeMake(0, 0)];
        [titleView setShadowRadius:1];
        return titleView;
    }else if (section==1){
        LabelView *titleView=[[LabelView alloc] init];
        [titleView setFrame:CGRectMake(50, 50, 50, 50)];
        [titleView setBackgroundColor:[UIColor clearColor]];
        [titleView setText:@"  Subtitle"];
        [titleView setFont:[UIFont boldSystemFontOfSize:17]];
        [titleView setTextColor:[UIColor grayColor]];
        [titleView setShadowColor:[UIColor whiteColor]];
        [titleView setShadowOffset:CGSizeMake(0, 0)];
        [titleView setShadowRadius:1];
        return titleView;
        
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kTableViewHeaderHeight;
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
        
        //[self.subtitleFiles addObject:path];
        
        
        if ([[path pathExtension] isEqualToString:@"srt"]) {
            [self.subtitleFiles addObject:path];
        }
         
    }
    
}

- (NSArray *)fileContent{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self userPath] error:nil];
}

- (NSString *)userPath{
    NSString *userPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return userPath;
}

- (void)initBarItems{
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToFirstView)];
    [backButton setTintColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    LabelView *titleView=[[LabelView alloc] init];
    [titleView setCenter:CGPointMake(self.view.center.x, 30)];
    [titleView setBounds:CGRectMake(0, 0, 70, 50)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleView setText:@"Files"];
    [titleView setFont:[UIFont boldSystemFontOfSize:24]];
    [titleView setTextColor:[UIColor whiteColor]];
    [titleView setTextAlignment:UITextAlignmentCenter];
    [titleView setShadowColor:[UIColor whiteColor]];
    [titleView setShadowOffset:CGSizeMake(0, 0)];
    [titleView setShadowRadius:3];
    
    
    [self.navigationItem setTitleView: titleView];
    
    
}

#pragma mark - action

- (void)moveToPlayView{
    
    NSString *videoName=[self.videoFiles objectAtIndex:self.selectedVideoNumber];
    NSString *subtitleName=[self.subtitleFiles objectAtIndex:self.selectedSubtitleNumber];
    
    PlayViewController *playVC=[[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
    
    playVC.videoPath=[[self userPath] stringByAppendingPathComponent:videoName];
    playVC.subtitlePath=[[self userPath] stringByAppendingPathComponent:subtitleName];
    
    [self.navigationController pushViewController:playVC animated:YES];
    [playVC.navigationController setNavigationBarHidden:YES];
    [playVC.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    
    
}

- (void)backToFirstView{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ((self.selectedVideoNumber!=kDefaultNumber) && (self.selectedSubtitleNumber!=kDefaultNumber) ) {
        
        UIBarButtonItem *playButton=[[UIBarButtonItem alloc] initWithTitle:@"Play" style:UIBarButtonItemStyleBordered target:self action:@selector(moveToPlayView)];
        [playButton setTintColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]];
        
        [self.navigationItem setRightBarButtonItem:playButton animated:NO];
        
    }else {
        
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        
    }
    
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
    
    [self initBarItems];
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
