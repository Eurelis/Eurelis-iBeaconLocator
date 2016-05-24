//
//  BeaconWrapper.h
//  iBLocator
//
//  Created by Eurelis on 21/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Beacon;
@interface BeaconWrapper : NSObject {
    Beacon *beacon;
}

@property (nonatomic, readonly) Beacon *beacon;

- (id)initWithBeacon:(Beacon *)beacon;

@end
