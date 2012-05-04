//
//  PlacesViewController.h
//  CandyFinder
//
//  Created by Devin Moss on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 This is the main view displayed when the user wants to tag a candy at a particular location
 The user is required to first select a location, then tag a candy
 This allows many candies to be tagged rapidly at the same location
 Every location dipslayed in the table view is pulled from Google places
 **/

#import <UIKit/UIKit.h>

@interface PlacesViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate> {
    //Container for the text entered while user is searching
    NSString *userSearchText;
    
    //The master content for the table view
    NSArray *listContent;
    
    // The content filtered as a result of a search
    NSMutableArray	*filteredListContent;
    
    //Container for NSURLConnection response data
    NSMutableData *responseData;
    
    //Indicator is displayed while results are loading
    UIActivityIndicatorView *indicator;
    
    //Logic helper so the controller knows how to behave
    BOOL fromTag;
}

@property(nonatomic, strong) NSString *userSearchText;
@property(nonatomic, strong) NSArray *listContent;
@property (nonatomic, strong) NSMutableArray *filteredListContent;
@property(nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, assign) BOOL fromTag;

//Begins filtering when the user types text in the search bar
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

@end
