//
//  TableViewGestureRecognizer.m
//  Samson
//
//  Created by Jason Peebles on 2012-08-29.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import "TableViewGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>

typedef enum
{
  TableViewGestureStateNone,
  TableViewGestureStateMoving,
  TableViewGestureStatePanning
} TableViewGestureState;

#define SNAPSHOT_TAG 19830416
#define DEFAULT_TRANSLATION_COMMIT_THRESHOLD 50;

@interface TableViewGestureRecognizer ()

@property(nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, weak)   UITableView *tableView;
@property(nonatomic, weak)   id<TableViewGestureRowMoveDelegate, TableViewGestureEditingRowDelegate> gestureDelegate;
@property(nonatomic, weak)   id<UITableViewDelegate> tableViewDelegate;
@property(nonatomic, assign) TableViewGestureState gestureState;
@property(nonatomic, assign) TableViewGestureState editingState;
@property(nonatomic, strong) NSTimer *cellMovementTimer;
@property(nonatomic, strong) NSIndexPath *movingIndexPath;
@property(nonatomic, strong) NSIndexPath *editingIndexPath;
@property(nonatomic, assign) CGFloat scrollRate;

- (void)scrollToCellMove;

@end

@interface TableViewGestureRecognizer (ProtocolConformanceHelpers)

- (BOOL)longPressGestureEnabled;
- (BOOL)gestureEditingEnabled;
@end

@interface TableViewGestureRecognizer (UIGestureRecognizerResponses)

- (void)longPressGestureDetected:(UILongPressGestureRecognizer *)recognizer;
- (void)panGestureDetected: (UIPanGestureRecognizer *)recognizer;

@end

@implementation TableViewGestureRecognizer

+ (TableViewGestureRecognizer *)addTableViewGestureRecognizerTo:(UITableView *)table withGestureDelegate:(id)delegate;
{
  if (![delegate conformsToProtocol:@protocol(TableViewGestureRowMoveDelegate)])
  {
    [NSException raise:@"Table view must conform to TableViewGestureRowMoveDelegate" format:nil];
  }
  
  //Sets up a table view gesture recognizer to intercept UITableViewDelegate Messages
  id tableViewGestureRecognizer = [TableViewGestureRecognizer new];
  [tableViewGestureRecognizer setTableView:table];
  [tableViewGestureRecognizer setGestureDelegate:delegate];
  [tableViewGestureRecognizer setTableViewDelegate:[table delegate]];
  [table setDelegate:tableViewGestureRecognizer];
  
  id longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:tableViewGestureRecognizer action:@selector(longPressGestureDetected:)];
  [longPress setDelegate:tableViewGestureRecognizer];
  [table addGestureRecognizer:longPress];
  [tableViewGestureRecognizer setLongPressGestureRecognizer:longPress];
  
  id pan = [[UIPanGestureRecognizer alloc] initWithTarget:tableViewGestureRecognizer action:@selector(panGestureDetected:)];
  [pan setDelegate:tableViewGestureRecognizer];
  [table addGestureRecognizer:pan];
  [tableViewGestureRecognizer setPanGestureRecognizer:pan];
  
  return tableViewGestureRecognizer;
}

- (void)scrollToCellMove;
{
  CGPoint tableOffset = [[self tableView] contentOffset];
  
  CGFloat tableViewFrameHeight = [[self tableView] frame].size.height;
  CGFloat tableViewContentHeight = [[self tableView] contentSize].height;
  
  CGFloat newYOffset = MAX(tableOffset.y + [self scrollRate], 0);
  
  if (tableViewContentHeight < tableViewFrameHeight)
  {
    newYOffset = tableOffset.y;
  }
  else if (newYOffset > tableViewContentHeight - tableViewFrameHeight)
  {
    newYOffset = tableViewContentHeight - tableViewFrameHeight;
  }
  
  [[self tableView] setContentOffset:CGPointMake(tableOffset.x, newYOffset)];
 
  CGPoint gestureLocation = [[self longPressGestureRecognizer] locationInView:[self tableView]];
  //Update the location of the snapshot and the moving index path
  if (gestureLocation.y >= 0)
  {
    UIImageView *snapshotImageView = (UIImageView *)[[self tableView] viewWithTag:SNAPSHOT_TAG];
    [snapshotImageView setCenter:CGPointMake([[self tableView] center].x, gestureLocation.y)];
  }
  
  [self refreshMovingIndexPathForCurrentGestureLocation];
}

