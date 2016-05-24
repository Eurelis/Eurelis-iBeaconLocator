//
//  MajorMinor.m
//  iBLocator
//
//  Created by Eurelis on 18/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "MajorMinor.h"

@implementation MajorMinor

@synthesize firstChar = firstChar;
@synthesize secondChar = secondChar;
@synthesize thirdChar = thirdChar;
@synthesize fourthChar = fourthChar;

- (id)initWithUnsignedShort:(uint16_t)value {
    return [self initWithString:[NSString stringWithFormat:@"%04x", value]];
}

- (id)initWithString:(NSString *)string {
    self = [super init];
    
    if (self) {
        firstChar = [string substringWithRange:(NSRange){0,1}];
        secondChar = [string substringWithRange:(NSRange){1,1}];
        thirdChar = [string substringWithRange:(NSRange){2,1}];
        fourthChar = [string substringWithRange:(NSRange){3,1}];
    }
 
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] initWithString:self.hexaString];
    
    return copy;
}

- (NSString *)hexaString {
    return [NSString stringWithFormat:@"%@%@%@%@", firstChar, secondChar, thirdChar, fourthChar, nil];
}

- (NSString *)charAtPosition:(NSUInteger)position {
    NSString *hexaChar = nil;
    
    switch (position) {
        case 0:
            hexaChar = firstChar;
            break;
        case 1:
            hexaChar = secondChar;
            break;
        case 2:
            hexaChar = thirdChar;
            break;
        case 3:
            hexaChar = fourthChar;
            break;
    }
    
    return hexaChar;
}

- (NSInteger)onlyDifferentCharPosition:(MajorMinor *)compare {
    
    NSInteger position = -1;
    NSUInteger differentCharCount = 0;
    
    if (![firstChar isEqualToString:compare->firstChar]) {
        position = 0;
        differentCharCount++;
    }
    
    if (![secondChar isEqualToString:compare->secondChar]) {
        position = 1;
        differentCharCount++;
    }
    
    if (![thirdChar isEqualToString:compare->thirdChar]) {
        position = 2;
        differentCharCount++;
    }
    
    if (![fourthChar isEqualToString:compare->fourthChar]) {
        position = 3;
        differentCharCount++;
    }
    
    if (differentCharCount != 1) {
        position = -1;
    }
    
    return position;
}

@end
