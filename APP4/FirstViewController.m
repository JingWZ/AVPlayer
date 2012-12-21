//
//  FirstViewController.m
//  APP4
//
//  Created by apple on 12-12-20.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//
#import <GLKit/GLKit.h>

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

#define kTimeInterval 1.0/60

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

static NSString *posterPath=@"/Users/apple/Code/AVPlayer/APP4/posters";
//uiview在左上角，quartz在左下角

@synthesize currentTime;
@synthesize timer;

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
    }else{
        [timer invalidate];
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
    //NSLog(@"%g=%g",t,result);
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
    [imageView setCenter:point];
    [imageView setBounds:CGRectMake(0, 0, kPosterWidth, kPosterHeight)];
    [imageView setTransform:CGAffineTransformMakeRotation(GLKMathDegreesToRadians(degree))];
    [self.view addSubview:imageView];
    
    [self.posters addObject:imageView];
    
}

//获得所有海报的名字
- (void)getPostersName{
    
    NSArray *allContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:posterPath error:nil];
    self.postersName=[NSMutableArray arrayWithCapacity:0];
    
    for (NSString *content in allContents) {
        if ([[content pathExtension] isEqualToString:@"jpg"]) {
            [self.postersName addObject:content];
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
    
    //手势识别
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapGesture];
    
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.postersName=nil;
    self.posters=nil;
    self.postersCenterY=nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
