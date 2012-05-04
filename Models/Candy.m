//
//  Candy.m
//  CandyFinder
//
//  Created by Devin Moss on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Candy.h"

@implementation Candy

@synthesize candy_id, title, subtitle, sku, created_at, updated_at;


//=========== Class Methods =========================
//***************************************************

+(Candy *)candyFromDictionary:(NSDictionary *)item {
    Candy *c = [[Candy alloc] init];
    c.candy_id = [NSString stringWithFormat:@"%@", [item objectForKey:@"id"]];
    c.sku = [item objectForKey:@"sku"];
    c.title = [item objectForKey:@"title"];
    c.subtitle = [item objectForKey:@"subtitle"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:SS'Z'"];
    c.created_at = [dateFormat dateFromString:[item objectForKey:@"created_at"]];
    c.updated_at = [dateFormat dateFromString:[item objectForKey:@"updated_at"]];
    return c;
}

+(NSMutableArray *)unserialize:(NSArray *)items {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dict in items) {
        //should be a candy in dictionary form
        Candy *c = [[Candy alloc] init];
        c.title = [dict objectForKey:@"title"];
        c.subtitle = [dict objectForKey:@"subtitle"];
        c.sku = [dict objectForKey:@"sku"];
        c.candy_id = [dict objectForKey:@"candy_id"];
        c.created_at = [dict objectForKey:@"created_at"];
        c.updated_at = [dict objectForKey:@"updated_at"];
        
        [array addObject:c];
    }
    
    return array;
}

+(NSData *)serialize:(NSArray *)items {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i = 0; i < [items count]; i++) {
        Candy *c = (Candy *)[items objectAtIndex:i];
        NSDictionary *dict = [self dictionaryFromCandy:c];
        [array addObject:dict];
    }
    
    NSString *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:array
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    
    if(plistData) {
        return plistData;
    }
    
    else {
        NSLog(@"%@", error);
    }
    
    return nil;
}

+(NSDictionary *)dictionaryFromCandy:(Candy *)candy {
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:candy.candy_id, candy.title, candy.subtitle, candy.sku, candy.created_at, candy.updated_at, nil]
                                       forKeys:[NSArray arrayWithObjects:@"candy_id", @"title", @"subtitle", @"sku", @"created_at", @"updated_at", nil]];
}

@end
