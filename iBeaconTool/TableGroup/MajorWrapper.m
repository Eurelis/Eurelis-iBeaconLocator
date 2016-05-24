//
//  MajorWrapper.m
//  iBLocator
//
//  Created by Eurelis on 21/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "MajorWrapper.h"

@implementation MajorWrapper

@synthesize major = major;

- (id)initWithMajor:(Major *)aMajor {
    self = [super init];
    
    if (self) {
        major = aMajor;
        beaconWrapperArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addBeaconWrapper:(BeaconWrapper *)beaconWrapper {
    [beaconWrapperArray addObject:beaconWrapper];
}


@end
