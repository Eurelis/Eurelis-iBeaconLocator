//
//  PointOfInterestTableViewCell.h
//  iBLocator
//
//  Created by Eurelis on 28/03/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointOfInterestTableViewCell : UITableViewCell

@property (nonatomic, strong) PointOfInterest *poi;

@property (nonatomic, weak) IBOutlet UIImageView *poiImageView;
@property (nonatomic, weak) IBOutlet UILabel *poiTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *poiTextLabel;

@end
