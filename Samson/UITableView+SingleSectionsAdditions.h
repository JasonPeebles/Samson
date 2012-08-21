//
//  UITableView+SingleSectionsAdditions.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-21.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (SingleSectionsAdditions)

- (void)insertRowsAtIndexes:(NSArray *)rowIndexes withRowAnimation:(UITableViewRowAnimation)animation;
- (void)insertRowsInIndexRange:(NSRange)range withRowAnimation:(UITableViewRowAnimation) animation;
- (void)insertRowsAtIndex:(NSInteger)index withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRowsAtIndexes:(NSArray *)rowIndexes withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRowsInIndexRange:(NSRange)range withRowAnimation:(UITableViewRowAnimation) animation;
- (void)deleteRowAtIndex:(NSInteger)index withRowAnimation:(UITableViewRowAnimation)animation;

@end
