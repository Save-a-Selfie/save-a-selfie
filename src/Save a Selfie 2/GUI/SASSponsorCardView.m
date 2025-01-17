//
//  SASSponsorCardView.m
//  Save a Selfie
//
//  Created by Stephen Fox on 12/08/2015.
//  Copyright (c) 2015 Stephen Fox. All rights reserved.
//

#import "SASSponsorCardView.h"
#import "UIView+NibInitializer.h"
#import "UIFont+SASFont.h"


@interface SASSponsorCardView()


@property (weak, nonatomic) IBOutlet UITextView *infoTextView;


@end

@implementation SASSponsorCardView

- (instancetype) init {
    if(self = [super init]) {
        self = [self initWithNibNamed:@"SASSponsorCardView"];
        self.layer.cornerRadius = 4.0;
        _button.layer.cornerRadius = 4.0;
        _infoTextView.selectable = NO;
        _imageView.center = self.center;
        
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(-2, 5);
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
    }
    return self;
}


- (void)setInfo:(NSString *)info {
    self.infoTextView.text = info;
}


- (IBAction)moreButtonPress:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.website]];
}

@end
