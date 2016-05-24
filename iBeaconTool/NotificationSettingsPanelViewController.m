//
//  NotificationSettingsPanelViewController.m
//  iBLocator
//
//  Created by Eurelis on 24/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "NotificationSettingsPanelViewController.h"
#import "StoreModel.h"
#import "GroupWrapper.h"
#import "MajorWrapper.h"
#import "BeaconWrapper.h"
#import "AppDelegate.h"
#import "BackgroundNotificationTableViewController.h"
#import "TableGroupListManager.h"

@interface NotificationSettingsPanelViewController ()

@end

@implementation NotificationSettingsPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.enableNotificationsLabel.text = NSLocalizedString(@"ENABLE_NOTIFICATIONS", @"");
    self.onEntryLabel.text = NSLocalizedString(@"ON_ENTRY", @"");
    self.onExitLabel.text = NSLocalizedString(@"ON_EXIT", @"");
    self.onDisplayLabel.text = NSLocalizedString(@"ON_DISPLAY", @"");
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    Notification *notification = self.notification;
    
    BOOL notifEnabled = [notification.enabled boolValue];
    [self.enableSwitch setOn:notifEnabled animated:NO];
    
    if (notifEnabled) {
        [self.onEnter setOn:[notification.onEntry boolValue] animated:NO];
        [self.onExit setOn:[notification.onExit boolValue] animated:NO];
        [self.onDisplay setOn:[notification.onDisplay boolValue] animated:NO];
        
        self.onDisplay.enabled = YES;
        self.onEnter.enabled = YES;
        self.onExit.enabled = YES;
    }
    else {
        [self.onEnter setOn:NO animated:NO];
        [self.onExit setOn:NO animated:NO];
        [self.onDisplay setOn:NO animated:NO];
        
        self.onDisplay.enabled = NO;
        self.onEnter.enabled = NO;
        self.onExit.enabled = NO;
        
        
    }
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)enableSwitchValueChanged:(UISwitch *)sender {
    
    BOOL isOn = sender.isOn;
    BOOL possible = YES;
    
    if (isOn) {
        // on vérifie qu'on ne dépasse pas les 20
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        
        NSUInteger notificationsCount = [appDelegate enabledNotificationsCount];
        NSArray *subNotifications = [appDelegate enabledSubNotifications:self.notification];
        
        notificationsCount -= [subNotifications count];
        
        if (notificationsCount > 20) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TOO_MANY_ENABLED_NOTIFICATIONS", @"TOO_MANY_ENABLED_NOTIFICATIONS") message:NSLocalizedString(@"TOO_MANY_ENABLED_NOTIFICATIONS_MSG", @"TOO_MANY_ENABLED_NOTIFICATIONS_MSG") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            possible = NO;
            [alertView show];
            isOn = NO;
            [sender setOn:NO animated:NO];
        }
        else {
            self.notification.enabled = [NSNumber numberWithBool:YES];
            
            for (Notification *subNotification in subNotifications) {
                subNotification.enabled = [NSNumber numberWithBool:NO];
            }
            
            [self.onDisplay setOn:[self.notification.onDisplay boolValue] animated:YES];
            [self.onEnter setOn:[self.notification.onEntry boolValue] animated:YES];
            [self.onExit setOn:[self.notification.onExit boolValue] animated:YES];
            
            self.onDisplay.enabled = YES;
            self.onEnter.enabled = YES;
            self.onExit.enabled = YES;
            
        }
    }
    else {
        self.notification.enabled = [NSNumber numberWithBool:NO];
        
        [self.onDisplay setOn:NO animated:YES];
        [self.onEnter setOn:NO animated:YES];
        [self.onExit setOn:NO animated:YES];
        self.onDisplay.enabled = NO;
        self.onEnter.enabled = NO;
        self.onExit.enabled = NO;
    }
    
    
    if (possible) {
        TableGroupListManager *tglm = ((BackgroundNotificationTableViewController *)self.parentViewController).tableGroupListManager;
    
        BeaconWrapper *beaconWrapper = [self beaconWrapper];
        if (beaconWrapper) {
            [tglm reloadWrapperForBeaconWrapper:beaconWrapper];
                        /*
            if (isOn) {
                
            }
            else {
                
            }*/
            
        }
        else {
            MajorWrapper *majorWrapper = [self majorWrapper];
            
            if (majorWrapper) {
                if (!isOn) {
                    [tglm addSubWrappersForMajorWrapper:majorWrapper];
                }
                else {
                    [tglm removeSubWrappersForMajorWrapper:majorWrapper];
                }
            }
            else {
                GroupWrapper *groupWrapper = [self groupWrapper];
                if (groupWrapper) {
                    if (!isOn) {
                        [tglm addSubWrappersForGroupWrapper:groupWrapper];
                    }
                    else {
                        [tglm removeSubWrappersForGroupWrapper:groupWrapper];
                    }
                }
            }
            
        }
    
    }
    
}

- (IBAction)backgroundTapped:(UITapGestureRecognizer *)sender {
    
    CGPoint point = [sender locationInView:self.nonTappableView];
    
    if (point.y < 0) {
        Notification *notification = self.notification;
        
        notification.enabled = [NSNumber numberWithBool:self.enableSwitch.isOn];
        notification.onEntry = [NSNumber numberWithBool:self.onEnter.isOn];
        notification.onExit = [NSNumber numberWithBool:self.onExit.isOn];
        notification.onDisplay = [NSNumber numberWithBool:self.onDisplay.isOn];
        
        
        BackgroundNotificationTableViewController *bntvc = (BackgroundNotificationTableViewController *)self.parentViewController;
        
        [bntvc dismissSettingsPanelViewController];
        [self removeFromParentViewController];
        [[UIApplication delegate] saveContext];
    }
    
}

- (BeaconWrapper *)beaconWrapper {
    if ([_wrapper isKindOfClass:[BeaconWrapper class]]) {
        return (BeaconWrapper *)_wrapper;
    }
    return nil;
}

- (MajorWrapper *)majorWrapper {
    if ([_wrapper isKindOfClass:[MajorWrapper class]]) {
        return (MajorWrapper *)_wrapper;
    }
    return nil;
}

- (GroupWrapper *)groupWrapper {
    if ([_wrapper isKindOfClass:[GroupWrapper class]]) {
        return (GroupWrapper *)_wrapper;
    }
    return nil;
}


- (Notification *)notification {
    Notification *notif = nil;
    BeaconWrapper *bWrapper = nil;
    MajorWrapper *mWrapper = nil;
    GroupWrapper *gWrapper = nil;
    
    NSManagedObject *object = nil;
    
    bWrapper = [self beaconWrapper];
    
    if (!bWrapper) {
        mWrapper = [self majorWrapper];
        
        if (!mWrapper) {
            gWrapper = [self groupWrapper];
            notif = gWrapper.group.notification;
            object = gWrapper.group;
        }
        else {
            notif = mWrapper.major.notification;
            object = mWrapper.major;
        }
    }
    else {
        notif = bWrapper.beacon.notification;
        object = bWrapper.beacon;
    }
    
    if (!notif) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        notif = (Notification *)[NSEntityDescription insertNewObjectForEntityForName:@"Notification" inManagedObjectContext:appDelegate.managedObjectContext];
        
        [object setValue:notif forKey:@"notification"];
        [appDelegate.managedObjectContext refreshObject:object mergeChanges:YES];
        
    }
    
    return notif;
}


@end
