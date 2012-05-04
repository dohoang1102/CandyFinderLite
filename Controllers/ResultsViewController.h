//
//  ResultsViewController.h
//  CandyFinder
//
//  Created by Devin Moss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 This is the search controller.  The user can search for candy by typing in the search bar 
 or by using the bar code scanner.
 Results are displayed in a table view. 
 When the user selects a row in the table view, he/she is taken to the map to see the nearest locations of that candy.
 **/

#import <UIKit/UIKit.h>

@interface ResultsViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, ZBarReaderDelegate, UIActionSheetDelegate> {
    //Container for the text entered when the user begins searching
    NSString *searchText;
    
    //The master content
    NSArray *listContent;
    
    //The content filtered as a result of a search
    NSMutableData *responseData;
    
    //Right navigation bar item.  
    //Becomes enabled when no results are returned.
    UIBarButtonItem *addCandy;
    
    //Used for Flurry analytics so we can track how often people use the scanner vs. the search bar
    BOOL isScanning;
    
    //Container for the sku when using the scanner
    NSString *sku;
    
    //Indicator is displayed while search results are being loaded
    UIActivityIndicatorView *indicator;
}

@property(nonatomic, strong) NSString *searchText;
@property(nonatomic, strong) NSArray *listContent;
@property(nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addCandy;
@property (nonatomic) BOOL isScanning;
@property (nonatomic, strong) NSString *sku;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

//Segues to the NewCandyViewController so the user can add a new candy to our database.
- (IBAction)addButtonTapped:(id)sender;

//Displays the barcode scanner in a modal view controller
- (IBAction) scanButtonTapped;

//This is deprecated.  We will be removing this in the near future as we no longer use it.
- (IBAction)displayActionSheet:(id)sender;

@end
