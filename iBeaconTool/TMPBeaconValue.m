//
//  TMPBeaconValue.m
//  iBLocator
//
//  Created by Jérôme Olivier Diaz on 26/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "TMPBeaconValue.h"

@implementation TMPBeaconValue

- (id)initWithBeacon:(CLBeacon *)beacon {
    if ((self = [super init])) {
        _rssi = beacon.rssi;
        _accuracy = beacon.accuracy;
        
        switch (beacon.proximity) {
            case CLProximityFar:
                _proximity = FAR;
                break;
            case CLProximityImmediate:
                _proximity = IMMEDIATE;
                break;
            case CLProximityNear:
                _proximity = NEAR;
                break;
            case CLProximityUnknown:
                _proximity = UNKNOWN;
                break;
        }
        
    }
    return self;
}

- (id)initWithRssi:(NSInteger)rssi andAccuracy:(CLLocationAccuracy)accuracy andProximity:(Proximity)proximity {
    if ((self = [super init])) {
        _rssi = rssi;
        _accuracy = accuracy;
        _proximity = proximity;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d %ld %f", _proximity, (long)_rssi, _accuracy];
    
}


@end
