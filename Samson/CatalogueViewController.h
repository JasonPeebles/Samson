//
//  CatalogueViewController.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewGestureRecognizer.h"

@interface CatalogueViewController : UITableViewController
{
  NSIndexPath *indexPathMarkedForDeletion;
}

- (void)markIndexPathForDeletion:(NSIndexPath *)indexPath;

@end
