//
//  TextFieldCell.m
//  Samson
//
//  Created by Jason Peebles on 2012-10-29.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import "TextFieldCell.h"

static NSString *ReuseIdentifier = @"TextFieldCell";

@interface TextFieldCell() <UITextFieldDelegate>

- (void)updateText;

@property(nonatomic, retain)UITextField *textField;

@end

@implementation TextFieldCell

+ (NSString *)reuseIdentifier;
{
  return ReuseIdentifier;
}

- (id)init;
{
  self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReuseIdentifier];
  
  [self setTextField:[[UITextField alloc] initWithFrame:CGRectZero]];
  [[self textField] setDelegate:self];
  [[self textField] setReturnKeyType:UIReturnKeyDone];
  [[self textField] setUserInteractionEnabled:NO];
  [[self contentView] addSubview:[self textField]];
  
  return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
{
  return [self init];
}

- (void)updateText;
{
  [[self textField] setText:[[self object] valueForKeyPath:[self keyPath]]];
}

- (void)setObject:(id)object;
{
  if ([_object isEqual:object])
  {
    return;
  }
  
  _object = object;
  
  if ([self keyPath])
  {
    [self updateText];
  }
}

- (void)setKeyPath:(NSString *)keyPath;
{
  if ([_keyPath isEqualToString:keyPath])
  {
    return;
  }
  
  _keyPath = keyPath;
  
  if ([self object])
  {
    [self updateText];
  }
}

- (void)beginEditing;
{
  [[self textField] setUserInteractionEnabled:YES];
  [[self textField] becomeFirstResponder];
}

- (void)endEditing;
{
  [[self textField] setUserInteractionEnabled:NO];
  [[self textField] resignFirstResponder];
}

- (void)setTextColor:(UIColor *)textColor;
{
  [[self textField] setTextColor:textColor];
}

- (void)layoutSubviews;
{
  CGRect bounds = [[self contentView] bounds];
  CGFloat inset = 10;
//  [[self textField] setBackgroundColor:[UIColor greenColor]];
  [[self textField] setFrame:CGRectInset(bounds, inset, inset)];
}

#pragma mark - UITextFieldDelegate Protocol
- (void)textFieldDidEndEditing:(UITextField *)field;
{
  [[self object] setValue:[field text] forKeyPath:[self keyPath]];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)field
{
  return [[field text] length] > 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)field
{
  [self endEditing];
  return YES;
}

@end
