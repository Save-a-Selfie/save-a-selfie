//
//  SASMapViewController.m
//  Save a Selfie
//
//  Created by Stephen Fox on 27/05/2015.
//  Copyright (c) 2015 Stephen Fox & Peter FitzGerald. All rights reserved.
//

#import "SASMapViewController.h"
#import "AppDelegate.h"
#import "SASImageViewController.h"
#import "ExtendNSLogFunctionality.h"
#import "Screen.h"
#import "UIView+Alert.h"
#import "SASImagePickerViewController.h"
#import "SASUploadViewController.h"
#import "UIFont+SASFont.h"
#import "SASNotificationView.h"
#import "UIView+Animations.h"
#import "EULAViewController.h"
#import "SASFilterView.h"
#import "FXAlert.h"
#import "SASTabBarController.h"
#import "SASNetworkQuery.h"
#import "SASNetworkManager.h"
#import "DefaultDownloadWorker.h"
#import "Cacheable.h"

@interface SASMapViewController ()
<SASImagePickerDelegate,
SASUploadViewControllerDelegate,
UIAlertViewDelegate,
MKMapViewDelegate,
Cacheable>

@property (nonatomic, strong) IBOutlet SASMapView* sasMapView;

@property (nonatomic, strong) SASImagePickerViewController *sasImagePickerController;
@property (nonatomic, strong) SASUploadViewController *sasUploadViewController;

@property (nonatomic, strong) UINavigationController *uploadImageNavigationController;

@property (strong, nonatomic) FXAlertController* permissionProblemAlert;

@property (weak, nonatomic) IBOutlet UIButton *showFilterViewButton;
@property (strong, nonatomic) IBOutlet UIButton *uploadNewImageToServerButton;
@property (strong, nonatomic) IBOutlet UIButton *locateUserButton;

@property (strong, nonatomic) UISegmentedControl *mapTypeSegmentedContol;
@property (strong, nonatomic) SASFilterView *sasFilterView;

@property (strong, nonatomic) SASNetworkManager *networkManager;
@property (strong, nonatomic) NSMutableDictionary <SASAnnotation*, SASDevice*> *annotationDict;
@property (strong, nonatomic) SASAppCache *sasAppCache;

@end

@implementation SASMapViewController

NSString *permissionsProblemText = @"Please enable location services for this app. Launch the iPhone Settings app to do this.\n\nGo to Privacy > Location Services > Save a Selfie > While Using the App. You have to go out of this app, using the 'Home' button.";


- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  self.tabBarController.tabBar.hidden = NO;
  
  self.sasMapView.notificationReceiver = self;
  self.sasMapView.zoomToUsersLocationInitially = YES;
  self.sasMapView.sasAnnotationImage = SASAnnotationImageCustom;
  self.sasMapView.mapType = MKMapTypeSatellite;
  
  [self downloadInformationFromServer];
}


- (IBAction)locateUser:(id)sender {
  [self.sasMapView locateUser];
}


