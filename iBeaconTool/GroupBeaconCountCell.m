//
//  GroupBeaconCountCell.m
//  iBLocator
//
//  Created by Eurelis on 13/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "GroupBeaconCountCell.h"
#import "Group.h"

@implementation GroupBeaconCountCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
   
    [self configure];
    
    [self.displaySwitch addTarget:self action:@selector(displaySwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)setGroup:(Group *)group {
    _group = group;
    [self configure];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    
    //BOOL switchState = !self.displaySwitch.isOn;
    
    //[self.displaySwitch setOn:switchState animated:NO];
    
}

- (IBAction)displaySwitchValueChanged:(UISwitch *)sender
{
    BOOL active = sender.isOn;
    self.group.active = [NSNumber numberWithBool:active];
    
    self.accessoryType = (active)?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
    
    self.groupLabel.text = (active?NSLocalizedString(@"ACTIVE_GROUP_DESC", @""):NSLocalizedString(@"INACTIVE_GROUP_DESC", @""));
    
    if (!active) {
        [[UIApplication delegate] disableNotificationsForGroup:self.group];
    }
    
}

- (void)configure {
     if (self.displaySwitch && self.group) {
         BOOL on = [self.group.active boolValue];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.displaySwitch setOn:on animated:YES];
             self.groupLabel.text = (on?NSLocalizedString(@"ACTIVE_GROUP_DESC", @""):NSLocalizedString(@"INACTIVE_GROUP_DESC", @""));
         });
         
     }
}


@end
