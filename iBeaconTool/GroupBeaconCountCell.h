//
//  GroupBeaconCountCell.h
//  iBLocator
//
//  Created by Eurelis on 13/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Group;

@interface GroupBeaconCountCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *groupLabel;
@property (nonatomic, retain) IBOutlet UISwitch *displaySwitch;
@property (nonatomic, weak) Group *group;

- (void)configure;

- (IBAction)displaySwitchValueChanged:(UISwitch *)sender;

@end
