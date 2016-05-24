//
//  BackgroundNotificationTableViewController.m
//  iBLocator
//
//  Created by Eurelis on 24/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "BackgroundNotificationTableViewController.h"
#import "TableGroupListManager.h"
#import "AppDelegate.h"
#import "BeaconWrapper.h"
#import "GroupWrapper.h"
#import "MajorWrapper.h"
#import "StoreModel.h"
#import "NotificationSettingsPanelViewController.h"
#import "MajorCreationPanelViewController.h"

static NSString *CellIdentifierGroup = @"GroupCell";
static NSString *CellIdentifierMajor = @"MajorCell";
static NSString *CellIdentifierBeacon = @"BeaconCell";

@interface BackgroundNotificationTableViewController ()

@end

@implementation BackgroundNotificationTableViewController

@synthesize tableGroupListManager = tableGroupListManager;


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.group) {
        tableGroupListManager = [[TableGroupListManager alloc] initWithGroup:_group notificationMode:YES];
        
        UIBarButtonItem *addMajorButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMajorButtonPushed:)];
        [addMajorButton setTintColor:[UIColor immediateColor]];
        self.navigationItem.rightBarButtonItem = addMajorButton;
        
    }
    else {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Beacon"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(major.group.active == 1)", nil];
        
        NSSortDescriptor *sortDescriptorGroupName = [NSSortDescriptor sortDescriptorWithKey:@"major.group.name" ascending:YES];
        // pour le cas où des groupes aurraient le même nom
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
        tableGroupListManager = [[TableGroupListManager alloc] initWithBeacons:beacons notificationMode:YES];

    }
    
    tableGroupListManager.tableView = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    groupWrapperClass = NSClassFromString(@"GroupWrapper");
    majorWrapperClass = NSClassFromString(@"MajorWrapper");
    beaconWrapperClass = NSClassFromString(@"BeaconWrapper");
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    backgroundImage.frame = self.view.frame;
    [self.view insertSubview:backgroundImage atIndex:0];
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundView = nil;

    self.navigationItem.title = NSLocalizedString(@"NOTIFICATIONS", @"");
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
        
        if ([beaconWrapper.beacon.notification.enabled boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.backgroundColor = [UIColor immediateColor];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor immediateColor];
        }
        
    }
    else if (majorWrapper) {
        cell.textLabel.text = majorWrapper.major.major;
        
        if ([majorWrapper.major.notification.enabled boolValue]) {
            cell.backgroundColor = [UIColor nearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor nearColor];
        }
        
    }
    else if (groupWrapper) {
        cell.textLabel.text = groupWrapper.group.name;
        
        if ([groupWrapper.group.notification.enabled boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.backgroundColor = [UIColor farColor];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor farColor];
        }
    }
    
    
    return cell;
}

- (NSManagedObjectContext *)managedObjectContext {
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id wrapper = [tableGroupListManager wrapperAtIndex:indexPath.row];

    NotificationSettingsPanelViewController *modalController = (NotificationSettingsPanelViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"NotificationSettingsPanelViewController"];
    
    modalController.wrapper = wrapper;
    
    CGRect frame = self.view.bounds;
    CGRect frame2 = self.tableView.bounds;
    
    CGRect frameToUse = CGRectMake(0, -frame2.origin.y, frame.size.width, frame.size.height + frame2.origin.y);
    containerView = [[UIView alloc] initWithFrame:frame];
    
    
    [self.view addSubview:containerView];
    
    [self addChildViewController:modalController];
    modalController.view.frame = frameToUse;
    [containerView addSubview:modalController.view];
    
    UIEdgeInsets tableViewInsets = tableView.contentInset;
    tableViewInsets.bottom = 300;
    tableView.contentInset = tableViewInsets;
    
    
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];

    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (IBAction)addMajorButtonPushed:(id)sender {
    MajorCreationPanelViewController *modalController = (MajorCreationPanelViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"MajorCreationPanelViewController"];

    modalController.group = self.group;
    
    
    CGRect frame = self.view.bounds;
    CGRect frame2 = self.tableView.bounds;
    
    CGRect frameToUse = CGRectMake(0, -frame2.origin.y, frame.size.width, frame.size.height + frame2.origin.y);
    containerView = [[UIView alloc] initWithFrame:frame];
    
    
    [self.view addSubview:containerView];
    
    [self addChildViewController:modalController];
    modalController.view.frame = frameToUse;
    [containerView addSubview:modalController.view];
    
    UIEdgeInsets tableViewInsets = self.tableView.contentInset;
    tableViewInsets.bottom = 300;
    self.tableView.contentInset = tableViewInsets;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}


- (IBAction)dismissSettingsPanelViewController {
    [containerView removeFromSuperview];
    containerView = nil;
    
    UIEdgeInsets tableViewInsets = self.tableView.contentInset;
    tableViewInsets.bottom = 0;
    self.tableView.contentInset = tableViewInsets;
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
}

- (IBAction)dismissMajorCreationViewController:(Major *)major {
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [containerView removeFromSuperview];
    containerView = nil;
    
    UIEdgeInsets tableViewInsets = self.tableView.contentInset;
    tableViewInsets.bottom = 0;
    self.tableView.contentInset = tableViewInsets;
    
    if (major) {
        NSUInteger tablePosition = [tableGroupListManager reloadFromGroup:self.group positionOfMajor:major notifications:YES];
        
        if (tablePosition != NSNotFound) {
            NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:tablePosition inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
            [self.tableView scrollToRowAtIndexPath:insertIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    }
    
    
    
}



@end
