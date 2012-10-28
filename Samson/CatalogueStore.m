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

double newSortValue(NSArray* sortValues, int destination, BOOL displaceDown)
{
  double sortValue = 0;
  
  if ([sortValues count] == 0)
  {
    sortValue = 1.0;
  }
  else if (destination == 0)
  {
    sortValue = [sortValues[0] doubleValue] - 1.0;
  }
  else if (destination >= [sortValues count] - 1)
  {
    sortValue = [[sortValues lastObject] doubleValue] + 1.0;
  }
  else
  {
    int previousIndex = destination - (int)displaceDown;
    int nextIndex = destination + (int)(!displaceDown);
    
    double previous = [sortValues[previousIndex] doubleValue];
    double next = [sortValues[nextIndex] doubleValue];
    
    sortValue = (previous + next)/2.0;
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
  NSLog(@"%@", [storeURL path]);
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
 "CategoryA" : [{name:"Exercise1", usesWeights: <BOOL>}, ...],
 "CategoryB" : [{name:"ExerciseN", usesWeights: <BOOL>}, ...],
 .
 .
 .
 
 
 </Root>
 usesWeights:
 YES => WeightExercise instance
 NO  => DurationExercise instance
 
 
 */
- (void)loadDefaultStoreData;
{
  id path = [[NSBundle mainBundle] pathForResource:@"InitialData" ofType:@"plist"];
  
  NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
  
  [[dictionary allKeys] enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
    
    Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
    
    [category setName:key];
    [category setSortValue:@(idx)];
    
    [_allCategories addObject:category];
    
    NSArray *exercises = [dictionary valueForKey:key];
    
    [exercises enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {            
      Exercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:context];
      
      [exercise setName:[obj valueForKey:@"name"]];
      [exercise setCategory:category];
      [exercise setSortValue:@(idx)];
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
    
  [category setSortValue:@(newSortValue([[self allCategories] valueForKey:@"sortValue"], destination, categoryIndex > destination))];
  [[self allCategories] removeObject:category];
  [[self allCategories] insertObject:category atIndex:destination];
}

- (void)moveExercise:(Exercise *)exercise withinCategoryToIndex:(int)destination;
{
  NSMutableArray *exercises = [self exercisesForCategory:[exercise category]];
  int exerciseIndex = [exercises indexOfObject:exercise];
  if (exerciseIndex == destination)
  {
    return;
  }
  [exercise setSortValue:@(newSortValue([exercises valueForKey:@"sortValue"], destination, exerciseIndex > destination))];
  [exercises removeObject:exercise];
  [exercises insertObject:exercise atIndex:destination];
}

- (void)moveExercise:(Exercise *)exercise toCategory:(Category *)destinationCategory andIndex:(int)destinationIndex;
{
  if ([destinationCategory isEqual:[exercise category]])
  {
    [self moveExercise:exercise withinCategoryToIndex:destinationIndex];
    return;
  }
  
  id newExercises = [self exercisesForCategory:destinationCategory];
  [exercise setSortValue:@(newSortValue([newExercises valueForKey:@"sortValue"], destinationIndex, NO))];
  [exercise setCategory:destinationCategory];
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
  double sortValue = newSortValue([[self allCategories] valueForKey:@"sortValue"], index, YES);
    
  Category *cat = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
  
  [cat setSortValue:@(sortValue)];
  [_allCategories insertObject:cat atIndex:index];
  
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
  double sortValue = newSortValue([exercises valueForKey:@"sortValue"], index, YES);
  
  Exercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:context];
  [exercise setSortValue:@(sortValue)];
  [exercise setCategory:category];
  
  return exercise;
}

- (void)deleteExercise:(Exercise *)exercise;
{
  [context deleteObject:exercise];
}

@end
