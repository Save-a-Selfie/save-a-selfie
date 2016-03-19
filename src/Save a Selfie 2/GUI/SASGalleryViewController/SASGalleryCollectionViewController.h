//
//  SASGalleryCollectionViewControllerTest.h
//  Save a Selfie
//
//  Created by Stephen Fox on 10/08/2015.
//  Copyright (c) 2015 Stephen Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASGalleryControllerDataSourceProtocol.h"

@interface SASGalleryCollectionViewController : UICollectionViewController

@property (nonatomic, weak) id<SASGalleryControllerDataSource> dataSource;

@end
