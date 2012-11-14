//
//  ImagesPackage.m
//  APP4
//
//  Created by apple on 12-11-11.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "ImagesPackage.h"

//先define一下图片大小和存储文件夹，之后通过设置页面让用户设置这些属性

#define kImageWidth 390
#define kImageHeight 300

@implementation ImagesPackage

@synthesize image;
@synthesize imageGenerator;

-(ImagesPackage *)initWithAsset:(AVAsset *)asset{
    if (asset) {
        self.imageGenerator=[AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    }else {
        NSLog(@"no asset, can't initialize the ImagePackage!");
    }
    return self;
}

- (void)saveImageWithTime:(CMTime)time inPath:(NSString *)path{
    
    [self extractImageWithCMTime:time];
    
    NSString *imagePath=[path stringByAppendingPathExtension:@"jpeg"];
    
    NSData *imageData=[NSData dataWithData:UIImageJPEGRepresentation(self.image, 1)];
    [imageData writeToFile:imagePath atomically:YES];
    
}

-(void)extractImageWithCMTime:(CMTime)time{
    
    NSError *error;
    CGImageRef cgimage=[self.imageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    
    self.image=[self resizeImage:cgimage toWidth:kImageWidth height:kImageHeight];
    
}


- (UIImage*)resizeImage:(CGImageRef)theImage toWidth:(NSInteger)width height:(NSInteger)height{
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), theImage);
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}



//手机的路径
 //NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 //NSString *documentDirectory= [paths objectAtIndex:0];
 //NSString *savePath=[documentDirectory stringByAppendingString:[self getImageSaveName:currentTime]];
 


@end

