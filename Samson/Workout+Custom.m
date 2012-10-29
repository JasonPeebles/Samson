//
//  Workout+Custom.m
//  Samson
//
//  Created by Jason Peebles on 2012-10-28.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import "Workout+Custom.h"

@implementation Workout (Custom)

- (void)awakeFromInsert;
{
  [super awakeFromInsert];
  [self setTimestamp:[NSDate date]];
}

@end
