//
//  CategoryCell.m
//  Samson
//
//  Created by Jason Peebles on 2012-08-21.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import "CatalogueCell.h"
#import "Category.h"
#import "Category+Custom.h"

#define CELL_IDENTIFIER @"CatalogueCell"
#define NIB_NAME @"CatalogueCell"
#define DELETION_OFFSET_THRESHOLD 50.0;

@implementation CatalogueCell

@synthesize tableView;
@synthesize controller;

+ (NSString *)nibName;
{
  return NIB_NAME;
}

+ (NSString *)reuseIdentifier;
{
  return CELL_IDENTIFIER;
}

- (id)init
{
  self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
  
  if (!self)
  {
    return nil;
  }
  

  return self;
}

- (void)awakeFromNib
{
  CGSize contentViewSize = [[self contentView] frame].size;
  
  CGFloat width = contentViewSize.width + DELETION_OFFSET_THRESHOLD;
  [scrollView setContentSize:CGSizeMake(width, contentViewSize.height)];
}

- (void)setCatalogueEntry:(id)obj
{
  _catalogueEntry = obj;
  
  [nameField setText:[_catalogueEntry description]];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

#pragma mark - UIScrollViewDelegate Protocol
- (void)scrollViewDidScroll:(UIScrollView *)scroll
{
  CGFloat xOffset = [scroll contentOffset].x;
  NSLog(@"Offset: %f", xOffset);
  
  CGFloat threshold = DELETION_OFFSET_THRESHOLD;
  
  CGFloat alpha = 1 - ((threshold - xOffset)/threshold);
  
  if (0 <= alpha && alpha <= 1)
  {
    [deletionIndicator setAlpha:alpha];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scroll willDecelerate:(BOOL)decelerate
{
  CGFloat xOffset = [scroll contentOffset].x;
  
  CGFloat threshold = DELETION_OFFSET_THRESHOLD;
  
  if (xOffset > 0)
  {
    [UIView animateWithDuration:0.5
                     animations:^{
      [scroll setContentOffset:CGPointZero];
    }
                    completion:^(BOOL finished) {
                      if (xOffset > threshold)
                      {
                        [self markIndexPathForDeletion];
                      }
                    }];
  
  }
  
//  if (xOffset > threshold)
//  {
//    [self markIndexPathForDeletion];
//  }
  
}

- (void)markIndexPathForDeletion;
{
  NSString *selectorName = [NSString stringWithFormat:@"%@:", NSStringFromSelector(_cmd)];
  SEL selector =  NSSelectorFromString(selectorName);
  id indexPath = [[self tableView] indexPathForCell:self];
  
  if ([[self controller] respondsToSelector:selector])
  {
    [[self controller] performSelector:selector withObject:indexPath];
  }
}




@end
