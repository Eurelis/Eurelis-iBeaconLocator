//
//  TableGroupListManager.m
//  iBLocator
//
//  Created by Eurelis on 21/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "TableGroupListManager.h"
#import "StoreModel.h"
#import "GroupWrapper.h"
#import "MajorWrapper.h"
#import "BeaconWrapper.h"

@implementation TableGroupListManager

- (id)initWithBeacons:(NSArray *)beacons {
    return [self initWithBeacons:beacons notificationMode:NO];
}


- (id)initWithBeacons:(NSArray *)beacons notificationMode:(BOOL)notification {
    self = [super init];
    
    if (self) {
        groupListArray = [[NSMutableArray alloc] init];
        wrapperListArray = [[NSMutableArray alloc] init];
        
        if (notification) {
            // si on n'est pas dans le cas des notifications, ce tableau ne sert à rien
            fullWrapperListArray = [[NSMutableArray alloc] init];
        }
        
        Group *tmpWorkGroup = nil;
        Major *tmpWorkMajor = nil;
        
        GroupWrapper *workGroupWrapper = nil;
        MajorWrapper *workMajorWrapper = nil;
        
        for (Beacon *beacon in beacons) {
            Major *workMajor = beacon.major;
            Group *workGroup = workMajor.group;
            
            if (![workGroup isEqual:tmpWorkGroup]) {
                workGroupWrapper = [[GroupWrapper alloc] initWithGroup:workGroup];
                [wrapperListArray addObject:workGroupWrapper];
                [groupListArray addObject:workGroupWrapper];
                [fullWrapperListArray addObject:workGroupWrapper];
                tmpWorkGroup = workGroup;
            }
            
            if (![workMajor isEqual:tmpWorkMajor]) {
                workMajorWrapper = [[MajorWrapper alloc] initWithMajor:workMajor];
                [workGroupWrapper addMajorWrapper:workMajorWrapper];
                if (!notification || ![workGroup.notification.enabled boolValue]) {
                    [wrapperListArray addObject:workMajorWrapper];
                }
                [fullWrapperListArray addObject:workMajorWrapper];
                
                tmpWorkMajor = workMajor;
            }
            
            BeaconWrapper *beaconWrapper = [[BeaconWrapper alloc] initWithBeacon:beacon];
            
            [workMajorWrapper addBeaconWrapper:beaconWrapper];
            
            [fullWrapperListArray addObject:beaconWrapper];
            if (!notification || ![workGroup.notification.enabled boolValue]) {
                if (!notification || ![workMajor.notification.enabled boolValue]) {
                    [wrapperListArray addObject:beaconWrapper];
                }
            }
            
        }
        
    }
    
    return self;
}


- (id)initWithGroup:(Group *)group notificationMode:(BOOL)notification {
    self = [super init];
    
    if (self) {
        [self reloadFromGroup:group positionOfMajor:nil notifications:notification];
        
    }
    
    return self;
}


- (NSUInteger)wrapperCount {
    return [wrapperListArray count];
}

- (id)wrapperAtIndex:(NSUInteger)index {
    return [wrapperListArray objectAtIndex:index];
}

