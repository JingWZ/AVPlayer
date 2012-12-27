//
//  GlossaryViewController.m
//  APP4
//
//  Created by apple on 12-12-26.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "GlossaryViewController.h"

#define KVGlossaryDefaults @"glossaryDefaults"
#define KVGlossaryCustom @"glossaryCustom"

@interface GlossaryViewController ()

@end

@implementation GlossaryViewController
@synthesize mTableView;

#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    if (self.glossaryCustom.count) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (section==0) {
        return self.glossaryDefaults.count;
    }if (section==1) {
        return self.glossaryCustom.count;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"默认生词本";
    }else if (section==1){
        return @"自定义生词本";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellID=@"cellid";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    
    if (indexPath.section==0) {
        cell.textLabel.text=[[self.glossaryDefaults objectAtIndex:indexPath.row] lastPathComponent];
    }else if (indexPath.section==1){
        cell.textLabel.text=[[self.glossaryCustom objectAtIndex:indexPath.row]lastPathComponent];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CardViewController *cardVC=[[CardViewController alloc] initWithNibName:@"CardViewController" bundle:nil];
    if (indexPath.section==0) {
        cardVC.savePath=[self.glossaryDefaults objectAtIndex:indexPath.row];
    }else if (indexPath.section==1){
        cardVC.savePath=[self.glossaryCustom objectAtIndex:indexPath.row];
    }
    [self.navigationController pushViewController:cardVC animated:YES];
    [cardVC.navigationController setNavigationBarHidden:YES];
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
    
    [self.navigationItem setTitle:@"生词本"];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];

    [self.mTableView setDelegate:self];
    [self.mTableView setDataSource:self];
    
    //初始化两种生词本
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    if ([ud arrayForKey:KVGlossaryDefaults]) {
        self.glossaryDefaults=[NSMutableArray arrayWithArray:[ud arrayForKey:KVGlossaryDefaults]];
    }else{
        self.glossaryDefaults=[NSMutableArray arrayWithCapacity:0];
    }
    if ([ud arrayForKey:KVGlossaryCustom]) {
        self.glossaryCustom=[NSMutableArray arrayWithArray:[ud arrayForKey:KVGlossaryCustom]];
    }else{
        self.glossaryCustom=[NSMutableArray arrayWithCapacity:0];
    }
    
}

- (void)viewDidUnload
{
    [self setMTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
