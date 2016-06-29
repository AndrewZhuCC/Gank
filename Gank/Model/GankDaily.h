//
//  GankDaily.h
//  Gank
//
//  Created by 朱安智 on 16/6/29.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GankResult;

@interface GankDaily : NSObject
@property (copy, nonatomic) NSArray *category;
@property (copy, nonatomic) NSDictionary<NSString *, NSArray<GankResult *> *> *results;
@property (copy, nonatomic) NSString *timeStamp;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