- (void)removeSubWrappersForGroupWrapper:(GroupWrapper *)groupWrapper {
    if ([groupWrapper.group.notification.enabled boolValue]) {
        NSUInteger groupWrapperIndex = [groupListArray indexOfObject:groupWrapper];
        NSUInteger startIndex = [wrapperListArray indexOfObject:groupWrapper];
        NSUInteger nextGroupWrapperIndex = groupWrapperIndex + 1;
        NSUInteger subWrapperCount = 0;
    
        if (nextGroupWrapperIndex == [groupListArray count]) {
            subWrapperCount = [wrapperListArray count] - [wrapperListArray indexOfObject:groupWrapper] - 1;
        }
        else {
            GroupWrapper *nextGroupWrapper = [groupListArray objectAtIndex:nextGroupWrapperIndex];
            subWrapperCount = [wrapperListArray indexOfObject:nextGroupWrapper] - startIndex - 1;
        }
    
        NSRange range = NSMakeRange(startIndex + 1, subWrapperCount);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [wrapperListArray removeObjectsAtIndexes:indexSet];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
        }];
        
        [self.tableView beginUpdates];
        NSIndexPath *refreshIndexPath = [NSIndexPath indexPathForRow:startIndex inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[refreshIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (void)addSubWrappersForGroupWrapper:(GroupWrapper *)groupWrapper {
    if (![groupWrapper.group.notification.enabled boolValue]) {
        NSUInteger startIndex = [fullWrapperListArray indexOfObject:groupWrapper];
        NSUInteger groupWrapperIndex = [groupListArray indexOfObject:groupWrapper];
        NSUInteger insertIndex = [wrapperListArray indexOfObject:groupWrapper];
        NSUInteger nextGroupWrapperIndex = groupWrapperIndex + 1;
        NSUInteger subWrapperCount = 0;
        
        if (nextGroupWrapperIndex == [groupListArray count]) {
            subWrapperCount = [fullWrapperListArray count] - [fullWrapperListArray indexOfObject:groupWrapper] - 1;
        }
        else {
            GroupWrapper *nextGroupWrapper = [groupListArray objectAtIndex:nextGroupWrapperIndex];
            subWrapperCount = [fullWrapperListArray indexOfObject:nextGroupWrapper] - startIndex - 1;
        }
        
        NSRange range = NSMakeRange(startIndex + 1, subWrapperCount);
        NSArray *subWrappers = [fullWrapperListArray subarrayWithRange:range];
        
        NSRange insertRange = NSMakeRange(insertIndex + 1, subWrapperCount);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:insertRange];
        [wrapperListArray insertObjects:subWrappers atIndexes:indexSet];
        
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
        }];
        
        [self.tableView beginUpdates];
        NSIndexPath *refreshIndexPath = [NSIndexPath indexPathForRow:insertIndex inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[refreshIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}


- (void)removeSubWrappersForMajorWrapper:(MajorWrapper *)majorWrapper {
    if ([majorWrapper.major.notification.enabled boolValue]) {
        NSUInteger startIndex = [wrapperListArray indexOfObject:majorWrapper] + 1;
        
        NSRange subArrayRange = NSMakeRange(startIndex, [wrapperListArray count] - startIndex);
        NSArray *subArray = [wrapperListArray subarrayWithRange:subArrayRange];
        
        Class beaconWrapperClass = NSClassFromString(@"BeaconWrapper");
        
        __block NSUInteger subWrapperCount = 0;
        [subArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:beaconWrapperClass]) {
                subWrapperCount++;
            }
            else {
                *stop = YES;
            }
        }];
        
        NSRange range = NSMakeRange(startIndex, subWrapperCount);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [wrapperListArray removeObjectsAtIndexes:indexSet];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
        }];
        
        [self.tableView beginUpdates];
        NSIndexPath *refreshIndexPath = [NSIndexPath indexPathForRow:(startIndex - 1) inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[refreshIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}


- (void)addSubWrappersForMajorWrapper:(MajorWrapper *)majorWrapper {
    if (![majorWrapper.major.notification.enabled boolValue]) {
        NSUInteger startIndex = [fullWrapperListArray indexOfObject:majorWrapper] + 1;
        NSUInteger insertIndex = [wrapperListArray indexOfObject:majorWrapper] + 1;
        
        NSRange subArrayRange = NSMakeRange(startIndex, [fullWrapperListArray count] - startIndex);
        NSArray *subArray = [fullWrapperListArray subarrayWithRange:subArrayRange];
        
        Class beaconWrapperClass = NSClassFromString(@"BeaconWrapper");
        
        __block NSUInteger subWrapperCount = 0;
        [subArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:beaconWrapperClass]) {
                subWrapperCount++;
            }
            else {
                *stop = YES;
            }
        }];
        
        NSRange range = NSMakeRange(startIndex, subWrapperCount);
        NSRange insertRange = NSMakeRange(insertIndex, subWrapperCount);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:insertRange];
        
        NSArray *insertSubArray = [fullWrapperListArray subarrayWithRange:range];
        [wrapperListArray insertObjects:insertSubArray atIndexes:indexSet];

        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
        }];
        
        [self.tableView beginUpdates];
        NSIndexPath *refreshIndexPath = [NSIndexPath indexPathForRow:(startIndex - 1) inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[refreshIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        
    }
}

