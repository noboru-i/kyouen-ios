//
//  ViewController.m
//  Kyouen
//
//  Created by 石倉 昇 on 2013/02/17.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <SVProgressHUD.h>

#import "TKTitleViewController.h"
#import "TKKyouenViewController.h"
#import "TKTumeKyouenDao.h"
#import "TKSettingDao.h"
#import "TKTwitterTokenDao.h"
#import "AdMobUtil.h"
#import "TKTwitterManager.h"
#import "TKTumeKyouenServer.h"

@interface TKTitleViewController ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TKTwitterManager *twitterManager;
@property (nonatomic, strong) NSArray *accounts;

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

    _twitterManager = [[TKTwitterManager alloc] init];

    [self sendTwitterAccount];
}

- (void)viewWillAppear:(BOOL)animated
{
    LOG_METHOD;
    [super viewWillAppear:animated];
    [self refreshCounts];
    // 通知を設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

// UIApplicationDidBecomeActiveNotification にて呼び出される
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    LOG_METHOD;
    [self refreshTwitterAccounts];
}

-(void)viewWillDisappear:(BOOL)animated
{
    LOG_METHOD;
    [super viewWillDisappear:animated];
    //通知を終了
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"StartSegue"]) {
        // 前回終了時のステージ番号を渡す
        TKSettingDao *settingDao = [[TKSettingDao alloc] init];
        NSNumber *stageNo = [settingDao loadStageNo];
        TKTumeKyouenDao *dao = [[TKTumeKyouenDao alloc] init];
        TumeKyouenModel *model = [dao selectByStageNo:stageNo];
        
        TKKyouenViewController *viewController = (TKKyouenViewController*)[segue destinationViewController];
        viewController.currentModel = model;
    }
}

- (IBAction)connectTwitterAction:(id)sender {
    LOG_METHOD;
    if ([self.accounts count] == 0) {
        // アカウントが設定されていない場合
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"alert_no_twitter_account", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    NSString *title = NSLocalizedString(@"action_title_choose", nil);
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (ACAccount *acct in self.accounts) {
        [sheet addButtonWithTitle:acct.username];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:self.view];
}

- (IBAction)syncDataAction:(id)sender {
    LOG_METHOD;
    TKTumeKyouenDao *dao = [[TKTumeKyouenDao alloc] init];
    NSArray *stages = [dao selectAllClearStage];

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    TKTumeKyouenServer *server = [[TKTumeKyouenServer alloc] init];
    [server addAllStageUser:stages callback:^(NSArray *response) {
        LOG_METHOD;
        [dao updateSyncClearData:response];
        [self refreshCounts];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"progress_sync_complete", nil)];
    }];
}

- (IBAction)getStages:(id)sender
{
    LOG_METHOD;

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];

    TKTumeKyouenDao *dao = [[TKTumeKyouenDao alloc] init];
    int stageCount = [dao selectCount];
    TKTumeKyouenServer *server = [[TKTumeKyouenServer alloc] init];
    [self getStage:stageCount server:server kyouenDao:dao];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        LOG(@"buttonIndex=%d", buttonIndex);

        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        [self.twitterManager performReverseAuthForAccount:self.accounts[buttonIndex] withHandler:^(NSData *responseData, NSError *error) {
            if (!responseData) {
                LOG(@"Reverse Auth process failed.");
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"progress_auth_fail", nil)];
                return;
            }

            // 認証情報を送信
            [self sendTwitterAccount];
        }];
    }
}

#pragma mark - Private

- (void)refreshTwitterAccounts
{
    LOG_METHOD;
    if (![TKTwitterManager isLocalTwitterAccountAvailable]) {
        // TODO twitterアカウントが設定されていない
    }
    else {
        [self obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                } else {
                    // 設定画面にてTwitter連携がされていない
                    // TODO Twitterでログインボタンをdisableにする？
                }
            });
        }];
    }
}

- (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    LOG_METHOD;
    _accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [_accountStore accountsWithAccountType:twitterType];
        }
        
        block(granted);
    };
    
    [_accountStore requestAccessToAccountsWithType:twitterType options:nil completion:handler];
}

- (void)refreshCounts
{
    // ステージ番号の描画
    TKTumeKyouenDao *dao = [[TKTumeKyouenDao alloc] init];
    NSUInteger clearCount = [dao selectCountClearStage];
    NSUInteger allCount = [dao selectCount];
    self.stageCountLabel.text = [NSString stringWithFormat:@"%d/%d", clearCount, allCount];
}

- (void)getStage:(int)maxStageNo server:(TKTumeKyouenServer *)server kyouenDao:(TKTumeKyouenDao *)dao
{
    LOG_METHOD;
    [server getStageData:(maxStageNo -1) callback:^(NSString *result, NSError *error) {
        if (error != nil) {
            // 取得できなかった
            [self refreshCounts];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        if (result == nil || [result length] == 0) {
            // 取得できなかった
            [self refreshCounts];
            [SVProgressHUD dismiss];
            return;
        }
        if ([result isEqualToString:@"no_data"]) {
            // データなし
            [self refreshCounts];
            [SVProgressHUD dismiss];
            return;
        }

        // データの登録
        NSArray *lines = [result componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            if (![dao insertWithCsvString:line]) {
                // エラー発生時
                break;
            }
        }
        [self refreshCounts];
        [self getStage:(maxStageNo + [lines count]) server:server kyouenDao:dao];
    }];
}

- (void)sendTwitterAccount
{
    // 認証情報を送信
    TKTwitterTokenDao *dao = [[TKTwitterTokenDao alloc] init];
    NSString *oauthToken = [dao getOauthToken];
    NSString *oauthTokenSecret = [dao getOauthTokenSecret];
    if (oauthToken == nil || oauthTokenSecret == nil) {
        [SVProgressHUD dismiss];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    TKTumeKyouenServer *server = [[TKTumeKyouenServer alloc] init];
    [server registUser:oauthToken tokenSecret:oauthTokenSecret callback:^(NSString *response, NSError *error) {
        if (error != nil) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"progress_auth_fail", nil)];
            return;
        }
        LOG(@"response = %@", response);
        [self.twitterButton setHidden:YES];
        [self.syncButton setHidden:NO];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"progress_auth_success", nil)];
    }];
}

@end
