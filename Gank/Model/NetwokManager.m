//
//  NetwokManager.m
//  Gank
//
//  Created by 朱安智 on 16/6/29.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "NetwokManager.h"

@implementation NetwokManager

+ (void)daysOfHistoryWithBlock:(DaysOfHistoryResult)block {
    __block typeof(block) bblock = block;
    NSLog(@"start get days");
    [AFHTTPSessionManager.manager GET:@"http://gank.io/api/day/history" parameters:nil progress:^(NSProgress *progress) {
        NSLog(@"days progress: %@", progress.localizedAdditionalDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        GankResponse *response = [[GankResponse alloc]initWithResponse:responseObject];
        NSArray *result = [response resultOfDaysHistory];
        bblock(result, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        bblock(nil, error);
    }];
}

@end
