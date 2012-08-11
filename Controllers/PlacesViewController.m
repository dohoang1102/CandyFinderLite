//
//  PlacesViewController.m
//  CandyFinder
//
//  Created by Devin Moss on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacesViewController.h"
#import "Location.h"
#import "AppDelegate.h"
#import "globals.h"
#import "SBJson.h"
#import "LocationPoster.h"
#import "FlurryAnalytics.h"

@implementation PlacesViewController

@synthesize listContent, userSearchText, responseData, filteredListContent, indicator, fromTag;

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
    NSLog(@"placesview received memory warning");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.responseData = [NSMutableArray arrayWithCapacity:[self.listContent count]];
    self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.listContent count]];
    
    [self.tableView reloadData];
    self.tableView.scrollEnabled = YES;
    
    //[self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageNamed:@"chocolate_pixel.png"]];
    //[self.searchDisplayController.searchBar setTintColor:[UIColor colorWithRed:0.969 green:0.9098 blue:0.937 alpha:1.0]];
    
    /*
    Location *tmpLoc = [LocationPoster sharedLocationPoster].currentLocation;
    if(tmpLoc) {
        UIAlertView *addressAlert = [[UIAlertView alloc] initWithTitle: @"Use this location?" message: [NSString stringWithFormat:@"%@\r\n%@, %@", tmpLoc.name, tmpLoc.address, tmpLoc.city]
                                                              delegate: self 
                                                     cancelButtonTitle: @"Yes" 
                                                     otherButtonTitles: @"No", nil];
        [addressAlert dismissWithClickedButtonIndex:0 animated:YES];
        [addressAlert show];
    }*/
    
    fromTag = NO;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.searchDisplayController) {
        [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageNamed:@"background_find_bot.png"]];
    }
    
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"background_AddHeader.png"] forBarMetrics:UIBarMetricsDefault];
    
    NetworkStatus remoteHostStatus = [((AppDelegate *)[[UIApplication sharedApplication] delegate]).reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable) {
        //no connectivity
    } else {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = self.view.center;
        indicator.hidesWhenStopped = YES;
        [self.view addSubview:indicator];
        [indicator startAnimating];
        
        Location *userLoc = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).currentLocation;
        
        responseData = [NSMutableData data];
        NSString *url = [NSString stringWithFormat:PLACES_URL, userLoc.lat, userLoc.lon, PLACES_RADIUS, @"", PLACES_KEY];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [FlurryAnalytics logPageView];
    
    if(!fromTag) {
        Location *tmpLoc = [LocationPoster sharedLocationPoster].currentLocation;
        if(tmpLoc) {
            [self performSegueWithIdentifier:@"LocationToTagCandy" sender:self];
            fromTag = YES;
        }
    } else {
        fromTag = NO;
        [LocationPoster sharedLocationPoster].currentLocation = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    if ([[segue identifier] isEqualToString:@"LocationToTagCandy"])
    {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Places" style:UIBarButtonItemStyleBordered target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:backButton];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        if(filteredListContent.count == 0 && self.searchDisplayController.searchBar.text){
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }else{
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
        return [self.filteredListContent count];
    }
	else
	{
        return [self.listContent count];
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
    } else {
        cell.backgroundView = [[UIView alloc] init ]; 
        cell.backgroundView.backgroundColor = DARK_BLUE;
    }
    
    Location *l = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        l = [self.filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
        l = [self.listContent objectAtIndex:indexPath.row];
    }
	
	cell.textLabel.text = l.name;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    if(l.address) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", l.address, l.city];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", l.city];
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(227.0, 11.0, 43.0, 21.0)];
    distanceLabel.text = [NSString stringWithFormat:@"%.1f mi", l.distance];
    distanceLabel.font = [UIFont systemFontOfSize:14.0];
    distanceLabel.textAlignment = UITextAlignmentLeft;
    distanceLabel.textColor = [UIColor lightGrayColor];
    distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell setAccessoryView:distanceLabel];
    
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
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        [LocationPoster sharedLocationPoster].currentLocation = (Location *)[self.filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
        [LocationPoster sharedLocationPoster].currentLocation = (Location *)[self.listContent objectAtIndex:indexPath.row];
    }
    
    fromTag = YES;
    [self performSegueWithIdentifier:@"LocationToTagCandy" sender:self];
}

#pragma mark JSON Request section
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    /*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (Location *l in listContent)
	{
		//if ([scope isEqualToString:@"All"] || [l.name isEqualToString:scope])
		//{
			NSComparisonResult result = [l.name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
			{
				[self.filteredListContent addObject:l];
            }
		//}
	}
}

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
    
    Location *userLoc = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).currentLocation;
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    responseData = [NSMutableData data];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    if([responseString length] > 0){
        NSDictionary *dictionary = [responseString JSONValue];
        if([[dictionary objectForKey:@"status"] isEqualToString:@"OK"]) {
            NSArray *results = (NSArray *)[dictionary objectForKey:@"results"];
            for(NSDictionary *r in results) {
                Location *loc = [Location locationFromPlace:r];
                loc.distance = [loc distanceFromLat:[userLoc.lat doubleValue] andLon:[userLoc.lon doubleValue]];
                [tempArray addObject:loc];
            }
        }
    }
    
    NSArray *sortedArray = [tempArray sortedArrayUsingComparator: ^(Location *obj1, Location *obj2) {
        if (obj1.distance > obj2.distance) {
            return (NSComparisonResult)NSOrderedDescending;
        }

        if (obj1.distance < obj2.distance) {            
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
        
    }];
    
    self.listContent = sortedArray;
    
    if (self.searchDisplayController.searchResultsTableView.hidden == YES){
        self.searchDisplayController.searchResultsTableView.hidden = NO;
    }
    
    //[self.searchDisplayController.searchResultsTableView reloadData];
    [self.tableView reloadData];
    
    if(listContent.count == 0){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else{
        //[self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.userSearchText = searchString;
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.userSearchText = searchBar.text;
    
    [self filterContentForSearchText:userSearchText scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [searchBar resignFirstResponder];
    //self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Yes"]) {
        NSLog(@"User clicked yes");
        //Use LocationPoster's location
        [self performSegueWithIdentifier:@"LocationToTagCandy" sender:self];
    } else {
        NSLog(@"User clicked something other than yes");
        Location *tmpLoc = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).currentLocation;
        
        responseData = [NSMutableData data];
        NSString *url = [NSString stringWithFormat:PLACES_URL, tmpLoc.lat, tmpLoc.lon, PLACES_RADIUS, @"", PLACES_KEY];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@", url);
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

@end
