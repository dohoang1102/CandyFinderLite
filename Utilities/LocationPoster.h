//
//  LocationPoster.h
//  CandyFinder
//
//  Created by Devin Moss on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "Candy.h"

@interface LocationPoster : NSObject {
    Location *currentLocation;
    NSMutableData *responseData;
}

@property (nonatomic, strong) Location *currentLocation;//This is the last location that the user interacted with
@property (nonatomic, strong) NSMutableData *responseData;

-(void)postLocation:(Location *)location;
-(void)putLocation:(Location *)location;

/**
 Creates a location if one doesn't already exist.
 Also creates an annotation at that location.
 If both already exist, database isn't updated.
 **/
-(void)locationWithAnnotation:(Location *)location;

/** 
 This is an alias for locationWithAnnotation
 but it uses self.currentLocation, so no parameters are required
 **/
-(void)postAnnotationForCandy:(Candy *)candy;

/**
 Sends off a POST in a background thread.
 Usually the object being POSTed is an annotation, like when the user tags a candy at a particular location
 **/
-(void)postRequestInBackground:(NSString *)url;

/**
 Sends off a PUT in a background thread.
 Usually the object being PUTed is an annotation, and the timestamp on the annotation is updated
 **/
-(void)putRequestInBackground:(NSString *)url;

/**
 Called by AnnotationDetailsViewController
 when a user clicks "update," meaning they've seen the candy that a previous user tagged 
 and are confirming its existence at that location
**/
- (void) updateAnnotationLocation:(Location *)location withCandy:(Candy *)candy;

+ (LocationPoster *)sharedLocationPoster;

@end
