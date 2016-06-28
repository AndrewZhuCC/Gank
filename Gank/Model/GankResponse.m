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

@end
