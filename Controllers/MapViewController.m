//
//  ViewController.m
//  CandyFinder
//
//  Created by Devin Moss on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "globals.h"
#import "TaggedLocation.h"
#import "AppDelegate.h"
#import "Web.h"
#import "Candy.h"
#import "SBJson.h"
#import "Location.h"
#import "LocationPoster.h"
#import "UIDevice+IdentifierAddition.h"
#import "FlurryAnalytics.h"
#import "LocationDetailsViewController.h"

@implementation MapViewController

@synthesize mapView, locationManager, bestLocation, isLocating;
@synthesize detailsView, responseData, selectedLocation;
@synthesize locationsNearYou, filterBar, isFilteringByCandy, regionWillChangeAnimatedCalled, regionChangedBecauseAnnotationSelected, shouldReloadAllAnnotations, fromAnnotationDetails, labelHolder, isFirstTimeLoading, isFilteringByLocation;

- (void)didReceiveMemoryWarning
{
    NSLog(@"mapview received memory warning");
    
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    responseData = [[NSMutableData alloc] init];
    
    isFilteringByCandy = NO;
    fromAnnotationDetails = NO;
    isFirstTimeLoading = YES;
    
    [filterBar setShowsCancelButton:YES animated:YES];
    [filterBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    locationManager = [[CLLocationManager alloc] init];
    
    //We will be the location manager delegate
    locationManager.delegate = self;
    
    //Track position at the best possible accuracy
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    //We want to see all location updates, regardless of distance change
    locationManager.distanceFilter = 0.0;
    
    [filterBar setBackgroundImage:[UIImage imageNamed:@"chocolage_bg_tall.png"]];
    
    
    //Add toolbar to bottom for clear button
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 387, 320, 44)];
     [toolbar setBarStyle:UIBarStyleBlack];
     UIBarButtonItem *meButton = [[UIBarButtonItem alloc] initWithTitle:@"Me" 
     style:UIBarButtonItemStyleBordered 
     target:self 
     action:@selector(myLocation:)];
     
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" 
                                                                 style:UIBarButtonItemStyleBordered 
                                                                target:self 
                                                                action:@selector(dismissAnnotationsForCandy:)];
     
     UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
     
     [toolbar setItems:[NSArray arrayWithObjects:clearButton, extraSpace, meButton, nil]];
    
    UILabel *templabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 1, 210, 40)];
    templabel.text = ALL_LOCATIONS;
    templabel.backgroundColor = [UIColor clearColor];
    templabel.textColor = [UIColor whiteColor];
    templabel.font = [UIFont systemFontOfSize:14.0];
    templabel.numberOfLines = 0;
    templabel.lineBreakMode = UILineBreakModeWordWrap;
    self.locationsNearYou = templabel;
    
    [toolbar addSubview:locationsNearYou];
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
    
    
    //Add the toolbar to the bottom
    [self.tabBarController.view addSubview:toolbar];
    
    
    [locationManager startUpdatingLocation];
    isLocating = YES;
    [self performSelector:@selector(checkLocationManager:) withObject:nil afterDelay:UPDATE_INTERVAL];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(isFirstTimeLoading) {
        //If it's the first time loading the map view, we load the annotations no matter what
        //We just have to check whether we are filtering by a particular candy or not
        if(app.currentCandy) {
            //First time loading and the user is filtering by a particular candy
            //This means the user launched the app and performed a search before they viewed the map
            isFilteringByCandy = YES;
            shouldReloadAllAnnotations = NO;
            //locationsNearYou.text = [NSString stringWithFormat:CANDY_LOCATIONS, app.currentCandy.title, app.currentCandy.subtitle];
            self.labelHolder = [NSString stringWithFormat:@"%@ %@", app.currentCandy.title, app.currentCandy.subtitle];
            [self getAnnotationsForCandy];
        } else {
            //It's the first time loading and the user isn't filtering by a particular candy
            //This means the user launched the app and went straight to the map, so we load all annotations
            [self getAnnotationsForRegion];
            isFilteringByCandy = NO;
            shouldReloadAllAnnotations = YES;
            locationsNearYou.text = [NSString stringWithFormat:ALL_LOCATIONS];
        }
    } else if(!fromAnnotationDetails) {
        if(app.currentCandy) {
            //If we're not coming back from annotation details, and app.currentCandy is not nil
            //Then the user is filtering by a particular candy so we load those annotations
            isFilteringByCandy = YES;
            shouldReloadAllAnnotations = NO;
            //locationsNearYou.text = [NSString stringWithFormat:CANDY_LOCATIONS, app.currentCandy.title, app.currentCandy.subtitle];
            self.labelHolder = [NSString stringWithFormat:@"%@ %@", app.currentCandy.title, app.currentCandy.subtitle];
            [self getAnnotationsForCandy];
        } else {
            //We aren't coming back from annotation details, and the user isn't filtering by a particular candy
            //This probably means nothing has changed, they are probably switching from one tab view to the next
            //So we don't change anything
        }
    } else {
        if(app.currentCandy) {
            //If we are coming back from annotation details, and app.currentCandy is not nil
            //Then the user opened the callout from the map to view the candies at a particular location
            //Then switched over to the search controller and searched for a candy
            //So the annotation details controller pops off, but fromAnnotationDetails is still set to yes.
            //I should re-think the logic of having fromAnnotationDetails.  If I can avoid it, I should.
            isFilteringByCandy = YES;
            shouldReloadAllAnnotations = NO;
            //locationsNearYou.text = [NSString stringWithFormat:CANDY_LOCATIONS, app.currentCandy.title, app.currentCandy.subtitle];
            self.labelHolder = [NSString stringWithFormat:@"%@ %@", app.currentCandy.title, app.currentCandy.subtitle];
            [self getAnnotationsForCandy];
            fromAnnotationDetails = NO;
        } else {
            //If we just came from annotationDetails view then we don't want to reload the map
            //So we set it back to NO here
            //It gets set to YES when the user clicks the callout button on an annotation
            fromAnnotationDetails = NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [FlurryAnalytics logPageView];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [locationManager stopUpdatingLocation];
    isLocating = NO; // When the annotationDetails view disappears, it re-zooms the map.  This should not be
    
    [toolbar removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"MapToLocationDetails"])
    {
        // Get reference to the destination view controller
        LocationDetailsViewController *vc = (LocationDetailsViewController *)[segue destinationViewController];
        UIButton *button = (UIButton *)sender;
        
        // Pass any objects to the view controller here, like...
        for(Location *loc in mapView.annotations) {
            if([loc isMemberOfClass:[Location class]]) {
                if ([loc.location_id isEqualToString:[NSString stringWithFormat:@"%i", button.tag]]) {
                    vc.location = loc;
                    break;
                }
            }
        }
        
        fromAnnotationDetails = YES;
    }
}


