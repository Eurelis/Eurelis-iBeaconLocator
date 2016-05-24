//
//  EditGroupViewController.h
//  iBLocator
//
//  Created by Eurelis on 13/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Beacon;
#import "StoreModel.h"

@interface EditGroupViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    NSUUID *emptyUUID;
    UIAlertView *uuidAlertView;
}

@property (nonatomic, strong) Beacon *beacon;
@property (nonatomic, weak) IBOutlet UISegmentedControl *uuidSegment;
@property (nonatomic, weak) IBOutlet UISegmentedControl *partialUuidSegment;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Group *group;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;

- (BOOL)checkUUIDInPasteboard;

- (void)setUUIDValue:(NSString *)uuid;

- (IBAction)uuidSegmentAction:(UISegmentedControl *)sender;
- (IBAction)partialUuidSegment:(UISegmentedControl *)sender;
- (IBAction)uuidKeyboardButtonPushed:(UIButton *)sender;


- (IBAction)actionDone:(id)sender;
- (IBAction)actionBack:(id)sender;

- (IBAction)backgroundTapped:(id)sender;


@end
