//
//  MATCShadowLabel.h
//  QuartzExamples
//
//  Created by Brad Larson on 2/9/2010.
//

#import <UIKit/UIKit.h>


@interface LabelView : UILabel
{
	UIColor *shadowColor;
	CGSize shadowOffset;
	CGFloat shadowRadius;
}

@property(readwrite, retain, nonatomic) UIColor *shadowColor;
@property(readwrite, nonatomic) CGSize shadowOffset;
@property(readwrite, nonatomic) CGFloat shadowRadius;

@end
