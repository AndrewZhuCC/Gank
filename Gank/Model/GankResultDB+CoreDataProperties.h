//
//  GankResultDB+CoreDataProperties.h
//  Gank
//
//  Created by 朱安智 on 16/7/1.
//  Copyright © 2016年 朱安智. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GankResultDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface GankResultDB (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSURL *url;
@property (nullable, nonatomic, retain) NSString *who;
@property (nullable, nonatomic, retain) NSString *desc;

@end

NS_ASSUME_NONNULL_END
