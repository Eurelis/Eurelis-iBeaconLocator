//
//  AppDelegate.m
//  iBLocator
//
//  Created by Eurelis on 12/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "AppDelegate.h"
#import "TMPBeacon.h"
#import "TMPBeaconValue.h"
#import "BeaconDetailViewController.h"
#import "ListenTableViewController.h"
#import "PoiFetcher.h"
#import "PictureDownloaderOperation.h"

#define TRANSMITTER_BEACON @"TransmitterBeacon"
#define TRANSMITTER_ON @"TransmitterIsOn"
#define USER_INFO_INSIDE_KEY @"isNotificationInsideKey"
#define USER_INFO_REGIONID_KEY @"regionIdKey"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UILocalNotification *localNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    //NSLog(@"localNotification %@", localNotification);
    
    peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSURL *transmitterBeaconURL = [userDefaults URLForKey:TRANSMITTER_BEACON];
    
    if (transmitterBeaconURL) {
        NSManagedObjectID *managedObjectID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:transmitterBeaconURL];
        self.transmitterBeacon = (Beacon *)[self.managedObjectContext objectWithID:managedObjectID];
    }
    self.transmitterIsOn = [userDefaults boolForKey:TRANSMITTER_ON];
    
    
    fullBeaconArray = [[NSMutableArray alloc] init];
    workingBeaconArray = [[NSMutableArray alloc] init];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:_window.frame];
    backgroundImageView.image = [UIImage imageNamed:@"background"];
    [_window addSubview:backgroundImageView];
    
    
    
    UINavigationController *navigationController = (UINavigationController *)[self.window rootViewController];
    navigationController.delegate = self;
    
    UIColor *tintColor = [UIColor colorWithRed:0.423529411764706 green:0.596078431372549 blue:0.650980392156863 alpha:1];
    
    [[UIBarButtonItem appearance] setTintColor:tintColor];
    [[UINavigationBar appearance] setTintColor:tintColor];

    if (localNotification) {
        [self backgroundLocalNotificationReceived:localNotification];
    }
    
    operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 2;
    
    [operationQueue addObserver:self forKeyPath:@"operationCount" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    // for iOS 8 compatibility
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined
        &&
        [locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]
        ) {
        [locationManager requestAlwaysAuthorization];
    }
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    return YES;
}




- (void)applicationWillResignActive:(UIApplication *)application
{
    active = NO;
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [operationQueue removeObserver:self forKeyPath:@"operationCount"];
    [operationQueue cancelAllOperations];
    [application setNetworkActivityIndicatorVisible:NO];
    
    [self saveContext];
    
    notInBackground = NO;
    
    
    [self stopListeningBeacons];
        
    //monitoringRange = NO;
    
    NSArray *notifications = [self backgroundNotifications];
    //NSLog(@"registering %ld background regions", (long)notifications.count);
    for (Notification *notif in notifications) {
        CLBeaconRegion *region = [self regionForNotification:notif];
        
        [locationManager startMonitoringForRegion:region];
        
    }

    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    for (CLRegion *monitoredRegion in locationManager.monitoredRegions) {
        [locationManager stopMonitoringForRegion:monitoredRegion];
    }
    
    [operationQueue addObserver:self forKeyPath:@"operationCount" options:(NSKeyValueObservingOptionNew) context:NULL];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    TRACE
    active = YES;
    notInBackground = YES;
    
    if (monitoringRange) {
        [self startListeningBeacons];
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - 

- (void)queuePoiFetcher:(PoiFetcher *)fetcher {
    [operationQueue addOperation:fetcher];
}



#pragma mark - Local notifications

- (void)backgroundLocalNotificationReceived:(UILocalNotification *)notification {
    TRACE
    NSDictionary *userInfo = notification.userInfo;
    NSString *notificationId = [userInfo valueForKey:USER_INFO_REGIONID_KEY];
    NSNumber *inside = [userInfo valueForKey:USER_INFO_INSIDE_KEY];
    
    if ([inside boolValue]) {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIViewController *visibleViewController = navigationController.visibleViewController;
        
        NSString *restorationId = visibleViewController.restorationIdentifier;
        
        Notification *notification = [self notificationObjectWithStringIdentifier:notificationId];
        
        
        if (notification.beacon) {
            BeaconDetailViewController *bdvc = nil;
            
            if ([restorationId isEqualToString:@"BeaconDetailViewController"]) {
                bdvc = (BeaconDetailViewController *)visibleViewController;
             
                [bdvc changeBeacon:notification.beacon];
            }
            else {
                bdvc = (BeaconDetailViewController *)[visibleViewController.storyboard instantiateViewControllerWithIdentifier:@"BeaconDetailViewController"];
                
                bdvc.beacon = notification.beacon;
                
                [navigationController pushViewController:bdvc animated:NO];
            }
            
        }
        else {
            displayNearestBeacon = YES;
            
            ListenTableViewController *ltvc = nil;
            
            if ([restorationId isEqualToString:@"ListenTableViewController"]) {
                //ltvc = (ListenTableViewController *)visibleViewController;
                // RAF
            }
            else {
                ltvc = (ListenTableViewController *)[visibleViewController.storyboard instantiateViewControllerWithIdentifier:@"ListenTableViewController"];
                
                [navigationController pushViewController:ltvc animated:NO];
                
            }
            
            
        }

        
    }
    
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    TRACE
    if (!active) {
        [self backgroundLocalNotificationReceived:notification];
    }
}




#pragma mark - Core Data

- (void)saveContext
{
    TRACE
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iBLocator" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iBLocator.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Querying core data

- (PointOfInterest *)poiWithNid:(NSNumber *)nid {
    PointOfInterest *poi = nil;
    
    if (nid) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"POI"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nid == %@", nid, nil];
        fetchRequest.predicate = predicate;
        
        NSError *error = nil;
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            TRACE
            //NSLog(@"%@", error);
        }
        
        if ([results count] == 1) {
            poi = [results objectAtIndex:0];
        }
        
    }
    
    return poi;
}

- (Group *)groupWithUUID:(NSString *)uuid {
    
    Group *groupObject = nil;

    if (uuid) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.uuid == %@", uuid, nil];
        
        
        fetchRequest.predicate = predicate;
        
        NSError *error = nil;
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            TRACE
            //NSLog(@"%@", error);
        }
        
        if ([results count] == 1) {
            groupObject = [results objectAtIndex:0];
        }

        
    }
    
    
    return groupObject;
}

