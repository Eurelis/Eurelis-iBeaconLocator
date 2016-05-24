//
//  MajorCreationPanelViewController.m
//  iBLocator
//
//  Created by Eurelis on 10/03/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "MajorCreationPanelViewController.h"
#import "BackgroundNotificationTableViewController.h"
#import "MajorMinorPickerManager.h"
#import "StoreModel.h"

@interface MajorCreationPanelViewController ()

@end

@implementation MajorCreationPanelViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    majorValue = @"0000";
    [self configureLabel];
    
    pickerManager = [[MajorMinorPickerManager alloc] initWithString:majorValue];
    
    self.pickerView.hidden = NO;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = pickerManager;
    
    
    [pickerManager initPicker:self.pickerView];
    
}


- (IBAction)doneButtonPushed:(id)sender {
    uint16_t major = [UIApplication convertMajorMinorString:majorValue];
    Major *majorObject = [[UIApplication delegate] majorForGroup:_group major:major createIfNotFound:NO];
    if (majorObject) {
        self.label.text = NSLocalizedString(@"ERROR_MAJOR_ALREADY_EXISTS", @"");
        
    }
    else {
        majorObject = [[UIApplication delegate] majorForGroup:_group major:major createIfNotFound:YES];
        
        BackgroundNotificationTableViewController *bntvc = (BackgroundNotificationTableViewController *)self.parentViewController;
        
        [bntvc dismissMajorCreationViewController:majorObject];
        [self removeFromParentViewController];
        
        [[UIApplication delegate] saveContext];
    }
    
}

- (IBAction)backgroundTapped:(UIGestureRecognizer *)sender {
    CGPoint coordinates = [sender locationInView:self.pickerView];
    
    
    if (coordinates.y < 0) {
        // si en dehors de la zone de sélection
        BackgroundNotificationTableViewController *bntvc = (BackgroundNotificationTableViewController *)self.parentViewController;
        
        [bntvc dismissMajorCreationViewController:nil];
        [self removeFromParentViewController];

    }
    
}

#pragma mark - Picker View Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [pickerManager pickerView:pickerView titleForRow:row forComponent:component];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *value = [pickerManager pickerView:pickerView titleForRow:row forComponent:component];
    
    
    NSString *newValue = [majorValue stringByReplacingCharactersInRange:NSMakeRange(component, 1) withString:value];
    
    majorValue = newValue;
    [self configureLabel];
    
    if ([pickerManager respondsToSelector:_cmd]) {
        [pickerManager pickerView:pickerView didSelectRow:row inComponent:component];
    }
    
}

- (void)configureLabel {
    NSString *format = NSLocalizedString(@"CREATE_MAJOR_LABEL_FORMAT", @"");
    self.label.text = [NSString stringWithFormat:format, majorValue];
}


@end
