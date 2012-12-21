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
@synthesize mTableVIew;
@synthesize videoFiles, subtitleFiles;
@synthesize isCheckingOfSectionOne, isCheckingOfSectionTwo;
@synthesize checkingNumOfSectionOne, checkingNumOfSectionTwo;

@synthesize checkNum;

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
        if ([[isCheckingOfSectionOne objectAtIndex:indexPath.row] boolValue]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    } else if (indexPath.section==1) {
        cell.textLabel.text=[self.subtitleFiles objectAtIndex:indexPath.row];
        if ([[isCheckingOfSectionTwo objectAtIndex:indexPath.row] boolValue]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        
        if ([[self.isCheckingOfSectionOne objectAtIndex:indexPath.row] boolValue]) {
                [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
            [self.isCheckingOfSectionOne removeObjectAtIndex:indexPath.row];
            [self.isCheckingOfSectionOne insertObject:[NSNumber numberWithBool:NO] atIndex:indexPath.row];
            
            NSLog(@"fsf");
            
        } else {
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            [self.isCheckingOfSectionOne removeObjectAtIndex:indexPath.row];
            [self.isCheckingOfSectionOne insertObject:[NSNumber numberWithBool:YES] atIndex:indexPath.row];
        }
        
    } else if (indexPath.section==1) {
        
    }
    
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    self.checkNum++;
}

#pragma mark - init

- (void)initVideoFiles{
    
    self.videoFiles=[NSMutableArray arrayWithCapacity:0];
    self.isCheckingOfSectionOne=[NSMutableArray arrayWithCapacity:0];

    for (NSString *path in [self fileContent]) {
        if ([[path pathExtension] isEqualToString:@"mp4"]) {
            [self.videoFiles addObject:path];
            [self.isCheckingOfSectionOne addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
}

- (void)initSubtitleFiles{
    
    self.subtitleFiles=[NSMutableArray arrayWithCapacity:0];
    self.isCheckingOfSectionTwo=[NSMutableArray arrayWithCapacity:0];
    
    for (NSString *path in [self fileContent]) {
        if ([[path pathExtension] isEqualToString:@"srt"]) {
            [self.subtitleFiles addObject:path];
            [self.isCheckingOfSectionTwo addObject:[NSNumber numberWithBool:NO]];

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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"checkNum"]) {
        if (self.checkNum==2) {
            //设置导航的右边的item
            UIBarButtonItem *playItem=[[UIBarButtonItem alloc] initWithTitle:@"Play" style:UIBarButtonItemStylePlain target:self action:@selector(moveToPlayView)];
            [self.navigationItem setRightBarButtonItem:playItem animated:YES];
        } else {
            [self.navigationItem setRightBarButtonItem:nil];
        }
    }
}

- (void)moveToPlayView{
    
    XXXPlayViewController *playVC=[[XXXPlayViewController alloc] initWithNibName:@"XXXPlayViewController" bundle:nil];
    [self.navigationController pushViewController:playVC animated:YES];
    
    [playVC.navigationController setNavigationBarHidden:NO];
    [playVC.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];

    //NSString *videoPath=[self userPath]
    //playVC.mURL=[NSURL fileURLWithPath:]
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
    
    [self.mTableVIew setDelegate:self];
    [self.mTableVIew setDataSource:self];
    
    [self.mTableVIew setBackgroundColor:[UIColor blackColor]];
    
    [self initVideoFiles];
    [self initSubtitleFiles];
    

    //监控check的数量
    //[self addObserver:self forKeyPath:@"checkNum" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)viewDidUnload
{
    [self setMTableVIew:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
