//
//  GroupListManager.m
//  iBLocator
//
//  Created by Eurelis on 13/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "GroupListManager.h"
#import "GroupManager.h"
#import "AppDelegate.h"
#import "StoreModel.h"
#import "ConfigBeaconsTableViewController.h"

@implementation GroupListManager

- (id)init {
    if (self = [super init]) {
        groupListMutableArray = [[NSMutableArray alloc] init];
        sectionListMutableArray = [[NSMutableArray alloc] init];
        editingSectionListMutableArray = [[NSMutableArray alloc] init];
        
        null = [NSNull null];
        
        NSFetchedResultsController *resultsController = self.fetchedResultsController;
        NSError *error = nil;
        if (![resultsController performFetch:&error]) {
            //NSLog(@"%@", error);
        }
        
        NSArray *results = [resultsController fetchedObjects];
        for (Group *group in results) {
            GroupManager *groupManager = [[GroupManager alloc] init];
            groupManager.groupListManager = self;
            groupManager.uuid = group.uuid;
            groupManager.group = group;
            groupManager.groupName = group.name;
            groupManager.active = [group.active boolValue];
            
            [groupListMutableArray addObject:groupManager];
            [sectionListMutableArray addObject:groupManager];
            [editingSectionListMutableArray addObject:groupManager];
            
            if (groupManager.active) {
                NSArray *sections = [groupManager.fetchedResultsController sections];
                
                [sectionListMutableArray addObjectsFromArray:sections];
                [editingSectionListMutableArray addObjectsFromArray:sections];
                //[editingSectionListMutableArray addObject:null];
            }
            
            
            
            
        }
        
        
    }
    
    return self;
}



- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    return _managedObjectContext;
}


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}


- (NSUInteger)sectionNumberForSection:(id<NSFetchedResultsSectionInfo>)section {
    return [self.sectionArray indexOfObject:section] + (self.tableViewController.isReallyEditing ? 1 : 0);
    
}

- (NSUInteger)sectionNumberForGroupManager:(GroupManager *)groupManager {
    return [self.sectionArray indexOfObject:groupManager] + (self.tableViewController.isReallyEditing ? 1 : 0);
}




- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {

    if (!_ignoreNextChange) {
        [self.tableViewController.tableView beginUpdates];
    }
    else {
        _subManagerIgnoreNextChange = YES;
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    if (!_ignoreNextChange) {
        [self.tableViewController.tableView endUpdates];
        
    }
    else {
        _ignoreNextChange = NO;
    }
    
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (!_ignoreNextChange) {
    
    Group *group = (Group *)anObject;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            NSUInteger section = newIndexPath.row;
            
            NSUInteger groupSection = section;
            if (self.tableViewController.isReallyEditing) {
                groupSection++;
            }
            
            NSMutableIndexSet *groupSectionIndexSet = [NSMutableIndexSet indexSet];
            
            GroupManager *groupManager = [[GroupManager alloc] init];
            groupManager.groupListManager = self;
            [groupListMutableArray insertObject:groupManager atIndex:section];
            groupManager.group = group;
            groupManager.uuid = group.uuid;
            groupManager.groupName = group.name;
            groupManager.active = [group.active boolValue];
            
            NSUInteger sectionListInsertionIndex = 0;
            NSUInteger editingSectionListInsertionIndex = 0;
            
            if (group.active) {
                [groupManager fetchedResultsController];
            }
            
            
            if (section == 0) {
                [sectionListMutableArray insertObject:groupManager atIndex:0];
                [groupSectionIndexSet addIndex:(self.tableViewController.isReallyEditing ? 1 : 0)];
                
                [editingSectionListMutableArray insertObject:groupManager atIndex:0];
                
            }
            else {
                GroupManager *previousGroupManager = [groupListMutableArray objectAtIndex:(section - 1)];
                sectionListInsertionIndex = [sectionListMutableArray indexOfObject:previousGroupManager] + 1;
                editingSectionListInsertionIndex = [editingSectionListMutableArray indexOfObject:previousGroupManager] + 1;
                
                sectionListInsertionIndex += [previousGroupManager majorCount];
                editingSectionListInsertionIndex += [previousGroupManager majorCount];
                
                
                [sectionListMutableArray insertObject:groupManager atIndex:sectionListInsertionIndex];
                
                [editingSectionListMutableArray insertObject:groupManager atIndex:editingSectionListInsertionIndex];
                
                if (self.tableViewController.isReallyEditing) {
                    [groupSectionIndexSet addIndex:(editingSectionListInsertionIndex + 1)];
                    
                }
                
            }
            
            
            // animation APRES l'ajout
            [self.tableViewController.tableView insertSections:groupSectionIndexSet withRowAnimation:UITableViewRowAnimationTop];
            
        }
            break;
        case NSFetchedResultsChangeDelete:
        {
            
            NSUInteger row = indexPath.row;
            GroupManager *groupManager = [groupListMutableArray objectAtIndex:row];
            
            NSUInteger nextGroupManagerIndex = row + 1;
            
            NSUInteger groupSize = 1;
            NSUInteger startIndex = [sectionListMutableArray indexOfObject:groupManager];
            NSUInteger editingStartIndex = [editingSectionListMutableArray indexOfObject:groupManager];
            
            if (nextGroupManagerIndex == [groupListMutableArray count]) {
                groupSize = [sectionListMutableArray count] - startIndex;
                
            }
            else {
                GroupManager *nextGroupManager = [groupListMutableArray objectAtIndex:nextGroupManagerIndex];
                groupSize = [sectionListMutableArray indexOfObject:nextGroupManager] - startIndex;
                
            }
            
            [groupListMutableArray removeObjectAtIndex:row];
            [sectionListMutableArray removeObjectsInRange:NSMakeRange(startIndex, groupSize)];
            
            // si le groupe est actif il y a un NSNull derrière
            [editingSectionListMutableArray removeObjectsInRange:NSMakeRange(editingStartIndex, groupSize)];

            
            NSIndexSet *deleteIndexSet = nil;
            if (self.tableViewController.isReallyEditing) {
                deleteIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(editingStartIndex + 1, groupSize)];

            }
            else {
                deleteIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, groupSize)];
            }
            
            [self.tableViewController.tableView deleteSections:deleteIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
            break;
        case NSFetchedResultsChangeMove:
        {
            BOOL insertBefore = (indexPath.row > newIndexPath.row);
            
            NSIndexPath *indexPathA, *indexPathB;
            
            if (insertBefore) {
                indexPathA = indexPath;
                indexPathB = newIndexPath;
            }
            else {
                indexPathA = newIndexPath;
                indexPathB = indexPath;
            }
            
            GroupManager *groupManagerToUpdate = [groupListMutableArray objectAtIndex:indexPath.row];
            NSUInteger sectionIndex = [self.sectionArray indexOfObject:groupManagerToUpdate] + (self.tableViewController.isReallyEditing ? 1 : 0);
            
            UITableViewCell *cell = [self.tableViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
            [self.tableViewController configureCell:cell withGroup:group];
            
            NSUInteger row = indexPathA.row;
            GroupManager *groupManager = [groupListMutableArray objectAtIndex:row];
            
            NSUInteger nextGroupManagerIndex = row + 1;
            
            NSUInteger groupSize = 1;
            NSUInteger startIndex = [sectionListMutableArray indexOfObject:groupManager];
            NSUInteger editingStartIndex = [editingSectionListMutableArray indexOfObject:groupManager];
            
            NSArray *sectionArray, *editingSectionArray;
            
            if (nextGroupManagerIndex == [groupListMutableArray count]) {
                // a la fin
                groupSize = [sectionListMutableArray count] - startIndex;
                
            }
            else {
                GroupManager *nextGroupManager = [groupListMutableArray objectAtIndex:nextGroupManagerIndex];
                groupSize = [sectionListMutableArray indexOfObject:nextGroupManager] - startIndex;
                
            }
            
            
            NSRange sectionRange = NSMakeRange(startIndex, groupSize);
            NSRange editingSectionRange = NSMakeRange(editingStartIndex, groupSize + (groupManager.active ? 1 : 0));
            
            sectionArray = [sectionListMutableArray subarrayWithRange:sectionRange];
            
            
            // si le groupe est actif il y a un NSNull derrière
            editingSectionArray = [editingSectionListMutableArray subarrayWithRange:editingSectionRange];
            

            NSUInteger newRow = indexPathB.row;
            GroupListManager *newGroupListManager = [groupListMutableArray objectAtIndex:newRow];
            
            
            [groupListMutableArray removeObjectAtIndex:row];
            [editingSectionListMutableArray removeObjectsInRange:editingSectionRange];
            [sectionListMutableArray removeObjectsInRange:sectionRange];
            [groupListMutableArray insertObject:groupManager atIndex:newRow];
            
            NSUInteger newPosition = [sectionListMutableArray indexOfObject:newGroupListManager];
            NSUInteger editingNewPosition = [editingSectionListMutableArray indexOfObject:newGroupListManager];
            
            
            NSRange insertSectionRange = NSMakeRange(newPosition, groupSize);
            NSRange insertEditingSectionRange = NSMakeRange(editingNewPosition, editingSectionRange.length);
            
            [sectionListMutableArray insertObjects:sectionArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:insertSectionRange]];
            [editingSectionListMutableArray insertObjects:editingSectionArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:insertEditingSectionRange]];
            
            
            if (self.tableViewController.isReallyEditing) {
                for (NSUInteger i = 0; i < insertEditingSectionRange.length; i++) {
                    [self.tableViewController.tableView moveSection:(editingStartIndex + i) toSection:(editingNewPosition + i)];
                }
            }
            else {
                for (NSUInteger i = 0; i < insertSectionRange.length; i++) {
                    [self.tableViewController.tableView moveSection:(startIndex + i) toSection:(newPosition + i)];
                }
            }
            
        }
            break;
        case NSFetchedResultsChangeUpdate:
        {
            GroupManager *groupManager = [groupListMutableArray objectAtIndex:indexPath.row];
            
            NSUInteger sectionIndex = [self.sectionArray indexOfObject:groupManager] + (self.tableViewController.isReallyEditing ? 1 : 0);
            
            UITableViewCell *cell = [self.tableViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
            [self.tableViewController configureCell:cell withGroup:group];
            
            BOOL tmpActive = groupManager.active;
            BOOL active = [group.active boolValue];
            
            if (tmpActive != active) {
                NSUInteger startIndex = [sectionListMutableArray indexOfObject:groupManager];
                NSUInteger editingStartIndex = [editingSectionListMutableArray indexOfObject:groupManager];
                
                NSArray *sections = [groupManager.fetchedResultsController sections];
                NSUInteger sectionCount = [sections count];
                
                NSRange indexRange = NSMakeRange(startIndex + 1, sectionCount);
                NSRange editingIndexRange = NSMakeRange(editingStartIndex + 1, sectionCount);
                
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:indexRange];
                NSIndexSet *editingIndexSet = [NSIndexSet indexSetWithIndexesInRange:editingIndexRange];
                
                if (active) {
                    [sectionListMutableArray insertObjects:sections atIndexes:indexSet];
                    [editingSectionListMutableArray insertObjects:sections atIndexes:editingIndexSet];
                    
                    if (self.tableViewController.isReallyEditing) {
                        editingIndexRange = NSMakeRange(editingStartIndex + 2, sectionCount);
                        editingIndexSet = [NSIndexSet indexSetWithIndexesInRange:editingIndexRange];
                        
                        [self.tableViewController.tableView insertSections:editingIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                    }
                    else {
                        [self.tableViewController.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    
                    
                }
                else if (!active) {
                    [sectionListMutableArray removeObjectsInRange:indexRange];
                    [editingSectionListMutableArray removeObjectsInRange:editingIndexRange];
                    
                    if (self.tableViewController.isReallyEditing) {
                        editingIndexRange = NSMakeRange(editingStartIndex + 2, sectionCount);
                        editingIndexSet = [NSIndexSet indexSetWithIndexesInRange:editingIndexRange];
                        
                        [self.tableViewController.tableView deleteSections:editingIndexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    else {
                        [self.tableViewController.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    
                }
                
                groupManager.active = active;
            }
            
        }
            
            break;
        }
        
    }
    
}


- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    //NSLog(@"sectionName %@", sectionName);
    
    return sectionName;
}


- (id)sectionAtIndex:(NSUInteger)index {
    return [self.sectionArray objectAtIndex:index];
}

- (BOOL)isGroupForSectionAtIndex:(NSUInteger)section {
    id sectionObject = [self.sectionArray objectAtIndex:section];
    return ([sectionObject isKindOfClass:[GroupManager class]]);
}


- (NSUInteger)numberOfRowsAtIndex:(NSUInteger)index {
    
    id section = [self.sectionArray objectAtIndex:index];
    
    if ([section isEqual:null]) {
        return 1;
    }
    else if ([section isKindOfClass:[GroupManager class]]) {
        return 2 + (self.tableViewController.isReallyEditing?1:0);
    }
    else {
        id<NSFetchedResultsSectionInfo> sectionInfo = (id<NSFetchedResultsSectionInfo>)section;

#if TARGET_IPHONE_SIMULATOR
#if __LP64__
        //NSLog(@"sectionInfo numberOfObjects %lu", sectionInfo.numberOfObjects);
#else
        //NSLog(@"sectionInfo numberOfObjects %u", sectionInfo.numberOfObjects);
#endif
#endif
        return sectionInfo.numberOfObjects;
    }


}


- (BOOL)isBeaconEditSectionAtIndex:(NSUInteger)section {
    if (self.tableViewController.isReallyEditing) {
        if ([[editingSectionListMutableArray objectAtIndex:section] isEqual:null]) {
            return YES;
        }
    }
    return NO;
}


- (Group *)groupForSectionAtIndex:(NSUInteger)section {
    if ([self isBeaconEditSectionAtIndex:section]) {
        section--;
    }
    
    NSManagedObject *object = [self objectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    if ([object isKindOfClass:[Group class]]) {
        return (Group *)object;
    }
    else if ([object isKindOfClass:[Beacon class]]) {
        return ((Beacon *)object).major.group;
        
    }
    
    return nil;
}



- (NSManagedObject *)objectForRowAtIndexPath:(NSIndexPath *)indexPath {

    id section = [self.sectionArray objectAtIndex:indexPath.section];
    
    if ([section isEqual:null]) {
        return nil;
    }
    else if ([section isKindOfClass:[GroupManager class]]) {
        NSUInteger sectionIndex = [groupListMutableArray indexOfObject:section];
        
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForRow:sectionIndex inSection:0];
        return [self.fetchedResultsController objectAtIndexPath:sectionIndexPath];
    }
    
    else {
        id<NSFetchedResultsSectionInfo> sectionInfo = (id<NSFetchedResultsSectionInfo>)section;
        return sectionInfo.objects[indexPath.row];
    }
    
}

- (NSUInteger)sectionCount {
    return [self.sectionArray count];
}


- (NSArray *)sectionArray {
    return (self.tableViewController.isReallyEditing)?editingSectionListMutableArray:sectionListMutableArray;
}


- (NSMutableIndexSet *)addBeaconCellIndexSet {
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    [editingSectionListMutableArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isEqual:null]) {
            [indexSet addIndex:(idx + 1)];
        }
        
    }];
    return indexSet;
}

