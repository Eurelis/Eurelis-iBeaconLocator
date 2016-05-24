//
//  PointOfInterestTableViewCell.m
//  iBLocator
//
//  Created by Eurelis on 28/03/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "PointOfInterestTableViewCell.h"

@implementation PointOfInterestTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
