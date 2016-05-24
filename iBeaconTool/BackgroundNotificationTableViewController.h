//
//  BackgroundNotificationTableViewController.h
//  iBLocator
//
//  Created by Eurelis on 24/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Group;
@class TableGroupListManager;
@interface BackgroundNotificationTableViewController : UIViewController {
    TableGroupListManager *tableGroupListManager;
    
    Class groupWrapperClass;
    Class majorWrapperClass;
    Class beaconWrapperClass;
    
    UIView *containerView;
}

@property (nonatomic, weak) Group *group;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) TableGroupListManager *tableGroupListManager;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)dismissSettingsPanelViewController;
- (IBAction)dismissMajorCreationViewController:(Major *)major;

@end
