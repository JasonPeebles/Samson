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
#import "UITableView+SingleSectionsAdditions.h"

@interface CatalogueViewController ()

- (NSManagedObject *)objectAtRowIndex:(int)index;
- (int)rowIndexOfObject:(id)obj;
- (BOOL)objectIsExercise:(id)obj;

@end

typedef enum
{
  DeleteExerciseConfirmation,
  DeleteCategoryConfirmation
} ActionSheetIdentifiers;

@implementation CatalogueViewController

- (id)init
{
  self = [super initWithStyle:UITableViewStylePlain];
  
  if (!self)
  {
    return nil;
  }
  
  indexPathMarkedForDeletion = nil;
  
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
    int categoryIndex = index - exercisesCount;
    return [[cs allCategories] objectAtIndex:categoryIndex];
  }
}

- (BOOL)objectIsExercise:(id)obj;
{
  return [obj isKindOfClass:[AbstractExercise class]];
}

#pragma mark - UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  CatalogueStore *cs = [CatalogueStore sharedCatalogue];
  
  return [[cs allCategories] count] + [[cs exercisesForSelectedCategory] count];
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
  
  [[cell textLabel] setText:[obj description]];
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


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete)
  {
    id obj = [self objectAtRowIndex:[indexPath row]];
    BOOL isExercise = [self objectIsExercise:obj];
    
    indexPathMarkedForDeletion = indexPath;
    
    if (isExercise)
    {
      id title = [NSString stringWithFormat:@"Are you sure you want to delete the exercise, \"%@\"", obj];
      
      id actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Delete"
                                          otherButtonTitles:nil];
      
      [actionSheet setTag:DeleteExerciseConfirmation];
      [actionSheet show];
    }
    else
    {
      id title = [NSString stringWithFormat:@"Are you sure you want to delete the category, \"%@\"? This will delete all exercises for this category as well!", obj];
      
      id actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Delete"
                                          otherButtonTitles:nil];
      
      [actionSheet setTag:DeleteCategoryConfirmation];
      [actionSheet show];
    }
  }
}


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

#pragma mark - UITableViewDelegate Protocol

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return UITableViewCellEditingStyleDelete;
}

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
      int oldSelectedCategoryIndex = [[cs allCategories] indexOfObject:oldSelectedCategory];
      
      NSRange indexRangeToDelete = NSMakeRange(oldSelectedCategoryIndex + 1, [[cs exercisesForSelectedCategory] count]);
      
      [cs setSelectedCategory:nil];
      
      [tableView deleteRowsInIndexRange:indexRangeToDelete withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if (obj != oldSelectedCategory)
    {
      [cs setSelectedCategory:obj];
      
      int newSelectedCategoryIndex = [[cs allCategories] indexOfObject:obj];
      
      NSRange indexRangeToInsert = NSMakeRange(newSelectedCategoryIndex + 1, [[cs exercisesForSelectedCategory] count]);
      
      [tableView insertRowsInIndexRange:indexRangeToInsert withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [tableView endUpdates];
  }
}

#pragma mark - UIActionSheetDelegate Protocol
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == [actionSheet cancelButtonIndex])
  {
    indexPathMarkedForDeletion = nil;
    return;
  }

  int identifier = [actionSheet tag];

  if (identifier == DeleteExerciseConfirmation)
  {
    id exercise = [self objectAtRowIndex:[indexPathMarkedForDeletion row]];
    [[CatalogueStore sharedCatalogue] deleteExercise:exercise];
    [[self tableView] deleteRowsAtIndexPaths:@[indexPathMarkedForDeletion] withRowAnimation:UITableViewRowAnimationFade];
  }

  if (identifier == DeleteCategoryConfirmation)
  {
    id categoryToDelete = [self objectAtRowIndex:[indexPathMarkedForDeletion row]];
    id cs = [CatalogueStore sharedCatalogue];

    BOOL isSelectedCategory = categoryToDelete == [cs selectedCategory];
    int exercisesCount = isSelectedCategory ? [[cs exercisesForSelectedCategory] count] : 0;

    NSRange indexRangeToDelete = NSMakeRange([indexPathMarkedForDeletion row], exercisesCount + 1);
    [cs deleteCategory:categoryToDelete];

    [[self tableView] deleteRowsInIndexRange:indexRangeToDelete withRowAnimation:UITableViewRowAnimationFade];
  }
}

@end
