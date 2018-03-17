//
//  AdMobUtil.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/08.
//  Copyright © 2016年 noboru. All rights reserved.
//

import GoogleMobileAds

class AdMobUtil {
    class func show(_ controller: UIViewController) {
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        var frame = bannerView.frame
        frame.origin.x = (controller.view.frame.size.width - frame.size.width) / 2
        frame.origin.y = controller.view.frame.size.height - frame.size.height
        bannerView.frame = frame

        bannerView.adUnitID = "a15122454742422"

        bannerView.rootViewController = controller
        controller.view.addSubview(bannerView)

        bannerView.load(GADRequest())
    }

    class func applyUnitId(bannerView: GADBannerView, controller: UIViewController) {
        bannerView.adUnitID = "a15122454742422"
        bannerView.rootViewController = controller
        bannerView.load(GADRequest())
    }
}
