//
//  PoiFetcher.h
//  iBLocator
//
//  Created by Eurelis on 17/03/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoiFetcher : NSOperation {
    NSURL *poiFetchURL;
    NSMutableData *fetchedData;
    NSMutableDictionary *beaconToPoiSetDictionary;
    
    BOOL m_finished;
    BOOL m_executing;
    
    NSURLConnection *urlConnection;
    NSURLRequest *request;
    
    NSArray *_beacons;
}

- (id)initWithUUID:(NSString *)uuid;
- (id)initWithUUID:(NSString *)uuid major:(NSString *)majorHex;
- (id)initWithUUID:(NSString *)uuid major:(NSString *)majorHex minor:(NSString *)minorHex;

- (void)initURLConnection;
- (void)myMain;



@end
