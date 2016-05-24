//
//  Major.h
//  iBLocator
//
//  Created by Eurelis on 25/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Beacon, Group, Notification;

@interface Major : NSManagedObject

@property (nonatomic, retain) NSString * major;
@property (nonatomic, retain) NSSet *beacons;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) Notification *notification;
@end

@interface Major (CoreDataGeneratedAccessors)

- (void)addBeaconsObject:(Beacon *)value;
- (void)removeBeaconsObject:(Beacon *)value;
- (void)addBeacons:(NSSet *)values;
- (void)removeBeacons:(NSSet *)values;

@end
