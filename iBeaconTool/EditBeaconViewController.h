//
//  EditBeaconViewController.h
//  iBLocator
//
//  Created by Eurelis on 17/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    EDITING_NONE,
    EDITING_MAJOR,
    EDITING_MINOR
} EDITING_MODE;

@class MajorMinorPickerManager;
@class Group;
@class Beacon;
@interface EditBeaconViewController : UIViewController <UIPickerViewDelegate> {
    EDITING_MODE editingMode;
    
    NSIndexPath *pickerViewIndexPath;
    MajorMinorPickerManager *pickerManager;
}


@property (nonatomic, strong) Group *group;
@property (nonatomic, strong) Beacon *beacon;

@property (nonatomic, weak) IBOutlet UILabel *powerDBLabel;
@property (nonatomic, weak) IBOutlet UIButton *minorButton;
@property (nonatomic, weak) IBOutlet UIButton *majorButton;

@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

@property (nonatomic, weak) IBOutlet UIView *powerView;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;

- (IBAction)powerSliderValueChanged:(UISlider *)sender;
- (IBAction)majorOrMinorButtonPushed:(UIButton *)sender;
- (IBAction)actionBack:(id)sender;
- (IBAction)actionDone:(id)sender;
- (IBAction)backgroundTapped:(UIGestureRecognizer *)sender;


@end
