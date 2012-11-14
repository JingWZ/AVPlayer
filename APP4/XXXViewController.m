//
//  XXXViewController.m
//  APP4
//
//  Created by user on 12-10-25.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "XXXViewController.h"
#import "XXXPlayViewController.h"
#import "GlossaryViewController.h"


@interface XXXViewController ()

@end

@implementation XXXViewController
@synthesize playViewController;
@synthesize glossaryViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)playPressed:(id)sender {
    self.playViewController=[[XXXPlayViewController alloc]initWithNibName:@"XXXPlayViewController" bundle:nil];
    [self.navigationController pushViewController:self.playViewController animated:YES];
    [self.playViewController.navigationController setNavigationBarHidden:YES];
    

}

- (IBAction)glossaryPredded:(id)sender {
    self.glossaryViewController=[[GlossaryViewController alloc]initWithNibName:@"GlossaryViewController" bundle:nil];
    [self.navigationController pushViewController:self.glossaryViewController animated:YES];
    //[self.glossaryViewController.navigationController setNavigationBarHidden:YES];
}



















@end
