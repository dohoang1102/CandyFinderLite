//
//  AnnotationDetails.h
//  barcodeTest2
//
//  Created by Devin Moss on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 This is the list of candies that are displayed when the user clicks the right callout button on a location on the map
 Candies are displayed in a table view along with their timestamp and a button that allows the user to update the annotation
 
 There is an add button at the top right that allows the user to tag more candies at this particular location.
 **/

#import <UIKit/UIKit.h>
#import "Location.h"
#import "Candy.h"

@interface AnnotationDetails : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate> {
    //TableView source
    NSArray *locationCandies;
    
    //The current location of all annotations displayed by this controller
    Location *location;
    NSString *location_name;
    NSInteger location_id;
    
    //Used for NSURLConnection Responses
    NSMutableData *responseData;
    
    BOOL addButtonTouched;
    BOOL isGoingBackToMap;
    
    //Indicator is displayed while data is loading
    UIActivityIndicatorView *indicator;
    
    //Container for a candy that the user wants to update.
    //Gets set when the user taps "Update," thereby verifying that annotation
    NSString *updateCandy_id;
    
    UIToolbar *toolbar;
    
    // The content filtered as a result of a search
    NSMutableArray	*filteredListContent;
    
    //Holds the index values for the index titles
    NSMutableDictionary *indices;
    
    //Holds the titles for the side index
    NSMutableArray *indexTitles;
    
    //Container for the number of rows in each section
    //The section # matches the array index
    NSMutableArray *sectionRows;
    
    //Container for the index of the 1st element in each section
    //Section # matches the array index
    NSMutableArray *sectionIndexes;
}

@property (nonatomic, strong) NSArray *locationCandies;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) NSString *location_name;
@property (nonatomic) NSInteger location_id;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) BOOL addButtonTouched;
@property (nonatomic, assign) BOOL isGoingBackToMap;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) Candy *updateCandy;

//Segues to the TagViewController so the user can tag more candy at this location
- (IBAction)addButtonTapped:(id)sender;

//Sets the updateCandy property and calls "displayActionSheet"
- (IBAction)updateButtonTapped:(id)sender;

//Displays a confirmation action sheet after the user clicks "Update"
//Sends off a PUT request using Web.h to update a certain annotation
- (IBAction)displayActionSheet:(id)sender;

- (IBAction)refreshButtonTapped:(id)sender;

@end
