//
//  AbstractExercise.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;

@interface AbstractExercise : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) double sortOrder;
@property (nonatomic, retain) Category *category;

@end
