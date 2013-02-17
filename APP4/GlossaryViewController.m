//
//  GlossaryViewController.m
//  APP4
//
//  Created by apple on 12-12-26.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "GlossaryViewController.h"
#import "LabelView.h"

#define kTableViewHeaderHeight 40;

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section==0) {
        return self.glossaryDefaults.count;
    }if (section==1) {
        return self.glossaryCustom.count;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
        LabelView *titleView=[[LabelView alloc] init];
        [titleView setFrame:CGRectMake(50, 50, 50, 50)];
        [titleView setBackgroundColor:[UIColor clearColor]];
        [titleView setText:@"  Default"];
        [titleView setFont:[UIFont boldSystemFontOfSize:17]];
        [titleView setTextColor:[UIColor whiteColor]];
        [titleView setShadowColor:[UIColor whiteColor]];
        [titleView setShadowOffset:CGSizeMake(0, 0)];
        [titleView setShadowRadius:1];
        return titleView;
    }else if (section==1){
        LabelView *titleView=[[LabelView alloc] init];
        [titleView setFrame:CGRectMake(50, 50, 50, 50)];
        [titleView setBackgroundColor:[UIColor clearColor]];
        [titleView setText:@"  Custom"];
        [titleView setFont:[UIFont boldSystemFontOfSize:17]];
        [titleView setTextColor:[UIColor whiteColor]];
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
        
        [self.cellNib instantiateWithOwner:self options:nil];
        
        NSString *glossaryName;
        if (indexPath.section==0) {
            glossaryName=[self.glossaryDefaults objectAtIndex:indexPath.row];
        }else if (indexPath.section==1){
            glossaryName=[self.glossaryCustom objectAtIndex:indexPath.row];
        }
        self.mGlossaryCell.glossaryNameLbl.text=glossaryName;

        
        cell=self.mGlossaryCell;
        //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CardViewController *cardVC=[[CardViewController alloc] initWithNibName:@"CardViewController" bundle:nil];
    
    GlossaryManagement *gm=[[GlossaryManagement alloc] init];
    
    if (indexPath.section==0) {
        NSMutableArray *glosDefault=[gm getDefaultGlossariesPath];
        cardVC.savePath=[glosDefault objectAtIndex:indexPath.row];
    }else if (indexPath.section==1){
        NSMutableArray *glosCustom=[gm getCustomGlossariesPath];
        cardVC.savePath=[glosCustom objectAtIndex:indexPath.row];
    }
    [self.navigationController pushViewController:cardVC animated:YES];
    [cardVC.navigationController setNavigationBarHidden:NO];
    [cardVC.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
}

- (void)initBarItems{
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToFirstView)];
    [backButton setTintColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    UIBarButtonItem *addButton=[[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(backToFirstView)];
    [addButton setTintColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]];
    [self.navigationItem setRightBarButtonItem:addButton];
    
    
    LabelView *titleView=[[LabelView alloc] init];
    [titleView setCenter:CGPointMake(self.view.center.x, 30)];
    [titleView setBounds:CGRectMake(0, 0, 70, 50)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleView setText:@"Gloss"];
    [titleView setFont:[UIFont boldSystemFontOfSize:24]];
    [titleView setTextColor:[UIColor whiteColor]];
    [titleView setTextAlignment:UITextAlignmentCenter];
    [titleView setShadowColor:[UIColor whiteColor]];
    [titleView setShadowOffset:CGSizeMake(0, 0)];
    [titleView setShadowRadius:3];
    
    [self.navigationItem setTitleView: titleView];
}

- (void)backToFirstView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initGlossaryData{
    
    GlossaryManagement *gm=[[GlossaryManagement alloc] init];
    
    self.glossaryDefaults=[gm getDefaultGlossariesName];
    self.glossaryCustom=[gm getCustomGlossariesName];
    
    
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
    
    [self initBarItems];
    
    [self.mTableView setDelegate:self];
    [self.mTableView setDataSource:self];
    
    [self initGlossaryData];
    
    self.cellNib=[UINib nibWithNibName:@"GlossaryCell" bundle:nil];
    
    
}

- (void)viewDidUnload
{
    [self setMTableView:nil];
    [self setMGlossaryCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
