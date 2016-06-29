//
//  NetwokManager.h
//  Gank
//
//  Created by 朱安智 on 16/6/29.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GankResponse.h"
#import <AFNetworking/AFNetworking.h>

typedef void(^DaysOfHistoryResult)(NSArray *result, NSError *error);

@interface NetwokManager : NSObject
+ (void)daysOfHistoryWithBlock:(DaysOfHistoryResult)block;
@end
