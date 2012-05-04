//
//  Location.m
//  CandyFinder
//
//  Created by Devin Moss on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Location.h"
#import "LocationPoster.h"

double const kRadiansPerDegree = 0.017453293;
double const kEarthsRadius = 6371.0;
double const kKmtoMiles = 0.621371192;
double const kMilestoKm = 1.609344;

@implementation Location

@synthesize name = _name;
@synthesize location_id, lat, lon, coordinate, address, city, state, zip;
@synthesize ext_id, ext_reference, ext_url, phone_formatted, phone_international, distance;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    
    if (self) {
        coordinate = coord;
        self.lat = [NSNumber numberWithDouble:coord.latitude];
        self.lon = [NSNumber numberWithDouble:coord.longitude];
    }
    
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    coordinate = newCoordinate;
    self.lat = [NSNumber numberWithDouble:newCoordinate.latitude];
    self.lon = [NSNumber numberWithDouble:newCoordinate.longitude];
    
    //Update address with geocoding
    
    //Update the new location to the database
    [[LocationPoster sharedLocationPoster] putLocation:self];
}

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return [NSString stringWithFormat:@"%@ %@, %@, %@", address, city, state, zip];
}

- (CLLocationCoordinate2D)coordinate {
    return coordinate;
}

-(double)distanceFromLat:(CLLocationDegrees)lat2 andLon:(CLLocationDegrees)lon2 {
    double d = acos((sin([lat doubleValue]) * sin(lat2)) + (cos([lat doubleValue]) * cos(lat2) * cos(lon2 - [lon doubleValue]))) * kEarthsRadius;
    return (d * kRadiansPerDegree) * kKmtoMiles; //Distance in miles
}

//=========== Class Methods =========================
//***************************************************
+(Location *)locationFromDictionary:(NSDictionary *)item {
    CLLocationCoordinate2D c;
    c.longitude = [[item objectForKey:@"lon"] doubleValue];
    c.latitude = [[item objectForKey:@"lat"] doubleValue];
    Location *location = [[Location alloc] initWithLocation:c];
    location.name = [item objectForKey:@"name"];
    location.location_id = [NSString stringWithFormat:@"%@", [item objectForKey:@"id"]];
    location.lon = [NSNumber numberWithDouble:[[item objectForKey:@"lon"] doubleValue]];
    location.lat = [NSNumber numberWithDouble:[[item objectForKey:@"lat"] doubleValue]];
    location.address = [NSString stringWithFormat:@"%@", [item objectForKey:@"address"]];
    location.city = [NSString stringWithFormat:@"%@", [item objectForKey:@"city"]];
    location.state = [NSString stringWithFormat:@"%@", [item objectForKey:@"state"]];
    location.zip = [NSString stringWithFormat:@"%@", [item objectForKey:@"zip"]];
    location.ext_id = [NSString stringWithFormat:@"%@", [item objectForKey:@"ext_id"]];
    location.ext_reference = [NSString stringWithFormat:@"%@", [item objectForKey:@"ext_id"]];
    location.ext_url = [NSString stringWithFormat:@"%@", [item objectForKey:@"ext_url"]];
    location.phone_formatted = [NSString stringWithFormat:@"%@", [item objectForKey:@"phone_formatted"]];
    location.phone_international = [NSString stringWithFormat:@"%@", [item objectForKey:@"phone_international"]];
    
    return location;
}

+(Location *)locationFromPlace:(NSDictionary *)item {
    NSDictionary *location = [(NSDictionary *)[item objectForKey:@"geometry"] objectForKey:@"location"];
    
    Location *currentLocation = [[Location alloc] init];
    currentLocation.lat = [location objectForKey:@"lat"];
    currentLocation.lon = [location objectForKey:@"lng"];
    NSArray *address = [[item objectForKey:@"vicinity"] componentsSeparatedByString:@", "];
    if([address count] > 1){
        currentLocation.address = [address objectAtIndex:0];
        currentLocation.city = [address objectAtIndex:1];
    } else {
        currentLocation.city = [address objectAtIndex:0];
    }
    currentLocation.ext_id = [item objectForKey:@"id"];
    currentLocation.ext_reference = [item objectForKey:@"reference"];
    currentLocation.name = [item objectForKey:@"name"];
    
    return currentLocation;
}

+(MKCoordinateRegion)calculateRegionFromLocations:(NSArray *)locations {
    
    Location *temp = [locations objectAtIndex:0];
    double maxLat = temp.coordinate.latitude;
    double minLat = temp.coordinate.latitude;
    double maxLon = temp.coordinate.longitude;
    double minLon = temp.coordinate.longitude;
    
    for(int i = 0; i < [locations count]; i++) {
        //if([[locations objectAtIndex:i] isKindOfClass:[Location class]]) {
            Location *loc = [locations objectAtIndex:i];
            double lat = loc.coordinate.latitude;
            double lon = loc.coordinate.longitude;
            if(lat > maxLat){
                maxLat = lat;
            } else if(lat < minLat) {
                minLat = lat;
            }
            if(lon > maxLon){
                maxLon = lon;
            } else if(lon < minLon) {
                minLon = lon;
            }
        //}
    }
    
    // FIND REGION
    MKCoordinateSpan locationSpan;
    locationSpan.latitudeDelta = maxLat - minLat;
    locationSpan.longitudeDelta = maxLon - minLon;
    
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLat + maxLat)/2, (minLon + maxLon)/2);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(center, locationSpan);
    
    return viewRegion;
    
    /*
    MKMapRect zoomRect = MKMapRectNull;
    for(int i = 0; i < [locations count]; i++)
    {
        Location *loc = [locations objectAtIndex:i];
        //if([[locations objectAtIndex:i] isKindOfClass:[Location class]]) {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(loc.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            if (MKMapRectIsNull(zoomRect)) {
                zoomRect = pointRect;
            } else {
                zoomRect = MKMapRectUnion(zoomRect, pointRect);
            }
        //}
    }

    return zoomRect;*/
}

+(double)metersBetweenMinLat:(double)lat1 andMaxLat:(double)lat2 {
    double d = acos((sin(lat1) * sin(lat2)) + (cos(lat1) * cos(lat2) * cos(0 - 0))) * kEarthsRadius;
    return (d * kRadiansPerDegree) * 1000;
}

+(double)metersBetweenMinLon:(double)lon1 andMaxLon:(double)lon2 {
    double d = acos((sin(0) * sin(0)) + (cos(0) * cos(0) * cos(lon2 - lon1))) * kEarthsRadius;
    return (d * kRadiansPerDegree) * 1000;
}

@end