- (NSArray *)beaconsInGroupWithUUID:(NSString *)uuid {
    NSArray *results = nil;
    
    if (uuid) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Beacon"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.major.group.uuid == %@", uuid, nil];
        
        
        fetchRequest.predicate = predicate;
        
        NSError *error = nil;
        results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            TRACE
            //NSLog(@"%@", error);
        }
        
    }
    
    
    return results;
}


- (void)resetBeaconsInGroupWithUUID:(NSString *)uuid {
    NSArray *results = nil;
    
    if (uuid) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Beacon"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(self.major.group.uuid == %@) AND (self.accuracy > 0)", uuid, nil];
        fetchRequest.predicate = predicate;
        
        NSError *error = nil;
        results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            TRACE
            //NSLog(@"%@", error);
        }
        else {
            for (Beacon *beacon in results) {
                [beacon setPrimitiveValue:[NSNumber numberWithInteger:0] forKey:@"rssi"];
                [beacon setPrimitiveValue:[NSNumber numberWithInteger:PROXIMITY_NOT_RECEIVED] forKey:@"proximity"];
                beacon.accuracy = [NSNumber numberWithDouble:-1.0];
            }
            
            
        }
    }
    
    
}


- (Major *)majorForGroup:(Group *)group major:(uint16_t)major createIfNotFound:(BOOL)create {
    Major *majorObject = nil;
    
    if (group) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Major"];
    
        NSString *majorNumber = [UIApplication convertMajorMinorToString:major];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(group == %@) AND (major == %@)", group, majorNumber, nil];
    
    
        fetchRequest.predicate = predicate;
    
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
        if ([results count] == 1) {
            majorObject = [results objectAtIndex:0];
        }
    
        if (!majorObject && create) {
            majorObject = (Major *)[NSEntityDescription insertNewObjectForEntityForName:@"Major" inManagedObjectContext:self.managedObjectContext];
        
            majorObject.group = group;
            majorObject.major = [NSString stringWithFormat:@"%04X", major];
            
            [self.managedObjectContext refreshObject:group mergeChanges:YES];
            
        }
        
    }
    
    return majorObject;
}

#pragma mark - 

- (NSArray *)beaconsForUUID:(NSString *)uuid major:(NSString *)majorHex minor:(NSString *)minorHex {
    
    NSArray *beacons = nil;
    
    if (uuid) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Beacon"];
        
        NSPredicate *predicate = nil;
        
        if (uuid && majorHex && minorHex) {
            predicate = [NSPredicate predicateWithFormat:@"(major.group.uuid == %@) AND (major.major == %@) AND (minor == %@)", uuid, majorHex, minorHex, nil];
        }
        else if (uuid && majorHex) {
            predicate = [NSPredicate predicateWithFormat:@"(major.group.uuid == %@) AND (major.major == %@)", uuid, majorHex, nil];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"(major.group.uuid == %@)", uuid, nil];
        }
        
        fetchRequest.predicate = predicate;
        
        beacons= [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        
       
        
    }
    
    
    return beacons;
    
}


- (Beacon *)beaconForUUID:(NSString *)uuid major:(NSString *)majorHex minor:(NSString *)minorHex createIfNotFound:(BOOL)create {
    Beacon *beaconObject = nil;
    
    if (uuid) {
        Group *group = [self groupWithUUID:uuid];
        
        uint16_t major = [UIApplication convertMajorMinorString:majorHex];
        uint16_t minor = [UIApplication convertMajorMinorString:minorHex];
        
        beaconObject = [self beaconForGroup:group major:major minor:minor createIfNotFound:create];
        
    }
    
    return beaconObject;
    
}


