//
//  Notification.h
//  iBLocator
//
//  Created by Eurelis on 25/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Beacon, Group, Major;

@interface Notification : NSManagedObject

@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSNumber * onDisplay;
@property (nonatomic, retain) NSNumber * onEntry;
@property (nonatomic, retain) NSNumber * onExit;
@property (nonatomic, retain) Beacon *beacon;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) Major *major;

@end
