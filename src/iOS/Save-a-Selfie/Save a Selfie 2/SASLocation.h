//
//  SASLocation.h
//  SASMapView
//
//  Created by Stephen Fox on 25/05/2015.
//  Copyright (c) 2015 Stephen Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

// This protocol provides a wrapper for CLLocationManagerDelegate, and enables us to retreive
// the appropriate location information needed.

@protocol SASLocationDelegate

- (void) locationDidUpdate: (CLLocationCoordinate2D) location;

@end

@interface SASLocation : NSObject <CLLocationManagerDelegate> {
    @public
    BOOL mappingAllowed;
}

@property(assign) id<SASLocationDelegate> delegate;


- (CLLocationCoordinate2D) currentUserLocation;
- (void) startUpdatingUsersLocation;


// Call this method to check what we have persmission to in terms of location services.
//  @return NO : We don't have permission to location services on the user's device.
//               This could be due to the user not allowing this app to use the location
//               or having location services turned off altogether.
//  @return YES: We have acceses to location services.
- (BOOL) checkLocationPermissions;


// Call this method to check if we can begin updating the user's location.
// As of iOS 8 we must call CLLocationManager requestWhenInUseAuthorization: or requestAlwaysAuthorization:
// this method call makes sure these methods are called before we begin updating users location.
- (BOOL) canStartLocating;

@end