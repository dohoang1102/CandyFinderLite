//
//  AnnotationDetails.m
//  barcodeTest2
//
//  Created by Devin Moss on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AnnotationDetails.h"
#import "Candy.h"
#import "Location.h"
#import "SBJson.h"
#import "globals.h"
#import "TagCandyViewController.h"
#import "FlurryAnalytics.h"
#import "LocationPoster.h"

@implementation AnnotationDetails

@synthesize locationCandies, location, location_name, location_id, responseData, addButtonTouched, isGoingBackToMap, indicator, updateCandy;
//@synthesize navController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"annotationdetails received memory warning");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:location_name];
    addButtonTouched = NO;
    isGoingBackToMap = YES;
    
    indices = [[NSMutableDictionary alloc] init];
    indexTitles = [[NSMutableArray alloc] init];
    sectionRows = [[NSMutableArray alloc] init];
    sectionIndexes = [[NSMutableArray alloc] init];
    
    filteredListContent = [[NSMutableArray alloc] init ];
    
    /*toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 387, 320, 44)];
    [toolbar setBarStyle:UIBarStyleBlack];
    UIBarButtonItem *tagNew = [[UIBarButtonItem alloc] initWithTitle:@"Tag Here" 
                                                                       style:UIBarButtonItemStyleBordered 
                                                                      target:self 
                                                                      action:@selector(addButtonTapped:)];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped:)];
    
    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolbar setItems:[NSArray arrayWithObjects:tagNew, extraSpace, refreshButton, nil]];
    
    [self.tabBarController.view addSubview:toolbar];*/
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    /*if ([[NSFileManager defaultManager] fileExistsAtPath:path2]) {
        self.locationCandies = [[NSMutableArray alloc] initWithContentsOfFile:path2];
    }*/
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.locationCandies = nil;
    
    toolbar = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    isGoingBackToMap = YES;
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    indicator.hidesWhenStopped = YES;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    //Using NSURL send the message
    responseData = [NSMutableData data];
    NSString *url = [NSString stringWithFormat:CANDIES_FROM_LOCATION, [NSString stringWithFormat:@"%i", location_id]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [FlurryAnalytics logPageView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(isGoingBackToMap && addButtonTouched) {
        //User went to tag controller, came back, and is going to map
        //Next time they touch the "Tag" tab, they won't expect to see this location
        //They expect to see a list of nearby locations
        //So we set currentLocation to nil
        //[LocationPoster sharedLocationPoster].currentLocation = nil;
    }
    
    //[toolbar removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"DetailsToTagCandy"])
    {
        // Get reference to the destination view controller
        TagCandyViewController *vc = (TagCandyViewController *)[segue destinationViewController];
        vc.fromAnnotationDetails = YES;
        NSLog(@"%i", self.location_id);
        vc.location_id = [NSString stringWithFormat:@"%i", self.location_id];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //return 1;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return [indexTitles count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return [[indices objectForKey:[NSString stringWithFormat:@"section%i", section]] intValue];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [filteredListContent count];
    }
	else
	{
        return [[sectionRows objectAtIndex:section] intValue];
        //return [self.locationCandies count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if([indexPath row] % 2 == 0) {
        cell.backgroundView = [[UIView alloc] init ]; 
        cell.backgroundView.backgroundColor = LIGHT_BLUE;
        cell.textLabel.backgroundColor = LIGHT_BLUE;
        cell.detailTextLabel.backgroundColor = LIGHT_BLUE;
    } else {
        cell.backgroundView = [[UIView alloc] init ]; 
        cell.backgroundView.backgroundColor = DARK_BLUE;
        cell.textLabel.backgroundColor = DARK_BLUE;
        cell.detailTextLabel.backgroundColor = DARK_BLUE;
    }
    
    Candy *candy = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        candy = [filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
        candy = [self.locationCandies objectAtIndex:([[sectionIndexes objectAtIndex:indexPath.section] intValue] + indexPath.row)];
    }
    
    // Configure the cell...
    
    cell.textLabel.text = candy.title;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    //cell.detailTextLabel.text = candy.subtitle;
    //UIImage *image = [UIImage imageNamed:@"milkyway.png"];
    //cell.imageView.image = image;
    
    /*UILabel *lastSeen = [[UILabel alloc] initWithFrame:CGRectMake(198.0, 0.0, 72.0, 21.0)];
    lastSeen.text = @"Last seen:";
    lastSeen.font = [UIFont systemFontOfSize:15.0];
    lastSeen.textAlignment = UITextAlignmentLeft;
    lastSeen.textColor = [UIColor darkGrayColor];
    lastSeen.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:lastSeen];*/
    
    NSTimeInterval timeInterval = abs([candy.updated_at timeIntervalSinceNow]);
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
    
    cell.detailTextLabel.text = timeAgo;
    
    
    /*UILabel *dateSeen = [[UILabel alloc] initWithFrame:CGRectMake(198.0, 20.0, 100.0, 21.0)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    dateSeen.text = [formatter stringFromDate:candy.updated_at];
    //dateSeen.text = [NSDateFormatter localizedStringFromDate:candy.updated_at dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    
    NSLog(@"%@", dateSeen.text);
    dateSeen.font = [UIFont systemFontOfSize:15.0];
    dateSeen.textAlignment = UITextAlignmentLeft;
    dateSeen.textColor = [UIColor lightGrayColor];
    dateSeen.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:dateSeen];*/
    
    UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect]; 
    updateButton.frame = CGRectMake(278.0, 6.0, 37.0, 28.0);
    [updateButton setTitle:@"Update" forState:UIControlStateNormal];
    updateButton.titleLabel.font = [UIFont systemFontOfSize:9.0];
    updateButton.titleLabel.textColor = [UIColor darkGrayColor];
    updateButton.tag = [candy.candy_id intValue];
    //updateButton.tag = [indexPath row];
    
    [updateButton addTarget:self action:@selector(updateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell setAccessoryView:updateButton];
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    //return [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return indexTitles;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        return [(NSNumber *)[indices objectForKey:title] intValue];
    }
}

