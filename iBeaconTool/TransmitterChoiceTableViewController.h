//
//  TransmitterChoiceTableViewController.h
//  iBLocator
//
//  Created by Eurelis on 21/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TableGroupListManager;
@interface TransmitterChoiceTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    TableGroupListManager *tableGroupListManager;
    
    Class groupWrapperClass;
    Class majorWrapperClass;
    Class beaconWrapperClass;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISwitch *transmitterSwitch;

@property (nonatomic, weak) IBOutlet UILabel *emitterStateLabel;
@property (nonatomic, weak) IBOutlet UILabel *selecterBeaconLabel;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)transmitterSwitchValueChanged:(UISwitch *)sender;

@end
