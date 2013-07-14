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
#import "TKOverlayKyouenView.h"
#import "TKTumeKyouenDao.h"
#import "TKGameModel.h"
#import "TKKyouenData.h"
#import "TKLine.h"
#import "TKTumeKyouenServer.h"

@interface TKKyouenViewController ()

@end

typedef NS_ENUM(NSInteger, TKAlertTag)
{
    TKAlertTagKyouen
};

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
    TKGameModel *model = [[TKGameModel alloc] initWithSize:[self.currentModel.size intValue]
                                                     stage:[self.mKyouenImageView1 getCurrentStage]];
    // 4つ選択されているかのチェック
    if ([model getStoneCount:2] != 4) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"4つの石を選択してください"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    // 共円のチェック
    TKKyouenData *kyouenData = [model isKyouen];
    if (kyouenData == nil) {
        [self setStage:currentModel to:self.mKyouenImageView1];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"共円ではありません"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    // 共円の場合
    TKTumeKyouenDao *dao = [[TKTumeKyouenDao alloc] init];
    [dao updateClearFlag:currentModel date:nil];
    [self.mStageNo setTextColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1]];
    [self.mOverlayKyouenView drawKyouen:kyouenData tumeKyouenModel:self.currentModel];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"共円！！"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Next", nil];
    alert.tag = TKAlertTagKyouen;
    [alert show];
}


#pragma mark -
#pragma mark delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case TKAlertTagKyouen:
        {
            NSNumber *nextStageNo = @([currentModel.stageNo intValue] + 1);
            [self moveStage:nextStageNo
                  direction:1];
        }
            break;
        default:
            break;
    }
}


#pragma mark -
#pragma mark private methods

- (void)moveStage:(NSNumber *)stageNo direction:(int)direction
{
    LOG(@"moveStage");
    TKTumeKyouenDao *dao = [[TKTumeKyouenDao alloc] init];
    TumeKyouenModel *model = [dao selectByStageNo:stageNo];
    if (model == nil) {
        // 取得できなかった場合の処理
        [self.mIndicator setAlpha:1];
        [self.mIndicator startAnimating];

        TKTumeKyouenServer *server = [[TKTumeKyouenServer alloc] init];
        [server getStageData:([stageNo intValue] -1) callback:^(NSString *result) {
            LOG(@"callback");
            LOG(@"%@", result);
            if (result == nil || [result length] == 0) {
                // 取得できなかった
                [self.mIndicator setAlpha:0];
                [self.mIndicator stopAnimating];
                return;
            }
            if ([result isEqualToString:@"no_data"]) {
                // データなし
                [self.mIndicator setAlpha:0];
                [self.mIndicator stopAnimating];
                return;
            }

            // データの登録
            TKTumeKyouenDao *dao = [[TKTumeKyouenDao alloc] init];
            NSArray *lines = [result componentsSeparatedByString:@"\n"];
            for (NSString *line in lines) {
                if (![dao insertWithCsvString:line]) {
                    // エラー発生時
                    break;
                }
            }
            [self.mIndicator setAlpha:0];
            [self.mIndicator stopAnimating];

            // ステージの移動
            [self moveStage:stageNo direction:direction];
        }];

        return;
    }
    [self setStageWithAnimation:model direction:direction];
}

- (void)setStageWithAnimation:(TumeKyouenModel *)model direction:(int)direction
{
    LOG(@"setStageWithAnimation");
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

- (void)setStage:(TumeKyouenModel *)model to:(KyouenImageView *)imageView
{
    LOG(@"setStage");
    self.currentModel = model;
    if ([self.currentModel.clearFlag isEqualToNumber:@1]) {
        [self.mStageNo setTextColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1]];
    } else {
        [self.mStageNo setTextColor:[UIColor whiteColor]];
    }
    [self.mStageNo setText:[NSString stringWithFormat:@"STAGE:%@", self.currentModel.stageNo]];
    [self.mCreator setText:[NSString stringWithFormat:@"created by %@", self.currentModel.creator]];
    [imageView setStage:currentModel];
    
    self.mOverlayKyouenView.alpha = 0;
}

- (void)endSetStageAnimation
{
    // 移動ボタンを有効化
    [self.mPrevButton setEnabled:YES];
    [self.mNextButton setEnabled:YES];
}

@end
