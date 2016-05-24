//
//  EditBeaconViewController.m
//  iBLocator
//
//  Created by Eurelis on 17/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "EditBeaconViewController.h"
#import "MajorMinor.h"
#import "MajorMinorPickerManager.h"
#import "Beacon.h"
#import "Major.h"
#import "Group.h"
#import "AppDelegate.h"
#import "ConfigBeaconsTableViewController.h"
#import "GroupListManager.h"

static CGFloat majorMinorButtonSelectedBorderWidth = 1.0f;
static CGFloat majorMinorButtonUnselectedBorderWidth = 0.0f;

@interface EditBeaconViewController ()

@end

@implementation EditBeaconViewController


- (void)setBeacon:(Beacon *)beacon {
    if (beacon) {
        self.group = beacon.major.group;
    }
    _beacon = beacon;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.beacon) {
        
        NSString *majorHexa = self.beacon.major.major;
        NSString *minorHexa = self.beacon.minor;
        
        self.nameTextField.text = self.beacon.name;
        [self.majorButton setTitle:majorHexa forState:UIControlStateNormal];
        [self.minorButton setTitle:minorHexa forState:UIControlStateNormal];
        
        
        NSInteger power = [self.beacon.txPower integerValue];
        
        self.slider.value = -1 * power;
        
#if __LP64__
        self.powerDBLabel.text = [NSString stringWithFormat:@"%lddB", power];
#else
        self.powerDBLabel.text = [NSString stringWithFormat:@"%ddB", power];
#endif
        
        
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", @"CANCEL") style:UIBarButtonItemStylePlain target:self action:@selector(actionBack:)];
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionDone:)];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    
    editingMode = EDITING_NONE;
    
    
    UIColor *color = [self.majorButton tintColor];
    CALayer *majorLayer = self.majorButton.layer;
    CALayer *minorLayer = self.minorButton.layer;
    
    majorLayer.borderColor = [color CGColor];
    minorLayer.borderColor = [color CGColor];
    
    majorLayer.borderWidth = majorMinorButtonUnselectedBorderWidth;
    minorLayer.borderWidth = majorMinorButtonUnselectedBorderWidth;
    
    majorLayer.cornerRadius = 4.0f;
    minorLayer.cornerRadius = 4.0f;
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    backgroundImage.frame = self.view.frame;
    [self.view insertSubview:backgroundImage atIndex:0];
    
    //self.view.backgroundView = backgroundImage;

    
}


#pragma mark - Actions

- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionDone:(id)sender {
    [self backgroundTapped:nil];
    
    BOOL success = YES;
    BOOL nameError = NO;
    BOOL unicityError = NO;
    
    
    NSString *minorString = [self.minorButton titleForState:UIControlStateNormal];
    NSString *majorString = [self.majorButton titleForState:UIControlStateNormal];
    
    NSScanner *minorScanner = [NSScanner scannerWithString:minorString];
    NSScanner *majorScanner = [NSScanner scannerWithString:majorString];
    unsigned int minorUI, majorUI;
    
    [minorScanner scanHexInt:&minorUI];
    [majorScanner scanHexInt:&majorUI];
    
    NSString *name = self.nameTextField.text;
    
    if ([name length] == 0) {
        success = NO;
        nameError = YES;
    }
    
    uint16_t minor = (uint16_t)minorUI;
    uint16_t major = (uint16_t)majorUI;
    
    
    short txPower = (short) (-1 * self.slider.value);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
   
    BOOL shouldTest = YES;
        
    if (self.beacon) {
        if ([self.beacon.minor isEqualToString:minorString] && [self.beacon.major.major isEqualToString:majorString]) {
                // major et minor n'ont pas changés
            shouldTest = NO;
        }
    }
    
    if (shouldTest) {
        Beacon *tBeacon = [appDelegate beaconForGroup:self.group major:major minor:minor createIfNotFound:NO];
        if (tBeacon) {
            success = NO;
            unicityError = YES;
        }
    }
    
    
    if (success) {
        Major *newMajor = [appDelegate majorForGroup:self.group major:major createIfNotFound:YES];
        
        if (!self.beacon) {
            _beacon = [NSEntityDescription insertNewObjectForEntityForName:@"Beacon" inManagedObjectContext:appDelegate.managedObjectContext];
            _beacon.major = newMajor;
        }
        
        else {
            if (![_beacon.major isEqual:newMajor]) {
                // si ce cas, ignorer le controllerDidChangeContent
                NSArray *viewControllers = self.navigationController.viewControllers;
                
                ConfigBeaconsTableViewController *parentController = [viewControllers objectAtIndex:([viewControllers count] - 2)];
                parentController.groupListManager.subManagerIgnoreNextChange = YES;
                parentController.groupListManager.ignoreNextChange = YES;
                parentController.groupListManager.majorChangeAsc = (([UIApplication convertMajorMinorString:newMajor.major] - [UIApplication convertMajorMinorString:_beacon.major.major]) < 0) ;
                
                
                
                Major *oldMajor = _beacon.major;
                _beacon.major = newMajor;
                
                [appDelegate.managedObjectContext refreshObject:oldMajor mergeChanges:YES];
                [appDelegate saveContext];
            }
        }
        
        [appDelegate.managedObjectContext refreshObject:newMajor mergeChanges:YES];
        
        _beacon.minor = [UIApplication convertMajorMinorToString:minor];
        _beacon.txPower = [NSNumber numberWithShort:txPower];
        _beacon.name = name;
        
        [self actionBack:sender];
        
        
        
    }
    else {
        
        NSString *errorString = nil;
        
        if (nameError && !unicityError) {
            errorString = NSLocalizedString(@"NAME_ERROR", @"NAME_ERROR");
        }
        else if (nameError && unicityError) {
            errorString = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"NAME_ERROR", @"NAME_ERROR"), NSLocalizedString(@"UNICITY_ERROR", @"UNICITY_ERROR")];
        }
        else if (!nameError && unicityError) {
            errorString = NSLocalizedString(@"UNICITY_ERROR", @"UNICITY_ERROR");
        }
        
        self.errorLabel.text = errorString;
        
    }
    
}



