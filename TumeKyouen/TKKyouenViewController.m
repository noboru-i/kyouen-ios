//
//  KyouenViewController.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/17.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TKKyouenViewController.h"
#import "TKTumeKyouenDao.h"

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
    [self setStage:currentModel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark actions

- (IBAction)moveNextStage:(id)sender
{
    NSNumber *nextStageNo = @([currentModel.stageNo intValue] + 1);
    [self moveStage:nextStageNo];
}

- (IBAction)movePrevStage:(id)sender
{
    NSNumber *nextStageNo = @([currentModel.stageNo intValue] - 1);
    [self moveStage:nextStageNo];
}

- (IBAction)checkKyouen:(id)sender
{
}


#pragma mark -
#pragma mark private methods

- (void)moveStage:(NSNumber *)stageNo
{
    TKTumeKyouenDao *dao = [[TKTumeKyouenDao alloc] init];
    TumeKyouenModel *model = [dao selectByStageNo:stageNo];
    [self setStage:model];
}

- (void)setStage:(TumeKyouenModel *)model
{
    self.currentModel = model;
    [self.mStageNo setText:[NSString stringWithFormat:@"STAGE:%@", self.currentModel.stageNo]];
    [self.mCreator setText:[NSString stringWithFormat:@"created by %@", self.currentModel.creator]];
    [self.mKyouenImageView setStage:currentModel];
}

@end
