//
//  CatalogueStore.m
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import "CatalogueStore.h"
#import "Category.h"
#import "AbstractExercise.h"
#import "AbstractExercise+Custom.h"
#import "WeightExercise.h"
#import "DurationExercise.h"
#import "UIActionSheet+Additions.h"

@interface CatalogueStore ()

- (void)loadDefaultStoreData;
//Returns a category's exercises ordered by the sortOrder attribute
- (NSMutableArray *)exercisesForCategory:(Category *)category;
@end

@implementation CatalogueStore

@synthesize allCategories = _allCategories;
@synthesize exercisesForSelectedCategory = _exercisesForSelectedCategory;

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

- (void)setSelectedCategory:(Category *)selectedCategory
{
  _selectedCategory = selectedCategory;
  
  [self loadAllExercisesForSelectedCategory];
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
    [category setSortOrder:idx];
    
    [_allCategories addObject:category];
    
    NSArray *exercises = [dictionary valueForKey:key];
    
    [exercises enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      BOOL usesWeights = [[obj valueForKey:@"usesWeights"] boolValue];
      
      NSString *entityName = [AbstractExercise concreteEntityNameUsingWeights:usesWeights];
      
      AbstractExercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
      
      [exercise setName:[obj valueForKey:@"name"]];
      [exercise setCategory:category];
      [exercise setSortOrder:idx];
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
    
    id sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES];
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
  id sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES];
  
  return [[[category exercises] sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
}

- (void)loadAllExercisesForSelectedCategory;
{
  _exercisesForSelectedCategory = nil;
  
  if (!_selectedCategory)
  {
    return;
  }
    
  _exercisesForSelectedCategory = [self exercisesForCategory:_selectedCategory];
}

- (void)moveCategoryAtIndex:(int)from toIndex:(int)to;
{
  
}

- (void)moveExerciseAtIndex:(int)from toIndex:(int)to;
{
  
}

- (void)moveExerciseAtIndex:(int)from toCategoryAtIndex:(int)to;
{
  
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

- (Category *)createCategory;
{
  double sortOrder;
  
  if ([_allCategories count] == 0)
  {
    sortOrder = 1.0;
  }
  else
  {
    sortOrder = [[_allCategories objectAtIndex:0] sortOrder] - 1.0;
  }
  
  Category *cat = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
  
  [cat setSortOrder:sortOrder];
  [_allCategories insertObject:cat atIndex:0];
  
  return cat;
}

- (void)deleteCategory:(Category *)toDelete
{
  if (toDelete == _selectedCategory)
  {
    [self setSelectedCategory:nil];
  }
  
  [context deleteObject:toDelete];
  [_allCategories removeObjectIdenticalTo:toDelete];
}

- (AbstractExercise *)createExerciseUsingWeights:(BOOL)usesWeights;
{
  double sortOrder;
  
  if ([_exercisesForSelectedCategory count] == 0)
  {
    sortOrder = 1.0;
  }
  else
  {
    sortOrder = [[_exercisesForSelectedCategory objectAtIndex:0] sortOrder] - 1.0;
  }
  
  NSString *entityName = [AbstractExercise concreteEntityNameUsingWeights:usesWeights];
  
  AbstractExercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
  
  [exercise setSortOrder:sortOrder];
  [exercise setCategory:_selectedCategory];
  
  [_exercisesForSelectedCategory insertObject:exercise atIndex:0];
  
  return exercise;
}

- (void)deleteExercise:(AbstractExercise *)exercise
{
  [context deleteObject:exercise];
  [_exercisesForSelectedCategory removeObjectIdenticalTo:exercise];
}

@end
