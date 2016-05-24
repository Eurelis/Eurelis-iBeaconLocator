//
//  Beacon.h
//  iBLocator
//
//  Created by Eurelis on 17/03/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Major, Notification, PointOfInterest;

@interface Beacon : NSManagedObject

@property (nonatomic, retain) NSNumber * accuracy;
@property (nonatomic, retain) NSString * minor;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * proximity;
@property (nonatomic, retain) NSNumber * rssi;
@property (nonatomic, retain) NSNumber * txPower;
@property (nonatomic, retain) Major *major;
@property (nonatomic, retain) Notification *notification;
@property (nonatomic, retain) NSSet *pois;
@end

@interface Beacon (CoreDataGeneratedAccessors)

- (void)addPoisObject:(PointOfInterest *)value;
- (void)removePoisObject:(PointOfInterest *)value;
- (void)addPois:(NSSet *)values;
- (void)removePois:(NSSet *)values;

@end