- (Beacon *)beaconForGroup:(Group *)group major:(uint16_t)major minor:(uint16_t)minor createIfNotFound:(BOOL)create {
    
    Beacon *beaconObject = nil;
    
    if (group) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Beacon"];
        
        NSString *majorNumber = [UIApplication convertMajorMinorToString:major];
        NSString *minorNumber = [UIApplication convertMajorMinorToString:minor];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(major.group == %@) AND (major.major == %@) AND (minor == %@)", group, majorNumber, minorNumber, nil];

        fetchRequest.predicate = predicate;
        
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        
        if ([results count] == 1) {
            beaconObject = [results objectAtIndex:0];
        }
        
        if (!beaconObject && create) {
            Major *majorObject = [self majorForGroup:group major:major createIfNotFound:YES];
            beaconObject = (Beacon *)[NSEntityDescription insertNewObjectForEntityForName:@"Beacon" inManagedObjectContext:self.managedObjectContext];
            
            beaconObject.name = [NSString stringWithFormat:@"Beacon %04X-%04X", major, minor, nil];
            beaconObject.minor = [UIApplication convertMajorMinorToString:minor];
            beaconObject.major = majorObject;
            beaconObject.proximity = [NSNumber numberWithInteger:PROXIMITY_NOT_RECEIVED];
            beaconObject.rssi = [NSNumber numberWithInteger:0];
            beaconObject.accuracy = [NSNumber numberWithDouble:-1.0];
            
            [self.managedObjectContext refreshObject:majorObject mergeChanges:YES];
            [self saveContext];
            
            // si on ne sauvegarde pas on re-créera par la suite
            //NSLog(@"Beacon created %@", beaconObject.name);
        }
        
    }
    
    
    return beaconObject;
}


- (NSArray *)activeGroups {
    NSArray *groups = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(self.active == %@)", @YES, nil];
    fetchRequest.predicate = predicate;
    
    
    NSError *error = nil;
    
    groups = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        TRACE
        //NSLog(@"%@", error);
    }
    
    return groups;
}


- (void)startListeningBeacons {
    TRACE
    //NSLog(@"%@",[NSThread callStackSymbols]);
    
    NSSet *rangedRegions = locationManager.rangedRegions;
    
    for (CLBeaconRegion *beaconRegion in rangedRegions) {
        [locationManager stopRangingBeaconsInRegion:beaconRegion];
        [self resetBeaconsInGroupWithUUID:[beaconRegion.proximityUUID UUIDString]];
    }
    
    NSSet *monitoredRegions = locationManager.monitoredRegions;
    
    for (CLRegion *region in monitoredRegions) {
        [locationManager stopMonitoringForRegion:region];
    }
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *activeGroups = [self activeGroups];
        //NSLog(@"activeGroups %lu", (unsigned long)activeGroups.count);
        
        for (Group *group in activeGroups) {
            CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:group.uuid] identifier:group.uuid];
            
            PoiFetcher *poiFetcher = [[PoiFetcher alloc] initWithUUID:group.uuid];
            [self queuePoiFetcher:poiFetcher];
            
            [locationManager startMonitoringForRegion:region];
            [locationManager requestStateForRegion:region];
        }
    });
    
    
}

- (void)stopListeningBeacons {
    TRACE
    
    [self willChangeValueForKey:@"workingBeaconCount"];
    NSSet *rangedRegions = locationManager.rangedRegions;
    
    for (CLBeaconRegion *beaconRegion in rangedRegions) {
        [locationManager stopRangingBeaconsInRegion:beaconRegion];
        [self resetBeaconsInGroupWithUUID:[beaconRegion.proximityUUID UUIDString]];
    }
    
    NSSet *monitoredRegions = locationManager.monitoredRegions;
    
    for (CLRegion *region in monitoredRegions) {
        [locationManager stopMonitoringForRegion:region];
    }

    _workingBeaconCount = 0;
    [fullBeaconArray removeAllObjects];
    [workingBeaconArray removeAllObjects];
    [self didChangeValueForKey:@"workingBeaconCount"];
}

