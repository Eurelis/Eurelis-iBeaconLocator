//
//  NotificationSettingsPanelViewController.h
//  iBLocator
//
//  Created by Eurelis on 24/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Notification;
@interface NotificationSettingsPanelViewController : UIViewController


@property (nonatomic, strong) id wrapper;
@property (nonatomic, weak) IBOutlet UISwitch *enableSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *onEnter;
@property (nonatomic, weak) IBOutlet UISwitch *onExit;
@property (nonatomic, weak) IBOutlet UISwitch *onDisplay;

@property (nonatomic, weak) IBOutlet UILabel *enableNotificationsLabel;
@property (nonatomic, weak) IBOutlet UILabel *onEntryLabel;
@property (nonatomic, weak) IBOutlet UILabel *onExitLabel;
@property (nonatomic, weak) IBOutlet UILabel *onDisplayLabel;


@property (nonatomic, weak) IBOutlet UIView *nonTappableView;

@property (nonatomic, readonly) Notification *notification;

- (IBAction)enableSwitchValueChanged:(UISwitch *)sender;

- (IBAction)backgroundTapped:(UITapGestureRecognizer *)sender;

@end
