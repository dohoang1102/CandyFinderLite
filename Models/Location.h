//
//  Location.h
//  CandyFinder
//
//  Created by Devin Moss on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@interface Location : NSObject <MKAnnotation> {
    NSString *_name;
    NSNumber *lat;
    NSNumber *lon;
    NSString *location_id;
    CLLocationCoordinate2D coordinate;
    NSString *address;
    NSString *city;
    NSString *state;
    NSString *zip;
    NSString *ext_id;
    NSString *ext_reference;
    NSString *ext_url;
    NSString *phone_formatted;
    NSString *phone_international;
    NSString *ext_image_url;
    NSString *local_image_url;
    double distance;
}

@property (copy) NSString *name;
@property (nonatomic, strong) NSString *location_id;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *ext_id;
@property (nonatomic, strong) NSString *ext_reference;
@property (nonatomic, strong) NSString *ext_url;
@property (nonatomic, strong) NSString *phone_formatted;
@property (nonatomic, strong) NSString *phone_international;
@property (nonatomic, strong) NSString *ext_image_url;
@property (nonatomic, strong) NSString *local_image_url;
@property (nonatomic) double distance; //Describes distance from user's current location (calculated at run-time)

- (id)initWithLocation:(CLLocationCoordinate2D)coord;
-(double)distanceFromLat:(CLLocationDegrees)lat andLon:(CLLocationDegrees)lon;

+(Location *)locationFromDictionary:(NSDictionary *)item;
+(Location *)locationFromPlace:(NSDictionary *)item;
+(double)metersBetweenMinLat:(double)lat1 andMaxLat:(double)lat2;
+(double)metersBetweenMinLon:(double)lon1 andMaxLon:(double)lon2;
+(MKCoordinateRegion)calculateRegionFromLocations:(NSArray *)locations;

@end

extern double const kRadiansPerDegree;
extern double const kEarthsRadius;
extern double const kKmtoMiles;
extern double const kMilestoKm;