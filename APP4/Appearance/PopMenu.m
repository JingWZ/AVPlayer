//
//  PopMenu.m
//  Quartz2DButton
//
//  Created by apple on 13-1-19.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PopMenu.h"

@interface ItemButton : UIButton
@property (assign, nonatomic) CGFloat buttonLineWidth;
@property (assign, nonatomic) CGFloat buttonTextSize;
@property (assign, nonatomic) CGFloat buttonTextPointX;
@property (assign, nonatomic) CGFloat buttonTextPointY;
@property (copy, nonatomic) NSString *buttonText;
@property (assign, nonatomic) NSInteger buttonIndex;
@end

@implementation PopMenu{
    CGFloat viewWidth;
    CGFloat viewHeight;
    CGFloat itemCount;
    CGRect originFrame;
}

@synthesize itemHeight, itemWidth, itemOriginX, itemOriginY;
@synthesize addBtnFrame;

- (PopMenu *)initWithFrame:(CGRect)frame Contents:(NSArray *)contents{
    
    //full screen as the gray background, hide above the main screen
    //CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    self=[super initWithFrame:frame];
    
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        viewWidth=self.bounds.size.width;
        viewHeight=self.bounds.size.height;
        
        itemHeight=40.0;
        itemWidth=viewWidth;
        itemOriginX=0;
        itemOriginY=40.0;
        
        addBtnFrame=CGRectMake(0, 0, 40.0, 40.0);
        originFrame=frame;
        
        //init item button
        if (contents) {
            self.itemContents=[NSMutableArray arrayWithArray:contents];
            itemCount=[self.itemContents count];
            
            self.contentSize=CGSizeMake(frame.size.width, addBtnFrame.size.height+itemCount*itemHeight);
            
            [self initItemBtns];
            
        }
        
        //init add button
        self.addBtn=[[AddButton alloc] initWithFrame:addBtnFrame];
        [self.addBtn setOffset:10];
        [self.addBtn setBackgroundColor:[UIColor clearColor]];
        [self.addBtn addTarget:self action:@selector(addBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: self.addBtn];
        
        //init text field and hide it
        self.textField=[[UITextField alloc] initWithFrame:CGRectMake(addBtnFrame.size.height, 5, viewWidth, itemHeight-10)];
        [self.textField setBorderStyle:UITextBorderStyleRoundedRect];
        [self.textField setPlaceholder:@"Enter new glossary"];
        [self.textField setClearsOnBeginEditing:YES];
        [self.textField setHidden:YES];
        [self.textField addTarget:self action:@selector(doWhenTextEditDone) forControlEvents:UIControlEventEditingDidEndOnExit];
        [self addSubview:self.textField];
        
        

        
    }
    return self;
    
}

- (void)showPopMenuInView:(UIView *)view{
    
    //show gray background
    self.backgroundView=[[UIControl alloc] initWithFrame:view.bounds];
    [self.backgroundView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [self.backgroundView addTarget:self action:@selector(backgroundViewPressed) forControlEvents:UIControlEventTouchDown];
    [view insertSubview:self.backgroundView belowSubview:self];
    
    [self setFrame:CGRectMake(0, 0, 320, 320)];
    
    
    [UIView animateWithDuration:0.6f delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        

        [self.itemBtns enumerateObjectsUsingBlock:^(ItemButton *item, NSUInteger idx, BOOL *stop) {
            CGFloat pointY=addBtnFrame.size.height+itemHeight*idx;
            
            [item setFrame:CGRectMake(0, pointY, itemWidth, itemHeight)];
        }];

         
    } completion:^(BOOL finished) {

        //[self.addBtn setFrame:CGRectMake(0, 0, kAddBtnHeight, kAddBtnHeight)];
    }];
    


}

- (void)backgroundViewPressed{
    

    
    [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        
        [self.itemBtns enumerateObjectsUsingBlock:^(ItemButton *item, NSUInteger idx, BOOL *stop) {
            [item setFrame:CGRectMake(0, -addBtnFrame.size.height, itemWidth, itemHeight)];
        }];
        
        
    } completion:^(BOOL finished) {
        
        [self setFrame:originFrame];
        
        [self.backgroundView removeFromSuperview];
        self.backgroundView=nil;
        //[self.addBtn setFrame:CGRectMake(0, 0, kAddBtnHeight, kAddBtnHeight)];
    }];
    
    
}

- (void)initItemBtns{
    
    itemCount=[self.itemContents count];
    self.itemBtns=[NSMutableArray arrayWithCapacity:itemCount];
    
    //show item buttons
    for (int i=0; i<itemCount; i++) {
        
        //CGFloat pointY=addBtnFrame.size.height+itemHeight*i;
        ItemButton *new=[[ItemButton alloc] initWithFrame:CGRectMake(0, -addBtnFrame.size.height, itemWidth, addBtnFrame.size.height)];
        new.buttonIndex=i;
        new.buttonText=[self.itemContents objectAtIndex:i];
        [new addTarget:self action:@selector(itemBtnsPressed:) forControlEvents:UIControlEventTouchDown];
        
        [self.itemBtns addObject:new];
        [self addSubview:new];
    }
}

