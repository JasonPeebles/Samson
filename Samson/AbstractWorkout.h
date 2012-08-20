//
//  AbstractWorkout.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AbstractWorkout : NSManagedObject

@property (nonatomic, strong) NSNumber *seconds;
@property (nonatomic, strong) NSDate *timestamp;

@end
