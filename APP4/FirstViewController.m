//
//  FirstViewController.m
//  APP4
//
//  Created by apple on 12-12-20.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//
#import <GLKit/GLKit.h>

#import "FileViewController.h"
#import "GlossaryViewController.h"

#import "FirstViewController.h"

#import "ButtonView.h"
#import "LabelView.h"
#import "LETGlossaryManagement.h"

#import "MBProgressHUD.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

#define kTimeInterval 1.0/60

#define kBorderWidth 5

#define kPosterWidth 96.0
#define kPosterHeight 128.0
#define kMainPosterWidth 224.0
#define kMainPosterHeight 160.0

#define kFirstCirclePosterCount 10
#define kFirstCircleRadius 130

#define kSecondCirclePosterCount 15
#define kSecondCircleRadius 220

#define kEndValue 440
#define animationDuration 1.5


//uiview在左上角，quartz在左下角

@synthesize tapGesture;
@synthesize currentTime;
@synthesize timer;
@synthesize menuView;
@synthesize titleLbl;
@synthesize videoBtn;
@synthesize glossaryBtn;

static NSString *_WebAdressOfFreeboxWS_LOGIN_2_0 = @"http://freeboxgame.com/feiheApp/php/call_ajax.php?LOGIN=";

/*
 
#pragma mark - Http request delegations

// 请求结束，获取 Response 数据
- ( void )requestFinished:(ASIHTTPRequest *)request{
    
    if ([[[request responseString]substringToIndex:5]isEqualToString:@"LOGIN"])
    {
        if ([DataParser loginApplication:[self.request responseString]])
        {
            //NSLog(@"%@",[self.request responseString]);
            [self loginSuccess];
        }
        else
        {
            [self loginFail];
        }
    }
    else
    {
        UIAlertView *requstError = [[UIAlertView alloc]initWithTitle:@"服务器响应错误" message:@"与服务器连接异常，请确认网络连接后重试。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [requstError show];
        [requstError release];
    }
    [self.loginBtn setEnabled:YES];
}

// 请求失败，获取 error
- ( void )requestFailed:( ASIHTTPRequest *)request{
    
    if ([self.request error])
    {
        NSLog(@"%@",[[self.request error] localizedDescription]) ;
        NSString *str = [[self.request error] localizedDescription];
        
        UIAlertView *requstError = [[UIAlertView alloc]initWithTitle:@"网络错误" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [requstError show];
        [requstError release];
    }
    [self.loginBtn setEnabled:YES];
}

*/

- (IBAction)loginPassword:(id)sender {
    self.userPassword=[sender text];
}

- (IBAction)login:(id)sender {
    
    LETGlossaryManagement *gm=[LETGlossaryManagement sharedInstance];
    [gm saveUserID:self.userID andPassword:self.userPassword];
    
    
    // —— 用户名或密码都不应为空
    
    // ========== MBProgressHUD ========== //
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // 多线程异步处理
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // ### ===== Do something... ===== ### //
        // #=============================
        NSString *userInput = [NSString stringWithFormat:@"%@@-%@",self.userID,self.userPassword];
        NSString *loginresult = [NSString stringWithFormat:@"%@%@",_WebAdressOfFreeboxWS_LOGIN_2_0,userInput];
        NSURL *url = [NSURL URLWithString:loginresult];
        [self setRequest:[ASIHTTPRequest requestWithURL:url]];
        //Customise our user agent, for no real reason
        [self.request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
        // 设定委托，委托自己实现异步请求方法
        [self.request setDelegate : self ];
        // 开始异步请求
        [self.request startAsynchronous];
        // ### ===== Do something End ===== ### //
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.loginBtn setHidden:YES];
            [self.loginIDTF setHidden:YES];
            [self.loginPasswordTF setHidden:YES];
            [self showButtonsAndLabel];
        });
    });
    
}

- (IBAction)loginID:(id)sender {
    
    self.userID=[sender text];
}