#pragma mark - Location Management
- (BOOL)isBetterLocation:(CLLocation *)location {
    if (bestLocation == nil){
        //best location not set yet, so it's a better locatin by default
        return YES;
    }
    
    // Figure out how long it's been since we got a better location
    NSTimeInterval timeDelta = [location.timestamp timeIntervalSinceDate:bestLocation.timestamp];
    //If receiver (location) is later (newer) than bestLocation, timeDelta is positive
    //Below tests to see if location is more than 2 minutes newer than bestLocation
    //AKA is bestLocation more than 2 minutes older than location?
    BOOL isSignificantlyNewer = timeDelta > TWO_MINUTES;
    //If the receiver (location) is earlier (older) than bestLocation, timeDelta is negative
    //Below tests to see if location is more than 2 minutes older than bestLocation
    BOOL isSignificantlyOlder = timeDelta < -TWO_MINUTES;
    BOOL isNewer = timeDelta > 0;
    
    if (isSignificantlyNewer) {
        return YES;
    }else if (isSignificantlyOlder) {
        return NO;
    }
    
    //Accuracy refers to the circle around the point
    //Horizontal and Vertical accuracy are each radius of that circle
    //So a more accurate location means a smaller circle, which means a smaller radius (horizontal/vertical accuracy)
    CLLocationAccuracy accuracyDelta = location.horizontalAccuracy - bestLocation.horizontalAccuracy;
    //You want accuracy to be low
    BOOL isLessAccurate = accuracyDelta > 0;
    BOOL isMoreAccurate = accuracyDelta < 0;
    BOOL isDifferent = location.coordinate.latitude != bestLocation.coordinate.latitude || 
    location.coordinate.longitude != bestLocation.coordinate.longitude;
    
    if (isMoreAccurate) {
        return YES;
    } else if (isNewer && !isLessAccurate && isDifferent) {
        return YES;
    }
    
    return NO;
}