#pragma mark -
- (BOOL)isUUID:(NSString *)testString {
    if (testString && testString.length > 0) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:testString];
        if (uuid) {
            return YES;
        }
        
    }
    
    return NO;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    TRACE
    //NSLog(@"%d %@ ", notInBackground, region);
    if (!notInBackground) {
        if ([region isKindOfClass:[CLBeaconRegion class]] && ![self isUUID:region.identifier]) {
            Notification *notification = [self notificationObjectWithStringIdentifier:region.identifier];
            
            if ([notification.enabled boolValue]) {
                
                NSString *notificationName = [self nameForNotification:notification];
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setValue:region.identifier forKey:USER_INFO_REGIONID_KEY];
                
                UILocalNotification *localNotification = nil;
                
                switch (state) {
                    case CLRegionStateInside:
                    {
                        if ([notification.onEntry boolValue]) {
                            [userInfo setValue:@YES forKey:USER_INFO_INSIDE_KEY];
                            localNotification = [[UILocalNotification alloc] init];
                            localNotification.fireDate = nil;
                            NSString *format = NSLocalizedString(@"INSIDE_NOTIFICATION_FORMAT", @"");
                            
                            localNotification.alertBody = [NSString stringWithFormat:format, notificationName];
                        }
                    }
                        break;
                    case CLRegionStateOutside:
                    {
                        if ([notification.onExit boolValue]) {
                            [userInfo setValue:@NO forKey:USER_INFO_INSIDE_KEY];
                            localNotification = [[UILocalNotification alloc] init];
                            localNotification.fireDate = nil;
                            
                            NSString *format = NSLocalizedString(@"OUTSIDE_NOTIFICATION_FORMAT", @"");
                            localNotification.alertBody = [NSString stringWithFormat:format, notificationName];
                        }
                    }
                        break;
                    default:
                        break;
                }
                
                
                if (localNotification) {
                    localNotification.userInfo = userInfo;
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                }
                
            }
            
        }
    }
    else {
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
            
            if (beaconRegion.major || beaconRegion.minor) {
                //NSSet *monitoredRegions = locationManager.monitoredRegions;
                //NSSet *rangedRegions = locationManager.rangedRegions;

                //NSLog(@"Major or Minor Region ! %ld %ld", (long)monitoredRegions.count, (long)rangedRegions.count);
                
                [self startListeningBeacons];
                
            }
            else if (state == CLRegionStateInside) {
                //NSLog(@"CLRegionStateInside");
                [manager startRangingBeaconsInRegion:beaconRegion];
            }
            
            else if (state == CLRegionStateOutside) {
                //NSLog(@"CLRegionStateOutside");
                [manager stopRangingBeaconsInRegion:beaconRegion];
                [self resetBeaconsInGroupWithUUID:[beaconRegion.proximityUUID UUIDString]];
                
            }
            else {
                //NSLog(@"CLRegionStateUnknown");
            }
        }
    }
}
/*
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    TRACE
    [self locationManager:manager didDetermineState:CLRegionStateOutside forRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    TRACE
    [self locationManager:manager didDetermineState:CLRegionStateInside forRegion:region];
    
}
*/
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    TRACE
    //NSLog(@"%@ %@", region, error);
}


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    //if (use) {
    NSString *uuidString = [region.proximityUUID UUIDString];
    Group *group = [self groupWithUUID:uuidString];
    
    NSMutableSet *detectedTmpBeaconSet = [[NSMutableSet alloc] initWithCapacity:beacons.count];
    
    for (CLBeacon *beacon in beacons) {
        TMPBeacon *tmpBeacon = [[TMPBeacon alloc] initWithBeacon:beacon];
        
        NSUInteger pos = [fullBeaconArray indexOfObject:tmpBeacon];
        if (pos != NSNotFound) {
            tmpBeacon = [fullBeaconArray objectAtIndex:pos];
        }
        else {
            [fullBeaconArray addObject:tmpBeacon];
        }
        if (beacon.proximity != CLProximityUnknown) {
            [tmpBeacon addValueFromBeacon:beacon];
        }
        else {
            [tmpBeacon addNullValue];
        }
        [detectedTmpBeaconSet addObject:tmpBeacon];
    }
    
    NSArray *workingFullBeaconArray = [fullBeaconArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        return ([[evaluatedObject valueForKey:@"uuid"] isEqual:region.proximityUUID]);
        
    }]];
    
    
    NSMutableSet *notDetectedBeaconSet = [NSMutableSet setWithArray:workingFullBeaconArray];
    [notDetectedBeaconSet minusSet:detectedTmpBeaconSet];
    
    for (TMPBeacon *notDetectedBeacon in notDetectedBeaconSet) {
        [notDetectedBeacon addNullValue];
        
        if (notDetectedBeacon.shouldBeRemoved) {
            [fullBeaconArray removeObject:notDetectedBeacon];
            [workingBeaconArray removeObject:notDetectedBeacon];
            
            [self willChangeValueForKey:@"workingBeaconCount"];
            _workingBeaconCount = [workingBeaconArray count];
            [self didChangeValueForKey:@"workingBeaconCount"];
            
            Beacon *beacon = [self beaconForGroup:group major:[notDetectedBeacon.major unsignedShortValue] minor:[notDetectedBeacon.minor unsignedShortValue] createIfNotFound:NO];
            /*
            for (PointOfInterest *poi in beacon.pois) {
                [poi willChangeValueForKey:@"beacon.proximity"];
                [poi willChangeValueForKey:@"beacon.accuracy"];
            }
            */
            [beacon setPrimitiveValue:[NSNumber numberWithInteger:0] forKey:@"rssi"];
            [beacon setPrimitiveValue:[NSNumber numberWithInteger:PROXIMITY_NOT_RECEIVED] forKey:@"proximity"];
            beacon.accuracy = [NSNumber numberWithDouble:-1.0];
            
            for (PointOfInterest *poi in beacon.pois) {
                [poi didChangeValueForKey:@"beacon.proximity"];
                [poi didChangeValueForKey:@"beacon.accuracy"];
            }
            
        }
        
    }
    
    for (TMPBeacon *detectedTMPBeacon in detectedTmpBeaconSet) {
        BOOL updateDB = NO;
        
        if ([workingBeaconArray containsObject:detectedTMPBeacon]) {
            updateDB = YES;
        }
        else if (detectedTMPBeacon.shouldBeAdded) {
            [workingBeaconArray addObject:detectedTMPBeacon];
            
            [self willChangeValueForKey:@"workingBeaconCount"];
            _workingBeaconCount = [workingBeaconArray count];;
            [self didChangeValueForKey:@"workingBeaconCount"];
            
            
            updateDB = YES;
        }
        
        if (updateDB) {
            Beacon *beacon = [self beaconForGroup:group major:[detectedTMPBeacon.major unsignedShortValue] minor:[detectedTMPBeacon.minor unsignedShortValue] createIfNotFound:YES];
            
            TMPBeaconValue *beaconValue = [detectedTMPBeacon computedBeaconValue];
            /*
            for (PointOfInterest *poi in beacon.pois) {
                [poi willChangeValueForKey:@"beacon.proximity"];
                [poi willChangeValueForKey:@"beacon.accuracy"];
            }*/
            
            [beacon setPrimitiveValue:[NSNumber numberWithInteger:beaconValue.proximity] forKey:@"proximity"];
            [beacon setPrimitiveValue:[NSNumber numberWithInteger:beaconValue.rssi] forKey:@"rssi"];
            beacon.accuracy = [NSNumber numberWithDouble:beaconValue.accuracy];
            
            /*
            for (PointOfInterest *poi in beacon.pois) {
                [poi didChangeValueForKey:@"beacon.proximity"];
                [poi didChangeValueForKey:@"beacon.accuracy"];
            }
             */
        }
        
    }
    
    if (displayNearestBeacon && detectedTmpBeaconSet.count) {
        NSSortDescriptor *accuracySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"accuracy" ascending:YES];
        NSArray *sortedDetectedBeacons = [detectedTmpBeaconSet sortedArrayUsingDescriptors:@[accuracySortDescriptor]];
        
        TMPBeacon *nearestTMPBeacon = sortedDetectedBeacons[0];
        Beacon *beacon = [self beaconForGroup:group major:[nearestTMPBeacon.major unsignedShortValue] minor:[nearestTMPBeacon.minor unsignedShortValue] createIfNotFound:NO];
        
        BeaconDetailViewController *bdvc = (BeaconDetailViewController *)[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"BeaconDetailViewController"];
        
        bdvc.beacon = beacon;
        
        [(UINavigationController *)self.window.rootViewController pushViewController:bdvc animated:YES];
        
        displayNearestBeacon = NO;
    }
    //[self saveContext];
    
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    
    [self resetBeaconsInGroupWithUUID:[region.proximityUUID UUIDString]];

    /*
    NSString *uuidString = [region.proximityUUID UUIDString];
    NSArray *beaconArray = [self beaconsInGroupWithUUID:uuidString];
    
    for (Beacon *beacon in beaconArray) {
        beacon.proximity = [NSNumber numberWithInteger:PROXIMITY_NOT_RECEIVED];
        beacon.rssi = [NSNumber numberWithInteger:0];
        beacon.accuracy = [NSNumber numberWithDouble:0.0];
    }
    
     */
    //NSLog(@"%@", error);
}

