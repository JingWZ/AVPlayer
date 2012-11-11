//
//  ImagesPackage.m
//  APP4
//
//  Created by apple on 12-11-11.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "ImagesPackage.h"

//先define一下图片大小和存储文件夹，之后通过设置页面让用户设置这些属性

#define kImageWidth 300
#define kImageHeight 200
#define savePath @"/Users/apple/Desktop/save/"

@implementation ImagesPackage

@synthesize imageItems;
@synthesize imageGenerator;

-(ImagesPackage *)initWithAsset:(AVAsset *)asset{
    if (asset) {
        self.imageGenerator=[AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        self.imageItems=[NSMutableArray arrayWithCapacity:0];
    }else {
        NSLog(@"Can't initialize the ImagePackage!");
    }
    return self;
}

-(void)extractImagewithCMTime:(CMTime)time andIndex:(NSUInteger)index{
    NSError *error;
    CGImageRef image=[self.imageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
    
    IndividualImage *individualImage=[IndividualImage new];
    individualImage.image=[self resizeImage:image toWidth:kImageWidth height:kImageHeight];
    individualImage.index=index;
    //先不储存在文件中，而是放入对象中
    [self.imageItems addObject:individualImage];
    
}



#pragma mark -

- (UIImage*)resizeImage:(CGImageRef)image toWidth:(NSInteger)width height:(NSInteger)height
{
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), image);
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}

- (NSString *)getImageSaveName:(CMTime)time {
    float timeInSecond=CMTimeGetSeconds(time);
    
    NSString *hour;
    if (timeInSecond/3600>0) {
        hour=[NSString stringWithFormat:@"0%d-",(int)timeInSecond/3600];
    }
    else{
        hour=@"00-";
    }
    
    NSString *min;
    if ((int)timeInSecond%3600/60<10) {
        min=[NSString stringWithFormat:@"0%d-",(int)timeInSecond%3600/60];
    }else{
        min=[NSString stringWithFormat:@"%d-",(int)timeInSecond%3600/60];
    }
    
    
    NSString *sec;
    if ((int)timeInSecond%3600%60<10) {
        sec=[NSString stringWithFormat:@"0%d-",(int)timeInSecond%3600%60];
    }else{
        sec=[NSString stringWithFormat:@"%d-",(int)timeInSecond%3600%60];
    }
    
    float fract=(timeInSecond-(int)timeInSecond)*100;
    NSString *fra;
    if (fract<10) {
        fra=[NSString stringWithFormat:@"0%d",(int)fract];
    }else{
        fra=[NSString stringWithFormat:@"%d",(int)fract];
    }
    
    
    NSString *imageSaveName=[[[[hour stringByAppendingString:min] stringByAppendingString:sec] stringByAppendingString:fra] stringByAppendingString:@".jpeg"];
    return imageSaveName;
}


/*
 self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:mAsset];
 CMTime currentTime=[self.mPlayer currentTime];
 NSError *error;
 
 CGImageRef image=[self.imageGenerator copyCGImageAtTime:currentTime actualTime:NULL error:&error];
 UIImage *imageToSave=[self resizeImage:image toWidth:320 height:200];
 NSData *imageData=[NSData dataWithData:UIImageJPEGRepresentation(imageToSave, 1)];
 
 //NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 //NSString *documentDirectory= [paths objectAtIndex:0];
 //NSString *savePath=[documentDirectory stringByAppendingString:[self getImageSaveName:currentTime]];
 
 NSString *path=@"/Users/apple/Desktop/save/";
 NSString *savePath=[path stringByAppendingString:[self getImageSaveName:currentTime]];
 
 [imageData writeToFile:savePath atomically:YES];
 
 */

@end

@implementation IndividualImage

@synthesize image;
@synthesize index;

@end


