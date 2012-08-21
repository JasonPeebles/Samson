//
//  NSIndexPath+SingleSectionAdditions.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-21.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>

//Some convenience methods to generate NSIndexPaths for UITableView manipulation when section is always 0
@interface NSIndexPath (SingleSectionAdditions)

+ (NSIndexPath *)indexPathForRow:(NSInteger)row;
+ (NSArray *)indexPathsForRowsInRange:(NSRange)range;
+ (NSArray *)indexPathsForRowIndexes:(NSArray *)rowIndexes;

@end