#pragma mark - action

- (IBAction)videoPressed:(id)sender {
    
    FileViewController *fileVC=[[FileViewController alloc] initWithNibName:@"FileViewController" bundle:nil];
    
    [self.navigationController pushViewController:fileVC animated:YES];
    [fileVC.navigationController setNavigationBarHidden:NO];
    [fileVC.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
}

- (IBAction)glossaryPressed:(id)sender {
    
    GlossaryViewController *glossaryVC=[[GlossaryViewController alloc] initWithNibName:@"GlossaryViewController" bundle:nil];

    [self.navigationController pushViewController:glossaryVC animated:YES];
    [glossaryVC.navigationController setNavigationBarHidden:NO];
    [glossaryVC.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
}

#pragma mark - animation

- (void)tap:(UITapGestureRecognizer *)gesture{
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTimeInterval target:self selector:@selector(movePosters) userInfo:nil repeats:YES];
    
}

- (void)movePosters{
    
    currentTime+=kTimeInterval;
    
    if (currentTime<=animationDuration) {
        for (int i=0; i<self.posters.count; i++) {
            UIImageView *imageView=[self.posters objectAtIndex:i];
            CGFloat startValue=[[self.postersCenterY objectAtIndex:i] floatValue];
            CGFloat pointY=PRTweenTimingFunctionBounceOut(currentTime, startValue, kEndValue-startValue, 1.5);
            [imageView setCenter:CGPointMake(imageView.center.x, pointY)];
        }
        
        [self.menuView setAlpha:(currentTime/animationDuration)];
        
    }else{
        [timer invalidate];
        [self.view removeGestureRecognizer:tapGesture];
        
    }
    
}

CGFloat PRTweenTimingFunctionBounceOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat result;
    
    if ((t/=d) < (1/2.75)) {//36%
        result = c*(7.5625*t*t) + b;
        
    } else if (t < (2/2.75)) {
        result = c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
        //54%
    } else if (t < (2.5/2.75)) {
        result = c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
    } else {
        result = c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
    }
    
    return result;
    
}


#pragma mark - show posters

- (void)showAllPosters{
    [self showPostersInCount:kSecondCirclePosterCount andRadius:kSecondCircleRadius];
    [self showPostersInCount:kFirstCirclePosterCount andRadius:kFirstCircleRadius];
}

