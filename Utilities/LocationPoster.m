//
//  LocationPoster.m
//  CandyFinder
//
//  Created by Devin Moss on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationPoster.h"
#import "SynthesizeSingleton.h"
#import "SBJson.h"
#import "Web.h"
#import "globals.h"
#import "AppDelegate.h"
#import "UIDevice+IdentifierAddition.h"

@implementation LocationPoster

@synthesize currentLocation, responseData;

SYNTHESIZE_SINGLETON_FOR_CLASS(LocationPoster);

- (id)init {
    self = [super init];
    
	if (self != nil) {
		responseData = [[NSMutableData alloc] init];
	}
    
	return self;
    
}

-(void)postLocation:(Location *)location {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSData *data = [[Web sharedWeb] getPostDataFromString:[NSString stringWithFormat:LOCATION_PARAMETERS, location.lat, location.lon, location.name, location.address, location.city, location.state, location.zip, app.authenticity_token]];
    NSString *mString = [NSString stringWithFormat:LOCATION_PARAMETERS, location.lat, location.lon, location.name, location.address, location.city, location.state, location.zip, app.authenticity_token];
    
    [[LocationPoster sharedLocationPoster] performSelectorInBackground:@selector(postRequestInBackground:) withObject:[[Web sharedWeb] encodeStringForURL:mString]];
}

-(void)putLocation:(Location *)location {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableString *mString = [NSMutableString stringWithFormat:UPDATE_LOCATION, location.location_id];
    [mString appendFormat:LOCATION_PARAMETERS, location.lat, location.lon, location.name, location.address, location.city, location.state, location.zip, app.authenticity_token];
    
    [[LocationPoster sharedLocationPoster] performSelectorInBackground:@selector(putRequestInBackground:) withObject:[[Web sharedWeb] encodeStringForURL:mString]];
}

- (void) locationWithAnnotation:(Location *)location {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableString *mString = [NSMutableString stringWithFormat:LOCATION_WITH_ANNOTATION];
    [mString appendFormat:TAG_PARAMETERS, location.lat, location.lon, location.name, location.ext_id, location.location_id, location.ext_reference, app.authenticity_token, app.currentCandy.candy_id, app.currentCandy.sku, [[UIDevice currentDevice] uniqueDeviceIdentifier]];
    
    [[LocationPoster sharedLocationPoster] performSelectorInBackground:@selector(postRequestInBackground:) withObject:[[Web sharedWeb] encodeStringForURL:mString]];
}

- (void) postAnnotationForCandy:(Candy *)candy {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableString *mString = [NSMutableString stringWithFormat:LOCATION_WITH_ANNOTATION];
    [mString appendFormat:TAG_PARAMETERS, currentLocation.lat, currentLocation.lon, currentLocation.name, currentLocation.ext_id, currentLocation.location_id, currentLocation.ext_reference, app.authenticity_token, candy.candy_id, candy.sku, [[UIDevice currentDevice] uniqueDeviceIdentifier]];
    
    [[LocationPoster sharedLocationPoster] performSelectorInBackground:@selector(postRequestInBackground:) withObject:[[Web sharedWeb] encodeStringForURL:mString]];
}

- (void) updateAnnotationLocation:(Location *)theLocation withCandy:(Candy *)candy {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableString *mString = [NSMutableString stringWithFormat:LOCATION_WITH_ANNOTATION];
    [mString appendFormat:TAG_PARAMETERS, theLocation.lat, theLocation.lon, theLocation.name, theLocation.ext_id, theLocation.location_id, theLocation.ext_reference, app.authenticity_token, candy.candy_id, candy.sku, [[UIDevice currentDevice] uniqueDeviceIdentifier]];
    
    [[LocationPoster sharedLocationPoster] performSelectorInBackground:@selector(postRequestInBackground:) withObject:[[Web sharedWeb] encodeStringForURL:mString]];
}

- (void) postRequestInBackground:(NSString *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:url]
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLResponse *response;
    
    NSError *error;
    
    
    //send it and forget it
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

- (void) putRequestInBackground:(NSString *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:url]
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:10];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLResponse *response;
    
    NSError *error;
    
    
    //send it and forget it
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

@end
