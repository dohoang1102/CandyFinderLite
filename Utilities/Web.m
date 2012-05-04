//
//  Web.m
//  barcodeTest2
//
//  Created by Devin Moss on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Web.h"
#import "SynthesizeSingleton.h"
#import "SBJson.h"
#import "globals.h"
#import "UIDevice+IdentifierAddition.h"
#import "AppDelegate.h"

@implementation Web

#define USER_FOUND          200
#define INVALID_AUTH_TOKEN  404

@synthesize responseData;

SYNTHESIZE_SINGLETON_FOR_CLASS(Web);

- (id)init {
    self = [super init];
    
	if (self != nil) {
		responseData = [[NSMutableData alloc] init];
	}
    
	return self;
    
}

- (NSURLRequest *)searchSKURequest:(NSString *) sku {
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:SEARCH_SKU, sku]]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}

- (NSURLRequest *)searchNameRequest:(NSString *) candyName {
    return NULL;
}

-(void)sendPostToURL:(NSString *)url withData:(NSData *)data {
    //[[Web sharedWeb] performSelectorInBackground:@selector(postDataInBackground:) withObject:[NSArray arrayWithObjects:url, data, nil]];    
}

-(void)sendPostToURL:(NSString *)url withBody:(NSString *)body{
    url = [NSString stringWithFormat:@"%@%@", url, body];
    url = [self encodeStringForURL:url];
    
    [[Web sharedWeb] performSelectorInBackground:@selector(postRequestInBackground:) withObject:url];
}

-(NSData *)getPostDataFromString:(NSString *)body {
    NSMutableData *postData = [NSMutableData data];
    body = [self encodeStringForURL:body];
    [postData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    return postData;
}

-(NSString *)encodeStringForURL:(NSString *)url{
    return [[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
}

-(void)recordAppHit {
    NSString *url = [NSString stringWithFormat:APP_HIT, [[UIDevice currentDevice] uniqueDeviceIdentifier]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[Web sharedWeb] performSelectorInBackground:@selector(postRequestInBackground:) withObject:url];
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


@end