//显示中心主海报，第一次运行程序时显示Friends海报，以后显示用户的截图
- (void)showMainPoster{
    
    int randomDegree=arc4random()%60-30;
    UIImage *image=[UIImage imageNamed:@"Friends.jpg"];
    UIImageView *imageView=[[UIImageView alloc] initWithImage:image];
    [imageView.layer setBorderWidth:kBorderWidth];
    [imageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    [imageView setCenter:self.view.center];
    [imageView setBounds:CGRectMake(0, 0, kMainPosterWidth, kMainPosterHeight)];
    [imageView setTransform:CGAffineTransformMakeRotation(GLKMathDegreesToRadians(randomDegree))];
    [self.view addSubview:imageView];
    
    [self.postersCenterY addObject:[NSNumber numberWithFloat:self.view.center.y]];
    [self.posters addObject:imageView];
    
}

//显示各圈上的海报
- (void)showPostersInCount:(int)count andRadius:(float)radius{

    int numberOfPosters=self.postersName.count;
    if (!numberOfPosters) {
        return;
    }
    
    float angle=2*M_PI/count;
    
    for (int i=1; i<=count; i++) {
        
        //取得海报的center
        float pointX, pointY;
        float theAngle=angle*i;
        
        float height=sin(theAngle)*radius;
        float width=cos(theAngle)*radius;
        pointY=self.view.center.y-height;
        pointX=self.view.center.x-width;
        
        //只显示center在屏幕范围内的图片
        if (pointX<self.view.bounds.size.width && pointY<self.view.bounds.size.height) {
            //随即取得海报名字和旋转角度
            int randomNum=arc4random()%(numberOfPosters-i);
            int randomDegree=arc4random()%60-30;
            
            //在UIView上显示海报
            [self showImage:[self.postersName objectAtIndex:randomNum] atCenter:CGPointMake(pointX, pointY) rotate:randomDegree];
            [self.postersName removeObjectAtIndex:randomNum];
            
            //把Y坐标加入array，以便之后做动画用
            [self.postersCenterY addObject:[NSNumber numberWithFloat:pointY]];
            
        }
        
    }
    
}

//显示海报
- (void)showImage:(NSString *)name atCenter:(CGPoint)point rotate:(int)degree{
    
    UIImage *image=[UIImage imageNamed:name];
    UIImageView *imageView=[[UIImageView alloc] initWithImage:image];
    [imageView.layer setBorderWidth:kBorderWidth];
    [imageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];

    [imageView setCenter:point];
    [imageView setBounds:CGRectMake(0, 0, kPosterWidth, kPosterHeight)];
    [imageView setTransform:CGAffineTransformMakeRotation(GLKMathDegreesToRadians(degree))];
    [self.view addSubview:imageView];
    
    [self.posters addObject:imageView];
    
}

//获得所有海报的名字
- (void)getPostersName{
    
    /*

    NSString *userPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //NSString *resourcePath=@"/Users/apple/Code/AVPlayer/APP4";
    NSString *poster=@"posters";
    self.posterPath=[userPath stringByAppendingPathComponent:poster];
    //NSLog(@"%@",self.posterPath);
    
    NSArray *allContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.posterPath error:nil];
    self.postersName=[NSMutableArray arrayWithCapacity:0];
    
    for (NSString *content in allContents) {
        if ([[content pathExtension] isEqualToString:@"jpg"]) {
            [self.postersName addObject:content];
        }
    }
     
     */
    
    NSArray *array=[NSArray arrayWithObjects:@"2 Broke Girls.jpg",
                    @"Bones.jpg",
                    @"Boston Legal.jpg",
                    @"Brothers and Sisters.jpg",
                    @"Cold Case.jpg",
                    @"Criminal Minds.jpg",
                    @"CSI.jpg",
                    @"Desperate Housewives.jpg",
                    @"Dexter.jpg",
                    @"Downton Abbey.jpg",
                    @"Friends2.jpg",
                    @"Fringe.jpg",
                    @"Gossip Girl.jpg",
                    @"Grey's Anatomy.jpg",
                    @"Heroes.jpg",
                    @"House.jpg",
                    @"How I Met Your Mother.jpg",
                    @"Legend of The Seeker.jpg",
                    @"Nikita.jpg",
                    @"Nip Tuck.jpg",
                    @"Prison Break.jpg",
                    @"Revenge.jpg",
                    @"Rome.jpg",
                    @"Sherlock.jpg",
                    @"Skins.jpg",
                    @"The 4400.jpg",
                    @"The Big Bang Theory.jpg",
                    @"The Big Bang Theory2.jpg",
                    @"The Closer.jpg",
                    @"The Good Wife.jpg",
                    @"The Killing.jpg",
                    @"The Office.jpg",
                    @"The Pretender.jpg",
                    @"The Prisoner.jpg",
                    @"True Blood.jpg",
                    @"Ugly Betty.jpg",
                    @"Weeds.jpg",
                    @"Will and Grace.jpg"
                    , nil];
    self.postersName=[NSMutableArray arrayWithArray:array];
    
}

#pragma mark - button

- (void)showButtonsAndLabel{
    
    CGColorSpaceRef cs=CGColorSpaceCreateDeviceRGB();
    CGColorRef color=CGColorCreate(cs, (CGFloat[]){244/255.0, 244/255.0, 244/255.0, 1});
    
    [self.videoBtn setCenter:CGPointMake(self.view.center.x, self.view.center.y-30)];
    [self.videoBtn setBounds:CGRectMake(0, 0, 80, 40)];
    [self.videoBtn setRadiusOfArcs:5];
    [self.videoBtn setLineOffset:3];
    [self.videoBtn setLineWidth:3];
    [self.videoBtn setTextSize:20];
    [self.videoBtn setTextPointX:12];
    [self.videoBtn setTextPointY:12];
    [self.videoBtn setFillColor:color];
    [self.videoBtn setButtonText:@"Video"];
    
    [self.glossaryBtn setCenter:CGPointMake(self.view.center.x, self.view.center.y+30)];
    [self.glossaryBtn setBounds:CGRectMake(0, 0, 110, 40)];
    [self.glossaryBtn setRadiusOfArcs:5];
    [self.glossaryBtn setLineOffset:3];
    [self.glossaryBtn setLineWidth:3];
    [self.glossaryBtn setTextSize:20];
    [self.glossaryBtn setTextPointX:13];
    [self.glossaryBtn setTextPointY:12];
    [self.glossaryBtn setFillColor:color];
    [self.glossaryBtn setButtonText:@"Glossary"];
    
    [self.titleLbl setCenter:CGPointMake(self.view.center.x, 90)];
    [self.titleLbl setBounds:CGRectMake(0, 0, 280, 100)];
    [self.titleLbl setText:@"看美剧学英语"];
    [self.titleLbl setFont:[UIFont boldSystemFontOfSize:60]];
    [self.titleLbl setTextColor:[UIColor whiteColor]];
    [self.titleLbl setShadowColor:[UIColor whiteColor]];
    [self.titleLbl setShadowOffset:CGSizeMake(0, 0)];
    [self.titleLbl setShadowRadius:20];
    
    [self.titleLbl setHidden:NO];
    [self.glossaryBtn setHidden:NO];
    [self.videoBtn setHidden:NO];
    
    CGColorSpaceRelease(cs);
    CGColorRelease(color);

}

//第一次启动时注册用户名和密码，然后把它存到userDefault，以后不再显示登陆项
- (void)showLogInThing{
    
    [self.loginIDTF setFrame:CGRectMake(20, 150, 280, 30)];
    [self.menuView addSubview:self.loginIDTF];
    
    [self.loginPasswordTF setFrame:CGRectMake(20, 200, 280, 30)];
    [self.menuView addSubview:self.loginPasswordTF];
    
    [self.loginBtn setFrame:CGRectMake(140, 250, 50, 50)];
    [self.menuView addSubview:self.loginBtn];
    
    [self.titleLbl setHidden:YES];
    [self.glossaryBtn setHidden:YES];
    [self.videoBtn setHidden:YES];
    
}

#pragma mark - defaults

//-(void)viewDidAppear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:YES];
//}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:YES];
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
    
    [self.navigationController setDelegate:self];
    
    //手势识别
    tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.menuView];
    [self.menuView setAlpha:0];
    
    /*

    //如果是第一次，则显示登陆控件
    LETGlossaryManagement *gm=[LETGlossaryManagement sharedInstance];
    if (![gm userID]) {
        
        [self showLogInThing];
    }else{
        
        [self showButtonsAndLabel];
        
    }
     */
    
    [self showButtonsAndLabel];


 
    //初始化所有海报
    self.posters=[NSMutableArray arrayWithCapacity:0];
    self.postersCenterY=[NSMutableArray arrayWithCapacity:0];
    [self getPostersName];
    
    //显示海报
    [self showAllPosters];
    [self showMainPoster];
    
    
}

- (void)viewDidUnload
{
    
    self.postersName=nil;
    self.posters=nil;
    self.postersCenterY=nil;
    

    [self setMenuView:nil];
    [self setVideoBtn:nil];
    [self setGlossaryBtn:nil];
    [self setTitleLbl:nil];
    [self setLoginIDTF:nil];
    [self setLoginPasswordTF:nil];
    [self setLoginBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    return toInterfaceOrientation==UIInterfaceOrientationPortrait;
    
}

@end
