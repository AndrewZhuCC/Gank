//
//  GankDaily.m
//  Gank
//
//  Created by 朱安智 on 16/6/29.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "GankDaily.h"

@interface GankDaily ()
@end

@implementation GankDaily

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        _title = [dic objectForKey:@"title"];
        __id = [dic objectForKey:@"_id"];
        _content = [dic objectForKey:@"content"];
        NSString *dates = [dic objectForKey:@"publishedAt"];
        _timeStamp = [[dates stringByReplacingOccurrencesOfString:@"T" withString:@" "] stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    }
    return self;
}

@end
