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
  TableViewGestureStateMoving
} TableViewGestureState;

#define SNAPSHOT_TAG 19830416

@interface TableViewGestureRecognizer ()

@property(nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property(nonatomic, weak)   UITableView *tableView;
@property(nonatomic, weak)   id<TableViewGestureRowMoveDelegate> gestureDelegate;
@property(nonatomic, weak)   id<UITableViewDelegate> tableViewDelegate;
@property(nonatomic, assign) TableViewGestureState gestureState;
@property(nonatomic, strong) NSTimer *cellMovementTimer;

- (void)scrollToCellMove;

@end

@interface TableViewGestureRecognizer (ProtocolConformanceHelpers)

- (BOOL)longPressGestureEnabled;

@end

@interface TableViewGestureRecognizer (UIGestureRecognizerResponses)

- (void)longPressGestureDetected:(UIGestureRecognizer *)recognizer;

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
  
  return tableViewGestureRecognizer;
}

- (void)scrollToCellMove;
{
  
}

#pragma mark - ProtocolConformanceHelpers Category
- (BOOL)longPressGestureEnabled;
{
  return [[self gestureDelegate] conformsToProtocol:@protocol(TableViewGestureRowMoveDelegate)];
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
  
  return YES;
}

#pragma mark UIGestureRecognizer Responses
- (void)longPressGestureDetected:(UIGestureRecognizer *)recognizer;
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
    [snapshotImageView setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
    [snapshotImageView setCenter:CGPointMake([[self tableView] center].x, gestureLocation.y)];
    [UIView commitAnimations];
    
    [[self tableView] beginUpdates];
    
    [[self tableView] deleteRowsAtIndexPaths:@[indexPathAtGesture] withRowAnimation:UITableViewRowAnimationNone];
    [[self tableView] insertRowsAtIndexPaths:@[indexPathAtGesture] withRowAnimation:UITableViewRowAnimationNone];
    
    //Tell the delegate moving will begin
    [[self gestureDelegate] gestureRecognizer:self willBeginRowMoveAtIndex:indexPathAtGesture];
    [[self tableView] endUpdates];
    
    //Begin listening for dragging image to edge of screen
    id timer = [NSTimer timerWithTimeInterval:1/4 target:self selector:@selector(scrollToCellMove) userInfo:nil repeats:YES];
    [self setCellMovementTimer:timer];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
  }
  
  else if (state == UIGestureRecognizerStateChanged)
  {
    
  }
  
  else if (state == UIGestureRecognizerStateEnded)
  {
  
  }
}

@end
