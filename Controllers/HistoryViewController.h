//
//  HistoryViewController.h
//  CandyFinder
//
//  Created by Devin Moss on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 Displays the user's search history in order of most recent candies searched
 **/

#import <UIKit/UIKit.h>

@interface HistoryViewController : UITableViewController {
    NSArray *listContent; //The master content
}

@property (nonatomic, strong) NSArray *listContent;

//Erases the search history
- (IBAction)clearHistory:(id)sender;

@end
