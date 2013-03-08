//
//  KyouenViewController.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/17.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TKKyouenViewController.h"
#import "KyouenImageView.h"
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
    [self setStage:currentModel to:self.mKyouenImageView1];
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
    [self moveStage:nextStageNo
          direction:1];
}

- (IBAction)movePrevStage:(id)sender
{
    NSNumber *nextStageNo = @([currentModel.stageNo intValue] - 1);
    [self moveStage:nextStageNo
          direction:-1];
}

- (IBAction)checkKyouen:(id)sender
{
    // TODO
    LOG(@"stage = %@", [self.mKyouenImageView1 getCurrentStage]);
}


#pragma mark -
#pragma mark private methods

- (void)moveStage:(NSNumber *)stageNo direction:(int)direction
{
    TKTumeKyouenDao *dao = [[TKTumeKyouenDao alloc] init];
    TumeKyouenModel *model = [dao selectByStageNo:stageNo];
    [self setStageWithAnimation:model direction:direction];
}

- (void)setStage:(TumeKyouenModel *)model to:(KyouenImageView *)imageView
{
    self.currentModel = model;
    [self.mStageNo setText:[NSString stringWithFormat:@"STAGE:%@", self.currentModel.stageNo]];
    [self.mCreator setText:[NSString stringWithFormat:@"created by %@", self.currentModel.creator]];
    [imageView setStage:currentModel];
}

- (void)setStageWithAnimation:(TumeKyouenModel *)model direction:(int)direction
{
    KyouenImageView *currentImageView = self.mKyouenImageView1;
    KyouenImageView *nextImageView = self.mKyouenImageView2;
    [self setStage:model
                to:nextImageView];

    // 移動ボタンを無効化
    [self.mPrevButton setEnabled:NO];
    [self.mNextButton setEnabled:NO];

    // 次に表示するViewを画面外に用意
    CGRect frame = [currentImageView frame];
    CGFloat origX = frame.origin.x;
    frame.origin.x = origX + direction * 320;
    [nextImageView setFrame:frame];

    // 2つのImageViewを移動
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endSetStageAnimation)];
    [UIView setAnimationDuration:0.4];
    frame.origin.x = origX - direction * 320;
    [currentImageView setFrame:frame];
    frame.origin.x = origX;
    [nextImageView setFrame:frame];
    [UIView commitAnimations];
    
    self.mKyouenImageView1 = nextImageView;
    self.mKyouenImageView2 = currentImageView;
}

- (void)endSetStageAnimation
{
    // 移動ボタンを有効化
    [self.mPrevButton setEnabled:YES];
    [self.mNextButton setEnabled:YES];
}

@end
