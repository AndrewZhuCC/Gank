//
//  GankResult.m
//  Gank
//
//  Created by 朱安智 on 16/6/27.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "GankResult.h"

@implementation GankResult

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        __id = [dic objectForKey:@"_id"];
        _type = [dic objectForKey:@"type"];
        _url = [NSURL URLWithString:[dic objectForKey:@"url"]];
        _who = [dic objectForKey:@"who"];
        _desc = [dic objectForKey:@"desc"];
    }
    return self;
}

@end
