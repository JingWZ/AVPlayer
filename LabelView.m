//
//  MATCShadowLabel.m
//  QuartzExamples
//
//  Created by Brad Larson on 2/9/2010.
//

#import "LabelView.h"


@implementation LabelView

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

#pragma mark -
#pragma mark Drawing methods

// This is how you manually draw the text, if you weren't dealing with a label

/*- (void)drawRect:(CGRect)rect 
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor( context, shadowOffset, shadowRadius, [shadowColor CGColor] );   
	CGContextSetFillColorWithColor(context, [self.textColor CGColor] );
//	CGContextSetCharacterSpacing(context, 200.0f);
	
	[self.text drawAtPoint:CGPointZero withFont:self.font];
}*/

// This is how you override the text context properties for a normal label

- (void)drawTextInRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor( context, shadowOffset, shadowRadius, [shadowColor CGColor] );   
	[super drawTextInRect:rect];
}



#pragma mark -
#pragma mark Accessors

@synthesize shadowColor;
@synthesize shadowOffset;
@synthesize shadowRadius;

@end
