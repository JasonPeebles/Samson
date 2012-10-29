//
//  Workout+Custom.h
//  Samson
//
//  Created by Jason Peebles on 2012-10-28.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import "Workout.h"

@interface Workout (Custom)

//Sets the timestamp to the current datetime
- (void)awakeFromInsert;

@end
