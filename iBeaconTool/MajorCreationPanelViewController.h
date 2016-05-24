//
//  MajorCreationPanelViewController.h
//  iBLocator
//
//  Created by Eurelis on 10/03/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MajorMinorPickerManager;
@class Group;
@interface MajorCreationPanelViewController : UIViewController <UIPickerViewDelegate> {
    MajorMinorPickerManager *pickerManager;
    NSString *majorValue;
}

@property (nonatomic, weak) Group *group;

@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

- (IBAction)doneButtonPushed:(id)sender;
- (IBAction)backgroundTapped:(UIGestureRecognizer *)sender;


@end
