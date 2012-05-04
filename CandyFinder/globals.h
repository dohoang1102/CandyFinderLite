//
//  globals.h
//  barcodeTest2
//
//  Created by Devin Moss on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef barcodeTest2_globals_h
#define barcodeTest2_globals_h

#define DEBUG_MODE                  1 //Shows debug messages in console when set to 1
#define NEW_ANNOTATION_FRAME        CGRectMake(15, 15, 640, 30)//x, y, width, height
#define SCANNER_OVERLAY_FRAME       CGRectMake(0, 0, 320, 480)

//Colors
#define DARK_PINK                   [UIColor colorWithRed:0.631 green:0.467 blue:0.631 alpha:1.0] //Darker pink
#define LIGHT_PINK                  [UIColor colorWithRed:0.969 green:0.9098 blue:0.937 alpha:1.0] //Super light pink
#define CHOCOLATE                   [UIColor colorWithRed:0.443 green:0.298 blue:0.2078 alpha:1.0] //Scanner button
#define DARK_CHOCOLATE              [UIColor colorWithRed:0.196 green:0.094 blue:0.031 alpha:1.0] //Scanner button
#define DARK_RED                    [UIColor colorWithRed:0.784 green:0.294 blue:0.294 alpha:1.0]
#define BRIGHT_RED                  [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.4]
#define DARK_BLUE                   [UIColor colorWithRed:0.76 green:0.87 blue:1.0 alpha:1.0]//Used with table rows
#define LIGHT_BLUE                  [UIColor colorWithRed:0.945 green:0.969 blue:1.0 alpha:1.0]//Used with table rows

//GET methods
#define SEARCH_NAME                 @"http://candyfinder.net/candies/name/%@"
#define SEARCH_SKU                  @"http://candyfinder.net/candies/sku/%@"
#define LOCATIONS_FROM_CANDY        @"http://candyfinder.net/locations/from_candy/%@?lat=%@&lon=%@"
#define CANDIES_FROM_LOCATION       @"http://candyfinder.net/candies/from_location/%@"
#define LOCATIONS_FROM_REGION       @"http://candyfinder.net/locations/from_region?minLon=%@&maxLon=%@&minLat=%@&maxLat=%@"
#define LOCATIONS_FROM_SEARCH       @"http://candyfinder.net/locations/from_search/%@?lat=%f&lon=%f"
#define LOCATIONS_FROM_NAME         @"http://candyfinder.net/locations/from_name/%@?lat=%f&lon=%f"

//POST methods
#define CREATE_LOCATION             @"http://candyfinder.net/locations?"
#define CREATE_ANNOTATION           @"http://candyfinder.net/annotations?"
#define CREATE_CANDY                @"http://candyfinder.net/candies?"
#define CREATE_SEARCH               @"http://candyfinder.net/searches?"
#define LOCATION_WITH_ANNOTATION    @"http://candyfinder.net/locations/create_with_annotation?"
#define APP_HIT                     @"http://candyfinder.net/home/record_hit/%@"

//PUT methods
#define UPDATE_LOCATION             @"http://candyfinder.net/locations/%@?"
#define UPDATE_CANDY                @"http://candyfinder.net/candies/%@?"
#define UPDATE_ANNOTATION           @"http://candyfinder.net/annotations/%@?"
#define UPDATE_SEARCH               @"http://candyfinder.net/searches/%@?"

//POST & PUT Parameters
#define ANNOTATION_PARAMETERS       @"annotation[candy_id]=%@&annotation[candy_sku]=%@&annotation[device_id]=%@&annotation[location_id]=%@&authenticity_token=%@"
#define LOCATION_PARAMETERS         @"location[lat]=%@&location[lon]=%@&location[name]=%@&location[address]=%@&location[city]=%@&location[state]=%@&location[zip]=%@&authenticity_token=%@"
#define CANDY_PARAMETERS            @"candy[sku]=%@&candy[title]=%@&candy[subtitle]=%@&authenticity_token=%@"
#define SEARCH_PARAMETERS           @"search[candy_id]=%@&search[device_id]=%@&search[search_term]=%@&authenticity_token=%@"
#define TAG_PARAMETERS              @"location[lat]=%@&location[lon]=%@&location[name]=%@&location[ext_id]=%@&location[id]=%@&location[ext_reference]=%@&authenticity_token=%@&candy_id=%@&candy_sku=%@&device_id=%@"

