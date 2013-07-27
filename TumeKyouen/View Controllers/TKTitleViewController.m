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

#import "TKTitleViewController.h"
#import "TKKyouenViewController.h"
#import "TKTumeKyouenDao.h"
#import "TKSettingDao.h"
#import "AdMobUtil.h"
#import "TKTwitterManager.h"

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshTwitterAccounts];
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
    LOG(@"connectTwitterAction");
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (ACAccount *acct in _accounts) {
        [sheet addButtonWithTitle:acct.username];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        LOG(@"buttonIndex=%d", buttonIndex);
        [_twitterManager performReverseAuthForAccount:_accounts[buttonIndex] withHandler:^(NSData *responseData, NSError *error) {
            if (responseData) {
                NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

                NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                NSString *lined = [parts componentsJoinedByString:@"\n"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:lined delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
            }
            else {
                // TODO Reverse Auth process failed.
                LOG(@"Reverse Auth process failed.");
            }
        }];
    }
}

#pragma mark - Private

- (void)refreshTwitterAccounts
{
    
    if (![TKTwitterManager isLocalTwitterAccountAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title" message:@"no account" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    // TODO ?
                    //                    _reverseAuthBtn.enabled = YES;
                } else {
                    // 設定画面にてTwitter連携がされていない
                    // TODO Twitterでログインボタンをdisableにする？
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title" message:@"perm access" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            });
        }];
    }
}

- (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
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

@end