#pragma mark - Core location configuration

- (void)setTransmitterBeacon:(Beacon *)transmitterBeacon {
    _transmitterBeacon = transmitterBeacon;
    
    NSURL *url = [transmitterBeacon.objectID URIRepresentation];
    [[NSUserDefaults standardUserDefaults] setURL:url forKey:TRANSMITTER_BEACON];
    
    [self checkTransmitter];
}

- (void)setTransmitterIsOn:(BOOL)transmitterIsOn {
    _transmitterIsOn = transmitterIsOn;
    [[NSUserDefaults standardUserDefaults] setBool:transmitterIsOn forKey:TRANSMITTER_ON];
    
    [self checkTransmitter];
}

- (void)checkTransmitter {
    if (peripheralManager.isAdvertising) {
        [self stopTransmitter];
    }
    
    if (peripheralManager.state == CBPeripheralManagerStatePoweredOn && self.transmitterIsOn && self.transmitterBeacon && !self.transmitterBeacon.isDeleted) {
        [self startTransmitter];
    }
}

- (void)startTransmitter {
    NSLog(@"startTransmitter");
    Major *major = self.transmitterBeacon.major;
    Group *group = major.group;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:group.uuid];
    
    CLBeaconMajorValue majorValue = [UIApplication convertMajorMinorString:major.major];
    CLBeaconMinorValue minorValue = [UIApplication convertMajorMinorString:self.transmitterBeacon.minor];
    
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:majorValue minor:minorValue identifier:@"transmitter"];
    
    NSDictionary *advertisingDict = [beaconRegion peripheralDataWithMeasuredPower:self.transmitterBeacon.txPower];
    
    [peripheralManager startAdvertising:advertisingDict];
    
}

- (void)stopTransmitter {
    [peripheralManager stopAdvertising];
}


#pragma mark - Peripheral Manager delegate

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"peripheralManagerDidStartAdvertising:error:");
    if (error) {
        TRACE
        NSLog(@"%@", error);
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self checkTransmitter];
    }
    else if (peripheralManager.state == CBPeripheralManagerStatePoweredOff) {
        [peripheralManager stopAdvertising];
    }
}