//Login, Logout, and Register
#define LOGIN_PARAMETERS            @"http://www.candyfinder.net/mobile/login?email=%@&password=%@"
#define LOGOUT_PARAMETERS           @"http://www.candyfinder.net/mobile/logout/%@"
#define GET_USER                    @"http://www.candyfinder.net/mobile/user/%@"

//Google Geocoding
#define FIND_ADDRESS                @"https://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true"
#define FIND_LATLON                 @"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true"

//MapKit Labels
#define ALL_LOCATIONS               @"Showing All Locations Near You"
#define CANDY_LOCATIONS             @"Showing %i %@ locations"
#define LABEL_SEARCH_LOCATIONS      @"Showing Location results for '%@'"

//Google Places API
#define PLACES_URL                  @"https://maps.googleapis.com/maps/api/place/search/json?location=%@,%@&radius=%@&types=%@&sensor=true&key=%@"
#define PLACES_RADIUS               @"1600"
#define PLACES_TYPES                @"gas_station|grocery_or_supermarket|liquor_store|shopping_mall|convenience_store"
#define PLACES_KEY                  @"AIzaSyB7Px85Mowk_a-S05aVqfvnzsDX98qLjYA"

//UITableViewCell Customization
#define MAP_LABEL                   @"Map"
#define MAP_LABEL_TAG               1

//Google Analytics
//Events
#define SEARCH                      @"search"
#define TAG                         @"tag"
#define CANDIES_SEARCHED            @"candies_searched"
#define CANDIES_TAGGED              @"candies_tagged"
#define NEW_CANDY                   @"new_candy"

//Actions
#define SEARCH_START_TEXT           @"search_start_text"  //When user touches the searchbar (searchbar becomes first responder)
#define SEARCH_START_SCAN           @"search_start_scan"  //When user clicks "Scanner"
#define SEARCH_ITEM_SCANNED         @"search_item_scanned" //When the scanner takes a picture
#define CANDY_NOT_FOUND             @"candy_not_found" //When no search results are found
#define SEARCH_SCAN_TOUCHED         @"search_touched_scan" //When the user selects a row after searching
#define SEARCH_TEXT_TOUCHED         @"search_touched_text" //same as above
#define SEARCH_HISTORY_TOUCHED      @"search_touched_history"
#define TAG_START_TEXT              @"tag_start_text"
#define TAG_START_SCAN              @"tag_start_scan"
#define TAG_ITEM_SCANNED            @"tag_item_scanned"
#define TAG_SCAN_TOUCHED            @"tag_touched_scan"
#define TAG_TEXT_TOUCHED            @"tag_touched_text"
#define SCAN_TAGGED                 @"tagged_scan" //When user selects "Yes" from tag confirmation action sheet
#define TEXT_TAGGED                 @"tagged_text" //same as above
#define SEARCH_SCAN_CANCEL          @"search_scan_cancelled" //when user hits "cancel" on scanner
#define TAG_SCAN_CANCEL             @"tag_scan_cancelled"
#define LOCATION_TOUCHED            @"location_touched" //when user selects his/her location from places controller
#define TAG_ADD_BUTTON              @"tag_add_candy"    //when no search results are found and user clicks "add new candy"
#define SEARCH_ADD_BUTTON           @"search_add_candy"

//Flury Analytics
#define FLURRY_API_KEY              @"21IR5FRS9WPYGT2ZX97H"

#endif