#pragma mark - ProtocolConformanceHelpers Category
- (BOOL)longPressGestureEnabled;
{
  return [[self gestureDelegate] conformsToProtocol:@protocol(TableViewGestureRowMoveDelegate)];
}

- (BOOL)gestureEditingEnabled;
{
  return [[self gestureDelegate] conformsToProtocol:@protocol(TableViewGestureEditingRowDelegate)];
}

//Set up TableViewGestureRecognizer as proxy class for UITableViewDelegate
//TODO: this is boiler plate.  Should be a way to set up these implementations within a single method like
//becomeProxyInstanceForObject:(id)obj
#pragma mark - NSProxy Methods
- (void)forwardInvocation:(NSInvocation *)anInvocation;
{
  [anInvocation invokeWithTarget:[self tableViewDelegate]];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  return [[self tableViewDelegate] respondsToSelector:aSelector] || [[self class] instancesRespondToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
  return [(NSObject *)[self tableViewDelegate] methodSignatureForSelector:aSelector];
}

#pragma mark UIGestureRecognizerDelegate Protocol
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  CGPoint gestureLocation = [gestureRecognizer locationInView:[self tableView]];
  NSIndexPath *indexPathAtGesture = [[self tableView] indexPathForRowAtPoint:gestureLocation];
  
  if (gestureRecognizer == [self longPressGestureRecognizer])
  {
    if (![self longPressGestureEnabled] || !indexPathAtGesture)
    {
      return NO;
    }
    
    //Ask the delegate if row can be moved
    return [[self gestureDelegate] gestureRecognizer:self canMoveRowAtIndexPath:indexPathAtGesture];
  }
  else if (gestureRecognizer == [self panGestureRecognizer])
  {
    if (![self gestureEditingEnabled])
    {
      return NO;
    }
    
    CGPoint translation = [[self panGestureRecognizer] translationInView:[self tableView]];
    if (!indexPathAtGesture || fabsf(translation.y) > fabsf(translation.x))
    {
      return NO;
    }
  }
  
  return YES;
}