- (IBAction)powerSliderValueChanged:(UISlider *)sender {
    NSInteger intDbValue = - sender.value;
    
#if __LP64__
    self.powerDBLabel.text = [NSString stringWithFormat:@"%lddB", intDbValue, nil];
#else
    self.powerDBLabel.text = [NSString stringWithFormat:@"%ddB", intDbValue, nil];
#endif
    
}

- (IBAction)majorOrMinorButtonPushed:(UIButton *)sender {
    [self.nameTextField endEditing:YES];
    
    if (editingMode == EDITING_NONE) {
        
        if (sender == self.minorButton) {
            editingMode = EDITING_MINOR;
        }
        else if (sender == self.majorButton) {
            editingMode = EDITING_MAJOR;
        }
        
        NSString *majorOrMinorString = [sender titleForState:UIControlStateNormal];
        
        pickerManager = [[MajorMinorPickerManager alloc] initWithString:majorOrMinorString];
        
        self.powerView.hidden = YES;
        self.slider.enabled = NO;
        
        self.pickerView.hidden = NO;
        self.pickerView.delegate = self;
        self.pickerView.dataSource = pickerManager;
        
        [pickerManager initPicker:self.pickerView];
        
        sender.layer.borderWidth = majorMinorButtonSelectedBorderWidth;
        self.errorLabel.text = @"";
        
    }
    
    else {
        if (sender == self.minorButton && editingMode == EDITING_MINOR) {
            editingMode = EDITING_NONE;
        }
        else if (sender == self.majorButton && editingMode == EDITING_MAJOR) {
            editingMode = EDITING_NONE;
        }
        
        else {
            sender.layer.borderWidth = majorMinorButtonSelectedBorderWidth;
            if (sender == self.minorButton) {
                editingMode = EDITING_MINOR;
                self.majorButton.layer.borderWidth = majorMinorButtonUnselectedBorderWidth;
                
            }
            else if (sender == self.majorButton) {
                editingMode = EDITING_MAJOR;
                self.minorButton.layer.borderWidth = majorMinorButtonUnselectedBorderWidth;
            }
            
            NSString *majorOrMinorString = [sender titleForState:UIControlStateNormal];
            
            pickerManager = [[MajorMinorPickerManager alloc] initWithString:majorOrMinorString];
            
            self.pickerView.hidden = NO;
            self.pickerView.delegate = self;
            self.pickerView.dataSource = pickerManager;
            
            [pickerManager initPicker:self.pickerView];
            
            self.powerView.hidden = YES;
            self.slider.enabled = NO;
            self.errorLabel.text = @"";
        }
        
        
        if (editingMode == EDITING_NONE) {
            sender.layer.borderWidth = majorMinorButtonUnselectedBorderWidth;
            self.powerView.hidden = NO;
            self.slider.enabled = YES;
            pickerManager = nil;
            self.pickerView.hidden = YES;
            self.pickerView.delegate = nil;
            self.pickerView.dataSource = nil;
            pickerManager = nil;
        }
        
    }
    
}

- (IBAction)backgroundTapped:(UIGestureRecognizer *)sender {
    
    if (!self.pickerView.hidden) {
        CGPoint point = (CGPoint){0, -1};
        if (sender) {
            point = [sender locationInView:self.pickerView];
        }
        if (point.y < 0) {
            self.pickerView.dataSource = nil;
            self.pickerView.delegate = nil;
            self.pickerView.hidden = YES;
            editingMode = EDITING_NONE;
            
            self.powerView.hidden = NO;
            self.slider.enabled = YES;
            
            self.majorButton.layer.borderWidth = majorMinorButtonUnselectedBorderWidth;
            self.minorButton.layer.borderWidth = majorMinorButtonUnselectedBorderWidth;
            pickerManager = nil;
        }
    }
    
    [self.nameTextField endEditing:YES];
    
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [pickerManager pickerView:pickerView titleForRow:row forComponent:component];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *value = [pickerManager pickerView:pickerView titleForRow:row forComponent:component];
    
    UIButton *button = nil;
    switch (editingMode) {
        case EDITING_MINOR:
            button = self.minorButton;
            break;
        case EDITING_MAJOR:
            button = self.majorButton;
            break;
        case EDITING_NONE:
            break;
    }
    
    
    NSString *buttonValue = [button titleForState:UIControlStateNormal];
    
    NSString *newValue = [buttonValue stringByReplacingCharactersInRange:NSMakeRange(component, 1) withString:value];
    
    [button setTitle:newValue forState:UIControlStateNormal];
    
    if ([pickerManager respondsToSelector:_cmd]) {
        [pickerManager pickerView:pickerView didSelectRow:row inComponent:component];
    }
    
}




#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.errorLabel.text = @"";
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
