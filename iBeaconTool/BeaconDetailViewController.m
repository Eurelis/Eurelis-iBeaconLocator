//
//  BeaconDetailViewController.m
//  iBLocator
//
//  Created by Jérôme Olivier Diaz on 11/03/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "BeaconDetailViewController.h"
#import "PoiFetcher.h"
#import "PointOfInterestCollectionCell.h"
#import "EmptyCollectionViewCell.h"

static CGRect deployedBeaconIdViewFrame;
static CGRect notDeployedBeaconIdViewFrame;
static CGRect deployedBeaconDataViewFrame;
static CGRect notDeployedBeaconDataViewFrame;


@interface BeaconDetailViewController ()

@end

@implementation BeaconDetailViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    hasPOI = (self.beacon.pois.count > 0);
    
    Major *major = self.beacon.major;
    Group *group = major.group;
    
    self.beaconNameLabel.text = self.beacon.name;
    self.groupNameLabel.text = group.name;
    self.groupUuidLabel.text = group.uuid;
    self.majorLabel.text = major.major;
    self.minorLabel.text = self.beacon.minor;
    
    rssiFormat = NSLocalizedString(@"RSSI_FORMAT_LABEL", @"");
    accuracyFormat = NSLocalizedString(@"ACCURACY_FORMAT_LABEL", @"");
    proximityFormat = NSLocalizedString(@"PROXIMITY_FORMAT_LABEL", @"");
    
    [self.beacon addObserver:self forKeyPath:@"accuracy" options:NSKeyValueObservingOptionNew context:NULL];
    [self retrievePois];
    [self configureLabels];
    
    _pageControl.numberOfPages = _beacon.pois.count;
    _pageControl.hidden = (_pageControl.numberOfPages == 0);
    
    
    detailsDisplayed = NO;
    
    self.groupUuidLabel.hidden = YES;
    self.majorLabel.hidden = YES;
    self.minorLabel.hidden = YES;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.beaconIdView.frame = notDeployedBeaconIdViewFrame;
        self.beaconDataView.frame = notDeployedBeaconDataViewFrame;
        
    } completion:^(BOOL finished) {
        self.beaconIdView.frame = notDeployedBeaconIdViewFrame;
        self.beaconDataView.frame = notDeployedBeaconDataViewFrame;

        self.groupNameLabel.text = NSLocalizedString(@"TAP_DISPLAY_MORE_INFOS", @"");
        detailsDisplayed = NO;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //self.beaconIdView.frame = notDeployedBeaconIdViewFrame;
    //self.beaconDataView.frame = notDeployedBeaconDataViewFrame;
    
    self.groupUuidLabel.hidden = YES;
    self.majorLabel.hidden = YES;
    self.minorLabel.hidden = YES;
    self.beaconDataView.hidden = YES;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.beaconIdView.frame = notDeployedBeaconIdViewFrame;
        self.beaconDataView.frame = notDeployedBeaconDataViewFrame;
        
    } completion:^(BOOL finished) {
        self.beaconIdView.frame = notDeployedBeaconIdViewFrame;
        self.beaconDataView.frame = notDeployedBeaconDataViewFrame;
        
        self.groupNameLabel.text = NSLocalizedString(@"TAP_DISPLAY_MORE_INFOS", @"");
        detailsDisplayed = NO;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.beacon removeObserver:self forKeyPath:@"accuracy"];
}

