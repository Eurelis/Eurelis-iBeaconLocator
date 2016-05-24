//
//  GroupManager.m
//  iBLocator
//
//  Created by Eurelis on 13/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "GroupManager.h"
#import "AppDelegate.h"
#import "GroupListManager.h"
#import "ConfigBeaconsTableViewController.h"

@implementation GroupManager

- (id)init {
    if (self = [super init]) {

    }
    
    return self;
}

- (NSUInteger)majorCount {
    if (!_active) {
        return 0;
    }
    
    return [[self.fetchedResultsController sections] count];
}

- (NSUInteger)minorCountForMajorAtIndex:(NSUInteger)index {
    if (!_active) {
        return 0;
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][index];
    return [sectionInfo numberOfObjects];
}




#pragma mark - FetchedResultsControllerDelegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    deleteSection = insertSection = NSNotFound;
    
    [self.groupListManager.tableViewController.tableView beginUpdates];
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.groupListManager.tableViewController.tableView endUpdates];
    self.groupListManager.subManagerIgnoreNextChange = NO;
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    NSArray *sectionInfoArray = [self.fetchedResultsController sections];
    
    
    //Beacon *beacon = (Beacon *)anObject;
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            id <NSFetchedResultsSectionInfo> section = [[self.fetchedResultsController sections] objectAtIndex:newIndexPath.section];
            
            if (section.numberOfObjects > 1) {
                NSUInteger realSection = [self.groupListManager sectionNumberForSection:section];
            
                NSIndexPath *insertIndexpath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:realSection];
            
                [self.groupListManager.tableViewController.tableView insertRowsAtIndexPaths:@[insertIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }
            break;
        case NSFetchedResultsChangeDelete:
        {            
            NSUInteger sectionNumber = [self.groupListManager sectionNumberForGroupManager:self] + 1 + indexPath.section;
            NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:sectionNumber];
            
            [self.groupListManager.tableViewController.tableView deleteRowsAtIndexPaths:@[realIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
            break;
        case NSFetchedResultsChangeMove:
        {
         
            // on met à jour les sections info pour la section d'origine et la section d'arrivée
            
            NSUInteger origSection = indexPath.section;
            NSUInteger destSection = newIndexPath.section;
            
            //if (!self.groupListManager.subManagerIgnoreNextChange) {
                
            NSUInteger sectionNumber = [self.groupListManager sectionNumberForGroupManager:self] + 1 + indexPath.section;
            NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:sectionNumber];
                
            NSUInteger newSectionNumber = [self.groupListManager sectionNumberForGroupManager:self] + 1 + newIndexPath.section;
            NSIndexPath *realNewIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newSectionNumber];
            
            if (deleteSection == NSNotFound && insertSection == NSNotFound) {
            
                id<NSFetchedResultsSectionInfo> origSectionInfo = [sectionInfoArray objectAtIndex:origSection];
                [self.groupListManager updateSectionInfo:origSectionInfo forGroupManager:self atIndex:origSection];
                
                if (origSection != destSection) {
                    id<NSFetchedResultsSectionInfo> destSectionInfo = [sectionInfoArray objectAtIndex:destSection];
                    [self.groupListManager updateSectionInfo:destSectionInfo forGroupManager:self atIndex:destSection];
                }
                
                UITableViewCell *cell = [self.groupListManager.tableViewController.tableView cellForRowAtIndexPath:realIndexPath];
                
                Beacon *beacon = (Beacon *)[self.groupListManager objectForRowAtIndexPath:realIndexPath];
                
                [self.groupListManager.tableViewController configureCell:cell withBeacon:beacon];
                
                [self.groupListManager.tableViewController.tableView moveRowAtIndexPath:realIndexPath toIndexPath:realNewIndexPath];
            }
            else {
                //[self.groupListManager reloadSectionsForGroupManager:self];
                
                if (deleteSection != NSNotFound && insertSection != NSNotFound) {
                    NSUInteger minSection = MIN(deleteSection, insertSection);
                    NSUInteger maxSection = MAX(deleteSection, insertSection);
                    
                    NSRange range = NSMakeRange(minSection, maxSection - minSection);
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                    
                    [self.groupListManager.tableViewController.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                else {
                
                    if (deleteSection == NSNotFound) {
                        // pas de suppression de section
                    
                        id<NSFetchedResultsSectionInfo> origSectionInfo = [sectionInfoArray objectAtIndex:origSection];
                        [self.groupListManager updateSectionInfo:origSectionInfo forGroupManager:self atIndex:origSection];
                    
                        [self.groupListManager.tableViewController.tableView deleteRowsAtIndexPaths:@[realIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                    }
                    else {
                        [self.groupListManager.tableViewController.tableView deleteSections:[NSIndexSet indexSetWithIndex:deleteSection] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    
                    if (insertSection == NSNotFound) {
                    // pas d'insertion de section
                    
                        id<NSFetchedResultsSectionInfo> destSectionInfo = [sectionInfoArray objectAtIndex:destSection];
                        [self.groupListManager updateSectionInfo:destSectionInfo forGroupManager:self atIndex:destSection];
                    
                    
                        [self.groupListManager.tableViewController.tableView insertRowsAtIndexPaths:@[realNewIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    else {
                        [self.groupListManager.tableViewController.tableView insertSections:[NSIndexSet indexSetWithIndex:insertSection] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                
                }
                
                
            }
            
        }
            break;
        case NSFetchedResultsChangeUpdate:
        {
            
            [self.groupListManager updateSectionInfo:[sectionInfoArray objectAtIndex:indexPath.section] forGroupManager:self atIndex:indexPath.section];
            
            NSUInteger sectionNumber = [self.groupListManager sectionNumberForGroupManager:self] + 1 + indexPath.section;
            NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:sectionNumber];
            
            UITableViewCell *cell = [self.groupListManager.tableViewController.tableView cellForRowAtIndexPath:realIndexPath];
            
            [self.groupListManager.tableViewController configureCell:cell withBeacon:(Beacon *)anObject];
            
        }
            break;
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            insertSection = sectionIndex;
            
            if (self.groupListManager.subManagerIgnoreNextChange && !self.groupListManager.majorChangeAsc) {
                //insertSection++;
            }
            
            
            [self.groupListManager insertSection:sectionInfo inGroupManager:self atIndex:insertSection];
            
            NSUInteger realSectionIndex = [self.groupListManager sectionNumberForSection:sectionInfo];
            
            if (self.groupListManager.subManagerIgnoreNextChange && !self.groupListManager.majorChangeAsc) {
                //realSectionIndex--;
            }

            
            if (!self.groupListManager.subManagerIgnoreNextChange) {
                [self.groupListManager.tableViewController.tableView insertSections:[NSIndexSet indexSetWithIndex:realSectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                insertSection = NSNotFound;
            }
            else {
                insertSection = realSectionIndex;
            }
            
        }
            break;
        case NSFetchedResultsChangeDelete:
        {
            
            NSUInteger realSectionIndex = [self.groupListManager sectionNumberForSection:sectionInfo];
            [self.groupListManager deleteSection:sectionInfo];
            
            deleteSection = realSectionIndex;
            
            if (self.groupListManager.subManagerIgnoreNextChange && self.groupListManager.majorChangeAsc) {
                //deleteSection--;
            }
            
            if (!self.groupListManager.subManagerIgnoreNextChange) {
                [self.groupListManager.tableViewController.tableView deleteSections:[NSIndexSet indexSetWithIndex:realSectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                deleteSection = NSNotFound;
            }
            
            
        }
            break;
        default:
            break;
    }
    
    
}


- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    
    NSUInteger integerValue = [sectionName integerValue];
#if __LP64__
    NSUInteger mask = 0x000000000000FFFF;
    integerValue &= mask;
    return [NSString stringWithFormat:@"Major %04lX", integerValue];
#else
    NSUInteger mask = 0x0000FFFF;
    integerValue &= mask;
    return [NSString stringWithFormat:@"Major %04X", integerValue];
#endif
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Beacon" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *uuidPredicate = [NSPredicate predicateWithFormat:@"self.major.group == %@", self.group, nil];
    
    NSSortDescriptor *sortDescriptorMajor = [NSSortDescriptor sortDescriptorWithKey:@"major.major" ascending:YES];
    NSSortDescriptor *sortDescriptorMinor = [NSSortDescriptor sortDescriptorWithKey:@"minor" ascending:YES];
    
    fetchRequest.sortDescriptors = @[sortDescriptorMajor, sortDescriptorMinor];
    
    
    fetchRequest.predicate = uuidPredicate;
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"self.major.major" cacheName:nil];
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






@end
