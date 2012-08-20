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
@class AbstractExercise;

@interface CatalogueStore : NSObject
{
  NSManagedObjectContext *context;
  NSManagedObjectModel *model;
}

@property(nonatomic, weak) Category *selectedCategory;
@property(readonly, nonatomic, strong) NSMutableArray *allCategories;
@property(readonly, nonatomic, strong) NSMutableArray *exercisesForSelectedCategory;

+ (CatalogueStore *)sharedCatalogue;

- (void)loadAllCategories;
- (void)loadAllExercisesForSelectedCategory;
- (void)moveCategoryAtIndex:(int)from toIndex:(int)to;
- (void)moveExerciseAtIndex:(int)from toIndex:(int)to;
- (void)moveExerciseAtIndex:(int)from toCategoryAtIndex:(int)to;
- (NSString *)catalogueArchivePath;
- (BOOL)saveChanges;
- (BOOL)objectIsExercise:(id)obj;
- (Category *)createCategory;
- (AbstractExercise *)createExerciseUsingWeights:(BOOL)usesWeights;

@end
