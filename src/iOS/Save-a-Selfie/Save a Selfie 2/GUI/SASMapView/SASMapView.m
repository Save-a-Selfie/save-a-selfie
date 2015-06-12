//
//  SASMapView1.m
//  Save a Selfie
//
//  Created by Stephen Fox on 28/05/2015.
//  Copyright (c) 2015 Stephen Fox. All rights reserved.
//

#import "SASMapView.h"
#import "SASLocation.h"
#import "SASAnnotation.h"
#import "SASMapAnnotationRetriever.h"
#import "PopupImage.h"

#import "UIView+NibInitializer.h"
#import "UIView+WidthXY.h"
#import "UIView+Alert.h"
#import "UIImage+Resize.h"

#import "AppDelegate.h"
#import "ExtendNSLogFunctionality.h"


@interface SASMapView() <SASMapAnnotationRetrieverDelegate, SASLocationDelegate> {
    // This variable is gotten from the SASLocationDelegate method
    //  locationDidUpdate:
    CLLocationCoordinate2D currentLocation;

    BOOL userAlreadyLocated;
}


@property(strong, nonatomic) SASLocation* sasLocation;

// Object to retrieve annotations from the server.
@property(strong, nonatomic) SASMapAnnotationRetriever *sasAnnotationRetriever;

// The annotation type for the map to show.
@property(assign, nonatomic) DeviceType annotationType;

@end




@implementation SASMapView

@synthesize sasLocation;
@synthesize sasAnnotationRetriever;
@synthesize notificationReceiver;
@synthesize sasAnnotationImage;
@synthesize annotationType;

@synthesize showAnnotations;
@synthesize zoomToUsersLocationInitially;


#pragma Object Life Cycle
- (instancetype) initWithFrame:(CGRect)frame {
    
    if(self == [super initWithFrame:frame]) {
        [self setupMapView];
    }
    return self;
}


- (instancetype)init {
    if(self = [super init]) {
        [self setupMapView];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self setupMapView];
    }
    return self;
}


// Sets up the SASMapView with the appropriate properties.
- (void) setupMapView {
    
    userAlreadyLocated = NO;
    sasAnnotationImage = Default;
    annotationType = All;
    
    self.mapType = MKMapTypeSatellite;
    
    self.delegate = self;
    self.showAnnotations = YES;
    
    // Our location object.
    self.sasLocation = [[SASLocation alloc] init];
    self.sasLocation.delegate = self;
    
    // Our annotationRetriever Object
    self.sasAnnotationRetriever = [[SASMapAnnotationRetriever alloc] init];
    self.sasAnnotationRetriever.delegate = self;
}



// Locates the user's current location and
// zooms to that location.
- (void) locateUser {
    
    if([self.sasLocation checkLocationPermissions]) {
        [self zoomToCoordinates:currentLocation animated:YES];
    }
    else {
        plog(@"SASMapView could not access location services.");
    }
}



// Displays a single annotation on the map.
- (void) showAnnotation:(SASAnnotation*) annotation andZoom:(BOOL) zoom animated:(BOOL) animated{
    if(showAnnotations) {
        [self removeExistingAnnotationsFromMapView];
        self.showsUserLocation = NO;
    
        [self addAnnotation:annotation];
    }
    
    if(zoom) {
        [self zoomToCoordinates:annotation.coordinate animated:animated];
    }
}


// Filters the map view and shows only one type of
// annotation on the map view.
- (void)filterAnnotationsForType:(DeviceType)type {
    
    switch (type) {
        case All:
            annotationType = All;
            break;
            
        case Defibrillator:
            annotationType = Defibrillator;
            break;
            
        case LifeRing:
            annotationType = LifeRing;
            break;
            
        case FirstAidKit:
            annotationType = FirstAidKit;
            break;
            
        case FireHydrant:
            annotationType = FireHydrant;
            break;
            
        default:
            break;
    }
    
    // This calls  -viewForAnnotation:(id <MKAnnotation>)annotation
    // which is where the flow control for checking what annotations
    // to display is located.
    [self.sasAnnotationRetriever reloadAnnotations];
}


// Zooms to a region on the map view.
- (void) zoomToCoordinates:(CLLocationCoordinate2D) coordinates animated:(BOOL) animated{
    float zoomTo = 0.003 * 0.3;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(zoomTo, zoomTo);
    
    [self setRegion: MKCoordinateRegionMake(coordinates, span) animated:animated];

}



