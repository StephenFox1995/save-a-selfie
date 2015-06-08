//
//  SASImageViewController.m
//  Save a Selfie
//
//  Created by Stephen Fox on 02/06/2015.
//  Copyright (c) 2015 Stephen Fox. All rights reserved.
//

#import "SASImageViewController.h"
#import "SASMapView.h"
#import "Screen.h"
#import "SASColour.h"
#import "SASActivityIndicator.h"
#import "SASUtilities.h"
#import "SASSocial.h"
#import "SASImageView.h"


@interface SASImageViewController () <SASMapViewNotifications> {
    DeviceType deviceType;
}

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet UITextView *photoDescription;
@property (nonatomic, strong) UIImage *sasImage;
@property (nonatomic, weak) IBOutlet SASImageView *sasImageView;
@property (nonatomic, strong) SASActivityIndicator *sasActivityIndicator;

@property (nonatomic, strong) IBOutlet SASMapView *sasMapView;

@property (nonatomic, weak) IBOutlet UIImageView *deviceImageView;
@property (nonatomic, weak) IBOutlet UILabel *deviceNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;

@property (nonatomic, weak) IBOutlet UIButton *showDeviceLocationPin;

@property (strong, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation SASImageViewController

@synthesize annotation;

@synthesize scrollView;

// This property is the image which has been fetched from
// the server getSASImageWithURLFromString:
@synthesize sasImage;

@synthesize sasImageView;
@synthesize sasMapView;
@synthesize photoDescription;
@synthesize deviceImageView;
@synthesize deviceNameLabel;
@synthesize contentView;
@synthesize sasActivityIndicator;
@synthesize distanceLabel;
@synthesize showDeviceLocationPin;
@synthesize doneButton;



- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self.view bringSubviewToFront:self.doneButton];
}



- (void)viewWillAppear:(BOOL)animated {

#pragma Setup of the UI Elements.
    // @Suggestion:
    // It is possible not every property of annotation
    // will be nil. S check what
    // properties of annoation are not nil and then
    // update the UI accordingly.
    
    // Store the type of device shown in the image
    deviceType = annotation.device.type;
    
    // Set the content size for the scroll view.
    [self.scrollView setContentSize:CGSizeMake([Screen width], 1000)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    // Add shadow to the contentView associated with the scrollView
    [self setShadowForView:self.contentView];
    
    
    // Using attributed string to increase the character spacing for deviceNameLabel
    NSString *deviceName = [Device deviceNames ][deviceType];
    NSMutableAttributedString *attributedDeviceNameLabel = [[NSMutableAttributedString alloc] initWithString:deviceName];
    [attributedDeviceNameLabel addAttribute:NSKernAttributeName value:@(2.0)
                                      range:NSMakeRange(0, [deviceName length])];
    self.deviceNameLabel.attributedText = attributedDeviceNameLabel;
    
    
    // The sasMapView property should show the location
    // of where the device is located.
    self.sasMapView.showAnnotations = YES;
    self.sasMapView.notificationReceiver = self;
    self.sasMapView.userInteractionEnabled = YES;
    self.sasMapView.showsUserLocation = NO;
    [self.sasMapView setMapType:MKMapTypeHybrid];
    [self showDeviceLocation:nil];
    
    
    
#pragma self.annotation.device nil checking
    if (self.annotation.device != nil) {
        
        // Set the image for deviceImageView associated with the device
        self.deviceImageView.image = [self deviceImageFromAnnotation:self.annotation.device];
        
        // Set the elements of the UI which are coloured to the
        // respective colour associated with the device.
        [self setColourForColouredUIElements:self.annotation.device];
    }
        
    
#pragma self.annotation.device.imageStandardRes nil checking. (Image)
    if(self.annotation.device.imageStandardRes != nil) {
        
        // Begin animation of sasActivityIndicator until image is loaded.
        self.sasActivityIndicator = [[SASActivityIndicator alloc] init];
        [self.view addSubview:sasActivityIndicator];
        self.sasActivityIndicator.center = self.sasImageView.center;
        self.sasActivityIndicator.backgroundColor = [UIColor clearColor];
        [self.sasActivityIndicator startAnimating];
        
        // Set the image from the URLString contained within the device property
        // of the annotation passed to this object.
        // NOTE: The URLString is contained inside the device.standard_resolution property.
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIImage* imageFromURL = [self getSASImageWithURLFromString:annotation.device.imageStandardRes];
            
            dispatch_async( dispatch_get_main_queue(), ^{
                self.sasImageView.image = imageFromURL;
                [self.sasActivityIndicator stopAnimating];
                [self.sasActivityIndicator removeFromSuperview];
                self.sasActivityIndicator = nil;
            });
        });
    }
    
    
#pragma self.annotatio.device.caption nil checking
    if(self.annotation.device.caption != nil) {
        // Set the text description of the photo.
        self.photoDescription.text = [NSString stringWithFormat:@"%@", annotation.device.caption];
        [self.photoDescription setFont:[UIFont fontWithName:@"Avenir Next" size:18]];
        [self.photoDescription sizeToFit];
        [self.photoDescription.layer setBorderWidth:0.0];
    }
}



// Shows the location of the device on the map.
- (IBAction)showDeviceLocation:(id)sender {
    [self.sasMapView showAnnotation:self.annotation andZoom:YES animated:YES];
}



#pragma TODO: Make custom class for this. UIView extension etc.
- (void) setShadowForView: (UIView*) view {
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, -2);
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowRadius = 1.0;
    view.clipsToBounds = NO;
}



// Sets all the UIElements of this view, whose colour
// is dependant on the device being shown in the image.
- (void) setColourForColouredUIElements:(Device*) device {
    NSArray* mapPinButtonImages = @[[UIImage imageNamed:@"MapPinAEDRed"],
                                    [UIImage imageNamed:@"MapPinLifeRingRed"],
                                    [UIImage imageNamed:@"MapPinFAKitGreen"],
                                    [UIImage imageNamed:@"MapPinHydrantBlue"]];
    [self.showDeviceLocationPin setImage:mapPinButtonImages[deviceType] forState:UIControlStateNormal];
    
    self.distanceLabel.textColor = [SASColour getSASColours][deviceType];
}



// Gets the image associated with the device.
- (UIImage*) deviceImageFromAnnotation: (Device*) device {
    return [Device deviceImages][device.type];
}



// Gets the image for the view from the URL
- (UIImage*) getSASImageWithURLFromString: (NSString *) string {
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:string]];
    
    // Hold reference to the image.
    self.sasImage = [UIImage imageWithData:data];
    
    return sasImage;
}


#pragma SASNotificationReceiver
- (void)sasMapViewUsersLocationHasUpdated:(CLLocationCoordinate2D)coordinate {
    double distance = [SASUtilities distanceBetween:self.annotation.coordinate and:coordinate];
    printf("CALLED");
    __weak NSString *distanceString = [NSString stringWithFormat:@"%.0fKM Approx", distance];
    self.distanceLabel.text = distanceString;
}


#pragma Share to Social Media
- (IBAction)shareToSocialMedia:(id)sender {
    if(annotation != nil) {
        [SASSocial shareToSocialMedia:self.annotation.device.caption andImage:self.sasImage target:self];
    }
}



- (IBAction)dissmissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (BOOL) prefersStatusBarHidden {
    return YES;
}

@end