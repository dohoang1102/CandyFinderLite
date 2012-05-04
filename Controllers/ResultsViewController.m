//
//  ResultsViewController.m
//  CandyFinder
//
//  Created by Devin Moss on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResultsViewController.h"
#import "SBJson.h"
#import "MapViewController.h"
#import "AppDelegate.h"
#import "NewCandyViewController.h"
#import "Web.h"
#import "Candy.h"
#import "UIDevice+IdentifierAddition.h"
#import "FlurryAnalytics.h"
#import "AnnotationDetails.h"
#import "ScannerOverlayView.h"

@implementation ResultsViewController

@synthesize searchText, listContent, responseData;
@synthesize addCandy, isScanning, sku, indicator;

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
    NSLog(@"resultsview received memory warning");
    
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
    
    // create a filtered list that will contain products for the search results table.
    
    self.responseData = [NSMutableArray arrayWithCapacity:[self.listContent count]];
    
    // restore search settings if they were saved in didReceiveMemoryWarning.
    
    [self.tableView reloadData];
    self.tableView.scrollEnabled = YES;
    
    if(self.searchDisplayController) {
        [self.searchDisplayController.searchResultsTableView setHidden:NO];
    }
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_AddBody_half.png"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.responseData = nil;
    self.searchDisplayController.delegate = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    addCandy.enabled = NO;
    
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"background_find_top.png"] forBarMetrics:UIBarMetricsDefault];
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageNamed:@"background_find_bot.png"]];
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
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // save the state of the search UI so that it can be restored if the view is re-created
    //self.searchWasActive = [self.searchDisplayController isActive];
    //self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    //self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma Scanning code

- (IBAction) scanButtonTapped
{    
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
    
    //Dispatch event
    [FlurryAnalytics logEvent:SEARCH_START_SCAN];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    isScanning = YES;
    
    [FlurryAnalytics logEvent:SEARCH_ITEM_SCANNED];
    
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // Just grab the first barcode
        break;
    
    if(symbol) {
        //resultText.text = symbol.data;
        //Chop off leading 0 (if it's 13 digits)
        self.sku = [NSString stringWithFormat:@"%@", symbol.data];
        
        //Using NSURL send the message
        responseData = [NSMutableData data];
        
        NSURLRequest *request = [[Web sharedWeb] searchSKURequest:symbol.data];
        
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        // EXAMPLE: do something useful with the barcode image
        //resultImage.image = [info objectForKey: UIImagePickerControllerOriginalImage];
        
        // ADD: dismiss the controller (NB dismiss from the *reader*!)
    }else {
        self.listContent = [[NSArray alloc] init];
        [self.searchDisplayController.searchResultsTableView reloadData];
        [self.tableView reloadData];
    }
    
    [reader dismissModalViewControllerAnimated: YES];
    
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker {
    [picker dismissModalViewControllerAnimated:YES];
    
    [FlurryAnalytics logEvent:SEARCH_SCAN_CANCEL];
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        /*UILabel *mapLabel = [[UILabel alloc] initWithFrame:CGRectMake(245.0, 14.0, 50.0, 15.0)];
        mapLabel.tag = MAP_LABEL_TAG;
        mapLabel.text = MAP_LABEL;
        mapLabel.font = [UIFont systemFontOfSize:14.0];
        mapLabel.textAlignment = UITextAlignmentRight;
        mapLabel.textColor = [UIColor blackColor];
        mapLabel.backgroundColor = [UIColor clearColor];
        mapLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:mapLabel];*/
    }
    
    /*
     If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
     */
    
    if([indexPath row] % 2 == 0) {
        cell.backgroundView = [[UIView alloc] init ]; 
        cell.backgroundView.backgroundColor = LIGHT_BLUE;
    } else {
        cell.backgroundView = [[UIView alloc] init ]; 
        cell.backgroundView.backgroundColor = DARK_BLUE;
    }
    
    
    Candy *candy = [self.listContent objectAtIndex:indexPath.row];
    
    cell.textLabel.text = candy.title;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = candy.subtitle;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    UIImage *image = [UIImage imageNamed:@"milkyway.png"];
    cell.imageView.image = image;
    
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
    Candy *candy = [self.listContent objectAtIndex:indexPath.row];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [app writeToHistoryPlist:candy];
    
    NSString *postString = [NSString stringWithFormat:SEARCH_PARAMETERS, candy.candy_id, [[UIDevice currentDevice] uniqueDeviceIdentifier], searchText, app.authenticity_token];
    
    [[Web sharedWeb] sendPostToURL:CREATE_SEARCH withBody:postString];
    
    //Dispatch event
    if(isScanning) {
        [FlurryAnalytics logEvent:SEARCH_SCAN_TOUCHED];
    } else {
        [FlurryAnalytics logEvent:SEARCH_TEXT_TOUCHED];
    }
    
    app.currentCandy = candy;
    
    UINavigationController *navController = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:2];
    if([navController.viewControllers count] > 0 && [navController.topViewController isKindOfClass:[AnnotationDetails class]]) {
        [navController popViewControllerAnimated:NO];
    }
    [self.tabBarController setSelectedIndex:2];
     
}

#pragma mark JSON Request section
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
    //NSLog(url);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //NSLog([request valueForHTTPHeaderField:@"Accept"]);
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
    
    responseData = [NSMutableData data];
    
    if(![responseString isEqualToString:@"null"]) {
        NSDictionary *candyInfo = [responseString JSONValue];
        
        for (NSDictionary *item in candyInfo){
            [tempArray addObject:[Candy candyFromDictionary:item]];
        }
    }
    
    self.listContent = tempArray;
    
    if (self.searchDisplayController.searchResultsTableView.hidden == YES){
        self.searchDisplayController.searchResultsTableView.hidden = NO;
    }
    
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
    }else{
        //self.navigationItem.rightBarButtonItem = nil;
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        addCandy.enabled = NO;
    }
    
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    isScanning = NO;
    
    self.searchText = searchString;
    if([searchString length] > 2) {
        [self filterContentForSearchText:searchString scope:
         [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
        
        // Return YES to cause the search result table view to be reloaded.
        return YES;
    }else {
        return NO;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    isScanning = NO;
    
    self.searchText = searchBar.text;
    
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

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [searchBar resignFirstResponder];
    //self.navigationItem.rightBarButtonItem = nil;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    NSArray *array = self.searchDisplayController.searchBar.subviews;
    for(UIView *view in array) {
        if([view isKindOfClass:[UIButton class]]) {
            //[((UIButton *)view) setTintColor:DARK_PINK];
        }
    }
}

#pragma mark - Navigation
- (IBAction)addButtonTapped:(id)sender {
    NSString *criteria = [[NSString alloc] init];
    if(isScanning) {
        criteria = self.sku;
    } else {
        criteria = self.searchDisplayController.searchBar.text;
    }
    [FlurryAnalytics logEvent:TAG_ADD_BUTTON withParameters:[NSDictionary dictionaryWithObject:criteria forKey:@"search_scan_criteria"]];
    
    [self performSegueWithIdentifier:@"SearchToNewCandy" sender:self];
}

#pragma mark - Action Sheet
- (IBAction)displayActionSheet:(id)sender {
    UIActionSheet *pickerSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"View Map", @"Add New Candy", nil];
    
    [pickerSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    [pickerSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self performSegueWithIdentifier:@"SearchToMapView" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"SearchToNewCandy" sender:self];
            break;
            
        default:
            break;
    }
}



@end
