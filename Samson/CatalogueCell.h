//
//  CategoryCell.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-21.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatalogueCell : UITableViewCell <UIScrollViewDelegate, UITextFieldDelegate>
{
  IBOutlet UIScrollView *scrollView;
  IBOutlet UITextField *nameField;
  IBOutlet UILabel *deletionIndicator;
}

+ (NSString *)nibName;
+ (NSString *)reuseIdentifier;

@property(nonatomic, weak)id catalogueEntry;
@property(nonatomic, weak)UITableView *tableView;
@property(nonatomic, weak)id controller;

- (void)markIndexPathForDeletion;

@end
