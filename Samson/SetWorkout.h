//
//  SetWorkout.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractWorkout.h"

@class WeightExercise;

@interface SetWorkout : AbstractWorkout

@property (nonatomic, strong) NSDecimalNumber *kilos;
@property (nonatomic, strong) NSNumber *repetitions;
@property (nonatomic, strong) WeightExercise *exercise;

@end
