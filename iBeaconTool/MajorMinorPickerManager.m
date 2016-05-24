//
//  MajorMinorPickerManager.m
//  iBLocator
//
//  Created by Eurelis on 18/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "MajorMinorPickerManager.h"
#import "MajorMinor.h"

@implementation MajorMinorPickerManager


- (id)init {
    return [self initWithUnsignedShort:0];;
}

- (id)initWithUnsignedShort:(uint16_t)value {
    return [self initWithMajorMinor:[[MajorMinor alloc] initWithUnsignedShort:value]];
}

- (id)initWithString:(NSString *)value {
    return [self initWithMajorMinor:[[MajorMinor alloc] initWithString:value]];
}

- (id)initWithMajorMinor:(MajorMinor *)value {
    self = [super init];
    if (self) {
        currentMajorMinor = [value copy];
        fullArray = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"A", @"B", @"C", @"D", @"E", @"F"];
        excludeList = [[NSMutableArray alloc] init];
        
        wheel0 = [fullArray copy];
        wheel1 = [fullArray copy];
        wheel2 = [fullArray copy];
        wheel3 = [fullArray copy];
        
    }
    return self;
}

- (void)initPicker:(UIPickerView *)picker {
    [self initPicker:picker forComponent:0];
    [self initPicker:picker forComponent:1];
    [self initPicker:picker forComponent:2];
    [self initPicker:picker forComponent:3];
    
}

- (void)initPicker:(UIPickerView *)picker forComponent:(NSUInteger)component {
    NSArray *array = [self arrayForComponent:component];
    NSString *hexaChar = [currentMajorMinor charAtPosition:component];
    NSInteger pos = [array indexOfObject:hexaChar];
    
    [picker selectRow:pos inComponent:component animated:NO];
    
}

- (void)initWheelAtIndex:(NSUInteger)index {
    if (index < 4) {
        // pour créer une copie
        NSArray *array = [NSArray arrayWithArray:fullArray];
        
        switch (index) {
            case 0:
                wheel0 = array;
                break;
            case 1:
                wheel1 = array;
                break;
            case 2:
                wheel2 = array;
                break;
            case 3:
                wheel3 = array;
                break;
        }
    }
}



- (void)setMajorMinor:(MajorMinor *)majorMinor {
    currentMajorMinor = majorMinor;
}


- (NSArray *)arrayForComponent:(NSInteger)component {
    NSArray *array = nil;;
    
    switch (component) {
        case 0:
            array = wheel0;
            break;
        case 1:
            array = wheel1;
            break;
        case 2:
            array = wheel2;
            break;
        case 3:
            array = wheel3;
            break;
    }

    return array;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self arrayForComponent:component] count];
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[self arrayForComponent:component] objectAtIndex:row];
}

@end
