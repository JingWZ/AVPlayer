//
//  CoverViewController.m
//  APP4
//
//  Created by apple on 12-12-18.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKit.h>

#import "CoverViewController.h"

@interface CoverViewController ()

@property (assign, nonatomic) float currentTime;

@end

@implementation CoverViewController

#define kFramerate 1.0/60

#define POSTER_WIDTH 96.0
#define POSTER_HEIGHT 128.0
#define MIN_POSTER_COUNT 16

#define MAIN_POSTER_WIDTH 224.0
#define MAIN_POSTER_HEIGHT 160.0


static NSString *posterPath=@"/Users/apple/Code/AVPlayer/APP4/posters";

@synthesize allLayers;
@synthesize randomDegree;
@synthesize currentTime;
@synthesize aView;

#pragma mark - init

- (void)showPosters{
    
    //设置次海报16张
    self.allLayers=[NSMutableArray arrayWithCapacity:0];
    
    //海报文件夹必须有16张以上海报
    int posterCount=[[self posters] count];
    if (posterCount < MIN_POSTER_COUNT) {
        return;
    }
    
    
    //设置海报
    int multiple=1;
    self.randomDegree=arc4random()%60-30;
    NSLog(@"%d",randomDegree);
    NSMutableArray *posters=[NSMutableArray arrayWithArray:[self posters]];
    
    for (int i=0; i<MIN_POSTER_COUNT; i++) {
        
        int randomNum=arc4random()%(MIN_POSTER_COUNT-i);
        int degree=self.randomDegree*multiple;
        
        CALayer *aLayer=[CALayer layer];
        NSString *poster=[posters objectAtIndex:randomNum];
        CGPoint posterPosition=[[[self postersPosition] objectAtIndex:i] CGPointValue];
        CGRect posterBounds=CGRectMake(0, 0, POSTER_WIDTH, POSTER_HEIGHT);
        
        
        [self layer:aLayer withImageName:poster position:posterPosition bounds:posterBounds andRotationDegree:degree];
        [self.allLayers addObject:aLayer];
        
        [posters removeObjectAtIndex:randomNum];
        multiple*=-1;
        
    }
    
    //设置主海报
    //第一次使用时，显示Friends海报，以后显示用户最近使用的图片
    CALayer *layerMain=[CALayer layer];
    NSString *mainPoster=@"Friends.jpg";
    CGPoint mainPosterPostion=CGPointMake(160, 260);
    CGRect mainPosterBounds=CGRectMake(0, 0, MAIN_POSTER_WIDTH, MAIN_POSTER_HEIGHT);
   // CGRect mainPosterBounds=CGRectMake(0, 0, 30, 30);
    

    
    [self layer:layerMain withImageName:mainPoster position:mainPosterPostion bounds:mainPosterBounds andRotationDegree:randomDegree];
    [self.allLayers addObject:layerMain];
    
}


- (NSArray *)posters{
    
    NSArray *allContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:posterPath error:nil];
    NSMutableArray *JPEGContents=[NSMutableArray arrayWithCapacity:0];
    
    for (NSString *content in allContents) {
        if ([[content pathExtension] isEqualToString:@"jpg"]) {
            [JPEGContents addObject:content];
        }
    }
    
    return JPEGContents;
}

- (void)layer:(CALayer *)layer withImageName:(NSString *)name position:(CGPoint)point bounds:(CGRect)rect andRotationDegree:(NSInteger)degree{
    UIImage *imageOriginal=[UIImage imageNamed:name];
    CGImageRef image=imageOriginal.CGImage;
    [self.view.layer addSublayer:layer];
    layer.position=point;
    layer.bounds=rect;
    layer.borderWidth=2.0;
    layer.borderColor=[[UIColor whiteColor] CGColor];
    layer.contents=(__bridge id)(image);
    layer.transform=CATransform3DMakeRotation(GLKMathDegreesToRadians(degree), 0, 0, 1);
}

