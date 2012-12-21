//
//  XXXViewController.m
//  APP4
//
//  Created by user on 12-10-25.
//  Copyright (c) 2012年 FreeBox. All rights reserved.
//

#import "XXXViewController.h"
#import "FileViewController.h"
#import "GlossaryViewController.h"

#import "XXXPlayViewController.h"



@interface XXXViewController ()

@end

@implementation XXXViewController
@synthesize aView;


- (IBAction)playPressed:(id)sender {
    
    FileViewController *fileVC=[[FileViewController alloc] initWithNibName:@"FileViewController" bundle:nil];
    [self.navigationController pushViewController:fileVC animated:YES];
    
    [fileVC.navigationController setNavigationBarHidden:NO];
    [fileVC.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];    
}

- (IBAction)glossaryPressed:(id)sender {
    GlossaryViewController *glossaryVC=[[GlossaryViewController alloc]initWithNibName:@"GlossaryViewController" bundle:nil];
    [self.navigationController pushViewController:glossaryVC animated:YES];
    
    [glossaryVC.navigationController setNavigationBarHidden:NO];
    [glossaryVC.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

#pragma mark - defaults

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setAView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
