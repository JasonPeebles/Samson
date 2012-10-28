//
//  CatalogueViewController.m
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import "CatalogueViewController.h"
#import "CatalogueStore.h"
#import "Category.h"
#import "Exercise.h"
#import "NSIndexPath+SingleSectionAdditions.h"
#import "UITableView+SingleSectionsAdditions.h"

@interface CatalogueViewController ()

@property(strong)Category *highlightedCategory;
@property(nonatomic, strong)TableViewGestureRecognizer *recognizer;

- (NSManagedObject *)objectAtRowIndex:(int)index;
- (int)rowIndexOfObject:(id)obj;
- (BOOL)objectIsExercise:(id)obj;
- (CGFloat)addCategoryOffsetThreshold;

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
  [self setRecognizer:[TableViewGestureRecognizer addTableViewGestureRecognizerTo:[self tableView] withGestureDelegate:self]];
  
  return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
  return [self init];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
//  [[self tableView] setContentInset:UIEdgeInsetsMake(-[self addCategoryOffsetThreshold], 0, 0, 0)];
  
//  id categoryCellNib = [UINib nibWithNibName:[CatalogueCell nibName] bundle:nil];
//  [[self tableView] registerNib:categoryCellNib forCellReuseIdentifier:[CatalogueCell reuseIdentifier]];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (CGFloat)addCategoryOffsetThreshold;
{
  return [[self tableView] rowHeight];
}

- (NSManagedObject *)objectAtRowIndex:(int)index;
{  
  CatalogueStore *cs = [CatalogueStore sharedCatalogue];
  NSArray *allCategories = [cs allCategories];
  
  if (![self highlightedCategory])
  {
    return allCategories[index];
  }
  
  int indexOfHighlightedCategory = [allCategories indexOfObject:[self highlightedCategory]];
  int exercisesCount = [[[self highlightedCategory] exercises] count];
  
  if (index <= indexOfHighlightedCategory)
  {
    return allCategories[index];
  }
  else if (index <= indexOfHighlightedCategory + exercisesCount)
  {
    int exerciseIndex = index - indexOfHighlightedCategory - 1;
    return [cs exercisesForCategory:[self highlightedCategory]][exerciseIndex];
  }
  else
  {
    int categoryIndex = index - exercisesCount;
    return allCategories[categoryIndex];
  }
}

- (BOOL)objectIsExercise:(id)obj;
{
  return [obj isKindOfClass:[Exercise class]];
}

- (void)markIndexPathForDeletion:(NSIndexPath *)indexPath;
{
  indexPathMarkedForDeletion = indexPath;

  id obj = [self objectAtRowIndex:[indexPath row]];
  BOOL isExercise = [self objectIsExercise:obj];
    
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

#pragma mark - UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  CatalogueStore *cs = [CatalogueStore sharedCatalogue];
  
  //Pull-To-Add-Category Row + Categories + Displayed Exercises
  return [[cs allCategories] count] + [[[self highlightedCategory] exercises] count];
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

//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//  if (editingStyle == UITableViewCellEditingStyleDelete)
//  {
//    id obj = [self objectAtRowIndex:[indexPath row]];
//    BOOL isExercise = [self objectIsExercise:obj];
//    
//    indexPathMarkedForDeletion = indexPath;
//    
//    if (isExercise)
//    {
//      id title = [NSString stringWithFormat:@"Are you sure you want to delete the exercise, \"%@\"", obj];
//      
//      id actionSheet = [[UIActionSheet alloc] initWithTitle:title
//                                                   delegate:self
//                                          cancelButtonTitle:@"Cancel"
//                                     destructiveButtonTitle:@"Delete"
//                                          otherButtonTitles:nil];
//      
//      [actionSheet setTag:DeleteExerciseConfirmation];
//      [actionSheet show];
//    }
//    else
//    {
//      id title = [NSString stringWithFormat:@"Are you sure you want to delete the category, \"%@\"? This will delete all exercises for this category as well!", obj];
//      
//      id actionSheet = [[UIActionSheet alloc] initWithTitle:title
//                                                   delegate:self
//                                          cancelButtonTitle:@"Cancel"
//                                     destructiveButtonTitle:@"Delete"
//                                          otherButtonTitles:nil];
//      
//      [actionSheet setTag:DeleteCategoryConfirmation];
//      [actionSheet show];
//    }
//  }
//}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

#pragma mark - UITableViewDelegate Protocol
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//  if ([indexPath row] == 0)
//  {
//    return UITableViewCellEditingStyleNone;
//  }
//  
//  return UITableViewCellEditingStyleDelete;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  id obj = [self objectAtRowIndex:[indexPath row]];
  
  BOOL isExercise = [self objectIsExercise:obj];
  
  if (isExercise)
  {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
  }
  //Otherwise, this is a category
  else
  {
    CatalogueStore *cs = [CatalogueStore sharedCatalogue];
    NSArray *allCategories = [cs allCategories];
    
    id oldSelectedCategory = [self highlightedCategory];
    
    [tableView beginUpdates];
    
    if (oldSelectedCategory)
    {
      int oldSelectedCategoryIndex = [allCategories indexOfObject:oldSelectedCategory];
      
      NSRange indexRangeToDelete = NSMakeRange(oldSelectedCategoryIndex + 1, [[oldSelectedCategory exercises] count]);
      
      [self setHighlightedCategory:nil];
      
      [tableView deleteRowsInIndexRange:indexRangeToDelete withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if (obj != oldSelectedCategory)
    {
      [self setHighlightedCategory:obj];
      
      int newSelectedCategoryIndex = [allCategories indexOfObject:obj];
      
      NSRange indexRangeToInsert = NSMakeRange(newSelectedCategoryIndex + 1, [[obj exercises] count]);
      
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
    
    int exercisesCount = (categoryToDelete == [self highlightedCategory]) ? [[[self highlightedCategory] exercises] count] : 0;
    
    NSRange indexRangeToDelete = NSMakeRange([indexPathMarkedForDeletion row], exercisesCount + 1);
    [cs deleteCategory:categoryToDelete];
    
    [[self tableView] deleteRowsInIndexRange:indexRangeToDelete withRowAnimation:UITableViewRowAnimationFade];
  }
}

#pragma mark - TableViewGestureRowMoveDelegate Protocol
- (BOOL)gestureRecognizer:(TableViewGestureRecognizer *)recognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
{
  return YES;
}

- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer willBeginRowMoveAtIndexPath:(NSIndexPath *)indexPath;
{
  id cell = [[self tableView] cellForRowAtIndexPath:indexPath];
  [cell setBackgroundColor:[UIColor lightGrayColor]];
  return;
}

- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer moveRowFromIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to;
{
  return;
}
- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer didFinishRowMoveAtIndexPath:(NSIndexPath *)indexPath;
{
  return;
}
@end
