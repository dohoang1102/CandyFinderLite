//
//  InstructionsViewController.h
//  CandyFinder
//
//  Created by Devin Moss on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstructionsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)dismiss:(id)sender;

@end
