//
//  DurationWorkout.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractWorkout.h"

@class DurationExercise;

@interface DurationWorkout : AbstractWorkout

@property (nonatomic, strong) DurationExercise *exercise;

@end
