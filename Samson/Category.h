//
//  Category.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AbstractExercise;

@interface Category : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *sortOrder;
@property (nonatomic, strong) NSSet *exercises;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addExercisesObject:(AbstractExercise *)value;
- (void)removeExercisesObject:(AbstractExercise *)value;
- (void)addExercises:(NSSet *)values;
- (void)removeExercises:(NSSet *)values;

@end
