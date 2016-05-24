//
//  Group.h
//  iBLocator
//
//  Created by Eurelis on 25/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Major, Notification;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSSet *majors;
@property (nonatomic, retain) Notification *notification;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addMajorsObject:(Major *)value;
- (void)removeMajorsObject:(Major *)value;
- (void)addMajors:(NSSet *)values;
- (void)removeMajors:(NSSet *)values;

@end
