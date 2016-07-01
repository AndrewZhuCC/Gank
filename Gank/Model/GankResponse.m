//
//  GankResponse.m
//  Gank
//
//  Created by 朱安智 on 16/6/28.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "GankResponse.h"

@interface GankResponse()
@property (strong, nonatomic) id responseObj;
@end

@implementation GankResponse

- (instancetype)initWithResponse:(id)responseObj {
    if (self = [super init]) {
        _responseObj = [responseObj copy];
    }
    return self;
}

- (NSArray<GankResult *> *)resultFromResponse {
    if ([_responseObj isKindOfClass:NSDictionary.class]) {
        if (![[_responseObj objectForKey:@"error"] boolValue]) {
            NSArray *dics = [_responseObj objectForKey:@"results"];
            if ([dics isKindOfClass:NSArray.class]) {
                NSMutableArray *result = NSMutableArray.new;
                for (NSDictionary *dic in dics) {
                    if ([dic isKindOfClass:NSDictionary.class]) {
                        GankResult *obj = [[GankResult alloc] initWithDictionary:dic];
                        [result addObject:obj];
                    }
                }
                return [result copy];
            }
        }
    }
    return nil;
}

- (GankDaily *)resultOfDaily {
    if ([_responseObj isKindOfClass:NSDictionary.class]) {
        if (![[_responseObj objectForKey:@"error"] boolValue]) {
            NSDictionary *tempResults = [_responseObj objectForKey:@"results"];
            NSArray *category = [_responseObj objectForKey:@"category"];
            
            NSMutableArray *mcategory = [category mutableCopy];
            NSString *fl = nil;
            for (NSString *key in mcategory) {
                if ([key isEqualToString:@"福利"]) {
                    fl = key;
                    break;
                }
            }
            
            if (fl) {
                [mcategory removeObject:fl];
                [mcategory insertObject:fl atIndex:0];
            }
            
            if ([tempResults isKindOfClass:[NSDictionary class]] && [category isKindOfClass:[NSArray class]]) {
                NSMutableDictionary *mresults = NSMutableDictionary.new;
                for (NSString *key in category) {
                    NSArray *gankresults = [tempResults objectForKey:key];
                    NSMutableArray *mganResults = NSMutableArray.new;
                    for (NSDictionary *dic in gankresults) {
                        GankResult *result = [[GankResult alloc] initWithDictionary:dic];
                        [mganResults addObject:result];
                    }
                    [mresults setObject:[mganResults copy] forKey:key];
                }
                GankDaily *daily = [[GankDaily alloc] initWithDictionary:@{@"category":category, @"results":[mresults copy]}];
                return daily;
            }
        }
    }
    return nil;
}

- (NSArray *)resultOfDaysHistory {
    if ([_responseObj isKindOfClass:NSDictionary.class]) {
        if (![[_responseObj objectForKey:@"error"] boolValue]) {
            NSArray *dics = [_responseObj objectForKey:@"results"];
            if ([dics isKindOfClass:NSArray.class]) {
                NSMutableArray *results = NSMutableArray.new;
                for (NSString *data in dics) {
                    NSString *date = [data stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
                    [results addObject:date];
                }
                return [results copy];
            }
        }
    }
    return nil;
}

@end
