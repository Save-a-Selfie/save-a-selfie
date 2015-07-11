//
//  SASUploadImageViewController.m
//  Save a Selfie
//
//  Created by Stephen Fox on 09/06/2015.
//  Copyright (c) 2015 Stephen Fox. All rights reserved.
//

#import "SASUploadImageViewController.h"
#import "SASImageView.h"
#import "SASUtilities.h"
#import "SASAnnotation.h"
#import "UIFont+SASFont.h"
#import "Screen.h"
#import "SASBarButtonItem.h"
#import "SASAlertView.h"
#import "SASUploader.h"
#import "SASDeviceButton.h"
#import "SASGreyView.h"
#import "EULAViewController.h"
#import "SASActivityIndicator.h"
#import "ExtendNSLogFunctionality.h"
#import "UIView+NibInitializer.h"


@interface SASUploadImageViewController () <UITextViewDelegate, SASUploaderDelegate, EULADelegate>

@property (strong, nonatomic) IBOutlet SASImageView *sasImageView;
@property (weak, nonatomic) IBOutlet SASMapView *sasMapView;
@property (strong, nonatomic) SASAnnotation *sasAnnotation;

@property (weak, nonatomic) IBOutlet SASDeviceButton *defibrillatorButton;
@property (weak, nonatomic) IBOutlet SASDeviceButton *lifeRingButton;
@property (weak, nonatomic) IBOutlet SASDeviceButton *firstAidKitButton;
@property (weak, nonatomic) IBOutlet SASDeviceButton *fireHydrantButton;

@property (weak, nonatomic) IBOutlet UILabel *selectDeviceLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextView *deviceCaptionTextView;

@property (strong, nonatomic) SASGreyView *sasGreyView;
@property (strong, nonatomic) SASActivityIndicator *sasActivityIndicator;

@property (strong, nonatomic) NSMutableArray *deviceButtonsArray;
@property (nonatomic, assign) BOOL deviceHasBeenSelected;

@property (strong, nonatomic) SASUploader *sasUploader;
@property (strong, nonatomic) EULAViewController * eulaViewController;



@end

@implementation SASUploadImageViewController

@synthesize sasImageView;
@synthesize sasUploadObject;
@synthesize sasMapView;
@synthesize sasAnnotation;
@synthesize sasGreyView;
@synthesize sasActivityIndicator;

@synthesize defibrillatorButton;
@synthesize lifeRingButton;
@synthesize firstAidKitButton;
@synthesize fireHydrantButton;
@synthesize deviceButtonsArray;
@synthesize selectDeviceLabel;
@synthesize doneButton;
@synthesize deviceHasBeenSelected;

@synthesize sasUploader;
@synthesize eulaViewController;


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissKeyboard];
}


