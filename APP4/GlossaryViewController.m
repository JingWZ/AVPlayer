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
        [titleView setTextColor:[UIColor grayColor]];
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
    [titleView setTextColor:[UIColor grayColor]];
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
    [self initGlossary:self.glossaryDefaults withKey:kGlossaryDefault];
    [self initGlossary:self.glossaryCustom withKey:kGlossaryCustom];
}

/*
 structure of the glossaries info in NSUserDefaults
 
 NSUserDefaults---->(key)kGlossaryDefault-->(value)NSDictionary1
               ---->(key)kGlossaryCustom-->(value)NSDictionary2
 
 NSDictionary1---->(key)kGlossaryPriority-->(object)NSArrayPriority(the sequence the glossary names shown in the view)
 NSDictionary1---->(key)glossary1,2,...,n-->(object)NSArrayGlossary(contain all the glossaries in Default of Custom)
 NSArrayGlossary---->(index)0-->(NSString *)glossaryPath
 NSArrayGlossary---->(index)1-->(NSString *)videoPath
 NSArrayGlossary---->(index)2-->(NSString *)subtitlePath
 NSArrayGlossary---->(index)3-->(NSDictionary *)allCards
 allCards---->(key)card1,2,...,n-->(NSArray *)eachCard
 eachCard---->(index)0-->(NSString)imagePath;
 eachCard---->(index)1-->(NSNumber)recordCount;
 
 */

- (void)initGlossary:(NSMutableArray *)array withKey:(NSString *)key{

    array=[NSMutableArray arrayWithCapacity:0];
    
    //get glossary data from NSUserDefaults if already had one
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    
    NSDictionary *allGlossaries=[ud dictionaryForKey:key];
    if (allGlossaries) {
        
        NSArray *priority=[allGlossaries objectForKey:kGlossaryPriority];
        NSInteger count=[priority count]; 
        
        if (priority) {
            for (int i=0; i<count; i++) {
                NSString *key=[priority objectAtIndex:i];
                NSArray *glossary=[allGlossaries objectForKey:key];
                NSString *glossaryPath=[glossary objectAtIndex:0];
                [array addObject:glossaryPath];
            }
        }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initBarItems];

    [self.mTableView setDelegate:self];
    [self.mTableView setDataSource:self];
    
    [self initGlossaryData];
    
    
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
