//
//  SASMapAnnotationRetriever.h
//  Save a Selfie
//
//  Created by Stephen Fox on 28/05/2015.
//  Copyright (c) 2015 Stephen Fox & Peter FitzGerald. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol SASMapAnnotationRetrieverDelegate <NSObject>


// @Discussion
//  This method will pass
//  a NSMutableArray with information regarding an annotation.
//
//  @param device: NSMutable array which contains device information.
- (void) sasAnnotationsRetrieved: (NSMutableArray*) devices;

@end



// This class will allow us to fetch/ retrieve MKMapAnnotations.
// This app uses Device.h/.m to wrap up extra information about the device
// i.e image, location etc...
// For more information refer to Device.h.
@interface SASMapAnnotationRetriever : NSObject


@property(nonatomic, weak) id<SASMapAnnotationRetrieverDelegate> delegate;

// @Discussion:
//  Fetches all the annotations from the server.
//  The annotations a passed via the `SASMapAnnotationRetrieverDelegate` method
//  -sasAnnotationsRetrieved:
- (void) fetchSASAnnotationsFromServer;


// @Abstract:
//  This method gets the images from the URL off the main thread.
//  It is called inside `dispatch_async` on the global_queue.
// @return UIImage from the `URL`
- (UIImage*) getImageFromURLWithString: (NSString *) string;

@end
