//
//  Category.h
//  Samson
//
//  Created by Jason Peebles on 2012-10-28.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exercise;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) double sortValue;
@property (nonatomic, retain) NSSet *exercises;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addExercisesObject:(Exercise *)value;
- (void)removeExercisesObject:(Exercise *)value;
- (void)addExercises:(NSSet *)values;
- (void)removeExercises:(NSSet *)values;

@end
