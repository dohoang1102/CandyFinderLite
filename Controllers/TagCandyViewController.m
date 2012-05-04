//
//  TagCandyViewController.m
//  CandyFinder
//
//  Created by Devin Moss on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TagCandyViewController.h"
#import "SBJson.h"
#import "MapViewController.h"
#import "Candy.h"
#import "AppDelegate.h"
#import "globals.h"
#import "Web.h"
#import "UIDevice+IdentifierAddition.h"
#import "LocationPoster.h"
#import "FlurryAnalytics.h"
#import "ScannerOverlayView.h"

@implementation TagCandyViewController

@synthesize responseData, listContent, addCandy, fromAnnotationDetails, location_id, segment, isScanning, sku, indicator;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"tagview received memory warning");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [segment addTarget:self action:@selector(segmentSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    if(self.searchDisplayController) {
        [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageNamed:@"background_find_bot.png"]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    //View is unloading, which means the user pushed back button "Location"
    //So we destroy the current location so the placesViewController won't segue automatically to here
    [LocationPoster sharedLocationPoster].currentLocation = nil;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    addCandy.enabled = NO;
    if([LocationPoster sharedLocationPoster].currentLocation == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Top Bar Blank.png"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.searchDisplayController.searchBar setShowsCancelButton:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //[self.searchDisplayController.searchBar resignFirstResponder];
    
    [FlurryAnalytics logPageView];
    
    isScanning = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    //[self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
     If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
     */
    
    return [self.listContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if([indexPath row] % 2 == 0) {
        cell.backgroundView = [[UIView alloc] init ]; 
        cell.backgroundView.backgroundColor = LIGHT_BLUE;
    } else {
        cell.backgroundView = [[UIView alloc] init ]; 
        cell.backgroundView.backgroundColor = DARK_BLUE;
    }
    
    /*
     If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
     */
    
    Candy *candy = [self.listContent objectAtIndex:indexPath.row];
    
    cell.textLabel.text = candy.title;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.detailTextLabel.text = candy.subtitle;
    UIImage *image = [UIImage imageNamed:@"milkyway.png"];
    cell.imageView.image = image;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    /*UILabel *mapLabel = [[UILabel alloc] initWithFrame:CGRectMake(215.0, 14.0, 100.0, 15.0)];
    mapLabel.tag = MAP_LABEL_TAG;
    mapLabel.text = @"Customization";
    mapLabel.font = [UIFont systemFontOfSize:14.0];
    mapLabel.textAlignment = UITextAlignmentRight;
    mapLabel.textColor = [UIColor blackColor];
    mapLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:mapLabel];
    */
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
    [self displayActionSheet:indexPath];
    
    //Dispatch event
    if(isScanning) {
        [FlurryAnalytics logEvent:TAG_SCAN_TOUCHED];
    } else {
        [FlurryAnalytics logEvent:TAG_TEXT_TOUCHED];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"TagToMapView" sender:self];
}

#pragma mark - Search Bar Delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    isScanning = NO;
    
    if([searchString length] > 2) {
        [self filterContentForSearchText:searchString scope:
         [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
        
        // Return YES to cause the search result table view to be reloaded.
        return YES;
    }else {
        return NO;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    
    isScanning = NO;
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    indicator.hidesWhenStopped = YES;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    //Using NSURL send the message
    responseData = [NSMutableData data];
    NSString *url = [NSString stringWithFormat:SEARCH_NAME, searchText];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - JSON Request section
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    if(![indicator isAnimating]) {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = self.view.center;
        indicator.hidesWhenStopped = YES;
        [self.view addSubview:indicator];
        [indicator startAnimating];
    }
    
    //Using NSURL send the message
    responseData = [NSMutableData data];
    NSString *url = [NSString stringWithFormat:SEARCH_NAME, searchText];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
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
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    if(![responseString isEqualToString:@"null"]) {
        NSDictionary *candyInfo = [responseString JSONValue];
        
        for (NSDictionary *item in candyInfo){
            
            [tempArray addObject:[Candy candyFromDictionary:item]];
        }
    }
    
    self.listContent = tempArray;
    
    [self.searchDisplayController.searchResultsTableView reloadData];
    [self.tableView reloadData];
    
    if(listContent.count == 0){
        NSString *searchText = self.searchDisplayController.searchBar.text;
        if(searchText) {
            [FlurryAnalytics logEvent:CANDY_NOT_FOUND withParameters:[NSDictionary dictionaryWithObject:self.searchDisplayController.searchBar.text forKey:@"searched_text"]];
        } else {
            
        }
        
        //make add button visible
        //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pushAddCandyController)];
        //self.navigationItem.rightBarButtonItem = addButton;
        
        //self.navigationController.navigationItem.rightBarButtonItem.enabled = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        addCandy.enabled = YES;
        
        [segment insertSegmentWithTitle:@"Add" atIndex:2 animated:YES];
    }else{
        //self.navigationItem.rightBarButtonItem = nil;
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        addCandy.enabled = NO;
    }
    
    
}

#pragma mark - Action Sheet
- (IBAction)displayActionSheet:(NSIndexPath *)indexPath {
    Candy *candy = [listContent objectAtIndex:[indexPath row]];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Tag %@ %@ at %@?", candy.title, candy.subtitle, [LocationPoster sharedLocationPoster].currentLocation.name]
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
            Candy *c = [listContent objectAtIndex:[[self.tableView  indexPathForSelectedRow] row]];
            
            [[LocationPoster sharedLocationPoster] postAnnotationForCandy:c];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank You" message:@"You tagged a candy!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert dismissWithClickedButtonIndex:0 animated:YES];
            [alert show];
            
            //Posting to the feed will look like this:
            //538985750/feed?app_id=158944047567520&   link=http://developers.facebook.com/docs/reference/dialogs/&   picture=http://fbrell.com/f8.jpg&   name=Facebook%20Dialogs&   caption=Reference%20Documentation&   description=Using%20Dialogs%20to%20interact%20with%20users.
            //The name becomes a link with "link"'s url
            //Caption is the text
            //Icon is displayed in the wall post
            //Picture is something I don't know
            //Description seems to be useless
            
            /*AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"this is a test", @"name", @"caption here", @"caption", @"description here", @"decription", @"http://candyfinder.net", @"link", nil];
            [app.facebook requestWithGraphPath:@"me/feed"  
                                 andParams:params  
                             andHttpMethod:@"POST" 
                               andDelegate:[FBDataGetter sharedFBDataGetter]];*/
            
            NSString *candyName = [NSString stringWithFormat:@"%@ %@", c.title, c.subtitle];
            [FlurryAnalytics logEvent:CANDIES_TAGGED withParameters:[NSDictionary dictionaryWithObject:candyName forKey:@"name"]];
            
            [(UITableViewCell *)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]] setSelected:NO];
            break;
        }
        default:
            break;
    }
}

#pragma mark - ZBarReader Delegate
- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    isScanning = YES;
    
    [FlurryAnalytics logEvent:TAG_ITEM_SCANNED];
    
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    if(symbol) {
        // EXAMPLE: do something useful with the barcode data
        NSLog(@"%@", symbol.data);
        //Chop off leading 0 (if it's 13 digits)
        self.sku = [NSString stringWithFormat:@"%@", symbol.data];
        
        //Using NSURL send the message
        responseData = [NSMutableData data];
        
        NSURLRequest *request = [[Web sharedWeb] searchSKURequest:symbol.data];
        
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
    } else {
        self.listContent = [[NSArray alloc] init];
        [self.searchDisplayController.searchResultsTableView reloadData];
        [self.tableView reloadData];
    }
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
    
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker {
    [picker dismissModalViewControllerAnimated:YES];
    
    [FlurryAnalytics logEvent:TAG_SCAN_CANCEL];
}

#pragma mark - UISegmentedControl
- (IBAction)segmentSwitch:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    
    if(segmentedControl.selectedSegmentIndex == 0) {
        //Tag
    } else if (segmentedControl.selectedSegmentIndex == 1) {
        //Scanner
        [self scanButtonTapped];
    }

}

#pragma mark - Custom Actions
- (IBAction)mapButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"TagToMapView" sender:self];
}

- (IBAction)addButtonTapped:(id)sender {
    NSString *criteria = [[NSString alloc] init];
    if(isScanning) {
        criteria = self.sku;
    } else {
        criteria = self.searchDisplayController.searchBar.text;
    }
    [FlurryAnalytics logEvent:TAG_ADD_BUTTON withParameters:[NSDictionary dictionaryWithObject:criteria forKey:@"search_scan_criteria"]];
    
    [self performSegueWithIdentifier:@"TagToNewCandy" sender:self];
}

- (IBAction) scanButtonTapped
{
    [FlurryAnalytics logEvent:TAG_START_SCAN];
    
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    [reader setCameraOverlayView:[[ScannerOverlayView alloc] initWithFrame:SCANNER_OVERLAY_FRAME]];
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader
                            animated: YES];
    //[reader release];
}

@end
