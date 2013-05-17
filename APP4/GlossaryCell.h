//
//  GlossaryCell.h
//  APP4
//
//  Created by apple on 13-1-30.
//  Copyright (c) 2013年 FreeBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlossaryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *glossaryImageView;
@property (weak, nonatomic) IBOutlet UILabel *glossaryNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *glossaryMaker;
@property (weak, nonatomic) IBOutlet UILabel *glossaryCount;

@end
