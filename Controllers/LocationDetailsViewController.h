//
//  LocationDetailsViewController.h
//  CandyFinder
//
//  Created by Devin Moss on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@interface LocationDetailsViewController : UITableViewController <UIAlertViewDelegate> {
    Location *location;
}

@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) IBOutlet UITableViewCell *nameCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *directionsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *phoneCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *inventoryCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *tagCandyCell;


@end
