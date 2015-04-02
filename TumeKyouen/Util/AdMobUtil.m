//
//  AdMobUtil.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/20.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "AdMobUtil.h"

@import GoogleMobileAds;

@implementation AdMobUtil

+ (void)show:(UIViewController*)controller {
    GADBannerView* bannerView =
        [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    CGRect frame = bannerView.frame;
    frame.origin.y = controller.view.frame.size.height - frame.size.height;
    frame.origin.x = (controller.view.frame.size.width - frame.size.width) / 2;
    bannerView.frame = frame;

    bannerView.adUnitID = MY_BANNER_UNIT_ID;

    bannerView.rootViewController = controller;
    [controller.view addSubview:bannerView];

    [bannerView loadRequest:[GADRequest request]];
}

@end
