//
//  TableViewGestureRecognizer.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-29.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TableViewGestureRecognizer;

@protocol TableViewGestureRowMoveDelegate <NSObject>

@required
//Sent to the delegate just before a long press begins.  Return NO to cancel move,
- (BOOL)gestureRecognizer:(TableViewGestureRecognizer *)recognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
//Sent to the delegate before row movement begins.  Allows delegate to set up a placeholder cell if desired.
- (void)gestureRecognizer:(TableViewGestureRecognizer *)recognizer willBeginRowMoveAtIndex:(NSIndexPath *)indexPath;
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

@interface TableViewGestureRecognizer : NSObject <UIGestureRecognizerDelegate, UITableViewDelegate>

+ (TableViewGestureRecognizer *)addTableViewGestureRecognizerTo:(UITableView *)tableView withGestureDelegate:(id)delegate;

@end