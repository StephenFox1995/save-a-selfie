//
//  SASUploader.h
//  Save a Selfie
//
//  Created by Stephen Fox on 01/07/2015.
//  Copyright (c) 2015 Stephen Fox & Peter FitzGerald. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SASUploadObject.h"

@class SASUploader;

@protocol SASUploaderDelegate <NSObject>


// The SASUpload Object uploaded to the server successfully.
- (void) sasUploaderDidFinishUploadWithSuccess:(SASUploader*) sasUploader;


// Upload failed.
- (void) sasUploader:(SASUploader*) sasUploader didFailWithError:(NSError*) error;


@end


// @Discussion:
//  Use this class for uploading a SASUploadObject to the server.
@interface SASUploader : NSObject

@property (weak, nonatomic) SASUploadObject *sasUploadObject;

@property (weak, nonatomic) id <SASUploaderDelegate> delegate;

- (instancetype)initWithSASUploadObject: (SASUploadObject*) object;


// Uploads the SASUploadObject initialized with this class.
- (void) upload;

@end