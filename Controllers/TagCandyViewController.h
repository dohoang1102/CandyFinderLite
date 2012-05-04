//
//  TagCandyViewController.h
//  CandyFinder
//
//  Created by Devin Moss on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 This controller is displayed after the "PlacesViewController," which is a list of Google Places
 This controller assumes that a location/place has been selected.
 The user can search for a candy using the search bar or the barcode scanner and tag that candy at the selected location (locations are all Google Places)
 **/

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TagCandyViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UITableViewDelegate, ZBarReaderDelegate> {
    //UISearchBar *searchBar;
    
    //Container for NSURLConnection responses
    NSMutableData *responseData;
    
    //Source for the table view
    NSArray *listContent;
    
    //Appears when no search results are returned. 
    //Segues to the NewCandyViewController when tapped
    UIBarButtonItem *addCandy;
    
    //Logic helper
    //Lets the controller know how to behave after a candy is tagged
    //In this case, it knows not to clear any location data
    BOOL fromAnnotationDetails;
    
    
    NSString *location_id;
    
    //Deprecated.  We are no longer using this.
    IBOutlet UISegmentedControl *segment;
    
    //Used for Flurry analytics.  Helps us see how often people are searching via scanner vs search bar
    BOOL isScanning;
    
    //Container for the barcode sku
    NSString *sku;
    
    //Indicator is displayed while search results are loading
    UIActivityIndicatorView *indicator;
}

//@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic, strong) NSMutableData *responseData;
@property(nonatomic, strong) NSArray *listContent;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addCandy;
@property (nonatomic) BOOL fromAnnotationDetails;
@property (nonatomic, strong) NSString *location_id;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segment;
@property (nonatomic) BOOL isScanning;
@property (nonatomic, strong) NSString *sku;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

//This method is called when the user begins typing
//Sends a search request to the server.  
//Gets called only after 3+ characters have been typed to avoid getting too many results
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

//Confirmation action sheet displayed after user selects a candy to tag
//If they click ok, POST is sent to server to create the annotation
- (IBAction)displayActionSheet:(NSIndexPath *)indexPath;

//Deprecated.  We are no longer using this.
- (IBAction)segmentSwitch:(id)sender;

//Deprecated.  We are no longer using this.
- (IBAction)mapButtonTapped:(id)sender;

//Segues to the NewCandyViewController
- (IBAction)addButtonTapped:(id)sender;

//Displays the barcode scanner modally.
- (IBAction) scanButtonTapped;

@end