//Refresh the movingIndexPath as the cell is dragged
- (void)refreshMovingIndexPathForCurrentGestureLocation;
{
  CGPoint location = [[self longPressGestureRecognizer] locationInView:[self tableView]];
  NSIndexPath *proposedIndexPath = [[self tableView] indexPathForRowAtPoint:location];
  
  if (!proposedIndexPath)
  {
    return;
  }
  
  if ([[self gestureDelegate] respondsToSelector:@selector(gestureRecognizer:targetIndexPathForRowMoveFromIndexPath:toProposedIndexPath:)])
  {
    proposedIndexPath = [[self gestureDelegate] gestureRecognizer:self targetIndexPathForRowMoveFromIndexPath:[self movingIndexPath] toProposedIndexPath:proposedIndexPath];
  }
  
  if ([[self movingIndexPath] isEqual:proposedIndexPath])
  {
    return;
  }
  
  [[self tableView] beginUpdates];
  
  [[self tableView] deleteRowsAtIndexPaths:@[[self movingIndexPath]] withRowAnimation:UITableViewRowAnimationNone];
  [[self tableView] insertRowsAtIndexPaths:@[proposedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
  [[self gestureDelegate] gestureRecognizer:self moveRowFromIndexPath:[self movingIndexPath] toIndexPath:proposedIndexPath];
  
  [self setMovingIndexPath:proposedIndexPath];
  
  [[self tableView] endUpdates];
}

#pragma mark UIGestureRecognizer Responses
- (void)longPressGestureDetected:(UILongPressGestureRecognizer *)recognizer;
{
  UIGestureRecognizerState state = [recognizer state];
  CGPoint gestureLocation = [recognizer locationInView:[self tableView]];
  NSIndexPath *indexPathAtGesture = [[self tableView] indexPathForRowAtPoint:gestureLocation];
  
  
  if (state == UIGestureRecognizerStateBegan)
  {
    //Grab a snapshot of the cell to move around, position it at gesture location
    id cell = [[self tableView] cellForRowAtIndexPath:indexPathAtGesture];
    UIGraphicsBeginImageContextWithOptions([cell bounds].size, NO, 0);
    [[cell layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *snapshotImageView = (UIImageView *)[[self tableView] viewWithTag:SNAPSHOT_TAG];
    if (!snapshotImageView)
    {
      snapshotImageView = [[UIImageView alloc] initWithImage:snapshot];
      [snapshotImageView setTag:SNAPSHOT_TAG];
      [[self tableView] addSubview:snapshotImageView];
      
//      CGPoint rowOrigin = [[self tableView] rectForRowAtIndexPath:indexPathAtGesture].origin;
      [snapshotImageView setFrame:[[self tableView] rectForRowAtIndexPath:indexPathAtGesture]];
    }
    
    [UIView beginAnimations:@"CellZoom" context:nil];
    [snapshotImageView setTransform:CGAffineTransformMakeScale(1.05, 1.1)];
    [snapshotImageView setCenter:CGPointMake([[self tableView] center].x, gestureLocation.y)];
    [UIView commitAnimations];
    
    [[self tableView] beginUpdates];
    //Tell the delegate moving will begin
    [[self gestureDelegate] gestureRecognizer:self willBeginRowMoveAtIndexPath:indexPathAtGesture];
    [[self tableView] endUpdates];
    
    id indexPath = [[self tableView] indexPathForRowAtPoint:gestureLocation];
    if (indexPath)
    {
      [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    //Begin listening for dragging image to edge of screen
    id timer = [NSTimer timerWithTimeInterval:1/4 target:self selector:@selector(scrollToCellMove) userInfo:nil repeats:YES];
    [self setCellMovementTimer:timer];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    [self setMovingIndexPath:indexPathAtGesture];
  }
  
  else if (state == UIGestureRecognizerStateChanged)
  {
    [self refreshMovingIndexPathForCurrentGestureLocation];
    
    UIImageView *snapshotImageView = (UIImageView *)[[self tableView] viewWithTag:SNAPSHOT_TAG];
    [snapshotImageView setCenter:CGPointMake([[self tableView] center].x, gestureLocation.y)];
    
    CGFloat yOffset = gestureLocation.y - [[self tableView] contentOffset].y;
    CGFloat tableViewBoundsHeight = [[self tableView] bounds].size.height;
  
    CGFloat scrollThreshold = tableViewBoundsHeight / 6;
    
    //Start scrolling up
    if (yOffset > tableViewBoundsHeight - scrollThreshold)
    {
      [self setScrollRate: 1 + (yOffset - tableViewBoundsHeight)/scrollThreshold];
    }
    //Start scrolling down
    else if (yOffset < scrollThreshold)
    {
      [self setScrollRate: -1 + MAX(yOffset, 0)/scrollThreshold];
    }
    else
    {
      [self setScrollRate:0];
    }
  }
  
  else if (state == UIGestureRecognizerStateEnded)
  {
    //Kill the scroll move timer
    [[self cellMovementTimer] invalidate];
    [self setCellMovementTimer:nil];
    
    UITableView *tableView = [self tableView];
    UIImageView *snapshotImageView = (UIImageView *)[tableView viewWithTag:SNAPSHOT_TAG];
    NSIndexPath *blockMovingIndexPath = [self movingIndexPath];
    
    [UIView animateWithDuration:0.33
                     animations:^{
                       CGPoint cellRectOrigin = [tableView rectForRowAtIndexPath:blockMovingIndexPath].origin;
                       [snapshotImageView setTransform:CGAffineTransformIdentity];
                       [snapshotImageView setFrame:CGRectOffset([snapshotImageView bounds], cellRectOrigin.x, cellRectOrigin.y)];
                     } completion:^(BOOL finished) {                       
                       //Give the gesture delegate a chance update things
                       [tableView beginUpdates];
                       [[self gestureDelegate] gestureRecognizer:self didFinishRowMoveAtIndexPath:blockMovingIndexPath];
                       [tableView endUpdates];
                       
                       id indexPath = [[self tableView] indexPathForRowAtPoint:gestureLocation];
                       if (indexPath)
                       {
                         [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                       }
                       
                       [self setMovingIndexPath:nil];
                       [self setGestureState:TableViewGestureStateNone];
                       [snapshotImageView removeFromSuperview];
                     }];
    
  }
}

- (BOOL)panGestureExceedsThreshold
{
  CGFloat xTranslation = [[self panGestureRecognizer] translationInView:[self tableView]].x;
  CGFloat commitThreshold = DEFAULT_TRANSLATION_COMMIT_THRESHOLD;
  if ([[self gestureDelegate] respondsToSelector:@selector(gestureRecognizer:translationThresholdForCommittingEditingState:forRowAtIndexPath:)])
  {
    commitThreshold = [[self gestureDelegate] gestureRecognizer:self translationThresholdForCommittingEditingState:(xTranslation > 0 ? TableViewGestureEditingStateLeft : TableViewGestureEditingStateRight) forRowAtIndexPath:[self editingIndexPath]];
  }

  return fabsf(xTranslation) >= commitThreshold;
}

- (void)panGestureDetected: (UIPanGestureRecognizer *)recognizer;
{
  UIGestureRecognizerState state = [recognizer state];
  
  if (!(state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged || state == UIGestureRecognizerStateEnded))
  {
    return;
  }
  
  CGFloat xTranslation = [recognizer translationInView:[self tableView]].x; 
  UITableViewCell *editingCell = [[self tableView] cellForRowAtIndexPath:[self editingIndexPath]];
  
  if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
  {
    CGPoint gestureLocation = [recognizer locationOfTouch:0 inView:[self tableView]];
    NSIndexPath *indexPathAtGesture = [[self tableView] indexPathForRowAtPoint:gestureLocation];
    
    if (![self editingIndexPath])
    {
      [self setEditingIndexPath:indexPathAtGesture];
    }
    
    //Adjust the cell's content view
    [[editingCell contentView] setFrame:CGRectOffset([[editingCell contentView] bounds], xTranslation, 0)];
    
    //Pass this on to the gestureDelegate if we've passed the threshold
    if ([self panGestureExceedsThreshold])
    {
      [self setEditingState:(xTranslation > 0 ? TableViewGestureEditingStateLeft : TableViewGestureEditingStateRight)];
      if ([[self gestureDelegate] respondsToSelector:@selector(gestureRecognizer:didEnterEditingState:forRowAtIndexPath:)])
      {
        [[self gestureDelegate] gestureRecognizer:self didEnterEditingState:[self editingState] forRowAtIndexPath:[self editingIndexPath]];
      }
    }
  }
  else if (state == UIGestureRecognizerStateEnded)
  {
    
    //Tell the delegate to commit the editing state
    if ([self panGestureExceedsThreshold])
    {
      if ([[self gestureDelegate] respondsToSelector:@selector(gestureRecognizer:commitEditingState:forRowAtIndexPath:)])
      {
        [[self gestureDelegate] gestureRecognizer:self commitEditingState:[self editingState] forRowAtIndexPath:[self editingIndexPath]];
      }
    }
    //Otherwise just adjust the cell's content view back to the original position
    else
    {
      [UIView beginAnimations:[NSString string] context:nil];
      [[editingCell contentView] setFrame:[[editingCell contentView] bounds]];
      [UIView commitAnimations];
    }
    
    [self setGestureState:TableViewGestureStateNone];
    [self setEditingState:TableViewGestureEditingStateNone];
    [self setEditingIndexPath:nil];
  }
}

@end
