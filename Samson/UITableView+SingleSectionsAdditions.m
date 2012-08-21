//
//  UITableView+SingleSectionsAdditions.m
//  Samson
//
//  Created by Jason Peebles on 2012-08-21.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import "UITableView+SingleSectionsAdditions.h"
#import "NSIndexPath+SingleSectionAdditions.h"

@implementation UITableView (SingleSectionsAdditions)

- (void)insertRowsAtIndexes:(NSArray *)rowIndexes withRowAnimation:(UITableViewRowAnimation)animation;
{
  [self insertRowsAtIndexPaths:[NSIndexPath indexPathsForRowIndexes:rowIndexes]
              withRowAnimation:animation];
}

- (void)insertRowsInIndexRange:(NSRange)range withRowAnimation:(UITableViewRowAnimation) animation;
{
  [self insertRowsAtIndexPaths:[NSIndexPath indexPathsForRowsInRange:range]
              withRowAnimation:animation];
}

- (void)insertRowsAtIndex:(NSInteger)index withRowAnimation:(UITableViewRowAnimation)animation;
{
  [self insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index]]
              withRowAnimation:animation];
}

- (void)deleteRowsAtIndexes:(NSArray *)rowIndexes withRowAnimation:(UITableViewRowAnimation)animation;
{
  [self deleteRowsAtIndexPaths:[NSIndexPath indexPathsForRowIndexes:rowIndexes]
           withRowAnimation:animation];
}

- (void)deleteRowsInIndexRange:(NSRange)range withRowAnimation:(UITableViewRowAnimation) animation;
{
  [self deleteRowsAtIndexPaths:[NSIndexPath indexPathsForRowsInRange:range]
           withRowAnimation:animation];
}

- (void)deleteRowAtIndex:(NSInteger)index withRowAnimation:(UITableViewRowAnimation)animation;
{
  [self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index]]
           withRowAnimation:animation];
}

@end
