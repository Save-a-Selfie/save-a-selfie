//
//  AppUserDefaults.h
//  Save a Selfie
//
//  Created by Stephen Fox on 28/02/2016.
//  Copyright © 2016 Stephen Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SASAppUserDefaults : NSObject



+ (void) addValueForEULAAccepted:(NSString*) value;

+ (NSString *) getValueForEULAAccepted;


+ (void) addUserToken:(NSString*) token;

+ (NSString*) userToken;

@end