#pragma mark - 
- (void)changeBeacon:(Beacon *)beacon {
    if (_beacon) {
        // il existait une beacon
        [_beacon removeObserver:self forKeyPath:@"accuracy"];
    }
    
    self.beacon = beacon;
    
    if (beacon) {
        hasPOI = (self.beacon.pois.count > 0);
        [self retrievePois];
        [self.beacon addObserver:self forKeyPath:@"accuracy" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    _pageControl.numberOfPages = beacon.pois.count;
    _pageControl.hidden = (_pageControl.numberOfPages == 0);
    
    [self configureLabels];
    
}

- (void)retrievePois {
    Major *major= _beacon.major;
    Group *group = major.group;
    PoiFetcher *poiFetcher = [[PoiFetcher alloc] initWithUUID:group.uuid major:major.major minor:_beacon.minor];
    
    [[UIApplication delegate] queuePoiFetcher:poiFetcher];
}

#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self configureLabels];
    
}

#pragma mark -
- (void)configureLabels {
    
    self.rssiLabel.text = [NSString stringWithFormat:rssiFormat, (long)[self.beacon.rssi integerValue], nil];
    self.accuracyLabel.text = [NSString stringWithFormat:accuracyFormat, [self.beacon.accuracy doubleValue], nil];
    
    NSString *proximity = @" - ";
    NSInteger prox = [self.beacon.proximity integerValue];
    switch (prox) {
        case IMMEDIATE:
            proximity = NSLocalizedString(@"PROXIMITY_IMMEDIATE", @"");
            break;
        case NEAR:
            proximity = NSLocalizedString(@"PROXIMITY_NEAR", @"");
            break;
        case FAR:
            proximity = NSLocalizedString(@"PROXIMITY_FAR", @"");
            break;
        case UNKNOWN:
            proximity = NSLocalizedString(@"PROXIMITY_UNKNOWN", @"");
            break;
    }
    
    
    self.proximityLabel.text = [NSString stringWithFormat:proximityFormat, proximity];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    backgroundImage.frame = self.view.frame;
    [self.view insertSubview:backgroundImage atIndex:0];

    
    CGPoint beaconIdViewOrigine = self.beaconIdView.frame.origin;
    CGPoint beaconDataViewOrigine = self.beaconDataView.frame.origin;
    CGSize beaconDataViewSize = self.beaconDataView.frame.size;
    
    notDeployedBeaconIdViewFrame = (CGRect){beaconIdViewOrigine,{320, 52}};
    notDeployedBeaconDataViewFrame = (CGRect){{-beaconDataViewSize.width, beaconDataViewOrigine.y}, beaconDataViewSize};
    deployedBeaconIdViewFrame = (CGRect){beaconIdViewOrigine,{320, 130}};
    deployedBeaconDataViewFrame = (CGRect){{0, beaconDataViewOrigine.y}, beaconDataViewSize};
    
    
    self.beaconIdView.frame = notDeployedBeaconIdViewFrame;
    self.beaconDataView.frame = notDeployedBeaconDataViewFrame;

    
}


#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (!hasPOI) {
        return 1;
    }
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!hasPOI) {
        return 1;
    }
    return [[self.fetchedResultsController sections][section] numberOfObjects];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        if (![[self.fetchedResultsController sections][0] numberOfObjects]) {
             EmptyCollectionViewCell *collectionViewCell = (EmptyCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"EmptyCollectionCell" forIndexPath:indexPath];
            
            collectionViewCell.label.text = NSLocalizedString(@"NO_KNOWN_POI", @"");
            
            return collectionViewCell;
        }
        
    }
    
    UICollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    

    PointOfInterest *poi = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:(PointOfInterestCollectionCell *)collectionViewCell withPOI:poi];
    
    return collectionViewCell;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[PointOfInterestCollectionCell class]]) {
        PointOfInterestCollectionCell * poiCell = (PointOfInterestCollectionCell *)cell;
        
        PointOfInterest *poi = poiCell.poi;
        
        if (poi.link && ![poi.link isEqualToString:@""]) {
            NSURL *url = [NSURL URLWithString:poi.link];
            if (url) {
                [[UIApplication sharedApplication] openURL:url];
                
            }
            
        }
        
    }
    
    return YES;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    return _managedObjectContext;
}



- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"POI" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(beacon == %@)", _beacon];
    fetchRequest.predicate = predicate;
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *titleSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = @[titleSortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}


