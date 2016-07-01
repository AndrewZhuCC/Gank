//
//  GankURLTransformer.m
//  Gank
//
//  Created by 朱安智 on 16/7/1.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "GankURLTransformer.h"

@implementation GankURLTransformer

+ (Class)transformedValueClass {
    return [NSURL class];
}

- (id)transformedValue:(id)value {
    if (!value) {
        return nil;
    }
    if ([value isKindOfClass:NSData.class]) {
        return value;
    }
    NSURL *url = value;
    NSString *urls = [url absoluteString];
    return [urls dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)reverseTransformedValue:(id)value {
    NSData *data = value;
    return [NSURL URLWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

@end
