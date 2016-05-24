//
//  ListenedBeaconCell.h
//  iBLocator
//
//  Created by Eurelis on 20/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListenedBeaconCell : UITableViewCell


@property (nonatomic, retain) IBOutlet UIImageView *beaconProximityImageView;
@property (nonatomic, retain) IBOutlet UILabel *beaconNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *rssiLabel;
@property (nonatomic, retain) IBOutlet UILabel *accuracyLabel;

@end
