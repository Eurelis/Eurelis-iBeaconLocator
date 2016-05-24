//
//  PointOfInterestCollectionCell.h
//  iBLocator
//
//  Created by Jérôme Olivier Diaz on 17/03/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PointOfInterest;

@interface PointOfInterestCollectionCell : UICollectionViewCell

@property (nonatomic, strong) PointOfInterest *poi;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;

@end
