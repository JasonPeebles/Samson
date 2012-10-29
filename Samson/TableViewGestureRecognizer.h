//
//  TableViewGestureRecognizer.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-29.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
  TableViewGestureEditingStateNone,
  TableViewGestureEditingStateLeft,
  TableViewGestureEditingStateRight
} TableViewGestureEditingState;

@class TableViewGestureRecognizer;

@protocol TableViewGestureRowMoveDelegate <NSObject>

@required
//Sent to the delegate just before a long press begins.  Return NO to cancel move,
- (BOOL)gestureRecognizer:(TableViewGestureRecognizer *)recognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
//Sent to the delegate before row movement begins.  Allows delegate to set up a placeholder cell if desired.
- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer willBeginRowMoveAtIndexPath:(NSIndexPath *)indexPath;
//Sent to the delegate each time a row changes position
- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer moveRowFromIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to;
//Sent once the gesture has finished, indicating the user has "dropped" the cell in the desired indexPath
//Allows the delegate to reconfigure the reordered cell
- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer didFinishRowMoveAtIndexPath:(NSIndexPath *)indexPath;

//Asks the delegate to return a new index path to retarget a proposed row move.
//Sent immediately before the delegate message gestureRecognizer:moveRowFromIndexPath:toIndexPath
@optional
- (NSIndexPath *)gestureRecognizer:(TableViewGestureRecognizer *)recognizer targetIndexPathForRowMoveFromIndexPath:(NSIndexPath *)from toProposedIndexPath:(NSIndexPath *)proposed;

@end

@protocol TableViewGestureEditingRowDelegate <NSObject>
@optional
//Asks the delegate for the translation threshold for editing a cell
- (CGFloat)gestureRecognizer:(TableViewGestureRecognizer *)recognizer translationThresholdForCommittingEditingState:(TableViewGestureEditingState)editingState forRowAtIndexPath:(NSIndexPath *)indexPath;
//Sent when a user drags the cell left or right beyond the commit threshold but hasn't yet ended the pan gesture
- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer didEnterEditingState:(TableViewGestureEditingState)editingState forRowAtIndexPath:(NSIndexPath *)indexPath;
//Sent when the users finishes panning the cell left or right and its translation is beyond the commit threshold
- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer commitEditingState:(TableViewGestureEditingState)editingState forRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface TableViewGestureRecognizer : NSObject <UIGestureRecognizerDelegate, UITableViewDelegate>

+ (TableViewGestureRecognizer *)addTableViewGestureRecognizerTo:(UITableView *)tableView withGestureDelegate:(id)delegate;

@end