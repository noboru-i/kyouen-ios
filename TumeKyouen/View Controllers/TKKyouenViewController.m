//
//  KyouenViewController.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/02/17.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <SVProgressHUD.h>

#import "TKKyouenViewController.h"
#import "KyouenImageView.h"
#import "TKOverlayKyouenView.h"
#import "TKTumeKyouenDao.h"
#import "TKSettingDao.h"
#import "TKGameModel.h"
#import "TKKyouenData.h"
#import "TKLine.h"
#import "TKTumeKyouenServer.h"
#import "AdMobUtil.h"

@interface TKKyouenViewController ()

@end

typedef NS_ENUM(NSInteger, TKAlertTag) {
    TKAlertTagKyouen,
    TKAlertTagStageSelect
};

@implementation TKKyouenViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 背景色の描画
    CAGradientLayer* gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors =
        [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor],
                                  (id)[[UIColor darkGrayColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];

    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.width >= 320.0 && screenSize.height >= 568.0) {
        // 4インチの場合
        // AdMob
        [AdMobUtil show:self];
    }

    // 初期化
    [self setStage:self.currentModel to:self.mKyouenImageView1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark actions

- (IBAction)moveNextStage:(id)sender {
    NSNumber* nextStageNo = @([self.currentModel.stageNo intValue] + 1);
    [self moveStage:nextStageNo direction:1];
}

- (IBAction)movePrevStage:(id)sender {
    NSNumber* nextStageNo = @([self.currentModel.stageNo intValue] - 1);
    [self moveStage:nextStageNo direction:-1];
}

- (IBAction)checkKyouen:(id)sender {
    LOG_METHOD;
    TKGameModel* model = [[TKGameModel alloc]
        initWithSize:[self.currentModel.size intValue]
               stage:[self.mKyouenImageView1 getCurrentStage]];
    // 4つ選択されているかのチェック
    LOG(@"count = %d", [model getStoneCount:2]);
    if ([model getStoneCount:2] != 4) {
        UIAlertView* alert = [[UIAlertView alloc]
                initWithTitle:NSLocalizedString(@"alert_less_stone", nil)
                      message:nil
                     delegate:nil
            cancelButtonTitle:nil
            otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }

    // 共円のチェック
    TKKyouenData* kyouenData = [model isKyouen];
    if (kyouenData == nil) {
        [self setStage:self.currentModel to:self.mKyouenImageView1];
        UIAlertView* alert = [[UIAlertView alloc]
                initWithTitle:NSLocalizedString(@"alert_not_kyouen", nil)
                      message:nil
                     delegate:nil
            cancelButtonTitle:nil
            otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }

    // 共円の場合
    TKTumeKyouenDao* dao = [[TKTumeKyouenDao alloc] init];
    [dao updateClearFlag:self.currentModel date:nil];
    [self.mStageNo
        setTextColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1]];
    [self.mOverlayKyouenView drawKyouen:kyouenData
                        tumeKyouenModel:self.currentModel];
    self.mOverlayKyouenView.layer.zPosition = 3;
    UIAlertView* alert =
        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kyouen", nil)
                                   message:nil
                                  delegate:self
                         cancelButtonTitle:nil
                         otherButtonTitles:@"Next", nil];
    alert.tag = TKAlertTagKyouen;
    [alert show];

    // クリアデータの送信
    TKTumeKyouenServer* server = [[TKTumeKyouenServer alloc] init];
    [server addStageUser:self.currentModel.stageNo];
}

- (IBAction)selectStage:(id)sender {
    TKTumeKyouenDao* dao = [[TKTumeKyouenDao alloc] init];
    NSUInteger maxStageNo = [dao selectCount];
    NSString* title = [NSString
        stringWithFormat:NSLocalizedString(@"dialog_title_stage_select", nil),
                         1, maxStageNo];
    UIAlertView* message = [[UIAlertView alloc]
            initWithTitle:title
                  message:nil
                 delegate:self
        cancelButtonTitle:@"Cancel"
        otherButtonTitles:NSLocalizedString(@"dialog_select", nil), nil];
    message.tag = TKAlertTagStageSelect;
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [message textFieldAtIndex:0].keyboardType =
        UIKeyboardTypeNumbersAndPunctuation;
    [message show];
}

#pragma mark -
#pragma mark delegate

- (void)alertView:(UIAlertView*)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case TKAlertTagKyouen: {
            NSNumber* nextStageNo = @([self.currentModel.stageNo intValue] + 1);
            [self moveStage:nextStageNo direction:1];
        } break;
        case TKAlertTagStageSelect: {
            if (buttonIndex == 0) {
                // キャンセルボタンは処理をスキップ
                break;
            }
            NSString* inputText = [[alertView textFieldAtIndex:0] text];
            NSNumber* nextStageNo =
                [NSNumber numberWithInt:[inputText intValue]];
            if (nextStageNo == 0) {
                break;
            }
            LOG(@"nextStageNo = %@", nextStageNo);
            TKTumeKyouenDao* dao = [[TKTumeKyouenDao alloc] init];
            TumeKyouenModel* model = [dao selectByStageNo:nextStageNo];
            if (model == nil) {
                // 取得できなかった場合は終了
                break;
            }
            [self moveStage:nextStageNo direction:1];
        } break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark private methods

- (void)moveStage:(NSNumber*)stageNo direction:(int)direction {
    LOG(@"moveStage");
    TKTumeKyouenDao* dao = [[TKTumeKyouenDao alloc] init];
    TumeKyouenModel* model = [dao selectByStageNo:stageNo];
    if (model == nil) {
        // 取得できなかった場合の処理

        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];

        TKTumeKyouenServer* server = [[TKTumeKyouenServer alloc] init];
        [server getStageData:([stageNo intValue] - 1)
                    callback:^(NSString* result, NSError* error) {
                      LOG(@"callback");
                      LOG(@"%@", result);
                      if (error != nil || result == nil ||
                          [result length] == 0) {
                          // 取得できなかった
                          [SVProgressHUD dismiss];
                          return;
                      }
                      if ([result isEqualToString:@"no_data"]) {
                          // データなし
                          [SVProgressHUD dismiss];
                          return;
                      }

                      // データの登録
                      TKTumeKyouenDao* dao = [[TKTumeKyouenDao alloc] init];
                      if (![dao insertWithCsvString:result]) {
                          // エラー発生時
                      }
                      [SVProgressHUD dismiss];

                      // ステージの移動
                      [self moveStage:stageNo direction:direction];
                    }];

        return;
    }
    [self setStageWithAnimation:model direction:direction];

    // 表示したステージ番号を保存
    TKSettingDao* settingDao = [[TKSettingDao alloc] init];
    [settingDao saveStageNo:model.stageNo];
}

