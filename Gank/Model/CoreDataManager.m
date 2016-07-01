//
//  CoreDataManager.m
//  Gank
//
//  Created by 朱安智 on 16/7/1.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "CoreDataManager.h"
#import "GankResponse.h"

@implementation CoreDataManager

+ (CoreDataManager *)instance {
    static CoreDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CoreDataManager alloc]init];
    });
    return instance;
}

- (void)dealloc {
    self.managedModel = nil;
    self.persistentStoreCoordinator = nil;
    self.managedContext = nil;
}

- (NSManagedObjectModel *)managedModel {
    if (_managedModel == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
        NSURL *url = [NSURL fileURLWithPath:path];
        _managedModel = [[NSManagedObjectModel alloc]initWithContentsOfURL:url];
    }
    return _managedModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator == nil) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:self.managedModel];
        NSURL *documentURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [documentURL URLByAppendingPathComponent:@"Model.sqlite"];
        
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedContext {
    if (_managedContext == nil) {
        _managedContext = [[NSManagedObjectContext alloc] init];
        _managedContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _managedContext;
}

#pragma mark - Public Methods

+ (BOOL)insertGankResultToDB:(GankResult *)result {
    if (!result) {
        return NO;
    }
    
    CoreDataManager *instance = [self instance];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:@"GankResultDB" inManagedObjectContext:instance.managedContext];
    GankResultDB *entityToInsert = [[GankResultDB alloc]initWithEntity:description insertIntoManagedObjectContext:instance.managedContext];
    entityToInsert.id = result._id;
    entityToInsert.type = result.type;
    entityToInsert.desc = result.desc;
    entityToInsert.url = result.url;
    entityToInsert.who = result.who;
    
    return YES;
}

+ (BOOL)removeGankResultFromDB:(GankResult *)result {
    if (!result) {
        return NO;
    }
    
    CoreDataManager *instance = [self instance];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"GankResultDB"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", result._id]];
    
    NSError *error = nil;
    NSArray *objs = [instance.managedContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%s error:%@", __func__, error);
        return NO;
    }
    
    if (objs.count > 0) {
        GankResultDB *entity = [objs firstObject];
        [instance.managedContext deleteObject:entity];
        return YES;
    }
    return NO;
}

+ (GankResult *)entityByID:(NSString *)ID {
    if (ID.length <= 0) {
        return nil;
    }
    
    CoreDataManager *instance = [self instance];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"GankResultDB"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", ID]];
    NSError *error = nil;
    NSArray *results = [instance.managedContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%s error:%@", __func__, error);
        return nil;
    }
    if (results.count > 0) {
        GankResultDB *dbentity = [results firstObject];
        return [[GankResult alloc] initWithGankResultDB:dbentity];
    }
    return nil;
}

+ (NSArray <GankResult *> *)entitysByType:(NSString *)type {
    BOOL needPredicate = YES;
    if (!type || type.length <= 0) {
        needPredicate = NO;
    }
    
    CoreDataManager *instance = [self instance];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"GankResultDB"];
    if (needPredicate) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"type == %@" ,type]];
    }
    NSError *error = nil;
    NSArray *results = [instance.managedContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%s error:%@", __func__, error);
        return nil;
    }
    
    NSMutableArray *returns = NSMutableArray.new;
    for (GankResultDB *dbentity in results) {
        GankResult *entity = [[GankResult alloc]initWithGankResultDB:dbentity];
        [returns addObject:entity];
    }
    
    return [returns copy];
}

@end
