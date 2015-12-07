//
//  Person+CoreDataProperties.h
//  CoreData_pro
//
//  Created by 沈红榜 on 15/12/4.
//  Copyright © 2015年 沈红榜. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *age;
@property (nullable, nonatomic, retain) NSString *gender;
@property (nullable, nonatomic, retain) NSNumber *kk;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *score;
@property (nullable, nonatomic, retain) NSString *test;
@property (nullable, nonatomic, retain) NSNumber *time;
@property (nullable, nonatomic, retain) NSNumber *six;

@end

NS_ASSUME_NONNULL_END
