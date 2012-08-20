//
//  AbstractInterval.h
//  Samson
//
//  Created by Jason Peebles on 2012-08-20.
//  Copyright (c) 2012 Jason Peebles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AbstractInterval : NSManagedObject

@property (nonatomic) int16_t repetitions;
@property (nonatomic) int16_t restSeconds;
@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic) int16_t workSeconds;

@end
