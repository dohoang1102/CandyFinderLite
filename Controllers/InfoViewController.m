//
//  InfoViewController.m
//  CandyFinder
//
//  Created by Devin Moss on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"
#import "Appirater.h"
#import "AppDelegate.h"

@implementation InfoViewController

@synthesize rateButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"infoview received memory warning");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"infoPageBackground_half.png"]]; 
    
    [rateButton setHidden:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *badge = [self.tabBarItem badgeValue];
    NSInteger badgeNumber = [badge integerValue];
    if(badgeNumber == 1) {
        rateButton.hidden = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) updateBadgeDisplay:(NSString *)text {
    [self.tabBarItem setBadgeValue:text];
}

- (IBAction)rateCandyfinder:(id)sender {
    NSString *badge = [self.tabBarItem badgeValue];
    NSInteger badgeNumber = [badge integerValue];
    if((badgeNumber - 1) < 1) {
        //[self.tabBarItem setBadgeValue:@""];
        [self.tabBarItem setBadgeValue:nil];
    } else {
        [self.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%i", badgeNumber - 1]];
    }
    
    [Appirater rateApp];
    
    [rateButton setHidden:YES];
}

@end
