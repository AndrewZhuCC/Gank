//
//  GankResult.m
//  Gank
//
//  Created by 朱安智 on 16/6/27.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "GankResult.h"
#import "GankResultDB+CoreDataProperties.h"

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

- (instancetype)initWithGankResultDB:(GankResultDB *)entity {
    if (self = [super init]) {
        __id = entity.id;
        _type = entity.type;
        _url = entity.url;
        _who = entity.who;
        _desc = entity.desc;
    }
    return self;
}

@end
