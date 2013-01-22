//
//  CardCell.m
//  APP4
//
//  Created by apple on 12-12-24.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "CardCell.h"

@implementation CardCell
@synthesize customImageView;
@synthesize subtitleEng;
@synthesize subtitleChi;
@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
