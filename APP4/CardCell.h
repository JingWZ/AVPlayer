//
//  CardCell.h
//  APP4
//
//  Created by apple on 12-12-24.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomImageView.h"

@interface CardCell : UITableViewCell

@property (weak, nonatomic) IBOutlet CustomImageView *customImageView;
@property (weak, nonatomic) IBOutlet UILabel *subtitleEng;
@property (weak, nonatomic) IBOutlet UILabel *subtitleChi;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