- (NSArray *)backgroundNotifications {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Notification"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"enabled == YES"];
    
    NSError *error = nil;
    NSArray *notifications = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        TRACE
        //NSLog(@"%@", error);
    }
    
    return notifications;
}


- (CLBeaconRegion *)regionForNotification:(Notification *)notification {
    CLBeaconRegion *region = nil;
    
    NSString *notificationString = [notification.objectID.URIRepresentation absoluteString];
    
    Beacon *beacon = nil;
    Major *major = nil;
    Group *group = nil;
    
    NSUUID *uuid = nil;
    CLBeaconMajorValue majorValue;
    CLBeaconMinorValue minorValue;
    
    if (notification.beacon) {
        beacon = notification.beacon;
        major = beacon.major;
        group = major.group;
    }
    else if (notification.major) {
        major = notification.major;
        group = major.group;
    }
    else {
        group = notification.group;
        
    }
    
    uuid = [[NSUUID alloc] initWithUUIDString:group.uuid];
    
    if (major) {
        majorValue = [UIApplication convertMajorMinorString:major.major];
        if (beacon) {
            minorValue = [UIApplication convertMajorMinorString:beacon.minor];
        }
    }
    
    if (beacon) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:majorValue minor:minorValue identifier:notificationString];
    }
    else if (major) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:majorValue identifier:notificationString];
    }
    else {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:notificationString];
    }
    
    region.notifyEntryStateOnDisplay = [notification.onDisplay boolValue];
    
    return region;
}


- (Notification *)notificationObjectWithStringIdentifier:(NSString *)stringIdentifier {
    NSURL *url = [NSURL URLWithString:stringIdentifier];
    NSManagedObjectID *objectID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:url];
    
    return (Notification *)[self.managedObjectContext objectWithID:objectID];
}

- (NSString *)nameForNotification:(Notification *)notification {
    NSString *name = nil;
    
    Beacon *beacon = nil;
    Major *major = nil;
    Group *group = nil;
    
    
    if (notification.beacon) {
        beacon = notification.beacon;
        NSString *format = NSLocalizedString(@"NOTIFICATION_BEACON_NAME_FORMAT", @"");
        
        name = [NSString stringWithFormat:format, beacon.name];
    }
    else if (notification.major) {
        major = notification.major;
        group = major.group;
        NSString *format = NSLocalizedString(@"NOTIFICATION_MAJOR_NAME_FORMAT", @"");
        
        name = [NSString stringWithFormat:format, group.name, major.major];
    }
    else {
        group = notification.group;
        NSString *format = NSLocalizedString(@"NOTIFICATION_GROUP_NAME_FORMAT", @"");
        
        name = [NSString stringWithFormat:format, group.name];
    }

    
    
    
    return name;
}

#pragma mark - Navigation Controller Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    BOOL listeningScreen = NO;
    BOOL navigationBarHidden = navigationController.navigationBarHidden;
    
    if ([viewController.restorationIdentifier isEqualToString:@"RootViewController"]) {
        listeningScreen = YES;
        if (!navigationBarHidden) {
            [navigationController setNavigationBarHidden:YES animated:animated];
        }
    }
    else {
        if (navigationBarHidden) {
            [navigationController setNavigationBarHidden:NO animated:animated];
        }
        if ([viewController.restorationIdentifier isEqualToString:@"ListenTableViewController"]) {
            listeningScreen = YES;
        }
        else if ([viewController.restorationIdentifier isEqualToString:@"BeaconDetailViewController"]) {
            listeningScreen = YES;
        }
        
    }
    

    if (monitoringRange && !listeningScreen) {
        [self stopListeningBeacons];
        monitoringRange = NO;
    }
    
    else if (!monitoringRange && listeningScreen && notInBackground) {
        [self startListeningBeacons];
        monitoringRange = YES;
    }
    
    
}

#pragma mark -


- (NSArray *)enabledSubNotifications:(Notification *)notification {
    NSArray *subNotifications = nil;
    
    if (!notification.beacon) {
        // pas de notifications en dessous d'une pour balise
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
        
        if (notification.group) {
            // si la notification est un group, on cherche les notifications sur les major et beacon en dessous
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(enabled == 1) AND ((major.group == %@) OR (beacon.major.group == %@))", notification.group, notification.group];
            
        }
        else {
            // major
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(enabled == 1) AND (beacon.major == %@)", notification.major];
        }
        
        NSError *error = nil;
        subNotifications = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            TRACE
            //NSLog(@"%@", error);
        }
        
    }
    
    
    return subNotifications;
}

- (NSUInteger)enabledNotificationsCount {
    
    NSUInteger count = 0;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"enabled == 1"];
    
    fetchRequest.resultType = NSCountResultType;
    NSError *error = nil;
    count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    if (error) {
        TRACE
        //NSLog(@"%@", error);
    }
    
    return count;
}


- (void)disableNotificationsForGroup:(Group *)group {
    group.notification.enabled = @NO;
    
    for (Major *major in group.majors) {
        major.notification.enabled = @NO;
        
        for (Beacon *beacon in major.beacons) {
            beacon.notification.enabled = @NO;
        }
        
    }
    
}

