//
//  CatalogueStore.m
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import "CatalogueStore.h"
#import "Category.h"
#import "Exercise.h"
#import "UIActionSheet+Additions.h"

@interface CatalogueStore ()

- (NSString *)catalogueArchivePath;
- (void)loadDefaultStoreData;
- (void)moveExercise:(Exercise *)exercise withinCategoryToIndex:(int)destination;

@end

double newSortValue(NSArray* sortValues, int destination)
{
  double sortValue = 0;
  if ([sortValues count] < 2)
  {
    sortValue = 1.0;
  }
  else
  {
    double lower = 0;
    if (destination > 0)
    {
      lower = [sortValues[destination - 1] doubleValue];
    }
    else
    {
      lower = [sortValues[1] doubleValue] - 2.0;
    }
    
    double upper = 0;
    if (destination < [sortValues count] - 1)
    {
      upper = [sortValues[destination + 1] doubleValue];
    }
    else
    {
      upper = [sortValues[destination - 1] doubleValue] + 2.0;
    }
    
    sortValue = (lower + upper)/2.0;
  }
  
  return sortValue;
}

@implementation CatalogueStore

+ (CatalogueStore *)sharedCatalogue;
{
  static CatalogueStore *sharedCatalogue = nil;
  
  if (!sharedCatalogue)
  {
    sharedCatalogue = [[super allocWithZone:nil] init];
  }
  
  return sharedCatalogue;
}

+ (id)allocWithZone:(NSZone *)zone;
{
  return [self sharedCatalogue];
}

- (id)init;
{
  self = [super init];
  
  if (!self)
  {
    return nil;
  }
  
  //Read in .xcdatamodeld file
  model = [NSManagedObjectModel mergedModelFromBundles:nil];
  
  NSPersistentStoreCoordinator *persistantStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
  
  
  //Find the SQLite store file
  NSURL *storeURL = [NSURL fileURLWithPath:[self catalogueArchivePath]];
  NSError *error = nil;
  
  if (![persistantStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                configuration:nil
                                                          URL:storeURL
                                                      options:nil
                                                        error:&error])
  {
    [NSException raise:@"Open Failed!" format:@"Reason: %@", [error localizedDescription]];
  }
  
  //Set up the managed object context
  context = [[NSManagedObjectContext alloc] init];
  [context setPersistentStoreCoordinator:persistantStoreCoordinator];
  //Don't need the undo manager
  [context setUndoManager:nil];
  
  [self loadAllCategories];
  
  return self;
}


/*Reads in a predefined plist of the form:
 <Root>
 "CategoryA" : [{name:"Exercise1", etc}, ...],
 "CategoryB" : [{name:"ExerciseN", etc}, ...],
 .
 .
 .
 
 
 </Root>
 */
- (void)loadDefaultStoreData;
{
  id path = [[NSBundle mainBundle] pathForResource:@"InitialData" ofType:@"plist"];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
  
  [[dictionary allKeys] enumerateObjectsUsingBlock:^(id key, NSUInteger categoryIndex, BOOL *categoryStop) {
    
    Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
    
    [category setName:key];
    [category setSortValue:categoryIndex];
    
    [[self allCategories] addObject:category];
    
    NSArray *exercises = [dictionary valueForKey:key];
    
    [exercises enumerateObjectsUsingBlock:^(id obj, NSUInteger exerciseIndex, BOOL *exerciseStop) {
      Exercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:context];
      
      [exercise setValuesForKeysWithDictionary:obj];
      
      [exercise setCategory:category];
      [exercise setSortValue:exerciseIndex];
    }];
    
  }];
}

- (void)loadAllCategories;
{
  if (!_allCategories)
  {
    id fetchRequest = [[NSFetchRequest alloc] init];
    
    id entityDescription = [[model entitiesByName] objectForKey:NSStringFromClass([Category class])];
    
    [fetchRequest setEntity:entityDescription];
    
    id sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sortValue" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    
    id fetchResults = [context executeFetchRequest:fetchRequest error:&error];
    
    if (!fetchResults)
    {
      [NSException raise:@"Category Fetch Failed!" format:@"Reason: %@", [error localizedDescription]];
    }
    
    _allCategories = [fetchResults mutableCopy];
  }
  
  //If this is first time app is run, load up the default categories and exercises
  if ([_allCategories count] == 0)
  {
    [self loadDefaultStoreData];
  }
}

