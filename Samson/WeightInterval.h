//
//  WeightInterval.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractInterval.h"

@class WeightExercise;

@interface WeightInterval : AbstractInterval

@property (nonatomic, strong) NSDecimalNumber *kilos;
@property (nonatomic, strong) WeightExercise *exercise;

@end
