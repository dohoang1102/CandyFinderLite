//
//  InfoViewController.h
//  CandyFinder
//
//  Created by Devin Moss on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 Info page.  
 Contains a link to "Rate this app"
 Will contain instructions on how to use the app
 Will contain relevant data on new candies or candies the user might like
 **/

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController {
    
}

@property (nonatomic, strong) IBOutlet UIButton *rateButton;

- (void) updateBadgeDisplay:(NSString *)text;
- (IBAction)rateCandyfinder:(id)sender;

@end
