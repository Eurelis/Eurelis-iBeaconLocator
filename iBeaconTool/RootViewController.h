//
//  RootViewController.h
//  iBLocator
//
//  Created by Eurelis on 27/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController


@property (nonatomic, weak) IBOutlet UILabel *beaconCountLabel;

@property (nonatomic, weak) IBOutlet UIButton *listenButton;
@property (nonatomic, weak) IBOutlet UIButton *emitButton;
@property (nonatomic, weak) IBOutlet UIButton *settingsButton;
@property (nonatomic, weak) IBOutlet UIButton *contactButton;


- (IBAction)contactButtonPushed:(id)sender;

@end
