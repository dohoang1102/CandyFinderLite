//
//  Candy.h
//  CandyFinder
//
//  Created by Devin Moss on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Candy : NSObject {
    NSString *candy_id;
    NSString *title;
    NSString *subtitle;
    NSString *sku;
    NSDate *created_at;
    NSDate *updated_at;
}

@property (nonatomic, strong) NSString *candy_id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *sku;
@property (nonatomic, strong) NSDate *created_at;
@property (nonatomic, strong) NSDate *updated_at;

+(Candy *)candyFromDictionary:(NSDictionary *)item;
+(NSMutableArray *)unserialize:(NSArray *)items;
+(NSData *)serialize:(NSArray *)items;
+(NSDictionary *)dictionaryFromCandy:(Candy *)candy;

@end
