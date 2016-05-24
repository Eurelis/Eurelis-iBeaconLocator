//
//  GroupWrapper.h
//  iBLocator
//
//  Created by Eurelis on 21/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Group;
@class MajorWrapper;
@interface GroupWrapper : NSObject {
    Group *group;
    NSMutableArray *majorWrapperArray;
}

@property (nonatomic, readonly) Group *group;

- (id)initWithGroup:(Group *)group;
- (void)addMajorWrapper:(MajorWrapper *)majorWrapper;




@end
