//
//  GroupManager.h
//  iBLocator
//
//  Created by Eurelis on 13/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GroupListManager;
@class Group;
@interface GroupManager : NSObject <NSFetchedResultsControllerDelegate> {
    NSUInteger deleteSection, insertSection;
}

@property (strong, nonatomic) GroupListManager *groupListManager;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) Group *group;
@property (nonatomic, assign) BOOL active;

- (NSUInteger)majorCount;
- (NSUInteger)minorCountForMajorAtIndex:(NSUInteger)index;


@end