- (void)itemBtnsPressed:(ItemButton *)sender{
    //NSLog(@"%d",sender.buttonIndex);
    //加入生词本
    //要获得当前的生词卡的信息
    
    
    
    
}

- (void)addBtnPressed{
    
    [self.addBtn setEnabled:NO];
    [self.textField setHidden:NO];
    
}

- (void)doWhenTextEditDone{
    
    //重画消耗资源高，所以移动frame来插入新增的text
    NSString *text=self.textField.text;
    
    if ([text length]) {
        
        //新增第一行
        ItemButton *new=[[ItemButton alloc] initWithFrame:CGRectMake(0, addBtnFrame.size.height, itemWidth, itemHeight)];
        new.buttonIndex=0;
        new.buttonText=text;
        [new addTarget:self action:@selector(itemBtnsPressed:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:new];
        
        //把原来的下移
        for (int i=0; i<itemCount; i++) {
            
            ItemButton *item=[self.itemBtns objectAtIndex:i];
            item.buttonIndex=i+1;
            [item setFrame:CGRectMake(0, addBtnFrame.size.height+itemHeight*(i+1), itemWidth, itemHeight)];
        }
        
        //synchronize two arrays
        [self.itemContents insertObject:text atIndex:0];
        [self.itemBtns insertObject:new atIndex:0];
        
        //synchronize scrollView size
        itemCount=[self.itemContents count];
        self.contentSize=CGSizeMake(viewWidth, addBtnFrame.size.height+itemHeight*itemCount);
        
        [self.textField setHidden:YES];
        [self.addBtn setEnabled:YES];
    }

}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


@end

#pragma mark - item button

@implementation ItemButton

@synthesize buttonIndex;
@synthesize buttonText;
@synthesize buttonLineWidth, buttonTextPointX, buttonTextPointY, buttonTextSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
        buttonLineWidth=4.0;
        buttonTextSize=20;
        buttonTextPointX=40.0;
        buttonTextPointY=13.0;
        [self setBackgroundColor:[UIColor grayColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    
    CGFloat viewWidth=self.bounds.size.width;
    CGFloat viewHeight=self.bounds.size.height;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    
    /*
     //画分割线
     
     CGMutablePathRef path=CGPathCreateMutable();
     CGPathMoveToPoint(path, NULL, 0, buttonLineWidth/2.0);
     CGPathAddLineToPoint(path, NULL, viewWidth, buttonLineWidth/2.0);
     
     CGContextAddPath(context, path);
     CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
     CGContextStrokePath(context);
     
     */
    
    //画菱形
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    CGMutablePathRef path2=CGPathCreateMutable();
    CGFloat rhombOrigin=12.0;
    CGFloat rhombHeight=5.0;
    CGFloat rhombWidth=8.0;
    
    CGPathMoveToPoint(path2, NULL, rhombOrigin, viewHeight/2.0);
    CGPathAddLineToPoint(path2, NULL, rhombOrigin+rhombWidth, viewHeight/2.0-rhombHeight);
    CGPathAddLineToPoint(path2, NULL, rhombOrigin+2*rhombWidth, viewHeight/2.0);
    CGPathAddLineToPoint(path2, NULL, rhombOrigin+rhombWidth, viewHeight/2.0+rhombHeight);
    CGPathCloseSubpath(path2);
    
    CGContextAddPath(context, path2);
    CGContextClip(context);
    
    CGContextAddPath(context, path2);
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGColorRef startColor=CGColorCreate(colorSpace, (CGFloat[]){0.98, 0.98, 0.98, 1});
    CGColorRef endColor=CGColorCreate(colorSpace, (CGFloat[]){0.53, 0.53, 0.53, 0.26});
    CFArrayRef colorArray=CFArrayCreate(kCFAllocatorDefault, (const void*[]){startColor,endColor}, 2, nil);
    CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, colorArray, NULL);
    CGPoint center=CGPointMake(rhombOrigin+rhombWidth, viewHeight/2.0);
    
    CGContextDrawRadialGradient(context, gradient, center, rhombWidth/3.0, center, rhombWidth*2, kCGGradientDrawsBeforeStartLocation);
    
    if (self.highlighted) {
        
        CGContextRestoreGState(context);
        CGContextSaveGState(context);
        
        CGContextDrawRadialGradient(context, gradient, center, viewWidth/10, center, viewWidth/2, kCGGradientDrawsBeforeStartLocation);
    }
    
    //写字
    CGContextRestoreGState(context);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextSelectFont(context, "Helvetica", buttonTextSize, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    const char *string=[buttonText cStringUsingEncoding:NSUTF8StringEncoding];
    size_t length=[buttonText lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    CGContextShowTextAtPoint(context, buttonTextPointX, buttonTextPointY, string, length);
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self setNeedsDisplay];
}

@end


