//
//  RootViewController.m
//  iBLocator
//
//  Created by Eurelis on 27/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    self.beaconCountLabel.layer.cornerRadius = 15;


    
    [self.listenButton setTitle:NSLocalizedString(@"LISTEN", @"") forState:UIControlStateNormal];
    [self.emitButton setTitle:NSLocalizedString(@"EMIT", @"") forState:UIControlStateNormal];
    [self.settingsButton setTitle:NSLocalizedString(@"SETTINGS", @"") forState:UIControlStateNormal];
    [self.contactButton setTitle:NSLocalizedString(@"CONTACT", @"") forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
#if __LP64__
    self.beaconCountLabel.text = [NSString stringWithFormat:@"%lu", appDelegate.workingBeaconCount];
#else
    self.beaconCountLabel.text = [NSString stringWithFormat:@"%d", appDelegate.workingBeaconCount];
#endif
    
    [appDelegate addObserver:self forKeyPath:@"workingBeaconCount" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate removeObserver:self forKeyPath:@"workingBeaconCount"];
}

- (void)dealloc {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate removeObserver:self forKeyPath:@"workingBeaconCount"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    AppDelegate *appDelegate = (AppDelegate *)object;
#if __LP64__
    self.beaconCountLabel.text = [NSString stringWithFormat:@"%lu", appDelegate.workingBeaconCount];
#else
    self.beaconCountLabel.text = [NSString stringWithFormat:@"%u", appDelegate.workingBeaconCount];
#endif
    
}


- (IBAction)contactButtonPushed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.eurelis.com/ibeacon"]];
}

@end
