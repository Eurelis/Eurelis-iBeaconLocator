//
//  MajorMinor.h
//  iBLocator
//
//  Created by Eurelis on 18/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MajorMinor : NSObject <NSCopying> {
    NSString *firstChar;
    NSString *secondChar;
    NSString *thirdChar;
    NSString *fourthChar;
    
}

@property (nonatomic, readonly) NSString *firstChar;
@property (nonatomic, readonly) NSString *secondChar;
@property (nonatomic, readonly) NSString *thirdChar;
@property (nonatomic, readonly) NSString *fourthChar;
@property (nonatomic, readonly) NSString *hexaString;

- (id)initWithUnsignedShort:(uint16_t)value;
- (id)initWithString:(NSString *)string;

- (NSString *)charAtPosition:(NSUInteger)position;
- (NSInteger)onlyDifferentCharPosition:(MajorMinor *)compare;


@end
