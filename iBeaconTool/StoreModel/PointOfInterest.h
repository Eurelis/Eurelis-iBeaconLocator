//
//  PointOfInterest.h
//  iBLocator
//
//  Created by Jérôme Olivier Diaz on 17/03/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Beacon;

@interface PointOfInterest : NSManagedObject

@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * nid;
@property (nonatomic, retain) NSNumber * changed;
@property (nonatomic, retain) NSNumber * image_changed;
@property (nonatomic, retain) NSNumber * current_image_changed;
@property (nonatomic, retain) Beacon *beacon;

@end
