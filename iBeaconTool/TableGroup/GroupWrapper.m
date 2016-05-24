//
//  GroupWrapper.m
//  iBLocator
//
//  Created by Eurelis on 21/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "GroupWrapper.h"

@implementation GroupWrapper

@synthesize group = group;

- (id)initWithGroup:(Group *)aGroup {
    self = [super init];
    
    if (self) {
        group = aGroup;
        majorWrapperArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addMajorWrapper:(MajorWrapper *)majorWrapper {
    [majorWrapperArray addObject:majorWrapper];
}



@end
