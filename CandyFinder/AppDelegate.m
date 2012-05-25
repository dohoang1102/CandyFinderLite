//
//  AppDelegate.m
//  CandyFinder
//
//  Created by Devin Moss on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "FlurryAnalytics.h"
#import "globals.h"
#import "Web.h"
#import "UIDevice+IdentifierAddition.h"
#import "Reachability.h"
#import "ReachabilityAppDelegate.h"
#import "Appirater.h"
#import "InfoViewController.h"
#import "ResultsViewController.h"
#import "PlacesViewController.h"
#import "TagCandyViewController.h"
#import "MapViewController.h"

@implementation AppDelegate

NSString	*kAppID	= @"530626986";
NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@synthesize window = _window;
@synthesize authenticity_token, currentCandy, currentLocation, locationManager, motionManager, isLocating, bestLocation, reachability;

- (void) doStuff {
    NSLog(@"do stuff");
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Customize Appearances
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Top Bar Blank.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:DARK_PINK];
    [[UISearchBar appearance] setTintColor:DARK_PINK];
    [[UIToolbar appearance] setTintColor:CHOCOLATE];
    
    
    
    //Begin checking network connectivity and handle a change of connectivity
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable) {
        NSLog(@"no");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Unavailable" 
                                                         message:@"App content may be limited without a network connection!" 
                                                        delegate:self 
                                               cancelButtonTitle:@"OK" 
                                               otherButtonTitles:nil];
        [alert show];

    } else if (remoteHostStatus == ReachableViaWiFi) {
        NSLog(@"wifi"); 
    } else if (remoteHostStatus == ReachableViaWWAN) {
        NSLog(@"cell"); 
    }
    
    
    
    //Begin running Flury Analytics
    [FlurryAnalytics startSession:FLURRY_API_KEY];
    [FlurryAnalytics setUserID:[[UIDevice currentDevice] uniqueDeviceIdentifier]];
    
    
    
    //Start up location manager and motion manager to get user's location
    motionManager = [[CMMotionManager alloc] init];
    if (motionManager.accelerometerAvailable) {
        motionManager.accelerometerUpdateInterval = 1.0/2.0;
        [motionManager startAccelerometerUpdates];
    }
    
    locationManager = [[CLLocationManager alloc] init];
    
    //We will be the location manager delegate
    locationManager.delegate = self;
    
    //Track position at the best possible accuracy
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    //We want to see all location updates, regardless of distance change
    locationManager.distanceFilter = 0.0;
    
    [locationManager startUpdatingLocation];
    isLocating = YES;
    
    //Start Appirater to see when to display the info badge for the user to rate this app
    [Appirater appLaunched:YES];
    
    
    
    //AdSetup
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSLog(@"%f", bounds.size.height);
    adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, bounds.size.height, 0, 0)];
    adBanner.delegate = self;
    adBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    UITabBarController *tabController = (UITabBarController*)self.window.rootViewController;
    [tabController.view addSubview:adBanner];
    [tabController setDelegate:self];

    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    [locationManager stopUpdatingLocation];
    isLocating = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    //Call server to track use
    [[Web sharedWeb] recordAppHit];
    
    //Get Authenticity Token
    //[self performSelectorInBackground:@selector(getCandyfinderAuthenticityToken) withObject:nil];
    [self getCandyfinderAuthenticityToken];
    
    [locationManager startUpdatingLocation];
    isLocating = YES;
    [self performSelector:@selector(checkLocationManager:) withObject:nil afterDelay:UPDATE_INTERVAL];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}






#pragma mark - Location Management
- (void)checkLocationManager:(id)sender {
    NSTimeInterval bestLocationAge = fabs([bestLocation.timestamp timeIntervalSinceNow]);
    
    if (bestLocationAge > (ONE_MINUTE/2)) {
        [locationManager stopUpdatingLocation];
        isLocating = NO;
        [self performSelector:@selector(refreshUserLocation:) withObject:nil afterDelay:ONE_MINUTE];
    }
    
    if (isLocating) {
        // Repeat the check until isLocating = NO
        [self performSelector:@selector(checkLocationManager:) withObject:nil afterDelay:UPDATE_INTERVAL];
    }
}

- (void)refreshUserLocation:(id)sender {
    //Location manager turns on for about 30 seconds to get user's location
    //This method fires every minute after locationManager turns off
    [locationManager startUpdatingLocation];
    isLocating = YES;
    [self performSelector:@selector(checkLocationManager:) withObject:nil afterDelay:UPDATE_INTERVAL];
}

- (BOOL)isBetterLocation:(CLLocation *)location {
    if (bestLocation == nil){
        //best location not set yet, so it's a better location by default
        return YES;
    }
    
    // Figure out how long it's been since we got a better location
    NSTimeInterval timeDelta = [location.timestamp timeIntervalSinceDate:bestLocation.timestamp];
    
    BOOL isSignificantlyNewer = timeDelta > TWO_MINUTES;
    
    BOOL isSignificantlyOlder = timeDelta < -TWO_MINUTES;
    
    BOOL isNewer = timeDelta > 0;
    
    if (isSignificantlyNewer) {
        return YES;
    }else if (isSignificantlyOlder) {
        return NO;
    }
    
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






#pragma mark - Location manager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if ([self isBetterLocation:newLocation]){
        self.bestLocation = newLocation;
        self.currentLocation = [[Location alloc] initWithLocation:newLocation.coordinate];
        
        [FlurryAnalytics setLatitude:newLocation.coordinate.latitude
                           longitude:newLocation.coordinate.longitude horizontalAccuracy:newLocation.horizontalAccuracy verticalAccuracy:newLocation.verticalAccuracy];
    } else {
        [locationManager stopUpdatingLocation];
        isLocating = NO;
        NSLog(@"AppDelegate: Turning off location manager >>>>>>>>>>>>>>>>>>>>>");
    }
}






