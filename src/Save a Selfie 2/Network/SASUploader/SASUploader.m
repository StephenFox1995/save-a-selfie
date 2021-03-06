//
//  SASUploader.m
//  Save a Selfie
//
//  Created by Stephen Fox on 01/07/2015.
//  Copyright (c) 2015 Stephen Fox & Peter FitzGerald. All rights reserved.
//

#import "SASUploader.h"
#import "UIImage+Resize.h"
#import "UIImage+SASImage.h"
#import "SASNetworkUtilities.h"
#import "SASUtilities.h"


@interface SASUploader() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>


@property (strong, nonatomic) UIImage* largeImage;
@property (strong, nonatomic) UIImage* thumbnailImage;

@property (strong, nonatomic) NSMutableData* responseData;

// Boolean flag that will be set to YES, when uploading occurs.
// When uploading finishes or hasn't began this property will be set to NO.
@property(nonatomic, assign) BOOL uploading;

@end

@implementation SASUploader

@synthesize delegate;

@synthesize sasUploadObject = _sasUploadObject;

@synthesize largeImage;
@synthesize thumbnailImage;

@synthesize responseData;
@synthesize uploading;


#pragma Object Life Cycle
- (instancetype)initWithSASUploadObject: (SASUploadObject <SASVerifiedUploadObject>*) object {
    
    if (self == [super init]) {
        _sasUploadObject = object;
    }
    return self;
}



#pragma mark UploadObject
- (void)upload {
    
    // Make sure we have a valid object
    // to upload.
    BOOL proceedToUpload = [self validateSASUploadObject];
    
    
    if(proceedToUpload) {
        
        [self setImagesToCorrectSize];
        
        
        // Construct information for uploading
        NSData *standardImageData = UIImageJPEGRepresentation(self.largeImage, 1.0);
        NSData *thumbnailImageData = UIImageJPEGRepresentation(self.thumbnailImage, 1.0);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"POST"];
        
        NSString *URL = @"http://www.saveaselfie.org/wp/wp-content/themes/magazine-child/iPhone.php";
        
        [request setURL:[NSURL URLWithString:URL]];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        NSString *standardImageString = [standardImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]; // the large (i.e., not thumbnail) image converted to a base-64 string
        NSString *thumbnailImageString = [thumbnailImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]; // the thumbnail image converted to a base-64 string
        
        self.sasUploadObject.caption = [SASNetworkUtilities encodeToPercentEscapeString:self.sasUploadObject.caption]; // The caption for the image – as entered by the user
        
        
        self.sasUploadObject.identifier = [NSString stringWithFormat:@"%@%@", self.sasUploadObject.timeStamp, [SASUtilities generateRandomString:4]];
        
        
        NSString *parameters = [ NSString stringWithFormat:@"id=%@&typeOfObject=%d&latitude=%f&longitude=%f&location=%@&user=%@&caption=%@&image=%@&thumbnail=%@&deviceID=%@&devType=iOS", self.sasUploadObject.identifier, self.sasUploadObject.associatedDevice.type, self.sasUploadObject.coordinates.latitude, self.sasUploadObject.coordinates.longitude, @"", @"", self.sasUploadObject.caption, standardImageString, thumbnailImageString, self.sasUploadObject.UUID];
        
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[parameters length]];
        [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        
        if(connection) {
            
            self.responseData = [[NSMutableData alloc] init];
            [self.responseData setLength:0];
            
            // Message the delegate that we have our connection and have begun uploading.
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(sasUploaderDidBeginUploading:)]) {
                [self.delegate sasUploaderDidBeginUploading:self];
            }
            
        }
        
    }
}



// @return YES: If the object is ready to be uploaded.
// @return NO: IF the object is not ready to be uploaded.

// This method will also call the delegate.
- (BOOL) validateSASUploadObject {
    
    if(![self.sasUploadObject captionHasBeenSet]) {
        
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(sasUploader:invalidObjectWithResponse:)]) {
            [self.delegate sasUploader: self.sasUploadObject invalidObjectWithResponse:SASUploadInvalidObjectCaption];
        }
        return NO;
    }
    if (![self.sasUploadObject deviceHasBeenSet]) {
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(sasUploader:invalidObjectWithResponse:)]) {
            [self.delegate sasUploader:self.sasUploadObject invalidObjectWithResponse:SASUploadInvalidObjectDeviceType];
        }
        return NO;
    }
    else {
        return YES;
    }
}


- (void) setImagesToCorrectSize {
    
    // TODO: Clean this up. Ideally all this resizing should be done within
    // a UIImage caterory.
    self.largeImage = self.sasUploadObject.image;
    
    
    float maxWidth = 400, thumbSize = 150;
    float ratio = maxWidth / self.largeImage.size.width;
    float height, width, minDim, tWidth, tHeight;
    
    if (ratio >= 1.0) {
        width = self.largeImage.size.width;
        height = self.largeImage.size.height;
    }
    else { width = maxWidth;
        height = self.largeImage.size.height * ratio;
    }
    
    // Large Image
    self.largeImage = [self.sasUploadObject.image resizedImage:CGSizeMake(width, height) interpolationQuality:kCGInterpolationHigh];
    
    
    // Thumbnail Image
    minDim = height < width ? height : width;
    ratio = thumbSize / minDim; tWidth = width * ratio; tHeight = height * ratio;
    
    self.thumbnailImage = [self.largeImage resizedImage:CGSizeMake(tWidth, tHeight) interpolationQuality:kCGInterpolationHigh];
    
    // Add watermarks.
    __weak UIImage *watermark = [UIImage imageNamed:@"Watermark"];
    
    self.largeImage = [UIImage doubleMerge:largeImage withImage:nil atX:20 andY:20 withStrength:1.0 andImage:watermark atX2:width - watermark.size.width - 20 andY2:height - watermark.size.height - 20 strength:1.0];
    
}


#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Failed! %@", error);
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(sasUploader:didFailWithError:)]) {
        [self.delegate sasUploader:self didFailWithError:error];
    }
}


#pragma mark NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response received! %@", response);
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"data received - length %lu", (unsigned long)data.length);
    
    [self.responseData appendData:data];
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"finished uploading...");
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(sasUploaderDidFinishUploadWithSuccess:)]) {
        [self.delegate sasUploaderDidFinishUploadWithSuccess:self];
    }
}

@end
