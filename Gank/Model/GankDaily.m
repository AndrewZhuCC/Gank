//
//  GankDaily.m
//  Gank
//
//  Created by 朱安智 on 16/6/29.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "GankDaily.h"
#import "GankResult.h"

@interface GankDaily ()
@end

@implementation GankDaily

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        _category = [dic objectForKey:@"category"];
        _results = [dic objectForKey:@"results"];
        _timeStamp = [dic objectForKey:@"time"];
    }
    return self;
}

@end
