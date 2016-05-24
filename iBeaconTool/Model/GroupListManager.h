//
//  GroupListManager.h
//  iBLocator
//
//  Created by Eurelis on 13/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Group;
@class GroupManager;
@class ConfigBeaconsTableViewController;
@interface GroupListManager : NSObject <NSFetchedResultsControllerDelegate> {
    NSMutableArray *groupListMutableArray;
    NSMutableArray *sectionListMutableArray;
    NSMutableArray *editingSectionListMutableArray;
    NSNull *null;
}

@property (nonatomic, assign) BOOL subManagerIgnoreNextChange;
@property (nonatomic, assign) BOOL ignoreNextChange;
@property (nonatomic, assign) BOOL majorChangeAsc;

@property (weak, nonatomic) ConfigBeaconsTableViewController *tableViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, readonly) NSArray *sectionArray;

- (BOOL)isBeaconEditSectionAtIndex:(NSUInteger)section;
- (BOOL)isGroupForSectionAtIndex:(NSUInteger)section;

- (NSUInteger)sectionCount;
- (id)sectionAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfRowsAtIndex:(NSUInteger)index;
- (NSManagedObject *)objectForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSMutableIndexSet *)addBeaconCellIndexSet;
- (NSArray *)addBeaconCellIndexPathArray;
- (Group *)groupForSectionAtIndex:(NSUInteger)section;


- (NSUInteger)sectionNumberForSection:(id<NSFetchedResultsSectionInfo>)section;
- (NSUInteger)sectionNumberForGroupManager:(GroupManager *)groupManager;

- (void)insertSection:(id<NSFetchedResultsSectionInfo>)section inGroupManager:(GroupManager *)manager atIndex:(NSUInteger)index;
- (void)deleteSection:(id<NSFetchedResultsSectionInfo>)section;


- (void)updateSectionInfo:(id<NSFetchedResultsSectionInfo>)section forGroupManager:(GroupManager *)manager atIndex:(NSUInteger)index;
- (void)reloadSectionsForGroupManager:(GroupManager *)groupManager;


@end