- (NSArray *)addBeaconCellIndexPathArray {
    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
    Class groupManagerClass = NSClassFromString(@"GroupManager");
    [editingSectionListMutableArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isKindOfClass:[groupManagerClass class]]) {
            [indexPathArray addObject:[NSIndexPath indexPathForRow:2 inSection:(idx + 1)]];
        }
        
    }];

    return indexPathArray;
}


- (void)insertSection:(id<NSFetchedResultsSectionInfo>)section inGroupManager:(GroupManager *)manager atIndex:(NSUInteger)index {
    
    NSUInteger sectionIndex = [sectionListMutableArray indexOfObject:manager] + 1 + index;
    NSUInteger editingSectionIndex = [editingSectionListMutableArray indexOfObject:manager] + 1 + index;
    
    [sectionListMutableArray insertObject:section atIndex:sectionIndex];
    [editingSectionListMutableArray insertObject:section atIndex:editingSectionIndex];
    
    
    
}

- (void)deleteSection:(id<NSFetchedResultsSectionInfo>)section {
    [sectionListMutableArray removeObject:section];
    [editingSectionListMutableArray removeObject:section];
    
}


- (void)updateSectionInfo:(id<NSFetchedResultsSectionInfo>)section forGroupManager:(GroupManager *)manager atIndex:(NSUInteger)index {
    
    NSUInteger sectionIndex = [sectionListMutableArray indexOfObject:manager] + 1 + index;
    NSUInteger editingSectionIndex = [editingSectionListMutableArray indexOfObject:manager] + 1 + index;
    
    [sectionListMutableArray replaceObjectAtIndex:sectionIndex withObject:section];
    [editingSectionListMutableArray replaceObjectAtIndex:editingSectionIndex withObject:section];
    
    
}


- (void)reloadSectionsForGroupManager:(GroupManager *)groupManager {
    
    NSUInteger nextGroupManagerIndex = [groupListMutableArray indexOfObject:groupManager] + 1;
    
    NSUInteger groupSize = 1;
    NSUInteger startIndex = [sectionListMutableArray indexOfObject:groupManager];
    NSUInteger editingStartIndex = [editingSectionListMutableArray indexOfObject:groupManager];
    
    if (nextGroupManagerIndex == [groupListMutableArray count]) {
        groupSize = [sectionListMutableArray count] - startIndex;
        
    }
    else {
        GroupManager *nextGroupManager = [groupListMutableArray objectAtIndex:nextGroupManagerIndex];
        groupSize = [sectionListMutableArray indexOfObject:nextGroupManager] - startIndex;
        
    }
    groupSize--;
    
    NSRange updateRange;
    
    if (self.tableViewController.isReallyEditing) {
        updateRange = NSMakeRange(editingStartIndex + 2, groupSize);
    }
    else {
        updateRange = NSMakeRange(startIndex + 1, groupSize);
    }
    
    [self.tableViewController.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:updateRange] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //NSRange updateRange = NSMakeRange(<#NSUInteger loc#>, <#NSUInteger len#>)
    
    
}



@end
