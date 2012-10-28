//
//  CatalogueStore.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//
//  Wrapper class to handle manipulation of Categories and Exercises

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;
@class Exercise;

@interface CatalogueStore : NSObject
{
  NSManagedObjectContext *context;
  NSManagedObjectModel *model;
}

@property(readonly, nonatomic, strong) NSMutableArray *allCategories;

+ (CatalogueStore *)sharedCatalogue;

- (void)loadAllCategories;
- (NSMutableArray *)exercisesForCategory:(Category *)category;
- (void)moveCategory:(Category *)category toIndex:(int)destination;
- (void)moveExercise:(Exercise *)exercise toCategory:(Category *)destinationCategory andIndex:(int)destinationIndex;
//Commits the current changes in the context to persistent store
- (BOOL)saveChanges;
//Creates a new category.  The index is used to determine the sortValue relative to the exisiting categories
- (Category *)createCategoryAtIndex:(int)index;
- (void)deleteCategory:(Category *)toDelete;
//Creates a new Exercise for the category.  The index is used to determine the sortValue relative to existing exercises
- (Exercise *)createExerciseForCategory:(Category *)category atIndex:(int)index;
- (void)deleteExercise:(Exercise *)exercise;

@end