- (void)setStageWithAnimation:(TumeKyouenModel*)model direction:(int)direction {
    LOG(@"setStageWithAnimation");
    KyouenImageView* currentImageView = self.mKyouenImageView1;
    KyouenImageView* nextImageView = self.mKyouenImageView2;
    nextImageView.alpha = 1.0f;
    [self setStage:model to:nextImageView];

    // 移動ボタンを無効化
    [self.mPrevButton setEnabled:NO];
    [self.mNextButton setEnabled:NO];

    // 次に表示するViewを画面外に用意
    CGRect frame = [currentImageView frame];
    CGFloat origX = frame.origin.x;
    frame.origin.x = origX + direction * 320;
    [nextImageView setFrame:frame];
    currentImageView.layer.zPosition = 1;
    nextImageView.layer.zPosition = 2;

    // 2つのImageViewを移動
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endSetStageAnimation)];
    [UIView setAnimationDuration:0.4];
    currentImageView.alpha = 0.0f;
    frame.origin.x = origX;
    [nextImageView setFrame:frame];
    [UIView commitAnimations];

    self.mKyouenImageView1 = nextImageView;
    self.mKyouenImageView2 = currentImageView;
}

- (void)setStage:(TumeKyouenModel*)model to:(KyouenImageView*)imageView {
    LOG(@"setStage");

    // 移動ボタンを無効化
    [self.mPrevButton setEnabled:NO];
    [self.mNextButton setEnabled:NO];

    self.currentModel = model;
    if ([self.currentModel.clearFlag isEqualToNumber:@1]) {
        [self.mStageNo
            setTextColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1]];
    } else {
        [self.mStageNo setTextColor:[UIColor whiteColor]];
    }
    [self.mStageNo
        setText:[NSString
                    stringWithFormat:@"STAGE:%@", self.currentModel.stageNo]];
    [self.mCreator
        setText:[NSString stringWithFormat:@"created by %@",
                                           self.currentModel.creator]];
    [imageView setStage:self.currentModel];

    self.mOverlayKyouenView.alpha = 0;

    [self endSetStageAnimation];
}

- (void)endSetStageAnimation
{
    LOG(@"stageNo = %@", self.currentModel.stageNo);
    if (![self.currentModel.stageNo isEqual:@1]) {
        // ステージ１の場合は戻れない
        [self.mPrevButton setEnabled:YES];
    }
    // 移動ボタンを有効化
    [self.mNextButton setEnabled:YES];
}

@end