- (void)jsonPoiReceived:(NSArray *)poiArray forBeacons:(NSArray *)beacons {
    
    // pour limiter les appels
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    NSEntityDescription *poiEntityDescription = [NSEntityDescription entityForName:@"POI" inManagedObjectContext:managedObjectContext];
    
    dispatch_queue_t asynchroneQueue = dispatch_queue_create("com.eurelis.mobile.ibloc.jsonPoiQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(asynchroneQueue, ^{
       
        NSMutableDictionary *beaconToPOISetDictionary = [NSMutableDictionary dictionary];
        NSMutableDictionary *fullIdToBeacon = [NSMutableDictionary dictionary];
        
        for (NSDictionary *poiDic in poiArray) {
            NSString *title = [poiDic valueForKey:@"title"];
            NSString *text = [poiDic valueForKey:@"text"];
            NSString *image = [poiDic valueForKey:@"image"];
            NSString *link = [poiDic valueForKey:@"link"];
            NSString *uuid = [poiDic valueForKey:@"uuid"];
            NSString *major = [poiDic valueForKey:@"major"];
            NSString *minor = [poiDic valueForKey:@"minor"];
            NSString *nidStr = [poiDic valueForKey:@"id"];
            NSString *changedStr = [poiDic valueForKey:@"changed"];
            NSString *imageChangedStr = [poiDic valueForKey:@"image_changed"];
            
            unsigned long long changedULL, imageChangedULL, nidULL;
            
            @autoreleasepool {
                NSScanner *changedScanner = [NSScanner scannerWithString:changedStr];
                [changedScanner scanUnsignedLongLong:&changedULL];
                NSScanner *imageChangedScanner = [NSScanner scannerWithString:imageChangedStr];
                [imageChangedScanner scanUnsignedLongLong:&imageChangedULL];
                NSScanner *nidScanner = [NSScanner scannerWithString:nidStr];
                [nidScanner scanUnsignedLongLong:&nidULL];
            }
            
            NSNumber *nid = [NSNumber numberWithUnsignedInteger:(NSUInteger)nidULL];
            NSNumber *changed = [NSNumber numberWithUnsignedInteger:(NSUInteger)changedULL];
            NSNumber *image_changed = [NSNumber numberWithUnsignedInteger:(NSUInteger)imageChangedULL];
            
            
            NSString *fullID = [NSString stringWithFormat:@"%@-%@-%@", [uuid uppercaseString], [major uppercaseString], [minor uppercaseString]];

            __block Beacon *beacon = [fullIdToBeacon valueForKey:fullID];
            NSMutableSet *poiSet = nil;
            
            if (!beacon) {
                // si on ne connait pas la balise on la récupère depuis le thread principal
                dispatch_sync(mainQueue, ^{
                    // peut créer des balises
                    beacon = [self beaconForUUID:[uuid uppercaseString] major:major minor:minor createIfNotFound:YES];
                
                });
                
                [fullIdToBeacon setValue:beacon forKey:fullID];
                poiSet = [NSMutableSet set];
                [beaconToPOISetDictionary setValue:poiSet forKey:fullID];
            }
            else {
                poiSet = [beaconToPOISetDictionary objectForKey:fullID];
            }
            
            __block PointOfInterest *poi = nil;
            dispatch_sync(mainQueue, ^{
                poi = [self poiWithNid:nid];
            });
            
            BOOL created = NO;
            if (!poi) {
                created = YES;
                poi = [[PointOfInterest alloc] initWithEntity:poiEntityDescription insertIntoManagedObjectContext:nil];
            }
            
            // pas d'insertion à ce moment
            //PointOfInterest *poi = [[PointOfInterest alloc] initWithEntity:poiEntityDescription insertIntoManagedObjectContext:nil];
            
            __block BOOL poiChanged = YES;
            if (created) {
                //[poi setPrimitiveValue:changed forKey:@"changed"];
                [poi setPrimitiveValue:nid forKey:@"nid"];
            }
            else {
                dispatch_sync(mainQueue, ^{
                    if ([poi.changed isEqual:changed]) {
                        poiChanged = NO;
                        // si existait déjà, on trigger le change seulement dans ce cas
                    }
                });
                
            }
            
            if (poiChanged) {
                dispatch_sync(mainQueue, ^{
                    [poi setPrimitiveValue:title forKey:@"title"];
                    [poi setPrimitiveValue:text forKey:@"text"];
                    [poi setPrimitiveValue:image forKey:@"imageURL"];
                    [poi setPrimitiveValue:link forKey:@"link"];
                    [poi setPrimitiveValue:image_changed forKey:@"image_changed"];
                    poi.changed = changed;
                });
            }
            
            /*
            poi.title = title;
            poi.text = text;
            poi.imageURL = image;
            poi.link = link;
            poi.changed = changed;
            poi.image_changed = image_changed;
            */
            
            [poiSet addObject:poi];
            
        }
        
        // ici on peuple
        
        dispatch_sync(mainQueue, ^{
           
            for (Beacon *beacon  in beacons) {
                Major *m = beacon.major;
                Group *g = m.group;
                
                NSString *fullID = [NSString stringWithFormat:@"%@-%@-%@", [g.uuid uppercaseString], [m.major uppercaseString], [beacon.minor uppercaseString]];
                
                if (![beaconToPOISetDictionary valueForKey:fullID]) {
                    [beaconToPOISetDictionary setValue:[NSSet set] forKey:fullID];
                    [fullIdToBeacon setValue:beacon forKey:fullID];
                }
                
            }
            
        });
        
        
        
        __block NSUInteger remainingBeacons = [beaconToPOISetDictionary count];
        
        [beaconToPOISetDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *fullId = (NSString *)key;
            NSSet *poiSet = (NSSet *)obj;
            Beacon *beacon = [fullIdToBeacon valueForKey:fullId];
           
            // fait en asynchrone sur le thread principal
            dispatch_async(mainQueue, ^{
                remainingBeacons--;
                
                NSMutableSet *newPoiNidSet = [NSMutableSet set];
                
                for (PointOfInterest *poi in poiSet) {
                    [newPoiNidSet addObject:poi.nid];
                }
                
                for (PointOfInterest *poi in beacon.pois) {
                    if (![newPoiNidSet containsObject:poi.nid]) {
                        // on supprime les éléments qui ne sont plus présents
                        [managedObjectContext deleteObject:poi];
                    }
                }
                
                for (PointOfInterest *poi in poiSet) {
                    if (!poi.managedObjectContext) {
                        [managedObjectContext insertObject:poi];
                        
                        if (poi.imageURL) {
                            PictureDownloaderOperation *pdo = [[PictureDownloaderOperation alloc] initWithPOI:poi];
                            [operationQueue addOperation:pdo];
                        }
                        
                    }
                    else {
                        if (![poi.image_changed isEqual:poi.current_image_changed]) {
                            PictureDownloaderOperation *pdo = [[PictureDownloaderOperation alloc] initWithPOI:poi];
                            [operationQueue addOperation:pdo];
                        }
                    }
                    
                    // ici test pour lancer le téléchargement
                    // on force la beacon, au cas où elle est changé
                    poi.beacon = beacon;
                }
                
                beacon.pois = poiSet; // remplacement des POIs

                                
                if (remainingBeacons == 0) {
                    // seulement sur la dernière beacon
                    [self saveContext];
                }
                
            });
            
        }];
        
        
        
    });
    
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
        
    if (object == operationQueue && [keyPath isEqualToString:@"operationCount"]) {
        UIApplication *app = [UIApplication sharedApplication];
         BOOL activityIndicatorVisible =  [app isNetworkActivityIndicatorVisible];
        
        if (operationQueue.operationCount == 0 && activityIndicatorVisible) {
            [app setNetworkActivityIndicatorVisible:NO];
            
        }
        else if (operationQueue.operationCount > 0 && !activityIndicatorVisible) {
            [app setNetworkActivityIndicatorVisible:YES];
        }
        
    }
    
}

