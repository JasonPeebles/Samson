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
#import "TextFieldCell.h"

@interface CatalogueViewController ()  <UIActionSheetDelegate, TableViewGestureRowMoveDelegate, TableViewGestureEditingRowDelegate>

@property(nonatomic, strong)Category *highlightedCategory;
@property(nonatomic, strong)TableViewGestureRecognizer *recognizer;
@property(nonatomic, assign)id grabbedObject;
@property(nonatomic, strong)NSIndexPath *grabbedObjectIndexPath;
@property(nonatomic, assign)BOOL highlightCategoryOnDrop;

- (NSManagedObject *)objectAtRowIndex:(int)index;
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
  [self setRecognizer:[TableViewGestureRecognizer addTableViewGestureRecognizerTo:[self tableView] withGestureDelegate:self]];
  
  return self;
}

- (void)setHighlightedCategory:(Category *)highlightedCategory
{
  CatalogueStore *cs = [CatalogueStore sharedCatalogue];
  NSArray *allCategories = [cs allCategories];
  
  id oldSelectedCategory = [self highlightedCategory];
  
  [[self tableView] beginUpdates];
  
  if (oldSelectedCategory)
  {
    int oldSelectedCategoryIndex = [allCategories indexOfObject:oldSelectedCategory];
    
    NSRange indexRangeToDelete = NSMakeRange(oldSelectedCategoryIndex + 1, [[oldSelectedCategory exercises] count]);
    
    _highlightedCategory = nil;
    
    [[self tableView] deleteRowsInIndexRange:indexRangeToDelete withRowAnimation:UITableViewRowAnimationFade];
  }
  
  if (highlightedCategory != oldSelectedCategory)
  {
    _highlightedCategory = highlightedCategory;
    
    int newSelectedCategoryIndex = [allCategories indexOfObject:highlightedCategory];
    
    NSRange indexRangeToInsert = NSMakeRange(newSelectedCategoryIndex + 1, [[highlightedCategory exercises] count]);
    
    [[self tableView] insertRowsInIndexRange:indexRangeToInsert withRowAnimation:UITableViewRowAnimationFade];
  }
  
  [[self tableView] endUpdates];

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
  if ([obj isEqual:[self highlightedCategory]])
  {
    [self setHighlightedCategory:nil];
  }
  
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
  
  //Categories + Displayed Exercises
  int numberOfRows = [[cs allCategories] count] + [[[self highlightedCategory] exercises] count];
  
  //If we're moving an exercise outside of the highlighted category, we need one more row to capture this
  if ([self objectIsExercise:[self grabbedObject]] && ![[[self grabbedObject] category] isEqual:[self highlightedCategory]])
  {
    numberOfRows++;
  }
  
  return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([[self grabbedObjectIndexPath] isEqual:indexPath])
  {
    NSString *CellIdentifier = @"Placeholder";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [[cell contentView] setBackgroundColor:[UIColor blackColor]];

    return cell;
  }
  
  TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:[TextFieldCell reuseIdentifier]];
  
  if (!cell)
  {
    cell = [[TextFieldCell alloc] init];
  }
  
  id obj = [self objectAtRowIndex:[indexPath row]];
  [cell setObject: obj];
  [cell setKeyPath:@"name"];
  [cell setTextColor:[self objectIsExercise:obj] ? [UIColor blueColor] : [UIColor blackColor]];
    // Configure the cell...
    
  return cell;
}


#pragma mark - UITableViewDelegate Protocol

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
    [self setHighlightedCategory:obj];
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
    id obj = [self objectAtRowIndex:[indexPathMarkedForDeletion row]];

    [[CatalogueStore sharedCatalogue] deleteExercise:obj];
    [[self tableView] deleteRowsAtIndexPaths:@[indexPathMarkedForDeletion] withRowAnimation:UITableViewRowAnimationFade];

  }
  
  if (identifier == DeleteCategoryConfirmation)
  {
    id categoryToDelete = [self objectAtRowIndex:[indexPathMarkedForDeletion row]];
    id cs = [CatalogueStore sharedCatalogue];
    
    [cs deleteCategory:categoryToDelete];
    
    [[self tableView] deleteRowsAtIndexPaths:@[indexPathMarkedForDeletion] withRowAnimation:UITableViewRowAnimationFade];
  }
  
  indexPathMarkedForDeletion = nil;
}

#pragma mark - TableViewGestureRowMoveDelegate Protocol
- (BOOL)gestureRecognizer:(TableViewGestureRecognizer *)recognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
{
  return YES;
}

- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer willBeginRowMoveAtIndexPath:(NSIndexPath *)indexPath;
{
  //If moving the highlightedCategory, collapse it first
  [self setGrabbedObject:[self objectAtRowIndex:[indexPath row]]];
  [self setGrabbedObjectIndexPath:indexPath];
  
  if ([self grabbedObject] == [self highlightedCategory])
  {
    [self setHighlightCategoryOnDrop:YES];
    [self setHighlightedCategory:nil];
  }
  else
  {
    [self setHighlightCategoryOnDrop:NO];
  }
}

- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer moveRowFromIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to;
{
  if ([from isEqual:to])
  {
    return;
  }

  BOOL objIsExercise = [self objectIsExercise:[self grabbedObject]];
  
  CatalogueStore *store = [CatalogueStore sharedCatalogue];
  
  if (objIsExercise)
  {
    //Get the closest category to the to row
    BOOL movingDown = [from row] < [to row];
    //If we're moving down, examine the target row, otherwise, examine the row above the target row
    //This index will always be non-negative since we're forbidding exercise moves to row 0
    int categoryScanIndex = [to row] - (int)!movingDown;
    id obj = [self objectAtRowIndex:categoryScanIndex];
    
    id nearestCategory = [self objectIsExercise:obj] ? [obj category] : obj;

    int destination = 0;

    //This checks to see if we're moving the exercise within the exercise sublist
    if ([[[self grabbedObject] category] isEqual:nearestCategory])
    {
      destination = [to row] - ([[store allCategories] indexOfObject:nearestCategory] + 1);
    }

    [store moveExercise:[self grabbedObject] toCategory:nearestCategory andIndex:destination];
  }
  else
  {
    int destination = [to row];
    
    if ([self highlightedCategory])
    {
      if (destination > [[store allCategories] indexOfObject:[self highlightedCategory]])
      {
        destination -= [[[self highlightedCategory] exercises] count];
      }
    }
    
    [store moveCategory:[self grabbedObject] toIndex:destination];
  }
  
  [self setGrabbedObjectIndexPath:to];
}

- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer didFinishRowMoveAtIndexPath:(NSIndexPath *)indexPath;
{
  if ([self highlightCategoryOnDrop])
  {
    [self setHighlightedCategory:[self grabbedObject]];
    [self setHighlightCategoryOnDrop:NO];
  }
  
  //If we just finished dropping an exercise into a category that is not the highlighted category, need to delete the row
  if ([self objectIsExercise:[self grabbedObject]] && ![[[self grabbedObject] category] isEqual:[self highlightedCategory]])
  {
    [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
  }
  
  [self setGrabbedObject:nil];
  [self setGrabbedObjectIndexPath:nil];
}

- (NSIndexPath *)gestureRecognizer:(TableViewGestureRecognizer *)recognizer targetIndexPathForRowMoveFromIndexPath:(NSIndexPath *)from toProposedIndexPath:(NSIndexPath *)proposed
{
  BOOL objIsExercise = [self objectIsExercise:[self grabbedObject]];
  
  //If moving an Exercise, permit any proposed indexPath except row 0, which gets redirected to row 1
  if (objIsExercise && [proposed row] == 0)
  {
    return [NSIndexPath indexPathForRow:1];
  }
  //If moving a Category, forbid moves to within Exercise sublist
  else if (!objIsExercise && [[[self highlightedCategory] exercises] count] > 0)
  {
    
    int forbiddenMinRow = [[[CatalogueStore sharedCatalogue] allCategories] indexOfObject:[self highlightedCategory]];
    int forbiddenMaxRow = forbiddenMinRow + [[[self highlightedCategory] exercises] count] - 1;
  
    //If we're moving the row up, we can move the row to where the highlighted category sits, as it will push the whole category-exercises group down
    //Otherwise
    if ([from row] > [proposed row])
    {
      forbiddenMinRow++;
      forbiddenMaxRow++;
    }
    
    if (forbiddenMinRow <= [proposed row] && [proposed row] <= forbiddenMaxRow)
    {
      return from;
    }
  }
  
  return proposed;
}

#pragma mark - TableViewGestureEditingRowDelegate Protocol
- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer commitEditingState:(TableViewGestureEditingState)editingState forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingState == TableViewGestureEditingStateNone)
  {
    return;
  }
  
  TextFieldCell *cell = (TextFieldCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
  [UIView beginAnimations:[NSString string] context:nil];
  [[cell contentView] setFrame:[[cell contentView] bounds]];
  [UIView commitAnimations];
  
  //Left State -> Rename Exercise/Category
  if (editingState == TableViewGestureEditingStateLeft)
  {
    [cell beginEditing];
  }
  
  //Right State -> Delete Exercise/Category
  if (editingState == TableViewGestureEditingStateRight)
  {
    [self markIndexPathForDeletion:indexPath];
  }
}

@end
