//
//  Exercise.h
//  Samson
//
//  Created by Jason Peebles on 2012-10-27.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Workout;

@interface Exercise : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sortValue;
@property (nonatomic, retain) NSNumber * measurementFlags;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSSet *workouts;
@end

@interface Exercise (CoreDataGeneratedAccessors)

- (void)addWorkoutsObject:(Workout *)value;
- (void)removeWorkoutsObject:(Workout *)value;
- (void)addWorkouts:(NSSet *)values;
- (void)removeWorkouts:(NSSet *)values;

@end
