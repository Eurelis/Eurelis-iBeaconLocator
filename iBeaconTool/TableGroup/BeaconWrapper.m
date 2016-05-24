//
//  BeaconWrapper.m
//  iBLocator
//
//  Created by Eurelis on 21/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "BeaconWrapper.h"

@implementation BeaconWrapper

@synthesize beacon = beacon;

- (id)initWithBeacon:(Beacon *)aBeacon {
    self = [super init];
    
    if (self) {
        beacon = aBeacon;
    }
    
    return self;
}

@end
