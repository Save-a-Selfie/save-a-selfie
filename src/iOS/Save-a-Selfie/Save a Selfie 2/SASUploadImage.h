//
//  SASUploadImage.h
//  Save a Selfie
//
//  Created by Stephen Fox on 09/06/2015.
//  Copyright (c) 2015 Stephen Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Device;

@interface SASUploadImage : UIImage

@property(nonatomic, weak) NSString *timeStamp;
@property(nonatomic, weak) Device *associatedDevice;

@end