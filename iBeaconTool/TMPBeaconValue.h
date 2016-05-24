//
//  TMPBeaconValue.h
//  iBLocator
//
//  Created by Jérôme Olivier Diaz on 26/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class CLBeacon;
@interface TMPBeaconValue : NSObject {

}

- (id)initWithBeacon:(CLBeacon *)beacon;
- (id)initWithRssi:(NSInteger)rssi andAccuracy:(CLLocationAccuracy)accuracy andProximity:(Proximity)proximity;

@property (nonatomic, readonly) NSInteger rssi;
@property (nonatomic, readonly) CLLocationAccuracy accuracy;
@property (nonatomic, readonly) Proximity proximity;

@end
