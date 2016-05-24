//
//  AppDelegate.h
//  iBLocator
//
//  Created by Eurelis on 12/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "StoreModel.h"

@class PoiFetcher;
@class PointOfInterest;
@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate, UINavigationControllerDelegate>
{
    CLLocationManager *locationManager;
    CBPeripheralManager *peripheralManager;
    BOOL monitoringRange;
    
    BOOL notInBackground;
    BOOL active;
    
    NSMutableArray *fullBeaconArray;
    NSMutableArray *workingBeaconArray;
    BOOL use;
    BOOL displayNearestBeacon;
    
    NSOperationQueue *operationQueue;
    
}

@property (nonatomic, readonly) NSUInteger workingBeaconCount;

@property (nonatomic, assign) BOOL transmitterIsOn;
@property (nonatomic, strong) Beacon *transmitterBeacon;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (Major *)majorForGroup:(Group *)group major:(uint16_t)major createIfNotFound:(BOOL)create;
- (Beacon *)beaconForGroup:(Group *)group major:(uint16_t)major minor:(uint16_t)minor createIfNotFound:(BOOL)create;
- (Beacon *)beaconForUUID:(NSString *)uuid major:(NSString *)majorHex minor:(NSString *)minorHex createIfNotFound:(BOOL)create;
- (NSArray *)beaconsForUUID:(NSString *)uuid major:(NSString *)majorHex minor:(NSString *)minorHex;
- (PointOfInterest *)poiWithNid:(NSNumber *)nid;

- (NSArray *)backgroundNotifications;
- (CLBeaconRegion *)regionForNotification:(Notification *)notification;
- (Notification *)notificationObjectWithStringIdentifier:(NSString *)stringIdentifier;
- (Group *)groupWithUUID:(NSString *)uuid;

- (void)startListeningBeacons;
- (void)stopListeningBeacons;

- (void)startTransmitter;
- (void)stopTransmitter;


- (NSArray *)enabledSubNotifications:(Notification *)notification;
- (NSUInteger)enabledNotificationsCount;

- (void)disableNotificationsForGroup:(Group *)group;


- (void)jsonPoiReceived:(NSArray *)poi forBeacons:(NSArray *)beacons;
- (void)queuePoiFetcher:(PoiFetcher *)fetcher;

- (NSString *)imagePathForPoi:(PointOfInterest *)poi;
- (BOOL)isUUID:(NSString *)testString;

@end


@interface UIApplication (Beacon)
+ (uint16_t)convertMajorMinorString:(NSString *)stringValue;
+ (NSString *)convertMajorMinorToString:(uint16_t)majorMinor;
+ (AppDelegate *)delegate;
@end

@interface UIColor (BeaconColor)
+ (UIColor *)immediateColor;
+ (UIColor *)nearColor;
+ (UIColor *)farColor;
+ (UIColor *)unknownColor;
+ (UIColor *)transparentBackgroundColor;
@end