- (void)checkLocationManager:(id)sender {
    NSTimeInterval bestLocationAge = fabs([bestLocation.timestamp timeIntervalSinceNow]);
    
    if (bestLocationAge > TWO_MINUTES) {
        [locationManager stopUpdatingLocation];
        isLocating = NO;
        NSLog(@"Turning off location manager >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }
    
    if (isLocating) {
        // Repeat the check until isLocating = NO
        [self performSelector:@selector(checkLocationManager:) withObject:nil afterDelay:UPDATE_INTERVAL];
    }
}

#pragma mark - Location manager delegate
//Event sent by CLLocationManager to CLLocationManagerDelegate
//Catch it here since we are locationManager's delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if ([self isBetterLocation:newLocation]){
        self.bestLocation = newLocation;
        if(isFirstTimeLoading) {
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(bestLocation.coordinate, 800, 800);
            MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
            [mapView setRegion:adjustedRegion animated:YES];
        }
    }
}

- (IBAction)myLocation:(id)sender {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 800, 800);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
}

#pragma mark - MKMapViewDelegate Stuff
- (void)mapView:(MKMapView *)map regionDidChangeAnimated:(BOOL)animated {
    if(!regionChangedBecauseAnnotationSelected) {
        if(isFilteringByCandy){
            [self getAnnotationsForCandy];
        } else if (shouldReloadAllAnnotations) {
            [self getAnnotationsForRegion];
        }
    }
    
    regionWillChangeAnimatedCalled = NO;
    regionChangedBecauseAnnotationSelected = NO;
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    regionWillChangeAnimatedCalled = YES;
    regionChangedBecauseAnnotationSelected = NO;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    regionChangedBecauseAnnotationSelected = regionWillChangeAnimatedCalled;
}


#pragma mark - Annotation Stuff
//Event triggered by the mapView sent to MapViewDelegate
//Whenever it finds an annotation, it asks for an annotationview
//I think the default is MKPinAnnotationView
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    //We can use this if we have a custom annotation that we want to display
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[Location class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView*    pinView = (MKPinAnnotationView*)[self.mapView
                                                                 dequeueReusableAnnotationViewWithIdentifier:@"Location"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:@"Location"];
            
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.canShowCallout = YES;
            if([((Location *)annotation).location_id isEqualToString:[LocationPoster sharedLocationPoster].currentLocation.location_id]) {
                pinView.draggable = NO;//used to say YES
                pinView.animatesDrop = YES;
            } else {
                pinView.draggable = NO;
                pinView.animatesDrop = NO;
            }
        }
        else {
            pinView.annotation = annotation;
            if([((Location *)annotation).location_id isEqualToString:[LocationPoster sharedLocationPoster].currentLocation.location_id]) {
                pinView.draggable = NO;//used to say YES but we don't allow dragging any longer
                pinView.animatesDrop = YES;
            } else {
                pinView.draggable = NO;
                pinView.animatesDrop = NO;
            }
        }
        
        // Add a detail disclosure button to the callout.
        UIButton* rightButton = [UIButton buttonWithType:
                                 UIButtonTypeDetailDisclosure];
        rightButton.frame = CGRectMake(0, 0, 30, 30);
        [rightButton setTitle:((Location *)annotation).name forState:UIControlStateNormal];
        [rightButton setTag:[((Location *)annotation).location_id integerValue]];
        //NSArray *array = mapView.annotations;
        //NSLog(@"%@'s index: %@", ((Location *)annotation).location_id, [mapView.annotations indexOfObject:annotation]);
        
        [rightButton addTarget:self action:@selector(showInfo:)
              forControlEvents:UIControlEventTouchUpInside];
        
        pinView.rightCalloutAccessoryView = rightButton;
        
        //LeftCalloutAccessoryView
        /*UIView *leftCAV = [[UIView alloc] initWithFrame:CGRectMake(0,0,30,30)];
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, 0, 30, 30);
        label.text = @":)";
        [leftCAV addSubview : label];
        pinView.leftCalloutAccessoryView = leftCAV;*/
        
        return pinView;
    }
    
    return nil;
}

