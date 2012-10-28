//
//  Category.h
//  Samson
//
//  Created by Jason Peebles on 2012-10-27.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Category : NSManagedObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * sortValue;
@property (nonatomic, strong) NSSet *exercises;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addExercisesObject:(NSManagedObject *)value;
- (void)removeExercisesObject:(NSManagedObject *)value;
- (void)addExercises:(NSSet *)values;
- (void)removeExercises:(NSSet *)values;

@end
