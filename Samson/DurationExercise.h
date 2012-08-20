//
//  DurationExercise.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractExercise.h"

@class DurationInterval, DurationWorkout;

@interface DurationExercise : AbstractExercise

@property (nonatomic, strong) NSSet *intervals;
@property (nonatomic, strong) NSSet *workouts;
@end

@interface DurationExercise (CoreDataGeneratedAccessors)

- (void)addIntervalsObject:(DurationInterval *)value;
- (void)removeIntervalsObject:(DurationInterval *)value;
- (void)addIntervals:(NSSet *)values;
- (void)removeIntervals:(NSSet *)values;

- (void)addWorkoutsObject:(DurationWorkout *)value;
- (void)removeWorkoutsObject:(DurationWorkout *)value;
- (void)addWorkouts:(NSSet *)values;
- (void)removeWorkouts:(NSSet *)values;

@end
