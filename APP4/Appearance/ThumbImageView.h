//
//  ThumbImageView.h
//  APP4
//
//  Created by apple on 13-1-5.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIImage (draw)
+ (UIImage *) imageWithView:(UIView *)view;
@end
@implementation UIImage (draw)

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}


@end


@interface ThumbImageView : UIView{
    CGFloat offset;
    BOOL isHighlighted;
}

- (UIImage *)getImage;

- (void)setHighlighted:(BOOL)highlight;

@end