- (void) dismissKeyboard {
    [self.deviceCaptionTextView resignFirstResponder];
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.sasAnnotation == nil) {
        self.sasAnnotation = [[SASAnnotation alloc] init];
    }
    
    self.sasAnnotation.coordinate = self.sasUploadObject.coordinates;
    
    self.sasMapView.sasAnnotationImage = DefaultAnnotationImage;
    [self.sasMapView showAnnotation:self.sasAnnotation andZoom:YES animated:YES];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.doneButton.hidden = YES;
    self.sasImageView.image = self.sasUploadObject.image;
    
    [UIFont increaseCharacterSpacingForLabel:self.selectDeviceLabel byAmount:2.0];
    [UIFont increaseCharacterSpacingForLabel:self.doneButton.titleLabel byAmount:1.0];
    
    
    self.deviceCaptionTextView.delegate = self;
    self.deviceCaptionTextView.layer.cornerRadius = 2.0;
    
    SASBarButtonItem *cancelBarButtonItem = [[SASBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dismissSASUploadImageViewController)];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    self.navigationController.navigationBar.topItem.title = @"Upload";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:17.0f] }];
    
    
    if (self.deviceButtonsArray == nil) {
        self.deviceButtonsArray = [[NSMutableArray alloc] initWithObjects:defibrillatorButton,
                                   lifeRingButton,
                                   firstAidKitButton,
                                   fireHydrantButton,
                                   nil];
    }
    
    self.defibrillatorButton.selectedImage = [UIImage imageNamed:@"DefibrillatorSelected"];
    self.defibrillatorButton.deviceType = Defibrillator;
    
    self.lifeRingButton.selectedImage = [UIImage imageNamed:@"LifeRingSelected"];
    self.lifeRingButton.deviceType = LifeRing;
    
    self.firstAidKitButton.selectedImage = [UIImage imageNamed:@"FirstAidKitSelected"];
    self.firstAidKitButton.deviceType = FirstAidKit;
    
    self.fireHydrantButton.selectedImage = [UIImage imageNamed:@"FireHydrantSelected"];
    self.fireHydrantButton.deviceType = FireHydrant;
    
    self.defibrillatorButton.unselectedImage = [UIImage imageNamed:@"DefibrillatorUnselected"];
    self.lifeRingButton.unselectedImage = [UIImage imageNamed:@"LifeRingUnselected"];
    self.firstAidKitButton.unselectedImage = [UIImage imageNamed:@"FirstAidKitUnselected"];
    self.fireHydrantButton.unselectedImage = [UIImage imageNamed:@"FireHydrantUnselected"];
    
}



- (IBAction)deviceSelected:(SASDeviceButton*) sender {
    
    [self deselectDeviceButtons];
    
    [sender select];
    
    #pragma mark SASUploadObject associated Device. set here.
    self.sasUploadObject.associatedDevice.type = sender.deviceType;

    self.doneButton.hidden = NO;
}




// 'Deselects' a button by putting the image of the button back
// to the default image when the button was not selected;
- (void) deselectDeviceButtons {
    for (SASDeviceButton* button in self.deviceButtonsArray) {
        [button deselect];
    }
}


- (void) selectDeviceButton:(SASDeviceButton *) button {
    [button select];
}





#pragma mark Upload Routine
- (IBAction)beginUploadRoutine:(id)sender {
    
    //[self checkEULAAcepted];
    #pragma mark SASUploadObject timestamp set here.
    [self.sasUploadObject setTimeStamp: [SASUtilities getCurrentTimeStamp]];
    
    
    self.sasUploader = [[SASUploader alloc] initWithSASUploadObject:self.sasUploadObject];
    self.sasUploader.delegate = self;
    [self.sasUploader upload];
    
}



#pragma mark SASUploaderDelegate
- (void) sasUploadDidBeginUploading:(SASUploader *)sasUploader {
    
    // Activity Indicator
    self.sasActivityIndicator = [[SASActivityIndicator alloc] initWithMessage:@"Posting"];
    self.sasActivityIndicator.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    [self.view addSubview:self.sasActivityIndicator];
    self.sasActivityIndicator.center = self.view.center;
    [self.sasActivityIndicator startAnimating];
    
}


- (void)sasUploaderDidFinishUploadWithSuccess:(SASUploader *)sasUploader {
    [self dismissSASUploadImageViewController];
    
    [self.sasActivityIndicator removeFromSuperview];
    [self.sasActivityIndicator stopAnimating];
    
}


- (void)sasUploader:(SASUploader *)sasUploader didFailWithError:(NSError *)error {
    
    SASAlertView *uploadErrorAlert = [[SASAlertView alloc] initWithTarget:self andAction:nil];
    uploadErrorAlert.title = @"Ooops!";
    uploadErrorAlert.message = @"There seemed to be a problem posting!\n Please try again";
    uploadErrorAlert.buttonTitle = @"Ok";
    
    [self.sasActivityIndicator removeFromSuperview];
    [self.sasActivityIndicator stopAnimating];
    
    [uploadErrorAlert animateIntoView:self.view];
    
}



