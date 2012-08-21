//
//  NSIndexPath+SingleSectionAdditions.m
//  Samson
//
//  Created by Jason Peebles on 2012-08-21.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import "NSIndexPath+SingleSectionAdditions.h"

@implementation NSIndexPath (SingleSectionAdditions)

+ (NSIndexPath *)indexPathForRow:(NSInteger)row;
{
  return [NSIndexPath indexPathForRow:row inSection:0];
}

+ (NSArray *)indexPathsForRowsInRange:(NSRange)range;
{
  id indexPaths = [NSMutableArray array];
  
  for (int row = range.location; row < range.location + range.length; row++) {
    [indexPaths addObject:[NSIndexPath indexPathForRow:row]];
  }
  
  return indexPaths;
}

+ (NSArray *)indexPathsForRowIndexes:(NSArray *)rowIndexes;
{
  id indexPaths = [NSMutableArray array];
  
  [rowIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [indexPaths addObject:[NSIndexPath indexPathForRow:[obj intValue]]];
  }];
  
  return indexPaths;
}

@end