- (NSString *)imagePathForPoi:(PointOfInterest *)poi {
    NSString *imageName = [NSString stringWithFormat:@"%lu.%@", (unsigned long)[poi.nid unsignedIntegerValue], [poi.imageURL pathExtension]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];

    return [documentDirectory stringByAppendingPathComponent:imageName];
}


@end


@implementation UIApplication (Beacon)

+ (uint16_t)convertMajorMinorString:(NSString *)stringValue {
    
    unsigned int rawValue;
    uint16_t value = 0;
    
    NSScanner *scanner = [NSScanner scannerWithString:stringValue];
    [scanner scanHexInt:&rawValue];
    value = rawValue;
    
    
    return value;
}

+ (NSString *)convertMajorMinorToString:(uint16_t)majorMinor {
    return [NSString stringWithFormat:@"%04X", majorMinor];
}

+ (AppDelegate *)delegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end

static __strong UIColor *s_immediateColor = nil;
static __strong UIColor *s_nearColor = nil;
static __strong UIColor *s_farColor = nil;
static __strong UIColor *s_unknownColor = nil;
static __strong UIColor *s_transparentBackgroundColor = nil;

@implementation UIColor (BeaconColor)


+ (UIColor *)immediateColor {
    if (!s_immediateColor) {
        s_immediateColor = [UIColor colorWithRed:0.54117647058824f green:0.66274509803922f blue:0.61176470588235f alpha:1.0f];
    }
    return s_immediateColor;
}

+ (UIColor *)nearColor {
    
    if (!s_nearColor) {
        s_nearColor = [UIColor colorWithRed:0.54117647058824f green:0.65882352941176f blue:0.65882352941176f alpha:1.0f];
    }
    return s_nearColor;
}

+ (UIColor *)farColor {
    
    if (!s_farColor) {
        s_farColor = [UIColor colorWithRed:0.53725490196078f green:0.57254901960784f blue:0.65882352941176f alpha:1.0f];
    }
    return s_farColor;
}

+ (UIColor *)unknownColor {
    
    if (!s_unknownColor) {
        s_unknownColor = [UIColor colorWithRed:0.65490196078431f green:0.52549019607843f blue:0.65490196078431f alpha:1.0f];
    }
    return s_unknownColor;
}

+ (UIColor *)transparentBackgroundColor {
    
    if (!s_transparentBackgroundColor) {
        s_transparentBackgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    }
    return s_transparentBackgroundColor;
}



@end


