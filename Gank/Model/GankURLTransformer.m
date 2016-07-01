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
    return [url dataRepresentation];
}

- (id)reverseTransformedValue:(id)value {
    return [NSURL URLWithDataRepresentation:value relativeToURL:nil];
}

@end
