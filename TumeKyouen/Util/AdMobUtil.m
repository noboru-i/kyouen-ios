//
//  AdMobUtil.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/20.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "AdMobUtil.h"

@implementation AdMobUtil

+ (void) show:(UIViewController *) controller {
    
    // 画面下部に標準サイズのビューを作成する
    GADBannerView* bannerView = [[GADBannerView alloc]
                   initWithFrame:CGRectMake(0.0,
                                            controller.view.frame.size.height
                                            - GAD_SIZE_320x50.height,
                                            GAD_SIZE_320x50.width,
                                            GAD_SIZE_320x50.height)];
    
    // 広告の「ユニット ID」を指定する。これは AdMob パブリッシャー ID です。
    bannerView.adUnitID = MY_BANNER_UNIT_ID;
    
    // ユーザーに広告を表示した場所に後で復元する UIViewController をランタイムに知らせて
    // ビュー階層に追加する。
    bannerView.rootViewController = controller;
    [controller.view addSubview:bannerView];
    
    // 一般的なリクエストを行って広告を読み込む。
    GADRequest *request =[GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
    [bannerView loadRequest:request];
}

@end