- (void) displayLocationDisabledAlert {
  [self clearLocationDisabledAlert];
  
  if (self.permissionProblemAlert == nil) {
    self.permissionProblemAlert = [[FXAlertController alloc] initWithTitle:@"LOCATION DISABLED" message:permissionsProblemText];
    self.permissionProblemAlert.font = [UIFont fontWithName:@"Avenir Next" size:15];
    
    FXAlertButton *gotoSettingsButton = [[FXAlertButton alloc] initWithType:FXAlertButtonTypeCancel];
    [gotoSettingsButton setTitle:@"Open Settings" forState:UIControlStateNormal];
    [gotoSettingsButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
    
    [self.permissionProblemAlert addButton:gotoSettingsButton];
    
    [self presentViewController:self.permissionProblemAlert animated:YES completion:nil];
    
  }
}



- (void) openSettings {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}



- (void) clearLocationDisabledAlert { // called when returning from outside app
  if (self.permissionProblemAlert) {
    [self.permissionProblemAlert dismissViewControllerAnimated:YES completion:nil];
    self.permissionProblemAlert = nil;
  }
}



- (IBAction) showSASFilterView:(id)sender {
  if (!self.sasFilterView) {
    self.sasFilterView = [[SASFilterView alloc] init];
    [self.sasFilterView mapToFilter:self.sasMapView];
  }
  [self.sasFilterView animateIntoView:self.view];
}



- (void) downloadInformationFromServer {
  self.networkManager = [SASNetworkManager sharedInstance];
  SASNetworkQuery *query = [SASNetworkQuery queryWithType:SASNetworkQueryTypeAll];
  DefaultDownloadWorker *downloadWorker = [[DefaultDownloadWorker alloc] init];
  
  [self.networkManager cacheableDownloadWithQuery:query
                                        forWorker:downloadWorker
                                            cache:self];
}


#pragma mark <Cacheable>
- (void)cacheObjects:(NSArray<NSObject *> *) objects {

  // Ideally we shouldn't need to check the contents
  // of the array, however, as we're going to cache it
  // we better make sure it is what we expect. (SASDevice);
  if (objects) {
    unsigned long length = objects.count;
    if ([objects[length - 1] isKindOfClass:[SASDevice class]]) {
      if (!self.sasAppCache) {
        self.sasAppCache = [SASAppCache sharedInstance];
      }
      

      // Cache all the devices and annotations
      // generated from the devices.
      for (SASDevice *s in objects) {
        SASAnnotation *annotation = [SASAnnotation annotationWithSASDevice:s];
        [self.sasAppCache cacheAnnotation:annotation forDevice:s];
      }
    }
  }
  [self displayAnnotationsToMap];
}


- (void) displayAnnotationsToMap {
  if (!self.sasAppCache) {
    self.sasAppCache = [SASAppCache sharedInstance];
  }
  
  NSArray *keys = [self.sasAppCache keys];
  for (SASDevice* key in keys) {
    [self.sasMapView addAnnotation:[self.sasAppCache cachedAnnotationForKey:key]];
  }
}

#pragma mark <SASMapViewNotifications>
- (void)sasMapView:(SASMapView *)mapView annotationWasTapped:(SASAnnotation *) annotation {
  // Present the SASImageviewController to display the image associated
  // with the annotation selected.
  SASImageViewController *sasImageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SASImageViewController"];
  sasImageViewController.device = [self.annotationDict objectForKey:annotation];
  sasImageViewController.annotation = annotation;
  [self.navigationController pushViewController:sasImageViewController animated:YES];
}



// This method will be called anytime permissions for lacation is changed.
- (void)sasMapView:(SASMapView *)mapView authorizationStatusHasChanged:(CLAuthorizationStatus)status {
  
  BOOL makeCheckForMapWarning = NO;
  
  
  if([CLLocationManager locationServicesEnabled]){
    switch(status){
        
      case kCLAuthorizationStatusAuthorizedAlways:
        NSLog(@"We have access to location services");
        break;
        
      case kCLAuthorizationStatusAuthorizedWhenInUse:
        makeCheckForMapWarning = YES;
        // Only when we have access to location
        // can this be set to YES.
        self.sasMapView.showsUserLocation = YES;
        break;
        
      case kCLAuthorizationStatusDenied:
        NSLog(@"Location services denied by user!");
        [self displayLocationDisabledAlert];
        break;
        
      case kCLAuthorizationStatusRestricted:
        NSLog(@"Parental controls restrict location services");
        break;
        
      case kCLAuthorizationStatusNotDetermined:
        NSLog(@"Unable to determine, possibly not available");
        break;
        
      default:
        [self displayLocationDisabledAlert];
        break;
        
    }
  }
  else {
    NSLog(@"Location Services Are Disabled");
    [self displayLocationDisabledAlert];
  }
  
  if (makeCheckForMapWarning) {
    [self makeCheckForMapWarning];
  }
}

#pragma Map Warning
- (void) makeCheckForMapWarning {
  
  BOOL hasMapWarningHasBeenAccepted = [[[NSUserDefaults standardUserDefaults]
                                        valueForKey:@"mapWarningAccepted"]
                                       isEqualToString:@"yes"];
  
  
  if (!hasMapWarningHasBeenAccepted) {
    
    FXAlertController *disclaimerWarning = [[FXAlertController alloc] initWithTitle:@"WARNING!" message:@"The information here is correct to the best of our knowledge, but use, is at your risk and discretion, with no liability to Save a Selfie, the developers or Apple."];
    
    FXAlertButton *acceptButton = [[FXAlertButton alloc] initWithType:FXAlertButtonTypeStandard];
    [acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
    [acceptButton addTarget:self action:@selector(acceptMapWarning) forControlEvents:UIControlEventTouchUpInside];
    
    FXAlertButton *declineButton = [[FXAlertButton alloc] initWithType:FXAlertButtonTypeCancel];
    [declineButton setTitle:@"Decline" forState:UIControlStateNormal];
    [declineButton addTarget:self action:@selector(declineMapWarning) forControlEvents:UIControlEventTouchUpInside];
    
    [disclaimerWarning addButton:acceptButton];
    [disclaimerWarning addButton:declineButton];
    
    [self presentViewController:disclaimerWarning animated:YES completion:nil];
  }
}



- (void) acceptMapWarning {
  self.sasMapView.userInteractionEnabled = YES;
  [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"mapWarningAccepted"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  EULAViewController *eulaVC = [EULAViewController new];
  [eulaVC updateEULATable];
}


- (void) declineMapWarning {
  // Disabled user interaction for user until they accept the map warning.
  self.sasMapView.userInteractionEnabled = NO;
  
  FXAlertController *disclaimerAlert = [[FXAlertController alloc] initWithTitle:@"DISCLAIMER" message:@"To use this app you must accept the disclaimer."];
  
  FXAlertButton *showMeButton = [[FXAlertButton alloc] initWithType:FXAlertButtonTypeStandard];
  [showMeButton setTitle:@"Show me" forState:UIControlStateNormal];
  [showMeButton addTarget:self action:@selector(makeCheckForMapWarning) forControlEvents:UIControlEventTouchUpInside];
  [disclaimerAlert addButton:showMeButton];
  
  [self presentViewController:disclaimerAlert animated:YES completion:nil];
  
}





#pragma mark Begin Upload Routine.

// @Discussion:
//  The upload routine involves the following steps:
//
//  1. Present sasImagePickerController: Here the user can take a photo
//     of the desired device.
//
//  2. Wait for delegate method - (void)sasImagePickerController didFinishWithImage:(UIImage *)image to be called.
//     This will give us the image taken by the user.
//     The image is then used to initialise a SASUploadObject.
//
//
//  3. Then the image is handed to sasUploadImageViewController, which will handle all
//     of the uploading.
- (IBAction)uploadNewNewDevice:(id)sender {
  
  if(self.sasImagePickerController == nil) {
    self.sasImagePickerController = [[SASImagePickerViewController alloc] init];
    self.sasImagePickerController.sasImagePickerDelegate = self;
  }
  
  if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    [self.sasImagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:self.sasImagePickerController animated:YES completion:nil];
  }
  
}


#pragma mark SASImagePickerDelegate Method
- (void)sasImagePickerController:(SASImagePickerViewController *)sasImagePicker didFinishWithImage:(UIImage *)image {
  // Create an upload object and set the image.
  SASNetworkObject *sasNetworkObject = [[SASNetworkObject alloc] initWithImage:image];
  
  [self.sasImagePickerController dismissViewControllerAnimated:YES completion:^{
    self.sasImagePickerController = nil;
    [self presentSASUploadImageViewControllerWithUploadObject:sasNetworkObject];
  }];
  
}



- (void)sasImagePickerControllerDidCancel:(SASImagePickerViewController *)sasImagePickerController {
  self.sasImagePickerController = nil;
}




// Presents a SASUploadImageViewController via
- (void) presentSASUploadImageViewControllerWithUploadObject:(SASNetworkObject*) sasUploadObject {
  // @Discussion:
  //  The user location will be set here, now it may
  //  seem like it should be set just before the user
  //  actually decides to upload the image/device, however,
  //  it is possible the user may take the picture and move
  //  from the location an upload moments later.
  //  So for now we will set the coordinates here.
  sasUploadObject.coordinates = [self.sasMapView currentUserLocation];
  
  
  if(self.sasUploadViewController == nil) {
    self.sasUploadViewController =
    (SASUploadViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SASUploadImageViewController"];
    self.sasUploadViewController.delegate = self;
    [self.sasUploadViewController setSasUploadObject:sasUploadObject];
  }
  
  
  if (self.uploadImageNavigationController == nil) {
    self.uploadImageNavigationController =
    [[UINavigationController alloc] initWithRootViewController:self.sasUploadViewController];
  }
  
  [self presentViewController:self.uploadImageNavigationController animated:YES completion:nil];
  
  
  
}

#pragma mark SASUploadViewController Delegate
- (void)sasUploadViewController:(UIViewController *)viewController withResponse:(SASUploadControllerResponse)response withObject:(SASNetworkObject *)sasUploadObject {
  // Alert the user if it was succes.
  if(response == SASUploadControllerResponseUploaded) {
    SASNotificationView *sasNotificationView = [[SASNotificationView alloc] init];
    sasNotificationView.title = @"THANK YOU!";
    sasNotificationView.image = [UIImage imageNamed:@"DoneImage"];
    [sasNotificationView animateIntoView:self.view];
  }
  
  
  sasUploadObject = nil;
  self.sasUploadViewController = nil;
  self.uploadImageNavigationController = nil;
}

@end
