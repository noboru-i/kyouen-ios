//
//  ViewController.m
//  Kyouen
//
//  Created by 石倉 昇 on 2013/02/17.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TKTitleViewController.h"
#import "TKKyouenViewController.h"
#import "TKTumeKyouenDao.h"
#import "TKSettingDao.h"
#import "AdMobUtil.h"

@interface TKTitleViewController ()

@end

@implementation TKTitleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 背景色の描画
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor darkGrayColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    // AdMob
    [AdMobUtil show:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"StartSegue"]) {
        // TODO 前回終了時のステージ番号を渡す
        TKSettingDao *settingDao = [[TKSettingDao alloc] init];
        NSNumber *stageNo = [settingDao loadStageNo];
        TKTumeKyouenDao *dao = [[TKTumeKyouenDao alloc] init];
        TumeKyouenModel *model = [dao selectByStageNo:stageNo];

        TKKyouenViewController *viewController = (TKKyouenViewController*)[segue destinationViewController];
        viewController.currentModel = model;
    }
}

@end