- (NSMutableArray *)exercisesForCategory:(Category *)category;
{
  id sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sortValue" ascending:YES];
  
  return [[[category exercises] sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
}


- (void)moveCategory:(Category *)category toIndex:(int)destination;
{
  int categoryIndex = [[self allCategories] indexOfObject:category];
  if (categoryIndex == destination)
  {
    return;
  }
  [category setSortValue:newSortValue([[self allCategories] valueForKey:@"sortValue"], destination)];
//  [category setSortValue:newSortValue([[self allCategories] valueForKey:@"sortValue"], destination, categoryIndex > destination)];
  [[self allCategories] removeObject:category];
  [[self allCategories] insertObject:category atIndex:destination];
  [category setSortValue:newSortValue([[self allCategories] valueForKey:@"sortValue"], destination)];
}

- (void)moveExercise:(Exercise *)exercise withinCategoryToIndex:(int)destination;
{
  NSMutableArray *exercises = [self exercisesForCategory:[exercise category]];
  int exerciseIndex = [exercises indexOfObject:exercise];
  if (exerciseIndex == destination)
  {
    return;
  }
  [exercises removeObject:exercise];
  [exercises insertObject:exercise atIndex:destination];
  [exercise setSortValue:newSortValue([exercises valueForKey:@"sortValue"], destination)];
//  [exercise setSortValue:newSortValue([exercises valueForKey:@"sortValue"], destination, exerciseIndex > destination)];
}

- (void)moveExercise:(Exercise *)exercise toCategory:(Category *)destinationCategory andIndex:(int)destinationIndex;
{
  if ([destinationCategory isEqual:[exercise category]])
  {
    [self moveExercise:exercise withinCategoryToIndex:destinationIndex];
    return;
  }
  
  [exercise setCategory:destinationCategory];
  id newExercises = [self exercisesForCategory:destinationCategory];
  [newExercises insertObject:exercise atIndex:destinationIndex];
  [exercise setSortValue:newSortValue([newExercises valueForKey:@"sortValue"], destinationIndex)];
  //  [exercise setSortValue:newSortValue([newExercises valueForKey:@"sortValue"], destinationIndex, NO)];
  
}

- (NSString *)catalogueArchivePath;
{
  NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  
  NSString *docDirectory = [documentDirectories objectAtIndex:0];
  
  return [docDirectory stringByAppendingPathComponent:@"Samson.sqlite"];
}

- (BOOL)saveChanges;
{
  NSError *error = nil;
  
  BOOL successful = [context save:&error];
  if (!successful)
  {
    NSLog(@"Error Saving.  Reason: %@", [error localizedDescription]);
  }
  
  return successful;
}


- (Category *)createCategoryAtIndex:(int)index;
{
//  double sortValue = newSortValue([[self allCategories] valueForKey:@"sortValue"], index, YES);
  
  Category *cat = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
  
  [_allCategories insertObject:cat atIndex:index];
  [cat setSortValue:newSortValue([[self allCategories] valueForKey:@"sortValue"], index)];
  
  return cat;
}

- (void)deleteCategory:(Category *)toDelete
{
  [context deleteObject:toDelete];
  [_allCategories removeObjectIdenticalTo:toDelete];
}

- (Exercise *)createExerciseForCategory:(Category *)category atIndex:(int)index;
{
  id exercises = [self exercisesForCategory:category];
  
  Exercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:context];
  [exercises insertObject:exercise atIndex:index];
  [exercise setSortValue:newSortValue([exercises valueForKey:@"sortValue"], index)];
  [exercise setCategory:category];
  
  return exercise;
}

- (void)deleteExercise:(Exercise *)exercise;
{
  [[exercise category] removeExercisesObject:exercise];
  [context deleteObject:exercise];
}

@end
