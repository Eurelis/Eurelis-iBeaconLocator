//
//  EditGroupViewController.m
//  iBLocator
//
//  Created by Eurelis on 13/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "EditGroupViewController.h"
#import "AppDelegate.h"

@interface EditGroupViewController ()

@end

@implementation EditGroupViewController

- (void)awakeFromNib {
    emptyUUID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", @"CANCEL") style:UIBarButtonItemStylePlain target:self action:@selector(actionBack:)];
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionDone:)];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    backgroundImage.frame = self.view.frame;
    [self.view insertSubview:backgroundImage atIndex:0];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.group) {
        [self setUUIDValue:self.group.uuid];
        
    }
    else {
        if (![self checkUUIDInPasteboard]) {
            // si on n'a pas trouvé d'UUID
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUUIDInPasteboard) name:UIApplicationDidBecomeActiveNotification object:nil];
        }
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    if (uuidAlertView) {
        [uuidAlertView dismissWithClickedButtonIndex:uuidAlertView.cancelButtonIndex animated:NO];
        uuidAlertView = nil;
    }
    
}

- (BOOL)checkUUIDInPasteboard {
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    NSString *pasteBoardString = pasteBoard.string;
    NSString *workString = [pasteBoardString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUUID *testUUID = [[NSUUID alloc] initWithUUIDString:workString];
    
    if (testUUID && ![testUUID isEqual:emptyUUID]) {
        uuidAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UUID_DETECTED", @"UUID_DETECTED") message:NSLocalizedString(@"UUID_IN_PASTEBOARD", @"UUID_IN_PASTEBOARD") delegate:self cancelButtonTitle:NSLocalizedString(@"NO", @"NO") otherButtonTitles:NSLocalizedString(@"YES", @"YES"), nil];
        
        [uuidAlertView show];
        return YES;
    }
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        NSString *workString = [pasteBoard.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSUUID *testUUID = [[NSUUID alloc] initWithUUIDString:workString];
        if (testUUID && ![testUUID isEqual:emptyUUID]) {
            [self setUUIDValue:[[testUUID UUIDString] uppercaseString]];
        }
    }
    
    
    uuidAlertView = nil;
}

- (void)setUUIDValue:(NSString *)uuidString {
    NSString *part1 = [uuidString substringWithRange:(NSRange){0, 8}];
    NSString *part2 = [uuidString substringWithRange:(NSRange){9, 4}];
    NSString *part3 = [uuidString substringWithRange:(NSRange){14, 4}];
    NSString *part4 = [uuidString substringWithRange:(NSRange){19, 4}];
    NSString *part5 = [uuidString substringWithRange:(NSRange){24, 12}];
    
    [self.uuidSegment setTitle:part1 forSegmentAtIndex:0];
    [self.uuidSegment setTitle:part2 forSegmentAtIndex:1];
    [self.uuidSegment setTitle:part3 forSegmentAtIndex:2];
    [self.uuidSegment setTitle:part4 forSegmentAtIndex:3];
    [self.uuidSegment setTitle:part5 forSegmentAtIndex:4];
    
    self.uuidSegment.selectedSegmentIndex = 0;
    [self uuidSegmentAction:self.uuidSegment];
    
    self.nameTextField.text = self.group.name;
}



- (IBAction)uuidSegmentAction:(UISegmentedControl *)sender {
    NSUInteger selectedSegment = sender.selectedSegmentIndex;
    NSString *selectedSegmentString = [sender titleForSegmentAtIndex:selectedSegment];
    
    NSUInteger charactersCount = [selectedSegmentString length];
    [_partialUuidSegment removeAllSegments];
    
    for (NSUInteger i = 0; i < charactersCount; i++) {
        [self.partialUuidSegment insertSegmentWithTitle:[selectedSegmentString substringWithRange:NSMakeRange(i, 1)] atIndex:i animated:NO];
    }
    
    self.partialUuidSegment.selectedSegmentIndex = 0;
}

- (IBAction)partialUuidSegment:(UISegmentedControl *)sender {
    
}

- (IBAction)uuidKeyboardButtonPushed:(UIButton *)sender {
    NSString *buttonTitle = [sender titleForState:UIControlStateNormal];
    
    NSInteger selectedPartialSegmentIndex = self.partialUuidSegment.selectedSegmentIndex;
    NSInteger selectedPartialSegmentCount = self.partialUuidSegment.numberOfSegments;
    NSInteger uuidSegmentIndex = self.uuidSegment.selectedSegmentIndex;
    NSMutableString *uuidSegmentString = [NSMutableString stringWithString:[self.uuidSegment titleForSegmentAtIndex:uuidSegmentIndex]];
    [uuidSegmentString replaceCharactersInRange:NSMakeRange(selectedPartialSegmentIndex, 1) withString:buttonTitle];
    
    [self.uuidSegment setTitle:uuidSegmentString forSegmentAtIndex:uuidSegmentIndex];
    
    
    [self.partialUuidSegment setTitle:buttonTitle forSegmentAtIndex:selectedPartialSegmentIndex];
    
    selectedPartialSegmentIndex++;
    if (selectedPartialSegmentIndex < selectedPartialSegmentCount) {
        self.partialUuidSegment.selectedSegmentIndex = selectedPartialSegmentIndex;
    }
    
    else if (selectedPartialSegmentIndex == selectedPartialSegmentCount) {
        NSInteger uuidSegmentCount = self.uuidSegment.numberOfSegments;
        
        uuidSegmentIndex++;
        if (uuidSegmentIndex < uuidSegmentCount) {
            self.uuidSegment.selectedSegmentIndex = uuidSegmentIndex;
            self.partialUuidSegment.selectedSegmentIndex = 0;
            [self uuidSegmentAction:self.uuidSegment];
        }
        
    }
}


- (IBAction)backgroundTapped:(id)sender {
    [self.nameTextField endEditing:YES];
}


- (IBAction)actionDone:(id)sender {
    [self.nameTextField endEditing:YES];
    
    NSString *uuid = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",
                        [self.uuidSegment titleForSegmentAtIndex:0],
                        [self.uuidSegment titleForSegmentAtIndex:1],
                        [self.uuidSegment titleForSegmentAtIndex:2],
                        [self.uuidSegment titleForSegmentAtIndex:3],
                        [self.uuidSegment titleForSegmentAtIndex:4],
                        nil
                      ];
    
    NSString *name = self.nameTextField.text;
    BOOL nameError = NO;
    BOOL unicityError = NO;
    BOOL success = YES;
    
    
    if ([name length] == 0) {
        success = NO;
        nameError = YES;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL shouldTestUnicity = YES;
    if (self.group) {
        if ([self.group.uuid isEqualToString:uuid]) {
            shouldTestUnicity = NO;
        }
    }
    
    
    if (shouldTestUnicity && [appDelegate groupWithUUID:uuid]) {
        unicityError = YES;
        success = NO;
    }
    
    if (success) {
        if (!self.group) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
            self.group = [[Group alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        }
        
        self.group.name = name;
        self.group.uuid = uuid;
        
        [self actionBack:sender];
    }
    else {
        
        if (nameError && !unicityError) {
            self.errorLabel.text = NSLocalizedString(@"EMPTY_NAME_ERROR", @"EMPTY_NAME_ERROR");
            
        }
        else if (nameError && unicityError) {
            self.errorLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"EMPTY_NAME_ERROR", @"EMPTY_NAME_ERROR"), NSLocalizedString(@"UUID_UNICITY_ERROR", @"UUID_UNICITY_ERROR")];
        }
        else if (!nameError && unicityError) {
            self.errorLabel.text = NSLocalizedString(@"UUID_UNICITY_ERROR", @"UUID_UNICITY_ERROR");
        }
        
        
    }
    
}


- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}



@end