- (void)markLocation:(Location *)location {
    //Create an annotation
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Candy *currentCandy = app.currentCandy;
    NSString *body = [NSString stringWithFormat:ANNOTATION_PARAMETERS, currentCandy.candy_id, currentCandy.sku, [[UIDevice currentDevice] uniqueDeviceIdentifier], location.location_id, app.authenticity_token];
    
    [[Web sharedWeb] sendPostToURL:CREATE_ANNOTATION withBody:body];
    
    [self getAnnotationsForRegion];
}

-(IBAction)showInfo:(id)sender 
{
    isFilteringByCandy = NO;
    [self performSegueWithIdentifier:@"MapToLocationDetails" sender:sender];
}

- (void) getAnnotationsForRegion {
    CLLocationDegrees longit = self.mapView.region.center.longitude;
    CLLocationDegrees lat = self.mapView.region.center.latitude;
    NSLog(@"Current lat: %f, lon: %f", lat, longit);
    
    NSNumber *minLat = [NSNumber numberWithDouble:mapView.region.center.latitude - (mapView.region.span.latitudeDelta / 2.0)];
    NSNumber *maxLat = [NSNumber numberWithDouble:mapView.region.center.latitude + (mapView.region.span.latitudeDelta / 2.0)];
    NSNumber *minLon = [NSNumber numberWithDouble:mapView.region.center.longitude - (mapView.region.span.longitudeDelta / 2.0)];
    NSNumber *maxLon = [NSNumber numberWithDouble:mapView.region.center.longitude + (mapView.region.span.longitudeDelta / 2.0)];
    
    //Make call to server using fromLat, toLat, fromLong, toLong
    //Call should return all annotations within those lattitudes/longitudes
    //Populate them on the mapView
    responseData = [NSMutableData data];
    NSString *url = [NSString stringWithFormat:LOCATIONS_FROM_REGION, minLon, maxLon, minLat, maxLat];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void) getAnnotationsForCandy {
    //Using NSURL send the message
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app.currentCandy) {
        responseData = [NSMutableData data];
        NSString *url = [NSString stringWithFormat:LOCATIONS_FROM_CANDY, app.currentCandy.candy_id, app.currentLocation.lat, app.currentLocation.lon];
        NSLog(@"search url: %@", url);
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
    } else {
        //no candy to filter by
    }
    //Set current candy to nil so the map doesn't try to zoom anymore
    app.currentCandy = nil;
}

#pragma mark  - Search functions
- (void) showAnnotationsForLocation:(NSDictionary *)location {
    //Put an annotation near our current location
    CLLocationCoordinate2D coord;
    coord.latitude = [[location objectForKey:@"lat"] doubleValue];
    coord.longitude = [[location objectForKey:@"long"] doubleValue];
    TaggedLocation *annotation = [[TaggedLocation alloc] initWithLocation:coord];
    annotation.candyName = [location objectForKey:@"name"];
    annotation.locationName = [location objectForKey:@"name"];
    
    [mapView addAnnotation:annotation];
}

- (void) showAnnotationsForCandy:(Candy *)candy {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.currentCandy = candy;
    
    locationsNearYou.text = [NSString stringWithFormat:CANDY_LOCATIONS, candy.title, candy.subtitle];
}

