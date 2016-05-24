//
//  MajorMinorPickerManager.h
//  iBLocator
//
//  Created by Eurelis on 18/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MajorMinor;
@interface MajorMinorPickerManager : NSObject <UIPickerViewDataSource, UIPickerViewDelegate> {
    MajorMinor *currentMajorMinor;
    
    NSArray *fullArray;
    
    NSArray *wheel0;
    NSArray *wheel1;
    NSArray *wheel2;
    NSArray *wheel3;
    
    NSMutableArray *excludeList;
    
}

- (id)init;
- (id)initWithUnsignedShort:(uint16_t)value;
- (id)initWithMajorMinor:(MajorMinor *)value;
- (id)initWithString:(NSString *)value;
- (void)initWheelAtIndex:(NSUInteger)index;
- (NSArray *)arrayForComponent:(NSInteger)component;

- (void)initPicker:(UIPickerView *)picker;

@property (nonatomic) MajorMinor *majorMinor;

@end