#pragma mark JSON Request section
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [responseData setLength:0];
    //[responseData removeAllObjects];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [responseData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//resultText.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [indicator stopAnimating];
    
    self.locationCandies = nil;
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
	NSDictionary *candyInfo = [responseString JSONValue];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    int indexCount = 0;
    for (NSDictionary *item in candyInfo){
        NSString *character = [[NSString stringWithFormat:@"%C", [[item objectForKey:@"title"] characterAtIndex:0]] uppercaseString];
        
        if(![indices objectForKey:character]) {
            //Dictionary doesn't contain a value for this key (which is a letter of the alphabet)
            
            //Set the section index of the section title (section "A" = 0, "B" = 1, etc)
            [indices setObject:[NSNumber numberWithInt:[indexTitles count]] forKey:character];
            
            [indices setObject:[NSNumber numberWithInt:1] forKey:[NSString stringWithFormat:@"section%i", [indexTitles count]]];
            
            //Set the number of rows in each section.  Since this is a new section, set it to 1
            [sectionRows insertObject:[NSNumber numberWithInt:1] atIndex:[indexTitles count]];
            
            //Set the index of the 1st object in a section.  We use this to know where to start pulling from locationCandies
            [sectionIndexes insertObject:[NSNumber numberWithInt:indexCount] atIndex:[indexTitles count]];
            
            //Indextitles is also what is used for section titles and # rows in each section
            [indexTitles addObject:character];
        } else {
            //Increment the "rows" value
            //NSInteger rowCount = [[indices objectForKey:[NSString stringWithFormat:@"section%i", ([indexTitles count] - 1)]] intValue];
            //rowCount += 1;
            //[indices setObject:[NSNumber numberWithInt:rowCount] forKey:[NSString stringWithFormat:@"section%i", ([indexTitles count] - 1)]];
            
            NSInteger rowCount = [[sectionRows objectAtIndex:([indexTitles count] - 1)] intValue];
            rowCount += 1;
            [sectionRows insertObject:[NSNumber numberWithInt:rowCount] atIndex:([indexTitles count] - 1)];
        }
        //Increment indexCount so we pull the correct candy from locationCandies (used by sectionIndexes)
        indexCount += 1;
        
        //Add candy object to array
        [tempArray addObject:[Candy candyFromDictionary:item]];
    }
    
    self.locationCandies = tempArray;
    [self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	return [indexTitles objectAtIndex:section];
    
}

#pragma mark - Helper Methods
- (IBAction)addButtonTapped:(id)sender {
    if(location) {
        [LocationPoster sharedLocationPoster].currentLocation = location;
    }
    addButtonTouched = YES;
    isGoingBackToMap = NO;
    [self.tabBarController setSelectedIndex:1];
}

- (void)backToMap {
    [LocationPoster sharedLocationPoster].currentLocation = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updateButtonTapped:(id)sender {
    [self displayActionSheet:sender];
}

- (IBAction)refreshButtonTapped:(id)sender {
    [indicator startAnimating];
    
    //Using NSURL send the message
    responseData = [NSMutableData data];
    NSString *url = [NSString stringWithFormat:CANDIES_FROM_LOCATION, [NSString stringWithFormat:@"%i", location_id]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - Action Sheet
#pragma mark - Action Sheet
- (IBAction)displayActionSheet:(id)sender {
    for(Candy *c in locationCandies) {
        if([c.candy_id isEqualToString:[NSString stringWithFormat:@"%i", ((UIButton *)sender).tag]]) {
            self.updateCandy = c;
            break;
        }
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Confirm that %@ still carries %@?", location.name, updateCandy.title]
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
            updateCandy.updated_at = [NSDate date];
            [[LocationPoster sharedLocationPoster] updateAnnotationLocation:location withCandy:updateCandy];
            
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

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    /*
	 Update the filtered array based on the search text and scope.
	 */
	
	[filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (Candy *c in locationCandies)
	{
		//if ([scope isEqualToString:@"All"] || [l.name isEqualToString:scope])
		//{
        //NSComparisonResult result = [c.title compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        //if (result == NSOrderedSame)
        if ([c.title.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound)
        {
            [filteredListContent addObject:c];
        }
		//}
	}
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self filterContentForSearchText:searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [searchBar resignFirstResponder];
    //self.navigationItem.rightBarButtonItem = nil;
}

@end