- (void)reloadWrapperForBeaconWrapper:(BeaconWrapper *)beaconWrapper {
    NSUInteger wrapperPosition = [wrapperListArray indexOfObject:beaconWrapper];
    
    if (wrapperPosition != NSNotFound) {
        
        NSIndexPath *refreshIndexPath = [NSIndexPath indexPathForRow:wrapperPosition inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[refreshIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    
}


- (NSUInteger)positionOfBeaconWrapperWithBeacon:(Beacon *)beacon {
    
    return [wrapperListArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[BeaconWrapper class]]) {
            if ([[obj valueForKey:@"beacon"] isEqual:beacon]) {
                return YES;
            }
        }
        return NO;
    }];
    
}

- (NSUInteger)insertMajor:(Major *)major atIndex:(NSUInteger)majorPosition {
    NSUInteger insertPosition = NSNotFound;
    
    
    
    return insertPosition;
}


- (NSUInteger)reloadFromGroup:(Group *)group  positionOfMajor:(Major *)majorToFind notifications:(BOOL)notification{
    NSUInteger majorPosition = NSNotFound;
    
    NSUInteger currentPosition = 0;
    
    groupListArray = [[NSMutableArray alloc] init];
    wrapperListArray = [[NSMutableArray alloc] init];
    
    BOOL groupNotificationEnabled = (!notification || ![group.notification.enabled boolValue]);
    
    if (notification) {
        // si on n'est pas dans le cas des notifications, ce tableau ne sert à rien
        fullWrapperListArray = [[NSMutableArray alloc] init];
    }
    
    
    GroupWrapper *groupWrapper = [[GroupWrapper alloc] initWithGroup:group];
    [groupListArray addObject:groupWrapper];
    [wrapperListArray addObject:groupWrapper];
    [fullWrapperListArray addObject:groupWrapper];
    
    NSSortDescriptor *majorSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"major" ascending:YES];
    NSSortDescriptor *beaconSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *majorArray = [group.majors sortedArrayUsingDescriptors:@[majorSortDescriptor]];
    
    for (Major *major in majorArray) {
        
        MajorWrapper *majorWrapper = [[MajorWrapper alloc] initWithMajor:major];
        [groupWrapper addMajorWrapper:majorWrapper];
        
        if (groupNotificationEnabled) {
            currentPosition++;
            if ([major isEqual:majorToFind]) {
                majorPosition = currentPosition;
            }
            
            [wrapperListArray addObject:majorWrapper];
        }
        [fullWrapperListArray addObject:majorWrapper];
        
        BOOL majorNotificationEnabled = (groupNotificationEnabled && (!notification || ![major.notification.enabled boolValue]));
        
        NSArray *beaconArray = [major.beacons sortedArrayUsingDescriptors:@[beaconSortDescriptor]];
        
        for (Beacon *beacon in beaconArray) {
            BeaconWrapper *beaconWrapper = [[BeaconWrapper alloc] initWithBeacon:beacon];
            [majorWrapper addBeaconWrapper:beaconWrapper];
            
            [fullWrapperListArray addObject:beaconWrapper];
            if (majorNotificationEnabled) {
                currentPosition++;
                [wrapperListArray addObject:beaconWrapper];
            }
        }
        
    }
    
    
    return majorPosition;
}


@end
