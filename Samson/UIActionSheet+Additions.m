//
//  UIActionSheet+Additions.m
//  1to1Real
//
//  Created by Jason Peebles on 12/23/11.
//  Copyright (c) 2011 CMaeON. All rights reserved.
//

#import "UIActionSheet+Additions.h"

@implementation UIActionSheet (Additions)

- (void)show;
{
  [self showInView:[[UIApplication sharedApplication] keyWindow]];
}

@end
