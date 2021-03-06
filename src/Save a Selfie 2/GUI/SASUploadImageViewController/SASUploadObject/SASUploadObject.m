//
//  SASUploadImage.m
//  Save a Selfie
//
//  Created by Stephen Fox on 09/06/2015.
//  Copyright (c) 2015 Stephen Fox. All rights reserved.
//

#import "SASUploadObject.h"
#import "UIImage+SASImage.h"


@interface SASUploadObject()


@property (assign, nonatomic) BOOL deviceHasBeenSet;

@end

@implementation SASUploadObject

@synthesize timeStamp;
@synthesize associatedDevice = _associatedDevice;
@synthesize coordinates;
@synthesize image = _image;
@synthesize caption;
@synthesize identifier;
@synthesize UUID;

- (instancetype)initWithImage:(UIImage *)imageToUpload {
    
    if (self = [super init]) {
        // @Discussion:
        // See UIImage+SASNormalizeImage.h
        // for reason on why we need to normalize
        // the image property.
        _image = [imageToUpload normalizedImage];
        
        _associatedDevice = [[SASDevice alloc] init];
        
        // This will be set to All as we need to check
        // if its been set. If .type is not All
        // then we know it has been set.
        _associatedDevice.type = All;
    }
    return self;
}



#pragma mark SASVerifiedUploadObject Protocol
- (BOOL)captionHasBeenSet {
    
    if ([self.caption isEqualToString:@""] ||
        [self.caption isEqualToString:@"Add Location Information"] ||
        self.caption == nil) {
        
        return NO;
        
    } else {
        return YES;
    }
}


- (BOOL)deviceHasBeenSet {
    if (self.associatedDevice.type != All) {
        return YES;
    } else {
        return NO;
    }
}



@end
