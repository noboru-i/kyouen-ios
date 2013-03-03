//
//  KyouenViewController.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/17.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TKKyouenViewController.h"

@interface TKKyouenViewController ()

@end

@implementation TKKyouenViewController

@synthesize currentModel;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 背景色の描画
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor darkGrayColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    // 初期化
    [self.mStageNo setText:[NSString stringWithFormat:@"STAGE:%@", self.currentModel.stageNo]];
    [self.mCreator setText:[NSString stringWithFormat:@"created by %@", self.currentModel.creator]];
    [self.mKyouenImageView setStage:currentModel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