// Removes any existing annotations.
- (void) removeExistingAnnotationsFromMapView {
    for(id<MKAnnotation> annotation in self.annotations) {
        [self removeAnnotation:annotation];
    }
}



#pragma SASLocation delegate method
- (void) locationDidUpdate:(CLLocationCoordinate2D)location {
   
    currentLocation = location;
    
    if(zoomToUsersLocationInitially) {
        // We only want the map to zoom the user
        // when it is first opened. We check `userAlreadyLocated`
        // so the map does no keep zooming every time the user's
        // location is updated.
        if (!userAlreadyLocated) {
            [self locateUser];
            userAlreadyLocated = YES;
        }
    }
    
    // As the map view is providing a wrapper for the location object
    // pass on the location update of the user.
    if (notificationReceiver != nil && [notificationReceiver respondsToSelector:@selector(sasMapViewUsersLocationHasUpdated:)]) {
        [self.notificationReceiver sasMapViewUsersLocationHasUpdated:location];
    }
}



// @Discussion:
//  The following method locationPermssionsHaveChanged:(CLAuthorizationStatus) is a protocol method from
//  SASLocationDelegate. However, any object who holds a SASMapView shouldn't need to adobt the SASLocation
//  delegate as it's SASMapView they should only really be interested in. So when this object(SASMapView) gets
//  an update from SASLocation about authorization changes for location services, we simply forward them onto
//  any object who wants to receive said notifications. This makes a nice object that updates, adoptees of location
//  and map changes.
- (void) locationPermissionsHaveChanged:(CLAuthorizationStatus)status {
    if(notificationReceiver != nil && [notificationReceiver respondsToSelector:@selector(authorizationStatusHasChanged:)]) {
        [notificationReceiver authorizationStatusHasChanged:status];
    }
}



#pragma SASMapAnnotationRetrieverDelegate method
- (void) sasAnnotationsRetrieved:(NSMutableArray *)devices {
    if(self.showAnnotations) {
        [self plotAnnotationsWithDeviceInformation:devices];
    }
}




// @Discussion
// Plots the annotations according to each device retreived from
// SASMapAnnotationRetrieverDelegate's method sasAnnotationsRetrieved:
- (void) plotAnnotationsWithDeviceInformation: (NSMutableArray*) devices {
    
    [self removeExistingAnnotationsFromMapView];
    
    int deviceNumber = 0;
    
    for (Device *d in devices) {
        SASAnnotation *annotation = [[SASAnnotation alloc] initAnnotationWithDevice:d index:deviceNumber];

        deviceNumber++;
        [self addAnnotation:annotation];
    }
}




#pragma MKMapViewDelegate
// @Discussion:
//  Here we are going to forward on the SASAnnotation which was tapped to any object conforming to SASMapViewNotifications
//  and who references notificationReceiver.
//  That object can handle what they do with the information provided by the
//  annotation.
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    SASAnnotation* selectedAnnotation = view.annotation;
    
    if(self.notificationReceiver != nil) {
        [self.notificationReceiver sasMapViewAnnotationTapped:selectedAnnotation];
    }
}




#pragma viewForAnnotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(SASAnnotation*)annotation {
    
    static NSString *annotationViewID = @"MyLocation";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewID];
    
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:annotationViewID];
    }
    
    
    if ([annotation isKindOfClass:MKUserLocation.class]) {
        mapView.showsUserLocation = YES;
        mapView.userLocation.title = @"You are here";
        return nil;
    }
    
#pragma TODO: Improve control flow here.
    // If the image for the annotation
    if(sasAnnotationImage == Default) {
        return nil;
    }
    
    if ([self returnForAnnotationDeviceType:annotation.device.type]) {
        annotationView.image = [Device deviceMapPinImages][annotation.device.type];
        annotationView.annotation = annotation;
        annotationView.enabled = YES;
        annotationView.canShowCallout = NO;
        return annotationView;
        
    } else {
        // Return `blank annotation`.
        return [[MKAnnotationView alloc] init];
    }
    
}



// @Discussion:
// Call this method to check whether or not the -viewForAnnotation: should return
// an MkAnnotationsView. If SASMapView's -filterAnnotationsForType: has been called,
// then the annoatations shown are custom, therefore we must check is
// appropriate to return.
- (BOOL) returnForAnnotationDeviceType:(DeviceType) deviceType {
    if (annotationType == deviceType) {
        return YES;
    }
    // As deviceType will not be ALL, we must check
    // it separately.
    else if(annotationType == All) {
        return YES;
    }
    else {
        return NO;
    }
}



@end