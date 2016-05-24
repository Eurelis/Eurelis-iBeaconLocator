//
//  TransmitterChoiceTableViewController.m
//  iBLocator
//
//  Created by Eurelis on 21/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "TransmitterChoiceTableViewController.h"
#import "TableGroupListManager.h"
#import "AppDelegate.h"
#import "BeaconWrapper.h"
#import "GroupWrapper.h"
#import "MajorWrapper.h"
#import "StoreModel.h"

static NSString *CellIdentifierGroup = @"GroupCell";
static NSString *CellIdentifierMajor = @"MajorCell";
static NSString *CellIdentifierBeacon = @"BeaconCell";


@interface TransmitterChoiceTableViewController ()

@end

@implementation TransmitterChoiceTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    groupWrapperClass = NSClassFromString(@"GroupWrapper");
    majorWrapperClass = NSClassFromString(@"MajorWrapper");
    beaconWrapperClass = NSClassFromString(@"BeaconWrapper");
    
    self.navigationItem.title = NSLocalizedString(@"EMIT", @"");
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    backgroundImage.frame = self.view.frame;
    [self.view insertSubview:backgroundImage atIndex:0];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = nil;
    
    self.selecterBeaconLabel.text = NSLocalizedString(@"SELECT_TRANSMITTER_BEACON", @"");

}

// chargement des données à ce moment
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self configureStateLabel];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Beacon"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(major.group.active == 1)", nil];
    
    NSSortDescriptor *sortDescriptorGroupName = [NSSortDescriptor sortDescriptorWithKey:@"major.group.name" ascending:YES];

    NSSortDescriptor *sortDescriptorGroup = [NSSortDescriptor sortDescriptorWithKey:@"major.group" ascending:YES];
    NSSortDescriptor *sortDescriptorMajor = [NSSortDescriptor sortDescriptorWithKey:@"major.major" ascending:YES];
    NSSortDescriptor *sortDescriptorMinor = [NSSortDescriptor sortDescriptorWithKey:@"minor" ascending:YES];
    
    fetchRequest.sortDescriptors = @[sortDescriptorGroupName, sortDescriptorGroup, sortDescriptorMajor, sortDescriptorMinor];
    
    fetchRequest.predicate = predicate;
    [fetchRequest setIncludesPendingChanges:YES];
    
    
    NSError *error = nil;
    NSArray *beacons = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    if (error) {
        TRACE
        //NSLog(@"%@", error);
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.transmitterSwitch setOn:appDelegate.transmitterIsOn animated:NO];
    
    tableGroupListManager = [[TableGroupListManager alloc] initWithBeacons:beacons];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Beacon *transmitterBeacon = appDelegate.transmitterBeacon;
    
    NSInteger transmitterBeaconposition = [tableGroupListManager positionOfBeaconWrapperWithBeacon:transmitterBeacon];

    if (transmitterBeaconposition != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:transmitterBeaconposition inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
    
}

- (NSManagedObjectContext *)managedObjectContext {
    return [[UIApplication  delegate] managedObjectContext];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // une seule section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tableGroupListManager wrapperCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = nil;
    id wrapper = [tableGroupListManager wrapperAtIndex:indexPath.row];
    
    GroupWrapper *groupWrapper = nil;
    MajorWrapper *majorWrapper = nil;
    BeaconWrapper *beaconWrapper = nil;
    
    if ([wrapper isKindOfClass:beaconWrapperClass]) {
        cellIdentifier = CellIdentifierBeacon;
        beaconWrapper = (BeaconWrapper *)wrapper;
    }
    else if ([wrapper isKindOfClass:majorWrapperClass]) {
        cellIdentifier = CellIdentifierMajor;
        majorWrapper = (MajorWrapper *)wrapper;
    }
    else if ([wrapper isKindOfClass:groupWrapperClass]) {
        cellIdentifier = CellIdentifierGroup;
        groupWrapper = (GroupWrapper *)wrapper;
    }
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (beaconWrapper) {
        cell.textLabel.text = beaconWrapper.beacon.name;
        
        if ([beaconWrapper.beacon isEqual:[UIApplication delegate].transmitterBeacon]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.backgroundColor = [UIColor immediateColor];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.backgroundColor = [UIColor transparentBackgroundColor];
            cell.textLabel.textColor = [UIColor immediateColor];

        }
        
        
    }
    else if (majorWrapper) {
        cell.textLabel.text = [NSString stringWithFormat:@"Major %@", majorWrapper.major.major, nil];
        cell.textLabel.textColor = [UIColor nearColor];
    }
    else if (groupWrapper) {
        cell.textLabel.text = groupWrapper.group.name;
        cell.textLabel.textColor = [UIColor farColor];
    }
    
    return cell;
}

#pragma mark - Table View Delegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id wrapper = [tableGroupListManager wrapperAtIndex:indexPath.row];
    
    if (![wrapper isKindOfClass:beaconWrapperClass]) {
        return nil;
    }
    
    Beacon *beacon = [wrapper valueForKey:@"beacon"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.transmitterBeacon = beacon;
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.backgroundColor = [UIColor immediateColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor transparentBackgroundColor];
    cell.textLabel.textColor = [UIColor immediateColor];
}

#pragma mark -

- (IBAction)transmitterSwitchValueChanged:(UISwitch *)sender {
    AppDelegate *appDelegate = [UIApplication delegate];
    appDelegate.transmitterIsOn = sender.isOn;
    [self configureStateLabel];
    
}

- (void)configureStateLabel {
    BOOL state = [UIApplication delegate].transmitterIsOn;
    
    NSString *label =
        state
    ? NSLocalizedString(@"ACTIVE_EMITTER", @"")
    : NSLocalizedString(@"INACTIVE_EMITTER", @"");
    
    UIColor *color =
        state
    ? [UIColor immediateColor]
    : [UIColor farColor];
    
    self.emitterStateLabel.text = label;
    self.emitterStateLabel.textColor = color;
    
}

@end
