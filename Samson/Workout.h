//
//  Workout.h
//  Samson
//
//  Created by Jason Peebles on 2012-10-27.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Workout : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * kilos;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * repetitions;
@property (nonatomic, retain) NSManagedObject *exercise;

@end
