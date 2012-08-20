//
//  WeightExercise.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractExercise.h"

@class SetWorkout, WeightInterval;

@interface WeightExercise : AbstractExercise

@property (nonatomic, strong) NSSet *intervals;
@property (nonatomic, strong) NSSet *workouts;
@end

@interface WeightExercise (CoreDataGeneratedAccessors)

- (void)addIntervalsObject:(WeightInterval *)value;
- (void)removeIntervalsObject:(WeightInterval *)value;
- (void)addIntervals:(NSSet *)values;
- (void)removeIntervals:(NSSet *)values;

- (void)addWorkoutsObject:(SetWorkout *)value;
- (void)removeWorkoutsObject:(SetWorkout *)value;
- (void)addWorkouts:(NSSet *)values;
- (void)removeWorkouts:(NSSet *)values;

@end
