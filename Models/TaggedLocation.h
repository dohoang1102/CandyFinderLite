//
//  TaggedLocation.h
//  barcodeTest2
//
//  Created by Devin Moss on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@interface TaggedLocation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *_candyName;
    NSString *_locationName;
    UIView *leftCalloutAccessoryView;
    
    //NSNumber *lattitude;
    //NSNumber *longitude;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy) NSString *candyName;
@property (copy) NSString *locationName;
@property (nonatomic, strong) UIView *leftCalloutAccessoryView;
//@property (nonatomic, strong) NSNumber *lattitude;
//@property (nonatomic, strong) NSNumber *longitude;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;

@end
