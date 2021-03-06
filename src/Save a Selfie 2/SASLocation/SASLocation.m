//
//  SASLocation.m
//  SASMapView
//
//  Created by Stephen Fox on 25/05/2015.
//  Copyright (c) 2015 Stephen Fox. All rights reserved.
//

#import "SASLocation.h"
#import "AppDelegate.h"
#import "ExtendNSLogFunctionality.h"


@interface SASLocation() {
    CLLocationCoordinate2D currentLocationCoordinates;
}

@property(nonatomic, strong) CLLocationManager *locationManager;


@end

@implementation SASLocation

@synthesize locationManager = _locationManager;
@synthesize delegate;


- (instancetype) init {
    if(self == [super init]) {
        [self setUpLocationManager];
    }
    return self;
}



- (void) setUpLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = (id<CLLocationManagerDelegate>)self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
}




// Discussion:
//      If the user's current location has been found, then this will return
// the last location the devices has located the user at.
- (CLLocationCoordinate2D)currentUserLocation {
    [self.locationManager startUpdatingLocation];
    return currentLocationCoordinates;
}



- (void) startUpdatingUsersLocation {
    if([self canStartLocating]) {
        [self.locationManager startUpdatingLocation];
    } else {
        plog(@"Cannot update users location");
    }
}



- (void) stopUpdatingUsersLocation {
    [self.locationManager stopUpdatingLocation];
}




- (BOOL) canStartLocating {
    
    // Must be called for ios 8
    if([self.locationManager respondsToSelector:NSSelectorFromString(@"requestWhenInUseAuthorization")]) {
        [self.locationManager requestWhenInUseAuthorization];
        
        // Finally check if we have the correct permissions for location services.
        return [self checkLocationPermissions];
    }
    else {
        
        // As this is pre iOS 8 we dont need to call either
        //  requestWhenInUseAuthorization: or requestAlwaysUseAuthorization:
        // so just check if we have appropriate permssions
        return [self checkLocationPermissions];
    }
}




- (BOOL) checkLocationPermissions {
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusDenied:
                NSLog(@"Location Services denied by user.");
                return NO;
                break;
                
            case kCLAuthorizationStatusRestricted:
                NSLog(@"Parental Control restricts location services");
                return NO;
                break;
                
            default:
                return YES;
                break;
        }
    }
    else {
        NSLog(@"Location Services Are disabled");
        return NO;
    }
}




#pragma mark LocationManagerDelegate methods.
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    
    // Assign the current user location to the CurrentUserLocations.
    currentLocationCoordinates = location.coordinate;
    
    // Call locationDidUpdate from SASLocationDelegate for any conforming object.
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(locationDidUpdate:)]) {
        [self.delegate locationDidUpdate:currentLocationCoordinates];
    }
}



// Forward permissions changes to any object referencing
// 'id<SASLocationDelegate> delegate'.
- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(locationPermissionsHaveChanged:)]) {
        [delegate locationPermissionsHaveChanged:status];
    }
}


@end
