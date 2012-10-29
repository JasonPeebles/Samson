//
//  TextFieldCell.h
//  Samson
//
//  Created by Jason Peebles on 2012-10-29.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldCell : UITableViewCell

@property(nonatomic, strong)id object;
@property(nonatomic, strong)NSString *keyPath;

- (void)beginEditing;
- (void)endEditing;
- (void)setTextColor:(UIColor *)textColor;
+ (NSString *)reuseIdentifier;

@end
