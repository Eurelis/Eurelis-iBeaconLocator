//
//  PoiFetcher.m
//  iBLocator
//
//  Created by Eurelis on 17/03/2014.
//  Copyright (c) 2014 Eurelis. All rights reserved.
//

#import "PoiFetcher.h"

static NSString *getURLPrefix = @"http://ibeacon.eurelis.info/";

@implementation PoiFetcher

- (id)initWithUUID:(NSString *)uuid {
    return [self initWithUUID:uuid major:nil minor:nil];
}

- (id)initWithUUID:(NSString *)uuid major:(NSString *)majorHex {
    return [self initWithUUID:uuid major:majorHex minor:nil];
}

- (id)initWithUUID:(NSString *)uuid major:(NSString *)majorHex minor:(NSString *)minorHex {
    if ((self = [super init])) {
        
        AppDelegate *appDelegate = [UIApplication delegate];
        
        _beacons = [[NSMutableArray alloc] init];
        
        NSURL *workURL = [NSURL URLWithString:getURLPrefix];
        NSLocale *currentLocale = [NSLocale currentLocale];
        
        NSString *countryCode = [currentLocale objectForKey:NSLocaleLanguageCode];
        
        workURL = [[workURL URLByAppendingPathComponent:countryCode] URLByAppendingPathComponent:@"query"];
        
        if (uuid) {
            workURL = [workURL URLByAppendingPathComponent:uuid];
            
            if (majorHex) {
                workURL = [workURL URLByAppendingPathComponent:majorHex];
                
                if (minorHex) {
                    workURL = [workURL URLByAppendingPathComponent:minorHex];
                    
                }
                
            }
            
            _beacons = [appDelegate beaconsForUUID:uuid major:majorHex minor:minorHex];
            
            
        }
        
        poiFetchURL = workURL;
        
    }
    
    return self;
}


#pragma mark - 
- (void)initURLConnection {
    fetchedData = [[NSMutableData alloc] init];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:poiFetchURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0f];
 
    urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
    
}

- (void)myMain {
    @autoreleasepool {
        [self performSelectorOnMainThread:@selector(initURLConnection) withObject:nil waitUntilDone:NO];
    }
}


#pragma mark - NSOperation related

- (void)start {
    [self willChangeValueForKey:@"isExecuting"];
    m_executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self myMain];
}

- (BOOL)isExecuting {
    return m_executing;
}

- (BOOL)isFinished {
    return m_finished;
}

- (BOOL)isConcurrent {
    return YES;
}




#pragma mark - URL Connection delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    @synchronized(connection) {
        [fetchedData appendData:data];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self completeOperation];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSString *string = [NSString stringWithUTF8String:[m_bufferData bytes]];
    ////NSLog(@"%@", string);
    NSError *error = nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:fetchedData options:0 error:&error];
    if (array) {
        [[UIApplication delegate] jsonPoiReceived:array forBeacons:_beacons];
    }
    else {
        TRACE
        //NSLog(@"%@", error);
    }
    
   
    urlConnection = nil;
    fetchedData = nil;
    [self completeOperation];
}


#pragma mark -

- (void)completeOperation {
    [self performSelectorOnMainThread:@selector(willChangeValueForKey:) withObject:@"isFinished" waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(willChangeValueForKey:) withObject:@"isExecuting" waitUntilDone:NO];
    
    m_finished = YES;
    m_executing = NO;
    
    [self performSelectorOnMainThread:@selector(didChangeValueForKey:) withObject:@"isExecuting" waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(didChangeValueForKey:) withObject:@"isFinished" waitUntilDone:NO];
}


@end
