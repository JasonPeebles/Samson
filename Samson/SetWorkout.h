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

@property (nonatomic) double kilos;
@property (nonatomic) int16_t repetitions;
@property (nonatomic, retain) WeightExercise *exercise;

@end
