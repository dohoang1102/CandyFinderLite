//
//  TaggedLocation.m
//  barcodeTest2
//
//  Created by Devin Moss on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaggedLocation.h"

@implementation TaggedLocation

@synthesize coordinate;
@synthesize candyName = _candyName;
@synthesize locationName = _locationName;
@synthesize leftCalloutAccessoryView;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    
    if (self) {
        coordinate = coord;
    }
    
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    coordinate = newCoordinate;
}

- (NSString *)title {
    return _candyName;
}

- (NSString *)subtitle {
    return _locationName;
}

- (CLLocationCoordinate2D)coordinate {
    return coordinate;
}

@end
