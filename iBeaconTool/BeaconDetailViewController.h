//
//  BeaconDetailViewController.h
//  iBLocator
//
//  Created by Jérôme Olivier Diaz on 11/03/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Beacon;
@interface BeaconDetailViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate> {
    NSString *rssiFormat;
    NSString *accuracyFormat;
    NSString *proximityFormat;
    
    NSMutableArray *updateSelectorArray;
    NSMutableArray *updateObjectArray;
    
    BOOL hasPOI;
    
    __block BOOL detailsDisplayed;
}

@property (nonatomic, strong) Beacon *beacon;
@property (nonatomic, weak) IBOutlet UILabel *beaconNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *groupNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *groupUuidLabel;
@property (nonatomic, weak) IBOutlet UILabel *majorLabel;
@property (nonatomic, weak) IBOutlet UILabel *minorLabel;

@property (nonatomic, weak) IBOutlet UILabel *rssiLabel;
@property (nonatomic, weak) IBOutlet UILabel *accuracyLabel;
@property (nonatomic, weak) IBOutlet UILabel *proximityLabel;

@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) IBOutlet UIView *beaconIdView;
@property (nonatomic, weak) IBOutlet UIView *beaconDataView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)changeBeacon:(Beacon *)beacon;
- (IBAction)pageControlValueChanged:(UIPageControl *)sender;

- (IBAction)resizableViewTapped:(UIGestureRecognizer *)sender;

@end
