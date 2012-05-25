//
//  ViewController.h
//  CandyFinder
//
//  Created by Devin Moss on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 The map does a few key things:
 1. Displays the user's current location and any candy locations near them
 2. Filters those locations by candy.  Here's how it works:
    a. User uses "ResultsViewController" to search for a candy
    b. User selects a candy from ResultsViewController and the map is displayed
    c. The map displays a few locations (up to 5, but selects the nearest few) and zooms in/out so the user can see all of them
 3. Filters those locations by location name
    a. The map has a search bar so the user can type something like 7-Eleven to only view 7-Eleven locations
 4. Re-focuses on the user's location.  This is accomplished by tapping the cross hairs shown on the bottom right corner of the map.
 **/

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <iAd/iAd.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "AnnotationDetails.h"
#import "Location.h"
#import "Candy.h"
#import "AppDelegate.h"

#define UPDATE_INTERVAL     1

#define ONE_MINUTE          (60)
#define TWO_MINUTES         (2 * ONE_MINUTE)

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, BannerViewContainer> {
    MKMapView *mapView;
    CLLocation *bestLocation;
    CLLocationManager *locationManager;
    BOOL isLocating;
    AnnotationDetails *detailsView;
    NSMutableData *responseData;
    Location *selectedLocation;
    UILabel *locationsNearYou;
    IBOutlet UISearchBar *filterBar;
    BOOL isFilteringByCandy;//Used to zoom the map one time
    BOOL regionWillChangeAnimatedCalled;
    BOOL regionChangedBecauseAnnotationSelected;
    BOOL shouldReloadAllAnnotations;
    BOOL fromAnnotationDetails;
    NSString *labelHolder;
    BOOL isFirstTimeLoading;
    
    //isFilteringByLocation tells the app that the user wants to zoom to the matching locations
    BOOL isFilteringByLocation;
    
    UIToolbar *toolbar;
    ADBannerView *_bannerView;
}

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet UILabel *locationsNearYou;
@property (nonatomic, strong) CLLocation *bestLocation;
@property (nonatomic, assign) BOOL isLocating;
@property (nonatomic, strong) AnnotationDetails *detailsView;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) Location *selectedLocation;
@property (nonatomic, strong) IBOutlet UISearchBar *filterBar;
@property (nonatomic, assign) BOOL isFilteringByCandy;
@property (nonatomic, assign) BOOL regionWillChangeAnimatedCalled;
@property (nonatomic, assign) BOOL regionChangedBecauseAnnotationSelected;
@property (nonatomic, assign) BOOL shouldReloadAllAnnotations; //Changes to yes only when the user isn't viewing a certain candy
                                                                //So when they click "dismiss" or when they just click the map tab

@property (nonatomic, assign) BOOL fromAnnotationDetails;//If we're coming back from annotationDetails, we don't want to change the map at all until the user does something
@property (nonatomic, strong) NSString *labelHolder;
@property (nonatomic, assign) BOOL isFirstTimeLoading;
@property (nonatomic, assign) BOOL isFilteringByLocation;

- (BOOL)isBetterLocation:(CLLocation *)location;
- (IBAction)tagCandy:(id)sender;
- (void)checkLocationManager:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)myLocation:(id)sender;
- (IBAction) scanButtonTapped;
- (void) showAnnotationsForCandy:(Candy *)candy;
- (void) getAnnotationsForRegion;
- (void) markLocation:(Location *)location;
- (void) getAnnotationsForCandy;
- (IBAction)dismissAnnotationsForCandy:(id)sender;
- (IBAction)searchButtonTapped:(id)sender;
- (void)dismissSearchBar;

@end
