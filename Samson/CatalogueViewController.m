//
//  CatalogueViewController.m
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import "CatalogueViewController.h"
#import "CatalogueStore.h"
#import "AbstractExercise.h"

@interface CatalogueViewController ()

- (NSManagedObject *)objectAtRowIndex:(int)index;
- (int)rowIndexOfObject:(id)obj;
- (BOOL)objectIsExercise:(id)obj;

@end

@implementation CatalogueViewController

- (id)init
{
  self = [super initWithStyle:UITableViewStylePlain];
  
  if (!self)
  {
    return nil;
  }
  
  return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
  return [self init];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
  
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (NSManagedObject *)objectAtRowIndex:(int)index;
{
  CatalogueStore *cs = [CatalogueStore sharedCatalogue];
  id selectedCategory = [cs selectedCategory];
  
  if (!selectedCategory)
  {
    return [[cs allCategories] objectAtIndex:index];
  }
  
  int indexOfSelectedCategory = [[cs allCategories] indexOfObject:selectedCategory];
  int exercisesCount = [[cs exercisesForSelectedCategory] count];
  
  if (index <= indexOfSelectedCategory)
  {
    return [[cs allCategories] objectAtIndex:index];
  }
  else if (index <= indexOfSelectedCategory + exercisesCount)
  {
    int exerciseIndex = index - indexOfSelectedCategory - 1;
    return [[cs exercisesForSelectedCategory] objectAtIndex:exerciseIndex];
  }
  else
  {
    int categoryIndex = index - indexOfSelectedCategory - exercisesCount;
    return [[cs allCategories] objectAtIndex:categoryIndex];
  }
}

- (BOOL)objectIsExercise:(id)obj;
{
  return [obj isKindOfClass:[AbstractExercise class]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  CatalogueStore *cs = [CatalogueStore sharedCatalogue];
  
  int rowCount = [[cs allCategories] count] + [[cs exercisesForSelectedCategory] count];
  NSLog(@"Row Count: %d", rowCount);
  
  return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  id obj = [self objectAtRowIndex:[indexPath row]];
  
  BOOL isExercise = [self objectIsExercise:obj];
  
  NSString *CellIdentifier = [NSString stringWithFormat:@"%@Cell", isExercise ? @"Exercise" : @"Catalogue"];
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (!cell)
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  [[cell textLabel] setText:[obj name]];
  [[cell textLabel] setTextColor:isExercise ? [UIColor blueColor] : [UIColor blackColor]];
  // Configure the cell...
  
  return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  id obj = [self objectAtRowIndex:[indexPath row]];
  
  BOOL isExercise = [self objectIsExercise:obj];
  
  if (isExercise)
  {
    return;
  }
  //Otherwise, this is a category
  else
  {
    CatalogueStore *cs = [CatalogueStore sharedCatalogue];
    
    id oldSelectedCategory = [cs selectedCategory];
    
    [tableView beginUpdates];
    if (oldSelectedCategory)
    {
      NSMutableArray *indexPathsToDelete = [NSMutableArray array];
      
      int oldSelectedCategoryIndex = [[cs allCategories] indexOfObject:oldSelectedCategory];
      
      [[cs exercisesForSelectedCategory] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:(oldSelectedCategoryIndex + idx + 1) inSection:0]];
      }];
      
      [cs setSelectedCategory:nil];
      
      [tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if (obj != oldSelectedCategory)
    {
      NSMutableArray *indexPathsToInsert = [NSMutableArray array];
    
      [cs setSelectedCategory:obj];
      
      int newSelectedCategoryIndex = [[cs allCategories] indexOfObject:obj];
      
      [[cs exercisesForSelectedCategory] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:(newSelectedCategoryIndex + idx + 1) inSection:0]];
      }];
      
      [tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [tableView endUpdates];
  }
}

@end
