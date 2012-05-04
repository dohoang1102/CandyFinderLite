//
//  Web.h
//  barcodeTest2
//
//  Created by Devin Moss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/** 
 This class is to be used as a generic POSTer of objects.
 Any view controllers that need to POST an object and not worry about handling the response
 get sent here (for example, when a user searches for a candy and clicks to display locations on the map,
 a POST of their search parameters is sent to the server)
 
 This class also provides some helpers, like searchSKURequest and searchNameRequest,
 which are used frequently by various controllers.
**/

#import <Foundation/Foundation.h>
#import "globals.h"

@interface Web : NSObject {
    NSMutableData *responseData;
}

@property (nonatomic, strong) NSMutableData *responseData;

- (NSURLRequest *)searchSKURequest:(NSString *) sku;
- (NSURLRequest *)searchNameRequest:(NSString *) candyName;
//- (void)searchIngredient:(NSString *) ingredient;

-(void)sendPostToURL:(NSString *)url withData:(NSData *)data;
-(void)sendPostToURL:(NSString *)url withBody:(NSString *)body;
-(NSString *)encodeStringForURL:(NSString *)url;
-(NSData *)getPostDataFromString:(NSString *)body;
-(void)recordAppHit;
-(void)postRequestInBackground:(NSString *)url;
-(void)getUserInfo:(NSString *)authentication_token;

+ (Web *)sharedWeb;

@end