- (void) sasUploadObject:(SASUploadObject *)object invalidObjectWithResponse:(SASUploadInvalidatedResponse) response {
    
    SASAlertView *alertView = [[SASAlertView alloc] initWithTarget:self andAction:nil];
    
    switch (response) {
        
        case SASUploadObjectInvalidCaption:
            alertView.title = @"Ooops!";
            alertView.message = @"Please add a description for this post!";
            alertView.buttonTitle = @"Ok";
            [alertView animateIntoView:self.view];
            break;
            
        default:
            break;
    }
}




#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if([self.deviceCaptionTextView.text isEqualToString:@"Add Location Information"]) {
        self.deviceCaptionTextView.text = @"";
    }
    
    [self addGreyView];
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if([self.deviceCaptionTextView.text isEqualToString:@""]) {
        self.deviceCaptionTextView.text = @"Add Location Information";
    }
    
    
    #pragma mark SASUploadObject.description set here.
    self.sasUploadObject.caption = textView.text;
    
    [self removeGreyView];
}





// Adds a SASGrey view which dims the background apart from `deviceCaptionTextView` &
// `sasImageView`.
- (void) addGreyView {
    if (self.sasGreyView == nil) {
        self.sasGreyView = [[SASGreyView alloc] initWithFrame:CGRectMake(0, 0, [Screen width], [Screen height])];
    }
    [self.sasGreyView animateIntoView:self.view];
    [self.view bringSubviewToFront:self.sasImageView];
    [self.view bringSubviewToFront:self.deviceCaptionTextView];
    
}

- (void) removeGreyView {
    [self.sasGreyView animateOutOfParentView];
}


- (void) dismissSASUploadImageViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self deselectDeviceButtons];
    
    
    // Call delegate.
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(sasUploadImageViewControllerDidFinishUploading:withObject:)]) {
        [self.delegate sasUploadImageViewControllerDidFinishUploading:self withObject:self.sasUploadObject];
    }

}




#pragma Check the user has agreed to the End User Licence Agreement
- (void) checkEULAAcepted {
    
    BOOL EULAAccepted = [[[NSUserDefaults standardUserDefaults] valueForKey:@"EULAAccepted"] isEqualToString:@"yes"];
    
    if (!EULAAccepted) {
        SASAlertView *sasAlertView = [[SASAlertView alloc] initWithTarget:self andAction:@selector(presentEULAViewController)];
        sasAlertView.title = @"Notice";
        sasAlertView.message = @"Before posting, we need you to agree to the terms of use.";
        sasAlertView.buttonTitle = @"Show me";
        
        [sasAlertView animateIntoView:self.view];
    } else {
        return;
    }
}


- (void) presentEULAViewController {

    self.eulaViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EULAViewController"];
    self.eulaViewController.delegate = self;
    
    [self presentViewController:eulaViewController animated:NO completion:nil];

    [eulaViewController EULALoaded];

}


- (void)eula:(EULAViewController *)eula didReceiveResponseFromUser:(EULAUserRespose)response {
    
    
    if (response == EULAAccepted) {
        [self updateEULATable];
        [self.eulaViewController dismissViewControllerAnimated:NO completion:nil];
    }
    else {
        
        [self.eulaViewController dismissViewControllerAnimated:NO completion:nil];
        
        SASAlertView *eulaDeclinedAlertView = [[SASAlertView alloc] initWithTarget:self andAction:nil];
        eulaDeclinedAlertView.title = @"NOTE";
        eulaDeclinedAlertView.message = @"You will only be able to upload if you accept the End User License Agreement.";
        eulaDeclinedAlertView.buttonTitle = @"Ok";
        
        [eulaDeclinedAlertView animateIntoView:self.view];
    }
    
}


-(void)updateEULATable {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    
    NSString *URL = @"http://www.saveaselfie.org/wp/wp-content/themes/magazine-child/updateEULA.php";
    [request setURL:[NSURL URLWithString:URL]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *parameters = [ NSString stringWithFormat:@"deviceID=%@&EULAType=EULA", [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[parameters length]];
    
    [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    plog(@"EULA URL: %@?%@", URL, parameters);
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection) {/* Silence the annoying unused variable warning :)*/ }
}






@end