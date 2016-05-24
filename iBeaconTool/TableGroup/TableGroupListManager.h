//
//  TableGroupListManager.h
//  iBLocator
//
//  Created by Eurelis on 21/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GroupWrapper;
@class MajorWrapper;
@class BeaconWrapper;
@class Beacon;
@class Group;
@class Major;
@interface TableGroupListManager : NSObject {
    NSMutableArray *fullWrapperListArray;
    NSMutableArray *wrapperListArray;
    NSMutableArray *groupListArray;
    
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (id)initWithBeacons:(NSArray *)beacons notificationMode:(BOOL)notification;
- (id)initWithBeacons:(NSArray *)beacons;
- (id)initWithGroup:(Group *)group notificationMode:(BOOL)notification;

- (NSUInteger)reloadFromGroup:(Group *)group  positionOfMajor:(Major *)major notifications:(BOOL)notification;

- (NSUInteger)wrapperCount;
- (id)wrapperAtIndex:(NSUInteger)index;

- (void)removeSubWrappersForGroupWrapper:(GroupWrapper *)groupWrapper;
- (void)addSubWrappersForGroupWrapper:(GroupWrapper *)groupWrapper;

- (void)removeSubWrappersForMajorWrapper:(MajorWrapper *)majorWrapper;
- (void)addSubWrappersForMajorWrapper:(MajorWrapper *)majorWrapper;

- (void)reloadWrapperForBeaconWrapper:(BeaconWrapper *)beaconWrapper ;

- (NSUInteger)positionOfBeaconWrapperWithBeacon:(Beacon *)beacon;
- (NSUInteger)insertMajor:(Major *)major atIndex:(NSUInteger)majorPosition;

@end
