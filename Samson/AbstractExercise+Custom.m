//
//  AbstractExercise+Custom.m
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import "AbstractExercise+Custom.h"

@implementation AbstractExercise (Custom)

+ (NSString *)concreteEntityNameUsingWeights:(BOOL)usesWeights;
{
 return [NSString stringWithFormat:@"%@Exercise", usesWeights ? @"Weight" : @"Duration"];
}

@end
