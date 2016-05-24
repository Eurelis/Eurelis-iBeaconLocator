//
//  PictureDownloaderOperation.m
//  Soho
//
//  Created by Jérôme Diaz on 28/07/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PictureDownloaderOperation.h"
#import "AppDelegate.h"


@implementation PictureDownloaderOperation

#pragma mark -
#pragma mark Life cycle

- (id)initWithPOI:(PointOfInterest *)aPoi {
    if ((self = [super init])) {
        m_isExecuting = NO;
        m_isFinished = NO;
        poi = aPoi;
        pictureRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:poi.imageURL]];
        picturePath = [[UIApplication delegate] imagePathForPoi:poi];

    }
    return self;
}





#pragma mark -
#pragma mark URL resolution methods

- (void)initURLConnection {    
    m_urlConnection = [[NSURLConnection alloc] initWithRequest:pictureRequest delegate:self startImmediately:YES];
}

- (void)start {
    if (![self isCancelled]) {
        [self willChangeValueForKey:@"isExecuting"];
        m_isExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];
        [self main];
    }
    else {
        [self willChangeValueForKey:@"isFinished"];
        m_isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
    }
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return m_isExecuting;
}

- (BOOL)isFinished {
    return m_isFinished;
}



#pragma mark -
#pragma mark NSOperation implementation

- (void)main {
    
    m_data = [[NSMutableData alloc] init];
    
    [self performSelectorOnMainThread:@selector(initURLConnection) withObject:nil waitUntilDone:YES];
    
    
}


- (void)cancel {
    if (m_isExecuting) {
        [m_urlConnection cancel];
    }
    
    [super cancel];
    
    if (m_isExecuting) {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        m_isExecuting = NO;
        m_isFinished = YES;
        
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isExecuting"];
    }
    
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    @synchronized(connection) {
        [m_data appendData:data];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    m_isExecuting = NO;
    m_isFinished = YES;
    
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    
    [m_data writeToFile:picturePath options:NSAtomicWrite error:&error];

    [poi setPrimitiveValue:poi.image_changed forKey:@"current_image_changed"];
    poi.image = picturePath;
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    m_isExecuting = NO;
    m_isFinished = YES;
    
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
    
}


@end
