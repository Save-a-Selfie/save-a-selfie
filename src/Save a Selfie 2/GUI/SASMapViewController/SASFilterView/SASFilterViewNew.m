//
//  SASFilterViewNew.m
//  Save a Selfie
//
//  Created by Stephen Fox on 27/09/2015.
//  Copyright © 2015 Stephen Fox. All rights reserved.
//

#import "SASFilterViewNew.h"
#import "SASFilterViewButton.h"
#import "SASDevice.h"
#import "Screen.h"


@interface SASFilterViewNew () {
    CGFloat buttonSpacing;
    
}

@property (strong, nonatomic) NSMutableArray *selectedItems;
@property (strong, nonatomic) NSMutableArray *unselectedItems;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (weak, nonatomic) SASMapView *referencedMapView;

@end



@implementation SASFilterViewNew

SASDeviceType filterableDevices[4] = {SASDeviceTypeDefibrillator,
                                      SASDeviceTypeLifeRing,
                                      SASDeviceTypeFirstAidKit,
                                      SASDeviceTypeFireHydrant
                                      };

- (instancetype)initWithPosition:(CGPoint) position forMapView:(SASMapView <Filterable>*) mapView {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.frame = CGRectMake(position.x, position.y, 45, 235);
    _referencedMapView = mapView;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor blackColor];
    
    return self;
}



- (void) presentIntoView:(UIView *) view {
    
    buttonSpacing = 55;

         if(!self.buttons) {
        
        
        int buttonCapacity = 4;
        self.buttons = [[NSMutableArray alloc] initWithCapacity:4];
        
        for (int i = 0; i < buttonCapacity; i++) {
            
            SASFilterButtonType buttonType = i; // use i to get Enum value.
            SASFilterViewButton *button = [[SASFilterViewButton alloc] initWithType:buttonType];
            button.frame = CGRectMake(0, self.frame.size.height - buttonSpacing, 45, 45);
            [button addTarget:self action:@selector(filterForDevice:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:button];
            [self.buttons addObject:button];

            buttonSpacing += 55;

        }
    }
    
    [view addSubview:self];
    [self animateToView];
}




- (void) animateToView {
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0);
    
    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 245);
                     }
                     completion:^(BOOL completed) {
                         _isInViewHierachy = YES;
                     }];

    
    
    
}



- (void) filterForDevice:(SASFilterViewButton *) sender {
    
    NSLog(@"%d (%@)", sender.deviceType, sender);
    
    switch (sender.deviceType) {
        case SASDeviceTypeDefibrillator:
            [self.referencedMapView filterMapForDevice:SASDeviceTypeDefibrillator];
            break;
            
        case SASDeviceTypeLifeRing:
            [self.referencedMapView filterMapForDevice:SASDeviceTypeLifeRing];
            break;
            
        case SASDeviceTypeFirstAidKit:
            [self.referencedMapView filterMapForDevice:SASDeviceTypeFirstAidKit];
            break;
            
        case SASDeviceTypeFireHydrant:
            [self.referencedMapView filterMapForDevice:SASDeviceTypeFireHydrant];
            break;
            
        default:
            break;
    }
}




#pragma mark - Helper methods.
- (UIImage *) imageForDevice:(SASDeviceType) type{
    return [SASDevice getDeviceImageForDeviceType:type];
}


- (UIImage *) unselectedImageForDevice: (SASDeviceType) type {
    return [SASDevice getUnselectedDeviceImageForDevice:type];
}



@end




