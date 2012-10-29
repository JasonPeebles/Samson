//
//  Workout.h
//  Samson
//
//  Created by Jason Peebles on 2012-10-28.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exercise;

@interface Workout : NSManagedObject

@property (nonatomic) int32_t duration;
@property (nonatomic) double kilograms;
@property (nonatomic) int16_t repetitions;
@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic, retain) Exercise *exercise;

@end