#pragma mark - NSURLConnection Request section
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
	if ([response respondsToSelector:@selector(allHeaderFields)]) {
		NSDictionary *dictionary = [httpResponse allHeaderFields];
		self.authenticity_token = (NSString *)[dictionary objectForKey:@"X-Authenticity-Token"];
	}
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//resultText.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
}






#pragma mark - History plist
- (BOOL) writeToHistoryPlist:(Candy *)candy {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"history.plist"];
    
    NSMutableArray *array = [self readHistoryPlist];
    while([array count] >= 25) {
        //For now, we're just showing 25 items in history
        //So we remove the last object in the array here
        [array removeObjectAtIndex:[array count] -1];
    }
    
    for(Candy *c in array) {
        if ([c.candy_id isEqualToString:candy.candy_id]) {
            //User searched something that is already in history
            //So we remove it from the array and push it onto the top
            //This effectively moves it to the top of the history list
            [array removeObject:c];
            break;
        }
    }
    
    [array insertObject:candy atIndex:0];
    NSData *data = [Candy serialize:array];
    
    if(data) {
        if([data writeToFile:plistPath atomically:YES]) {
            return YES;
        } else {
            NSLog(@"Error writing data to plist");
            return NO;
        }
    }
    else {
        NSLog(@"Error serializing the data for writing to plist");
        return NO;
    }
}

- (BOOL) clearHistoryPlist {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"history.plist"];
    
    NSData *data = [[NSData alloc] init];
    return [data writeToFile:plistPath atomically:YES];
}

- (NSMutableArray *) readHistoryPlist {
    NSPropertyListFormat format;
    NSString *errorDesc = nil;
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"history.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        
        plistPath = [[NSBundle mainBundle] pathForResource:@"history" ofType:@"plist"];
        
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    
    NSArray *temp = (NSArray *)[NSPropertyListSerialization
                                          
                                          propertyListFromData:plistXML
                                          
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          
                                          format:&format
                                          
                                          errorDescription:&errorDesc];
    
    if (!temp) {
        
        NSLog(@"Error reading plist: %@, format: %i", errorDesc, format);
        
    }
    
    return [Candy unserialize:temp];
}






#pragma mark - Reachability helper
- (void) handleNetworkChange:(NSNotification *)notice
{
    
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable) {
        NSLog(@"no");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Unavailable" 
                                                        message:@"App content may be limited without a network connection!" 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    else if (remoteHostStatus == ReachableViaWiFi) {NSLog(@"wifi"); }
    else if (remoteHostStatus == ReachableViaWWAN) {NSLog(@"cell"); }
}






#pragma mark - badge and authenticity token
- (void)incrementBadgeDisplayForInfo {
    UITabBarController *tabController = (UITabBarController*)self.window.rootViewController;
    InfoViewController *infoController = (InfoViewController *)[tabController.customizableViewControllers objectAtIndex:4];
    NSString *badge = [infoController.tabBarItem badgeValue];
    NSInteger badgeNumber = [badge integerValue];
    if((badgeNumber - 1) < 1) {
        [infoController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%i", 1]];
    } else {
        [infoController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%i", badgeNumber - 1]];
    }
}

- (void)getCandyfinderAuthenticityToken {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://candyfinder.net"]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}



#pragma mark - Ad Banner View Delegate
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [UIView beginAnimations:@"fixupViews" context:nil];
    if(_currentController) {
        [_currentController showBannerView:adBanner animated:YES];
    } else {
        [adBanner setFrame:CGRectMake(0, 381, adBanner.bounds.size.width, adBanner.bounds.size.height)];
    }
    [UIView commitAnimations];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView beginAnimations:@"fixupViews" context:nil];
    if(_currentController) {
        [_currentController hideBannerView:adBanner animated:YES];
    } else {
        CGRect bounds = [[UIScreen mainScreen] bounds];
        [adBanner setFrame:CGRectMake(0, bounds.size.height, adBanner.bounds.size.width, adBanner.bounds.size.height)];
    }
    [UIView commitAnimations];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionWillBegin object:self];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionDidFinish object:self];
}




#pragma mark - Tab Bar Controller Delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (_currentController == viewController) {
        return;
    }
    
    if ([tabBarController selectedIndex] == 2) {
        //If the user is selecting the mapview controller, we set _currentController to it
        _currentController = (UIViewController<BannerViewContainer> *)[((UINavigationController *)viewController).viewControllers objectAtIndex:0];
        
        if (adBanner.bannerLoaded) {
            //[_currentController hideBannerView:adBanner animated:NO];
            [_currentController showBannerView:adBanner animated:YES];
        } else {
            
        }
    } else {
        _currentController = nil;
    }
}


@end
