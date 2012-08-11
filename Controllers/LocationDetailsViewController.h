//
//  LocationDetailsViewController.h
//  CandyFinder
//
//  Created by Devin Moss on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "Candy.h"

@interface LocationDetailsViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
    Location *location;
    Candy *filteredCandy;
}

@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) Candy *filteredCandy;
@property (nonatomic, strong) IBOutlet UITableViewCell *nameCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *directionsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *phoneCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *inventoryCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *tagCandyCell;

//Sets the updateCandy property and calls "displayActionSheet"
- (IBAction)updateButtonTapped:(id)sender;

//Displays a confirmation action sheet after the user clicks "Update"
//Sends off a PUT request using Web.h to update a certain annotation
- (IBAction)displayActionSheet:(id)sender;

@end
