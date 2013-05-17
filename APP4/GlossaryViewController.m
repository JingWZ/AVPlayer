//
//  GlossaryViewController.m
//  APP4
//
//  Created by apple on 12-12-26.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "GlossaryViewController.h"
#import "LabelView.h"
#import "ASIFormDataRequest.h"

#define kTableViewHeaderHeight 40;

@implementation GlossaryViewController

@synthesize mTableView;

static NSString *_WebAdressOfFreeboxWS_LOGIN_2_0 = @"http://freeboxgame.com/feiheApp/php/call_ajax.php?LOGIN=";


#pragma mark - tableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    LETGlossaryManagement *gm=[LETGlossaryManagement sharedInstance];
    
    NSInteger number=[[gm allGlossaries] count];
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellID=@"cellid";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellID];
    
    if (cell==nil) {
        
        [self.cellNib instantiateWithOwner:self options:nil];
        
        LETGlossaryManagement *gm=[LETGlossaryManagement sharedInstance];
        LETGlossary *glossary=[gm glossaryAtIndex:indexPath.row];
        
        [self.mGlossaryCell.glossaryNameLbl setText:glossary.glossaryName];
        
        cell=self.mGlossaryCell;
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CardViewController *cardVC=[[CardViewController alloc] initWithNibName:@"CardViewController" bundle:nil];
    
    cardVC.glossaryIndex=indexPath.row;
    
    [self.navigationController pushViewController:cardVC animated:YES];
    [cardVC.navigationController setNavigationBarHidden:NO];
    [cardVC.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
}

#pragma mark - 上传

/*
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    //上传代码
    //每次上传前，要登陆服务器
    LETGlossaryManagement *gm=[LETGlossaryManagement sharedInstance];
    NSString *userID=[gm userID];
    NSString *userPassword=[gm userPassword];
    
    
    // —— 用户名或密码都不应为空
    
    
    // 多线程异步处理
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // ### ===== Do something... ===== ### //
        // #=============================
        NSString *userInput = [NSString stringWithFormat:@"%@@-%@",userID,userPassword];
        NSString *loginresult = [NSString stringWithFormat:@"%@%@",_WebAdressOfFreeboxWS_LOGIN_2_0,userInput];
        NSURL *url = [NSURL URLWithString:loginresult];
        [self setARequest:[ASIHTTPRequest requestWithURL:url]];
        //Customise our user agent, for no real reason
        [self.aRequest addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
        // 设定委托，委托自己实现异步请求方法
        [self.aRequest setDelegate : self ];
        // 开始异步请求
        [self.aRequest startAsynchronous];
        // ### ===== Do something End ===== ### //
        
        
        [self uploadGlossaryAtIndex:indexPath.row];
        
    });
    
}
 */

- (void)uploadGlossaryAtIndex:(NSInteger)index{
    
    //必须提供memberID, title, quantity
    
    LETGlossaryManagement *gm=[LETGlossaryManagement sharedInstance];
    LETGlossary *glossary=[gm glossaryAtIndex:index];
    
    NSString *title=glossary.glossaryName;
    NSInteger count=[glossary.glossaryCards count];
    NSString *quantity=[NSString stringWithFormat:@"%d",count];
    
    
    //ASIHttpRequest
    NSString *serverURL=@"http://coursepi.com/php/microCardup.php";
    NSURL *url=[NSURL URLWithString:serverURL];
    
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request setPostValue:title forKey:@"title"];
    [request setPostValue:quantity forKey:@"quantity"];
    
    for (int i=0; i<count; i++) {
        
        NSString *subtitlePath=[gm cardSubtitlePathAtGlossaryIndex:index cardIndex:i];
        NSString *imagePath=[gm cardImagePathAtGlossaryIndex:index cardIndex:i];
        NSString *audioPath=[gm cardAudioPathAtGlossaryIndex:index cardIndex:i];
        
        NSString *subtitleKey=[NSString stringWithFormat:@"%d_subtitle",i];
        NSString *imageKey=[NSString stringWithFormat:@"%d_image",i];
        NSString *audioKey=[NSString stringWithFormat:@"%d_audio",i];
        
        [request setFile:subtitlePath forKey:subtitleKey];
        [request setFile:imagePath forKey:imageKey];
        [request setFile:audioPath forKey:audioKey];
        
    }
    
    [request startAsynchronous];
}

- (void)uploadRequestFinished:(ASIHTTPRequest *)request{
    NSData *responseData = [request responseData];
    // Store incoming data into a string
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Server response:%@", response);
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"上传成功" message:@"" delegate:self cancelButtonTitle:@"ok!" otherButtonTitles: nil];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [alert show];
}


- (void)uploadRequestFailed:(ASIHTTPRequest *)request{
    NSLog(@"fail");
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"上传失败" message:@"" delegate:self cancelButtonTitle:@"ok!" otherButtonTitles: nil];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [alert show];
}

#pragma mark - init

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
