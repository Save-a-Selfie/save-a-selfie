//
//  SASNetworkQuery.h
//  Save a Selfie
//
//  Created by Stephen Fox on 29/01/2016.
//  Copyright © 2016 Stephen Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSUInteger, SASNetworkQueryType) {
  SASNetworkQueryTypeAll,
  SASNetworkQueryTypeClosest, // The closest devices to the user.
  SASNetworkQueryImageDownload // A images download query.
};

/**
 An object that encapsulate some way of 
 requesting information from the server.
*/
@interface SASNetworkQuery : NSObject

@property (nonatomic, assign) SASNetworkQueryType type;


/**
 Returns a new instance of SASNetworkQuery for a specific query
 type.
 */
+ (SASNetworkQuery*) queryWithType: (SASNetworkQueryType) type;


/**
 This MUST be set when creating a query of type SASNetworkQeuryClosest.
 Otherwise there will be no way of knowing the current location of the user.
 
 @param coordinates The coordinates to be used in the query.
 */
- (void) setLocationArguments:(CLLocationCoordinate2D) coordinates;


/**
 Sets a collection of image paths to use for downloading.
*/
- (void)setImagesPaths:(NSArray<NSString *> *)imagesPaths;

- (NSArray<NSString*>*) imagePaths;

/**
 The coordinates for a query.
 */
- (CLLocationCoordinate2D) coordinates;
@end
