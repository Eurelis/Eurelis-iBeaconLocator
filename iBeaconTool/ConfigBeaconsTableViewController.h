//
//  ConfigBeaconsTableViewController.h
//  iBLocator
//
//  Created by Eurelis on 13/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupListManager;

@class Group;
@class Beacon;
@interface ConfigBeaconsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    GroupListManager *groupListManager;
    BOOL insertGroupDisplayed;
    BOOL editingSingleRow;
    
    Group *workGroup;
    Beacon *workBeacon;
    
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) GroupListManager *groupListManager;
@property (nonatomic, readonly) BOOL editingSingleRow;
@property (nonatomic, readonly) BOOL isReallyEditing;

- (void)configureCell:(UITableViewCell *)cell withGroup:(Group *)group;
- (void)configureCell:(UITableViewCell *)cell withBeacon:(Beacon *)beacon;

@end