- (IBAction)dismissAnnotationsForCandy:(id)sender {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.currentCandy = nil;
    locationsNearYou.text = ALL_LOCATIONS;
    isFilteringByCandy = NO;
    shouldReloadAllAnnotations = YES;
    [self getAnnotationsForRegion];
}

#pragma mark JSON Request section
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [responseData setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [responseData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//resultText.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    responseData = [NSMutableData data];
    
	NSArray *locationInfo = [responseString JSONValue];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *item in locationInfo){
        //Before creating a location, we could loop through mapView.annotations to see if this location is already in there
        //I don't know if that would save time or not
        Location *annotation = [Location locationFromDictionary:item];
        [tempArray addObject:annotation];
    }
    
    //Loop through, remove old annotations that won't appear on the map
    //Add new annotations (any left over in tempArray after this loop are new)
    NSMutableArray *removeAnnotations = [[NSMutableArray alloc] init];    
    for(int i = 0; i < [mapView.annotations count]; i++){
        Location *loc = [mapView.annotations objectAtIndex:i];
        if([loc isKindOfClass:[Location class]]){
            BOOL isFound = NO;
            for(Location *l2 in tempArray) {
                if ([l2.location_id isEqualToString:loc.location_id]) {
                    //The location returned from the server is already displayed on the map
                    //So don't add it to the map (remove it from the locations returned from server)
                    [tempArray removeObject:l2];
                    isFound = YES;
                    break;
                }
            }
            if(!isFound) {
                //The location on the map wasn't found in the locations returned by the server
                //So we have to remove it from the map
                [removeAnnotations addObject:loc];
            }
        }else {
            //This is the MKUserLocation annotation
        }
    }
    [mapView removeAnnotations:removeAnnotations];
    [mapView addAnnotations:tempArray];
    
    if(isFilteringByCandy) {
        tempArray = (NSMutableArray *)mapView.annotations;
        //[mapView setVisibleMapRect:[Location calculateRegionFromLocations:tempArray] animated:YES];
        
        if(isFirstTimeLoading) {
            isFirstTimeLoading = NO;
            
            //MKUserLocation isn't in the annotations array yet, so we don't subtract one from the count
            locationsNearYou.text = [NSString stringWithFormat:CANDY_LOCATIONS, [mapView.annotations count], labelHolder];
            //Add user's location from the delegate since the map hasn't loaded it yet.  This doesn't get added to the mapview though
            [tempArray addObject:((AppDelegate *)[[UIApplication sharedApplication] delegate]).currentLocation];
        }else {
            locationsNearYou.text = [NSString stringWithFormat:CANDY_LOCATIONS, [mapView.annotations count] - 1, labelHolder];
        }
        
        MKCoordinateRegion adjustedRegion = [Location calculateRegionFromLocations:tempArray];
        [mapView setRegion:adjustedRegion animated:YES];
        isFilteringByCandy = NO;
    } else if(isFilteringByLocation) {
        tempArray = (NSMutableArray *)mapView.annotations;
        
        MKCoordinateRegion adjustedRegion = [Location calculateRegionFromLocations:tempArray];
        [mapView setRegion:adjustedRegion animated:YES];
        isFilteringByLocation = NO;
    }
    
    if(isFirstTimeLoading) {
        isFirstTimeLoading = NO;
    }
}

#pragma mark - SearchBar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    shouldReloadAllAnnotations = NO;
    isFilteringByLocation = YES;
    
    //Using NSURL send the message
    responseData = [NSMutableData data];
    NSString *url = [NSString stringWithFormat:LOCATIONS_FROM_NAME, searchBar.text, bestLocation.coordinate.latitude, bestLocation.coordinate.longitude];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    locationsNearYou.text = [NSString stringWithFormat:LABEL_SEARCH_LOCATIONS, searchBar.text];
    
    [self dismissSearchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissSearchBar];
}

- (IBAction)searchButtonTapped:(id)sender {
    filterBar.hidden = NO;
    [filterBar becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)dismissSearchBar {
    //[filterBar setShowsCancelButton:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if([filterBar isFirstResponder]){
        [filterBar resignFirstResponder];
    }
    [filterBar setHidden:YES];
}

@end
