//
//  ConfigBeaconsTableViewController.m
//  iBLocator
//
//  Created by Eurelis on 13/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "ConfigBeaconsTableViewController.h"
#import "GroupListManager.h"
#import "StoreModel.h"
#import "EditGroupViewController.h"
#import "EditBeaconViewController.h"
#import "AppDelegate.h"
#import "GroupBeaconCountCell.h"
#import "GroupManager.h"
#import "BackgroundNotificationTableViewController.h"

static NSString *cellIdentifierA = @"GroupCell1";
static NSString *cellIdentifierB = @"GroupCell2";
static NSString *cellIdentifierC = @"BeaconCell";
static NSString *cellIdentifierD = @"NewGroupCell";
static NSString *cellIdentifierE = @"NewBeaconCell";

@interface ConfigBeaconsTableViewController ()

@end

@implementation ConfigBeaconsTableViewController

@synthesize groupListManager = groupListManager;
@synthesize editingSingleRow = editingSingleRow;

- (BOOL)isReallyEditing {
    return (self.tableView.isEditing && !editingSingleRow);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    insertGroupDisplayed = NO;
    groupListManager = [[GroupListManager alloc] init];
    groupListManager.tableViewController = self;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = NSLocalizedString(@"SETTINGS", @"");
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    backgroundImage.frame = self.view.frame;
    [self.view insertSubview:backgroundImage atIndex:0];
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundView = nil;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [self.tableView setEditing:editing animated:animated];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:0];
    NSArray *indexPathArray = [groupListManager addBeaconCellIndexPathArray];
    
    UITableViewRowAnimation animation = (animated)?UITableViewRowAnimationAutomatic:UITableViewRowAnimationNone;
    
    [self.tableView beginUpdates];
    if (editing) {
        insertGroupDisplayed = YES;
        [self.tableView insertSections:indexSet withRowAnimation:animation];
        [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:animation];
    }
    else {
        insertGroupDisplayed = NO;
        [self.tableView deleteSections:indexSet withRowAnimation:animation];
        [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:animation];
    }
    [self.tableView endUpdates];
  
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}




#pragma mark - Table view cell configuration
- (void)configureCell:(UITableViewCell *)cell withGroup:(Group *)group {
    cell.textLabel.text = group.name;
    cell.detailTextLabel.text = group.uuid;
}

- (void)configureCell:(UITableViewCell *)cell withBeacon:(Beacon *)beacon {
    cell.textLabel.text = beacon.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Minor %@", beacon.minor];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    NSUInteger sectionCount = [groupListManager sectionCount];
    if (self.isReallyEditing) {
        sectionCount++;
    }
    
    return sectionCount;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#if TARGET_IPHONE_SIMULATOR
    //NSInteger realSection = section;
#endif
    NSInteger returnValue = 0;
    
    if (self.isReallyEditing) {
        section--;
        if (section == -1) {
            return 1;
        }
    }
    
    returnValue = [groupListManager numberOfRowsAtIndex:section];
#if TARGET_IPHONE_SIMULATOR
    #if __LP64__
    //NSLog(@"numberOfRowsInSection %ld => %ld", realSection, returnValue);
    #else
    //NSLog(@"numberOfRowsInSection %d => %d", realSection, returnValue);
    #endif
#endif
    return returnValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = nil;
    
    if (self.isReallyEditing) {

        if (indexPath.row == 0 && indexPath.section == 0) {
            cellIdentifier = cellIdentifierD;
        }
        else {
            indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)];
            
        }
    }
    
    NSManagedObject *managedObject = nil;
    
    if (!cellIdentifier) {
        managedObject = [groupListManager objectForRowAtIndexPath:indexPath];
   
        if ([managedObject isKindOfClass:[Beacon class]]) {
            cellIdentifier = cellIdentifierC;
        
        }
        else {
            switch (indexPath.row) {
                case 0:
                    cellIdentifier = cellIdentifierA;
                    break;
                case 1:
                    cellIdentifier = cellIdentifierB;
                    break;
                default:
                    cellIdentifier = cellIdentifierE;
            }
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if ([cellIdentifier isEqualToString:cellIdentifierB]) {
        GroupBeaconCountCell *beaconCountCell = (GroupBeaconCountCell *)cell;
        beaconCountCell.group = (Group *)managedObject;
        [beaconCountCell configure];
        /*
        beaconCountCell.accessoryType = ([beaconCountCell.group.active boolValue])?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
        [beaconCountCell.displaySwitch setOn:[beaconCountCell.group.active boolValue] animated:NO];
         */
        
    }
    else if ([cellIdentifier isEqualToString:cellIdentifierA]) {
        Group *group = (Group *)managedObject;
        [self configureCell:cell withGroup:group];
    }
    else if ([cellIdentifier isEqualToString:cellIdentifierC]) {
        Beacon *beacon = (Beacon *)managedObject;
        [self configureCell:cell withBeacon:beacon];
    }
    else if ([cellIdentifier isEqualToString:cellIdentifierD]) {
        cell.textLabel.text = NSLocalizedString(@"CREATE_NEW_GROUP", @"");
    }
    else if ([cellIdentifier isEqualToString:cellIdentifierE]) {
        cell.textLabel.text =  NSLocalizedString(@"CREATE_NEW_BEACON", @"");
    }
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:cellIdentifierB]) {
        return NO;
    }
    
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    
    if (insertGroupDisplayed) {
        if (indexPath.row == 0 && indexPath.section == 0) {
            return UITableViewCellEditingStyleInsert;
        }
        else {
            section--;
        }
    }
    
    if ([groupListManager isGroupForSectionAtIndex:section]) {
        if (indexPath.row == 1) {
            return UITableViewCellEditingStyleNone;
        }
        else if (indexPath.row == 2) {
            return UITableViewCellEditingStyleInsert;
        }
    }
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        if (indexPath.row == 0 && indexPath.section == 0) {
            [self performSegueWithIdentifier:@"displayEditGroup" sender:self];
        }
        
        else {
            NSUInteger section = indexPath.section - 1;
            if ([groupListManager isGroupForSectionAtIndex:section] && indexPath.row == 2) {
                workGroup = [groupListManager groupForSectionAtIndex:section];
                [self performSegueWithIdentifier:@"displayEditBeacon" sender:self];
            }
            
        }
    }
    
    else if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.isReallyEditing) {
            indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)];
        }
        
        NSManagedObject *managedObject = [groupListManager objectForRowAtIndexPath:indexPath];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.managedObjectContext deleteObject:managedObject];
        
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // pas de correction d'index, ne peut arriver que si on n'est pas en mode d'édition
    NSManagedObject *managedObject = [groupListManager objectForRowAtIndexPath:indexPath];
    
    if ([managedObject isKindOfClass:[Group class]]) {
        // seulement sur la première ligne d'un groupe
        if (indexPath.row == 0) {
            workGroup = (Group *)managedObject;
            [self performSegueWithIdentifier:@"displayEditGroup" sender:self];
        }
        else if (indexPath.row == 1) {
            workGroup = (Group *)managedObject;
            if ([workGroup.active boolValue]) {
                [self performSegueWithIdentifier:@"pushNotificationSettings" sender:self];
            }
            else {
                workGroup = nil;
            }
        }
    }
    
    else if ([managedObject isKindOfClass:[Beacon class]]) {
        workBeacon = (Beacon *)managedObject;
        [self performSegueWithIdentifier:@"displayEditBeacon" sender:self];
    }
    
}




- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    editingSingleRow = YES;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    editingSingleRow = NO;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.isReallyEditing) {
        section--;
        
        if (section == -1) {
            return nil;
        }
    }
    
    id sectionObj = [groupListManager.sectionArray objectAtIndex:section];
    
    UIView *view = nil;
    
    if ([sectionObj conformsToProtocol:NSProtocolFromString(@"NSFetchedResultsSectionInfo")]) {
        view = [[UIView alloc] initWithFrame:(CGRect){0, 0, 320, 0}];
        
        view.layer.backgroundColor = [[UIColor colorWithRed:0.92156862745098 green:0.92156862745098 blue:0.92156862745098 alpha:1.0] CGColor];
        
        id<NSFetchedResultsSectionInfo> sectionInfo = (id<NSFetchedResultsSectionInfo>)sectionObj;
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){20, 0, 280, 20}];
        label.text = sectionInfo.indexTitle;
        
        [view addSubview:label];
    }
    
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat defaultHeight = 44;
    
    if (self.isReallyEditing) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            return defaultHeight;
        }
        
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)];
    }
    
    id sectionObj = [groupListManager objectForRowAtIndexPath:indexPath];
    
    if ([sectionObj isKindOfClass:[Beacon class]]) {
        return 38;
    }
    
    
    return defaultHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat defaultHeight = tableView.sectionFooterHeight;
    
    if (self.isReallyEditing) {
        section--;
        
        if (section == -1) {
            return defaultHeight;
        }
    }
    
    id sectionObj = [groupListManager.sectionArray objectAtIndex:section];
    
    if ([sectionObj conformsToProtocol:NSProtocolFromString(@"NSFetchedResultsSectionInfo")]) {
        return 0;
    }
    
    
    return defaultHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    CGFloat defaultHeight = tableView.sectionHeaderHeight;
    
    if (self.isReallyEditing) {
        section--;
        
        if (section == -1) {
            return defaultHeight;
        }
    }
    
    id sectionObj = [groupListManager.sectionArray objectAtIndex:section];
    
    
    if ([sectionObj conformsToProtocol:NSProtocolFromString(@"NSFetchedResultsSectionInfo")]) {
        return 20;
    }
    else if ([sectionObj isKindOfClass:[GroupManager class]]) {
        return 15;
    }
    
    
    return defaultHeight;
}


#pragma mark - segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([identifier isEqualToString:@"displayEditGroup"]) {
        EditGroupViewController *editGroupViewController = (EditGroupViewController *)[segue destinationViewController];
        editGroupViewController.managedObjectContext = appDelegate.managedObjectContext;
        editGroupViewController.group = workGroup;
        workGroup = nil;
        
    }
    else if ([identifier isEqualToString:@"displayEditBeacon"]) {
        EditBeaconViewController *editBeaconViewController = (EditBeaconViewController *)[segue destinationViewController];
        editBeaconViewController.group = workGroup;
        editBeaconViewController.beacon = workBeacon;
        workGroup = nil;
        workBeacon = nil;
        
    }
    else if ([identifier isEqualToString:@"pushNotificationSettings"]) {
        BackgroundNotificationTableViewController *destinationViewController = (BackgroundNotificationTableViewController *)[segue destinationViewController];
        destinationViewController.group = workGroup;
        workGroup = nil;
        
    }
    
}



@end
