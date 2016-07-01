//
//  CoreDataManager.h
//  Gank
//
//  Created by 朱安智 on 16/7/1.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "GankResultDB+CoreDataProperties.h"

@class GankResult;

@interface CoreDataManager : NSObject

@property (strong, nonatomic) NSManagedObjectModel *managedModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectContext *managedContext;

+ (CoreDataManager *)instance;

- (BOOL)insertGankResultToDB:(GankResult *)result;
- (BOOL)removeGankResultFromDB:(GankResult *)result;
- (NSArray <GankResult *> *)entitysByType:(NSString *)type;

@end
