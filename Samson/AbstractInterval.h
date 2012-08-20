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

@property (nonatomic, strong) NSNumber *repetitions;
@property (nonatomic, strong) NSNumber *restSeconds;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSNumber *workSeconds;

@end
