//
//  MajorWrapper.h
//  iBLocator
//
//  Created by Eurelis on 21/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Major;
@class BeaconWrapper;
@interface MajorWrapper : NSObject {
    Major *major;
    NSMutableArray *beaconWrapperArray;
}

@property (nonatomic, readonly) Major *major;

- (id)initWithMajor:(Major *)major;
- (void)addBeaconWrapper:(BeaconWrapper *)beaconWrapper;


@end