- (void)configureCell:(PointOfInterestCollectionCell *)cell withPOI:(PointOfInterest *)poi {
    cell.titleLabel.text = poi.title;
    cell.textLabel.text = poi.text;
    cell.poi = poi;
    
    if (poi.image) {
        UIImage *poiImage = [UIImage imageWithContentsOfFile:poi.image];
        cell.imageView.image = poiImage;
    }
    
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    //[self.tableView beginUpdates];
    
    updateSelectorArray = [[NSMutableArray alloc] init];
    updateObjectArray = [[NSMutableArray alloc] init];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    
    /*
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [updateSelectorArray addObject:@"insertSections:"];
            [updateObjectArray addObject:[NSIndexSet indexSetWithIndex:sectionIndex]];

            
            break;
            
        case NSFetchedResultsChangeDelete:
            //[self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            [updateSelectorArray addObject:@"deleteSections:"];
            [updateObjectArray addObject:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
    }
     */
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    //UICollectionView *collectionView = self.collectionView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
        {
            if (!hasPOI && newIndexPath.row == 0) {
                hasPOI = YES;
                [updateSelectorArray addObject:@"reloadItemsAtIndexPaths:"];
                [updateObjectArray addObject:@[newIndexPath]];
            }
            else {
                [updateSelectorArray addObject:@"insertItemsAtIndexPaths:"];
                [updateObjectArray addObject:@[newIndexPath]];
            }
        }
            break;
            
        case NSFetchedResultsChangeDelete:
            
            if ([[self.fetchedResultsController sections][0] numberOfObjects] == 0 && indexPath.row == 0 && indexPath.section == 0) {
                hasPOI = NO;
                [updateSelectorArray addObject:@"reloadItemsAtIndexPaths:"];
                [updateObjectArray addObject:@[indexPath]];
            }
            else {
                [updateSelectorArray addObject:@"deleteItemsAtIndexPaths:"];
                [updateObjectArray addObject:@[indexPath]];
            }
            
            break;
            
        case NSFetchedResultsChangeUpdate:
        {

            [updateSelectorArray addObject:@"reloadItemsAtIndexPaths:"];
            [updateObjectArray addObject:@[indexPath]];
        }
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    //[self.collectionView endUpdates];
    if (updateObjectArray && updateObjectArray.count) {
        [self.collectionView performBatchUpdates:^{
            [updateSelectorArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *selectorName = (NSString *)obj;
                id value = updateObjectArray[idx];
                
                ////NSLog(@"%@ %@", selectorName, value);
                [self.collectionView performSelectorOnMainThread:NSSelectorFromString(selectorName) withObject:value waitUntilDone:YES];
            }];
        } completion:^(BOOL finished) {
            if (finished) {
                
                self.pageControl.numberOfPages = [self collectionView:_collectionView numberOfItemsInSection:0];
                
                _pageControl.hidden = (_pageControl.numberOfPages == 0);
                
                CGPoint currentPoint = _collectionView.contentOffset;
                
                NSUInteger currentPage = ((currentPoint.x + (320 / 2)) / 320);
                
                if (currentPage != self.pageControl.currentPage) {
                    [self.pageControl setCurrentPage:currentPage];
                }
                
                updateSelectorArray = nil;
                updateObjectArray = nil;
            }
        }];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
    if (_scrollView == _collectionView) {
        CGPoint currentPoint = _scrollView.contentOffset;
        
        NSUInteger currentPage = ((currentPoint.x + (320 / 2)) / 320);
        
        if (currentPage != self.pageControl.currentPage) {
            [self.pageControl setCurrentPage:currentPage];
        }
        
        //[self setInstrument:currentPage withScroll:NO];
    }
}


- (IBAction)pageControlValueChanged:(UIPageControl *)sender {
    NSInteger currentPage = sender.currentPage;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentPage inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally) animated:YES];
}


- (IBAction)resizableViewTapped:(UIGestureRecognizer *)sender {
    
    if (detailsDisplayed) {
        self.groupUuidLabel.hidden = YES;
        self.majorLabel.hidden = YES;
        self.minorLabel.hidden = YES;
        
        [UIView animateWithDuration:0.4 animations:^{
            
            self.beaconIdView.frame = notDeployedBeaconIdViewFrame;
            self.beaconDataView.frame = notDeployedBeaconDataViewFrame;
            
        } completion:^(BOOL finished) {
            self.groupNameLabel.text = NSLocalizedString(@"TAP_DISPLAY_MORE_INFOS", @"");
            detailsDisplayed = NO;
            self.beaconDataView.hidden = YES;

        }];
    }
    else {
        self.beaconDataView.hidden = NO;
        
        [UIView animateWithDuration:0.4 animations:^{
            self.beaconIdView.frame = deployedBeaconIdViewFrame;
            self.beaconDataView.frame = deployedBeaconDataViewFrame;
        } completion:^(BOOL finished) {
            
            self.groupUuidLabel.hidden = NO;
            self.majorLabel.hidden = NO;
            self.minorLabel.hidden = NO;
            self.groupNameLabel.text = _beacon.major.group.name;
            
            detailsDisplayed = YES;

        }];
    }
    
}
@end
