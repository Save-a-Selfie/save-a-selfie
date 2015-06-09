//
//  SASAnnotation.m
//

#import "SASAnnotation.h"
#import "ExtendNSLogFunctionality.h"
#import "AppDelegate.h"
#import "Device.h"


@interface SASAnnotation()


@end

@implementation SASAnnotation


- (instancetype) initAnnotationWithDevice:(Device*) device index:(int) deviceNumber {
    if (self = [super init]) {
        
        _name = [Device deviceNames][device.type];
        _coordinate = device.deviceLocation;
        _image = (UIImage*)[Device deviceImages][device.type];
        _device = device;
        _index = deviceNumber;

    }
    return self;
}



- (NSString *)title {
    return _name;
}

- (Device *)device { return _device; }
- (int)index { return _index; }
- (UIImage *)image { return _image; }
- (NSString *)subtitle { return _address; }


- (void)dealloc {
    _name = nil;
    _address = nil;
    _image = nil;
}

@end