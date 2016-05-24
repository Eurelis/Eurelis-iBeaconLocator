//
//  ListenTableViewController.h
//  iBLocator
//
//  Created by Eurelis on 20/02/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MODE_BEACONS,
    MODE_POIS
} LISTEN_MODE;

@interface ListenTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    UIColor *proximityImmediateColor;
    UIColor *proximityNearColor;
    UIColor *proximityFarColor;
    UIColor *proximityUnknownColor;
    
    LISTEN_MODE listenMode;
    
}

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender;


@end