- (NSArray *)postersPosition{
    
    //初始化海报的位置CGRect
    NSValue *rect0=[NSValue valueWithCGPoint:CGPointMake(300.0, 170.0)];
    NSValue *rect1=[NSValue valueWithCGPoint:CGPointMake(20.0, 170.0)];
    NSValue *rect2=[NSValue valueWithCGPoint:CGPointMake(20.0, 60.0)];
    NSValue *rect3=[NSValue valueWithCGPoint:CGPointMake(300.0, 60.0)];
    NSValue *rect4=[NSValue valueWithCGPoint:CGPointMake(220.0, 60.0)];
    NSValue *rect5=[NSValue valueWithCGPoint:CGPointMake(100.0, 60.0)];
    NSValue *rect6=[NSValue valueWithCGPoint:CGPointMake(160.0, 60.0)];
    NSValue *rect7=[NSValue valueWithCGPoint:CGPointMake(200.0, 140.0)];
    NSValue *rect8=[NSValue valueWithCGPoint:CGPointMake(100.0, 140.0)];
    NSValue *rect9=[NSValue valueWithCGPoint:CGPointMake(20.0, 400.0)];
    NSValue *rect10=[NSValue valueWithCGPoint:CGPointMake(300.0, 400.0)];
    NSValue *rect11=[NSValue valueWithCGPoint:CGPointMake(40.0, 300.0)];
    NSValue *rect12=[NSValue valueWithCGPoint:CGPointMake(280.0, 300.0)];
    NSValue *rect13=[NSValue valueWithCGPoint:CGPointMake(220.0, 400.0)];
    NSValue *rect14=[NSValue valueWithCGPoint:CGPointMake(100.0, 400.0)];
    NSValue *rect15=[NSValue valueWithCGPoint:CGPointMake(160.0, 380.0)];
    
    NSArray *positions=[NSArray arrayWithObjects:rect0, rect1, rect2, rect3, rect4, rect5, rect6, rect7, rect8, rect9, rect10, rect11, rect12, rect13, rect14, rect15, nil];
    
    return positions;
    
}

#pragma mark - animation


- (void)animateMainPoster{
    
    CALayer *layer=[self.allLayers objectAtIndex:MIN_POSTER_COUNT];
    
    CGMutablePathRef thePath=CGPathCreateMutable();
    
    CGPathMoveToPoint(thePath, NULL, layer.position.x, layer.position.y);
    CGPathAddLineToPoint(thePath, NULL, layer.position.x, self.view.bounds.size.height);
    
    CGPathMoveToPoint(thePath, NULL, layer.position.x, self.view.bounds.size.height);
    CGPathAddLineToPoint(thePath, NULL, layer.position.x, self.view.bounds.size.height-(self.view.bounds.size.height-layer.position.y)/3);
    
    CGPathMoveToPoint(thePath, NULL, layer.position.x, self.view.bounds.size.height-(self.view.bounds.size.height-layer.position.y)/3);
    CGPathAddLineToPoint(thePath, NULL, layer.position.x, self.view.bounds.size.height);

    
    CAKeyframeAnimation *theAnimation=[CAKeyframeAnimation
                                       
                                       animationWithKeyPath:@"position"];
    theAnimation.path=thePath;
    theAnimation.duration=1.5;
    theAnimation.timingFunctions=[NSArray arrayWithObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    CFRelease(thePath);
    layer.position=CGPointMake(layer.position.x, self.view.bounds.size.height);
    
    [layer addAnimation:theAnimation forKey:@"animationssss"];
    
    //11,12
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:1.0f]
                     forKey:kCATransactionAnimationDuration];
    CALayer *layer11=[self.allLayers objectAtIndex:11];
    CALayer *layer12=[self.allLayers objectAtIndex:12];
    layer11.transform=CATransform3DMakeRotation(GLKMathDegreesToRadians(-45.0), 0, 0, 1);
    layer11.position=CGPointMake(layer11.position.x-20, layer11.position.y);
    layer11.timeOffset=15.0;
    layer12.transform=CATransform3DMakeRotation(GLKMathDegreesToRadians(45.0), 0, 0, 1);
    
                      
    [CATransaction commit];

}

- (void)animatePosters{
    
    for (int i=0; i<9; i++) {
        CALayer *layer=[self.allLayers objectAtIndex:i];
        if (i==0 || i==1 || i==7 || i==8) {
            layer.position=CGPointMake(layer.position.x, 420);
            [layer removeFromSuperlayer];
            [self.view.layer addSublayer:layer];
        }
    }
}

#pragma mark - gestures

- (void)tap:(UITapGestureRecognizer *)gesture{
    
    CALayer *layer=[allLayers objectAtIndex:MIN_POSTER_COUNT];
    float startValue=layer.position.y;
    float endValue=self.view.layer.bounds.size.height;
    

    self.aView=[[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.aView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.aView];

    //[[PRTween sharedInstance] removeTweenOperation:activeTweenOperation];
    

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
    
    [self showPosters];
    
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
