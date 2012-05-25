//
//  AppDelegate.h
//  CandyFinder
//
//  Created by Devin Moss on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
//#import "MapViewController.h"
#import "Candy.h"
#import "Location.h"
#import "Reachability.h"
@class MapViewController;


@protocol BannerViewContainer <NSObject>

- (void)showBannerView:(ADBannerView *)bannerView animated:(BOOL)animated;
- (void)hideBannerView:(ADBannerView *)bannerView animated:(BOOL)animated;

@end


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, MKMapViewDelegate, ADBannerViewDelegate, UITabBarControllerDelegate> {
    /**
     Delegate retrieves this from backend server when app loads
     Provides security for PUT and POST requests
     **/
    NSString *authenticity_token;
    
    /** 
     (Candy *)currentCandy - 
     Gets set whenever a user searches for a candy. 
     Allows other controllers (like the map) to know what the user is searching
     **/
    Candy *currentCandy;
    
    /**
     (Location *)currentLocation - 
     Gets updated when the user's location changes
     Allows other controllers to retrieve user's current location
     Also used when making calls to Google GeoCoder to get
     the approximate address of the user
     **/
    Location *currentLocation;//This is the user's location
    
    CLLocationManager *locationManager;
    CMMotionManager *motionManager;
    BOOL isLocating;
    CLLocation *bestLocation;
    
    //Checks for a network connection
    //Alert displayed if none found
    Reachability *reachability;
    
    //Displays the ad banner
    ADBannerView *adBanner;
    
    //Container for the currently-selected view controller
    UIViewController<BannerViewContainer> *_currentController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *authenticity_token;
@property (strong, nonatomic) Candy *currentCandy;
@property (strong, nonatomic) Location *currentLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic, assign) BOOL isLocating;
@property (nonatomic, strong) CLLocation *bestLocation;
@property (nonatomic, strong) Reachability *reachability;
//@property (nonatomic, strong) IBOutlet UIViewController *currentController;

- (BOOL) writeToHistoryPlist:(Candy *)candy;
- (NSMutableArray *) readHistoryPlist;
- (BOOL) clearHistoryPlist;
- (void) handleNetworkChange:(NSNotification *)notice;
- (void)checkLocationManager:(id)sender;
- (void)refreshUserLocation:(id)sender; //Used to turn locationManger on and update user's location
                                        //Turns on every minute after locationManager gets switched off
- (void)incrementBadgeDisplayForInfo;
- (void)getCandyfinderAuthenticityToken;

@end