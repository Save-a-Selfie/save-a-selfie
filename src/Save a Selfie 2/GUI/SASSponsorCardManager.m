//
//  SASSponsorCardController.m
//  Save a Selfie
//
//  Created by Stephen Fox on 13/08/2015.
//  Copyright (c) 2015 Stephen Fox. All rights reserved.
//

#import "SASSponsorCardManager.h"

@implementation SASSponsorCardManager

+ (NSArray *) allCards {
    
    
    SASSponsorCardView *saveSelfie = [[SASSponsorCardView alloc] init];
    saveSelfie.titleLabel.text = @"Save A Selfie";
    saveSelfie.imageView.image = [UIImage imageNamed:@"SaveASelfieLogo"];
    saveSelfie.button.titleLabel.text = @"See website";
    saveSelfie.info = @"Your smile can save a life!";
    saveSelfie.website = @"www.saveaselfie.org";
    
    SASSponsorCardView *orderOfMalta = [[SASSponsorCardView alloc] init];
    orderOfMalta.titleLabel.text = @"Order of Malta";
    orderOfMalta.imageView.image = [UIImage imageNamed:@"Order of Malta 70px high"];
    orderOfMalta.button.titleLabel.text = @"See website";
    orderOfMalta.info = @"Saving lifes, Touching lifes, Changing lifes!";
    orderOfMalta.website = @"http://www.orderofmaltaireland.org/";
    
    
    SASSponsorCardView *fireBrigade = [[SASSponsorCardView alloc] init];
    fireBrigade.titleLabel.text = @"Dublin Fire Brigade";
    fireBrigade.imageView.image = [UIImage imageNamed:@"dublin fire brigade 300"];
    fireBrigade.button.titleLabel.text = @"See website";
    fireBrigade.info = @"Serving Dublin for over 150 years!";
    fireBrigade.website = @"http://www.dfbexternaltraining.ie/";
    

    SASSponsorCardView *codeForIreland = [[SASSponsorCardView alloc] init];
    codeForIreland.titleLabel.text = @"Code For Ireland";
    codeForIreland.imageView.image = [UIImage imageNamed:@"Code for ireland logo"];
    codeForIreland.button.titleLabel.text = @"See website";
    codeForIreland.info = @"Building, creating, empowering through technology!";
    codeForIreland.website = @"http://codeforireland.com/";
    
    SASSponsorCardView *adamsGift = [[SASSponsorCardView alloc] init];
    adamsGift.titleLabel.text = @"Adams Gift";
    adamsGift.imageView.image = [UIImage imageNamed:@"AdamsGift"];
    adamsGift.button.titleLabel.text = @"See website";
    adamsGift.info = @"Saving lives through awareness and education!";
    adamsGift.website = @"https://www.facebook.com/pages/Adams-Gift/334232113442348?fref=ts";
    
    SASSponsorCardView *emergencyCare = [[SASSponsorCardView alloc] init];
    emergencyCare.titleLabel.text = @"Emergency Care";
    emergencyCare.imageView.image = [UIImage imageNamed:@"ecplogo"];
    emergencyCare.button.titleLabel.text = @"See website";
    emergencyCare.info = @"Providing a high level of customer service and excellent quality products";
    emergencyCare.website = @"www.emergencycare.ie";
    

    
    
    
    
    NSArray *cardViews = [[NSArray alloc] initWithObjects: saveSelfie, orderOfMalta, fireBrigade, codeForIreland, adamsGift, emergencyCare, nil];
    return cardViews;

}


+ (NSUInteger)sponsorAmount {
    return 6;
}


@end
