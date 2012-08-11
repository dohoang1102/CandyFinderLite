//
//  LocationDetailsViewController.m
//  CandyFinder
//
//  Created by Devin Moss on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "AppDelegate.h"
#import "Location.h"
#import "AnnotationDetails.h"
#import "LocationPoster.h"

@interface LocationDetailsViewController ()

@end

@implementation LocationDetailsViewController

@synthesize location, filteredCandy, directionsCell, nameCell, phoneCell, inventoryCell, tagCandyCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"LocationToAnnotationDetails"])
    {
        // Get reference to the destination view controller
        AnnotationDetails *vc = (AnnotationDetails *)[segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.location = self.location;
        vc.location_id = [self.location.location_id intValue];
        vc.location_name = self.location.name;
        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(indexPath.section == 0) {
        //name and directions section
        switch (indexPath.row) {
            case 0: {
                //namecell
                if(location) {
                    self.nameCell.textLabel.text = [NSString stringWithFormat:@"%@", location.name];
                    CGRect frame = nameCell.detailTextLabel.frame;
                    [nameCell.detailTextLabel setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height * 2)];
                    frame = nameCell.detailTextLabel.frame;
                    nameCell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
                    self.nameCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@, %@ %@", location.address, location.city, location.state, location.zip];
                    self.nameCell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:location.ext_image_url]]];
                    //Insert distance label
                    
                    return self.nameCell;
                }
                break;
            }
            case 1: {
                //directionscell. Do nothing.
                return directionsCell;
                break;
            }
        }
    }else if (indexPath.section == 1) {
        //Phonecell
        NSLog(@"%@", [location.phone_international class]);
        if(location.phone_international && ![location.phone_international isEqualToString:@"<null>"]) {
            self.phoneCell.detailTextLabel.text = location.phone_international;
        } else {
            phoneCell.detailTextLabel.text = @"Unknown";
            phoneCell.userInteractionEnabled = NO;
        }
        
        return phoneCell;
    }else if (indexPath.section == 2) {
        //Tag Candy cell
        if(filteredCandy) {
            //tagCandyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
            tagCandyCell.textLabel.text = filteredCandy.title;
            //tagCandyCell.textLabel.font = [UIFont systemFontOfSize:15.0];
            
            NSTimeInterval timeInterval = abs([filteredCandy.updated_at timeIntervalSinceNow]);
            NSString *timeAgo;
            double minutes = round(timeInterval / 60);
            if(minutes < 60) {
                timeAgo = [NSString stringWithFormat:@"Last seen: %.f %@ ago", round(minutes), minutes == 1? @"minute":@"minutes"];
            } else {
                double hours = round((timeInterval / 60) / 60);
                if(hours < 24){
                    if(hours < 2) {
                        timeAgo = [NSString stringWithFormat:@"Last seen: %.f hour ago", (hours)];
                    } else {
                        timeAgo = [NSString stringWithFormat:@"Last seen: %.f hours ago", (hours)];
                    }
                } else {
                    double days = round(hours / 24);
                    if(days < 2) {
                        timeAgo = [NSString stringWithFormat:@"Last seen: %.f day ago", (days)];
                    }else if(days < 30) {
                        timeAgo = [NSString stringWithFormat:@"Last seen: %.f days ago", (days)];
                    } else if (days < 365) {
                        double months = round(days / 30);
                        if(months < 2) {
                            timeAgo = [NSString stringWithFormat:@"Last seen: %.f month ago", (months)];
                        } else {
                            timeAgo = [NSString stringWithFormat:@"Last seen: %.f months ago", (months)];
                        }
                    } else {
                        double years = round(days / 365);
                        if(years < 2) {
                            timeAgo = [NSString stringWithFormat:@"Last seen: %.f year ago", (years)];
                        } else {
                            timeAgo = [NSString stringWithFormat:@"Last seen: %.f years ago", (years)];
                        }
                    }
                }
            }
            
            tagCandyCell.detailTextLabel.text = timeAgo;
            
            UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect]; 
            updateButton.frame = CGRectMake(278.0, 6.0, 37.0, 28.0);
            [updateButton setTitle:@"Update" forState:UIControlStateNormal];
            updateButton.titleLabel.font = [UIFont systemFontOfSize:9.0];
            updateButton.titleLabel.textColor = [UIColor darkGrayColor];
            updateButton.tag = [filteredCandy.candy_id intValue];
            
            [updateButton addTarget:self action:@selector(updateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [tagCandyCell setAccessoryView:updateButton];
        } else {
            //tagCandyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            tagCandyCell.textLabel.text = @"Tag Candy Here";
            tagCandyCell.detailTextLabel.text = nil;
            tagCandyCell.userInteractionEnabled = YES;
        }
        return tagCandyCell;
    }else if (indexPath.section == 3) {
        //Inventory cell
        //Already configured
        return inventoryCell;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    //Name row.  Do nothing
                    break;
                case 1: {
                    //Directions to location
                    [self directionButtonTapped];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1: {
            //Phone number
            //Call the store
            [self phoneButtonTapped];
            break;
        }
        case 2: {
            //Tag Candy
            if(filteredCandy) {
                [self updateButtonTapped:self];
            } else {
                //Set selected index to 1 (for "Tag New")
                if(location) {
                    [LocationPoster sharedLocationPoster].currentLocation = location;
                }
                [self.tabBarController setSelectedIndex:1];
            }
            break;
        }
        case 3: {
            //Inventory
            //Segue to annotation details
            [self performSegueWithIdentifier:@"LocationToAnnotationDetails" sender:self];
            break;
        }
        default:
            break;
    }
}

- (void) directionButtonTapped {
    //Display alert
    //Open google maps navigation to this location's lat/lon
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Switching to Navigation" message:@"Do you want to leave Candy Finder to view directions?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [alert show];
    [directionsCell setSelected:NO];
}

- (void) phoneButtonTapped {
    //Display alert
    //Open phone center, if user has phone
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:+11111"]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Switching to Phone" message:@"Do you want to leave Candy Finder to call this location?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        [alert show];
        [phoneCell setSelected:NO];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        if([alertView.title isEqualToString:@"Switching to Navigation"]) {
            //User wants directions
            //Open maps and navigate
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //NSLog(@"lat: %f lon: %f", app.currentLocation.coordinate.latitude, app.currentLocation.coordinate.longitude);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",app.currentLocation.coordinate.latitude, app.currentLocation.coordinate.longitude, location.coordinate.latitude, location.coordinate.longitude]]];  
        } else if ([alertView.title isEqualToString:@"Switching to Phone"]) {
            //User wants to call the location
            //Make phone call
            NSCharacterSet *specialCharSet = [NSCharacterSet characterSetWithCharactersInString:@" )(-+,"];
            NSArray *components = [location.phone_international componentsSeparatedByCharactersInSet:specialCharSet];
            NSString *phoneStr = [components componentsJoinedByString:@""];
            phoneStr = [NSString stringWithFormat:@"tel:%@", phoneStr];
            NSURL *url = [[NSURL alloc] initWithString:phoneStr];

            NSLog(@"%@", phoneStr);
            [[UIApplication sharedApplication] openURL:url];
        }
        
    }
}


#pragma mark - Action Sheet
- (IBAction)updateButtonTapped:(id)sender {
    [self displayActionSheet:sender];
}

- (IBAction)displayActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Confirm that %@ still carries %@?", location.name, filteredCandy.title]
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Yes", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            //PUT annotation here (update it)
            filteredCandy.updated_at = [NSDate date];
            [[LocationPoster sharedLocationPoster] updateAnnotationLocation:location withCandy:filteredCandy];
            
            if(self.navigationController.navigationBarHidden) {
                [self.searchDisplayController.searchResultsTableView reloadData];
            } else {
                [self.tableView reloadData];
            }
            //[self refreshButtonTapped:self];
            break;
        }
        default:
            break;
    }
}

@end
