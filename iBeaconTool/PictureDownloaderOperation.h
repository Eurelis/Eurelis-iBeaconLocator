//
//  PictureDownloaderOperation.h
//  Soho
//
//  Created by Jérôme Diaz on 28/07/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RootViewController;

@class PointOfInterest;

@interface PictureDownloaderOperation : NSOperation {
        
    NSURLRequest *pictureRequest;
    NSURLConnection *m_urlConnection;
    NSMutableData *m_data;
    NSString *picturePath;
    
    BOOL m_isExecuting;
    BOOL m_isFinished;
    
    PointOfInterest *poi;
    
}

- (id)initWithPOI:(PointOfInterest *)poi;

@end
