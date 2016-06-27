//
//  GankResult.h
//  Gank
//
//  Created by 朱安智 on 16/6/27.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GankResult : NSObject

@property (copy, nonatomic) NSString *_id;
@property (copy, nonatomic) NSString *type;
@property (strong, nonatomic) NSURL *url;
@property (copy, nonatomic) NSString *who;

@end
