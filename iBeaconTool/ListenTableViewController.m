//
//  ListenTableViewController.m
//  iBLocator
//
//  Created by Eurelis on 20/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "ListenTableViewController.h"
#import "StoreModel.h"
#import "AppDelegate.h"
#import "ListenedBeaconCell.h"
#import "BeaconDetailViewController.h"
#import "PointOfInterestTableViewCell.h"

@interface ListenTableViewController ()

@end

@implementation ListenTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    listenMode = MODE_BEACONS;
    
    proximityImmediateColor = [UIColor immediateColor];
    proximityNearColor = [UIColor nearColor];
    proximityFarColor = [UIColor farColor];
    proximityUnknownColor = [UIColor unknownColor];
    
    UIBarButtonItem *notificationsBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NOTIFICATIONS", @"NOTIFICATIONS") style:UIBarButtonItemStylePlain target:self action:@selector(notificationButtonAction:)];
    self.navigationItem.rightBarButtonItem = notificationsBarButtonItem;
    
    self.navigationItem.title = NSLocalizedString(@"LISTEN", @"");
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    backgroundImage.frame = self.view.frame;
    [self.view insertSubview:backgroundImage atIndex:0];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = nil;
    
    [self.segmentedControl setTitle:NSLocalizedString(@"LISTEN_BEACONS", @"") forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"LISTEN_POIS", @"") forSegmentAtIndex:1];
    
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_fetchedResultsController) {
        [self fetchedResultsController];
    }
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate stopListeningBeacons];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (listenMode == MODE_BEACONS) {
        return 44.0f;
    }
    else {
        return 100.0f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 0;
    if (listenMode == MODE_BEACONS) {
        sections = [[self.fetchedResultsController sections] count]; // 0 ou 1
    }
    else {
        sections = [[self.fetchedResultsController sections][0] numberOfObjects];
    }
    
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    
    if (listenMode == MODE_BEACONS) {
        numberOfRows = [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects]; // 0 ou 1
    }
    else {
        numberOfRows = [[self.fetchedResultsController.sections[0] objects][section] pois].count;
    }
    
    return numberOfRows;
    //return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *BeaconCellIdentifier = @"Cell";
    static NSString *POICellIdentifier = @"PoiCell";
    
    UITableViewCell *cell = nil;
    
    if (listenMode == MODE_BEACONS) {
        cell = [tableView dequeueReusableCellWithIdentifier:BeaconCellIdentifier forIndexPath:indexPath];
    
        [self configureBeaconCell:(ListenedBeaconCell *)cell atIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:POICellIdentifier forIndexPath:indexPath];
        
        [self configurePoiCell:(PointOfInterestTableViewCell *)cell atIndexPath:indexPath];
    }
        
    // Configure the cell...
    
    return cell;
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
    

    NSFetchedResultsController *aFetchedResultsController = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Beacon" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = nil;
    if (listenMode == MODE_BEACONS) {
        predicate = [NSPredicate predicateWithFormat:@"(major.group.active == %@) AND (accuracy >= %@)", @YES, @0];
    }
    else if (listenMode == MODE_POIS) {
        predicate = [NSPredicate predicateWithFormat:@"(major.group.active == %@) AND (accuracy >= %@) AND (pois.@count > 0)", @YES, @0];
    }
    fetchRequest.predicate = predicate;
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    //NSSortDescriptor *majorNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"major.group.name" ascending:YES];
    NSSortDescriptor *proximityDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"proximity" ascending:NO];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"accuracy" ascending:YES];
    NSArray *sortDescriptors = @[
                                 //majorNameSortDescriptor,
                                 proximityDescriptor, sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];

    

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





- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{

    /*
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
     */
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{

    UITableView *tableView = self.tableView;
    if (listenMode == MODE_BEACONS) {
        
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:{
                [self configureBeaconCell:(ListenedBeaconCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
               
            }
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
        
    } else if (listenMode == MODE_POIS) {
        
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [tableView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.row] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:{
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationNone];
                
            }
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView moveSection:indexPath.row toSection:newIndexPath.row];
                
                break;
        }
        
        
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configurePoiCell:(PointOfInterestTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Beacon *beacon = (Beacon *)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.section inSection:0]];
    
    NSArray *poiArray = [beacon.pois sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    
    NSInteger row = indexPath.row;
    if (row >= 0 && row < poiArray.count) {
        PointOfInterest *poi = poiArray[row];
        
        if (poi.image) {
            cell.poiImageView.image = [UIImage imageWithContentsOfFile:poi.image];
        }
        else {
            cell.poiImageView.image = nil;
        }
        
        cell.poiTitleLabel.text = poi.title;
        cell.poiTextLabel.text  = poi.text;
        cell.poi = poi;
    
    }
    //[cell setBackgroundColor:proximityColor];
    
}

- (void)configureBeaconCell:(ListenedBeaconCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Beacon *beacon = (Beacon *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *nameString = beacon.name;
    
    NSInteger proximity = [beacon.proximity integerValue];
    //UIImage *proximityImage = nil;
    UIColor *proximityColor = nil;
    
    switch (proximity) {
        case PROXIMITY_NOT_RECEIVED:
           
            break;
        case PROXIMITY_UNKNOWN:
            proximityColor = proximityUnknownColor;
            break;
        case PROXIMITY_FAR:
            proximityColor = proximityFarColor;
            break;
        case PROXIMITY_NEAR:
            proximityColor = proximityNearColor;
            break;
        case PROXIMITY_IMMEDIATE:
            proximityColor = proximityImmediateColor;
            break;
    }
    
    [cell setBackgroundColor:proximityColor];
    
    //cell.beaconProximityImageView.image = proximityImage;
    
    cell.beaconNameLabel.text = nameString;
    
#if __LP64__
    cell.rssiLabel.text = [NSString stringWithFormat:@"%lddB", [beacon.rssi integerValue]];
#else
    cell.rssiLabel.text = [NSString stringWithFormat:@"%ddB", [beacon.rssi integerValue]];
#endif
    
    cell.accuracyLabel.text = [NSString stringWithFormat:@"%.3lf m", [beacon.accuracy doubleValue]];


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (listenMode == MODE_BEACONS) {
        Beacon *beacon = (Beacon *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        BeaconDetailViewController *pushedController = [self.storyboard instantiateViewControllerWithIdentifier:@"BeaconDetailViewController"];
        
        pushedController.beacon = beacon;
        [self.navigationController pushViewController:pushedController animated:YES];
    }
    else if (listenMode == MODE_POIS) {
        PointOfInterestTableViewCell *cell = (PointOfInterestTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        PointOfInterest *poi = cell.poi;
        
        if (poi.link && ![poi.link isEqualToString:@""]) {
            NSURL *url = [NSURL URLWithString:poi.link];
            if (url) {
                [[UIApplication sharedApplication] openURL:url];
                
            }
        }
        
    }
    
    
}



- (void)notificationButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"pushNotificationSettings" sender:sender];
    
}


- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            listenMode = MODE_BEACONS;
            break;
        case 1:
            listenMode = MODE_POIS;
            break;
    }
    
    [self.tableView reloadData];
    
}



@end
