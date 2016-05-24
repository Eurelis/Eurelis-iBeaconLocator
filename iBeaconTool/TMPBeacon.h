//
//  TMPBeacon.h
//  iBLocator
//
//  Created by Jérôme Olivier Diaz on 26/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLBeacon;
@class TMPBeaconValue;

@interface TMPBeacon : NSObject {
    NSMutableArray *valueArray;
}

@property (nonatomic, readonly) NSUUID *uuid;
@property (nonatomic, readonly) NSNumber *major;
@property (nonatomic, readonly) NSNumber *minor;
@property (nonatomic, strong) NSNumber *accuracy;

- (id)initWithBeacon:(CLBeacon *)beacon;
- (void)addValueFromBeacon:(CLBeacon *)beacon;
- (void)addNullValue;
- (TMPBeaconValue *)computedBeaconValue;

@property (nonatomic, readonly) BOOL shouldBeAdded;
@property (nonatomic, readonly) BOOL shouldBeRemoved;

@end
