//
//  TMPBeacon.m
//  iBLocator
//
//  Created by Jérôme Olivier Diaz on 26/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "TMPBeacon.h"
#import <CoreLocation/CoreLocation.h>
#import "TMPBeaconValue.h"

static NSNull *null;

@implementation TMPBeacon

+ (void)initialize {
    null = [NSNull null];
}

- (id)initWithBeacon:(CLBeacon *)beacon {
    if ((self = [super init])) {
        _uuid = beacon.proximityUUID;
        _major = beacon.major;
        _minor = beacon.minor;
        
        valueArray = [[NSMutableArray alloc] initWithCapacity:BEACON_BUFFER_SIZE];
    }
    
    return self;
}

- (void)addValueFromBeacon:(CLBeacon *)beacon {
    TMPBeaconValue *beaconValue = [[TMPBeaconValue alloc] initWithBeacon:beacon];
    
    if ([valueArray count] == BEACON_BUFFER_SIZE) {
        [valueArray removeLastObject];
    }
    
    [valueArray insertObject:beaconValue atIndex:0];
}

- (void)addNullValue {
    if ([valueArray count] == BEACON_BUFFER_SIZE) {
        [valueArray removeLastObject];
    }
    [valueArray insertObject:null atIndex:0];
}

- (TMPBeaconValue *)computedBeaconValue {
    NSUInteger count = [valueArray count];
    TMPBeaconValue *beaconValue = nil;
    
    
    if (count) {
        
        double totalWeight = 0;
        double rssi = 0;
        double proximity = 0;
        double accuracy = 0;
        NSUInteger index = 0;
        
        for (TMPBeaconValue *bValue in valueArray) {
            
            if (![bValue isEqual:null]) {
                if (bValue.proximity != UNKNOWN || bValue.rssi > -25) {
                    //double weight = 1.0f;
                    double weight = count - index;
                    //weight *= weight;
                    totalWeight += weight;
                    
                    rssi       +=  bValue.rssi * weight;
                    proximity  +=  bValue.proximity * weight;
                    accuracy   +=  bValue.accuracy * weight;
                }
            }
            
            
            index++;
        }
        
        if (totalWeight != 0) {
            rssi /= totalWeight;
            proximity /= totalWeight;
            accuracy /= totalWeight;
            
            beaconValue = [[TMPBeaconValue alloc] initWithRssi:rssi andAccuracy:accuracy andProximity:proximity];
            
            ////NSLog(@"\n%@\n%@", valueArray, beaconValue);
            
            _accuracy = [NSNumber numberWithDouble:accuracy];
        }
    
    }
    
    
    return beaconValue;
}




- (BOOL)shouldBeAdded {
    if ([valueArray count] < 2) {
        return NO;
    }
    
    if (valueArray[0] != null && valueArray[1] != null) {
        // possible car singleton
        return YES;
    }
    return NO;
}


- (BOOL)shouldBeRemoved {
    if ([valueArray count] < 2) {
        return NO;
    }
    if (valueArray[0] == null && valueArray[1] == null) {
        // possible car singleton
        return YES;
    }
    return NO;
}

- (BOOL)isEqual:(id)object {
    if ([object isMemberOfClass:[self class]]) {
        return ([self hash] == [object hash]);
    }
    return NO;
}

- (NSUInteger)hash {
    NSUInteger hashValue = [_uuid hash] + [_major hash] + [_minor hash];
    return hashValue;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%04X %04X", [_major unsignedShortValue], [_minor unsignedShortValue]];
}

@end
