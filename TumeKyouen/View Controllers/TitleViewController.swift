//
//  KyouenViewController.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/09.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit
import QuartzCore
import Accounts
import SVProgressHUD

class TitleViewController: UIViewController {
    @IBOutlet private weak var twitterButton: UIButton!
    @IBOutlet private weak var syncButton: UIButton!
    @IBOutlet private weak var stageCountLabel: UILabel!

    var accountStore: ACAccountStore! = nil
    let twitterManager = TwitterManager()
    var accounts = [ACAccount]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景色の描画
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor.blackColor().CGColor,
            UIColor.darkGrayColor().CGColor
        ]
        view.layer.insertSublayer(gradient, atIndex: 0)

        // AdMob
        AdMobUtil.show(self)

        sendTwitterAccount()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshCounts()
        refreshTwitterAccounts()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StartSegue" {
            // 前回終了時のステージ番号を渡す
            let stageNo = SettingDao().loadStageNo()
            let model = TumeKyouenDao().selectByStageNo(stageNo)
            if let vc = segue.destinationViewController as? KyouenViewController {
                vc.currentModel = model
            }
        }
    }

    @IBAction private func connectTwitterAction(_: AnyObject) {
        if accounts.count == 0 {
            let alert = UIAlertController.alert("alert_no_twitter_account")
            presentViewController(alert, animated: true, completion: nil)
            return
        }

        let title = NSLocalizedString("action_title_choose", comment: "")
        let sheet = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        let handler = { (action: UIAlertAction) -> Void in
            let index = sheet.actions.indexOf(action)!
            SVProgressHUD.show()
            self.twitterManager.performReverseAuthForAccount(self.accounts[index], withHandler: {responseData, error in
                if responseData == nil {
                    SVProgressHUD.showErrorWithStatus(NSLocalizedString("progress_auth_fail", comment: ""))
                    return
                }

                // 認証情報を送信
                self.sendTwitterAccount()
            })

        }
        for acct in accounts {
            sheet.addAction(UIAlertAction(title: acct.username, style: .Default, handler: handler))
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(sheet, animated: true, completion: nil)
    }

    @IBAction private func syncDataAction(_: AnyObject) {
        let stages = TumeKyouenDao().selectAllClearStage()

        SVProgressHUD.show()
        TumeKyouenServer().addAllStageUser(stages, callback: {response, error in
            if error != nil {
                // 通信が異常終了
                SVProgressHUD.showErrorWithStatus(error.localizedDescription)
            }
            var responseData = [NSDictionary]()
            for item in response {
                if let dic = item as? NSDictionary {
                    responseData.append(dic)
                }
            }
            TumeKyouenDao().updateSyncClearData(responseData)
            self.refreshCounts()
            SVProgressHUD.showSuccessWithStatus(NSLocalizedString("progress_sync_complete", comment: ""))
        })
    }

    @IBAction private func getStages(_: AnyObject) {
        SVProgressHUD.show()

        let stageCount = TumeKyouenDao().selectCount()
        getStage(stageCount)
    }

    // MARK: - Private
    private func refreshTwitterAccounts() {
        if !TwitterManager.isLocalTwitterAccountAvailable() {
            // TODO twitterアカウントが設定されていない
            return
        }
        obtainAccessToAccountsWithBlock({granted in
            dispatch_async(dispatch_get_main_queue(), {
                if !granted {
                    return
                }
                // 設定画面にてTwitter連携がされていない
                // TODO Twitterでログインボタンをdisableにする？
            })
        })
    }

    private func obtainAccessToAccountsWithBlock(block: (Bool) -> ()) {
        accountStore = ACAccountStore()
        let twitterType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        let handler: ACAccountStoreRequestAccessCompletionHandler = {granted, error in
            if granted {
                self.accounts.removeAll()
                for account in self.accountStore.accountsWithAccountType(twitterType) {
                    if let account = account as? ACAccount {
                        self.accounts.append(account)
                    }
                }
            }
            block(granted)
        }
        accountStore.requestAccessToAccountsWithType(twitterType, options: nil, completion: handler)
    }

    private func refreshCounts() {
        // ステージ番号の描画
        let dao = TumeKyouenDao()
        let clearCount = dao.selectCountClearStage()
        let allCount = dao.selectCount()
        stageCountLabel.text = String(format: "%ld/%ld", arguments: [clearCount, allCount])
    }

    private func getStage(maxStageNo: Int) {
        TumeKyouenServer().getStageData(maxStageNo, callback: {result, error in
            if error != nil {
                // 取得できなかった
                self.refreshCounts()
                SVProgressHUD.showErrorWithStatus(error.localizedDescription)
                return
            }
            if result.characters.count == 0 {
                // 取得できなかった
                self.refreshCounts()
                SVProgressHUD.dismiss()
                return
            }
            if result == "no_data" {
                // データなし
                self.refreshCounts()
                SVProgressHUD.dismiss()
                return
            }

            // データの登録
            if !TumeKyouenDao().insertWithCsvString(result) {
                // エラー発生時
            }
            self.refreshCounts()
            let lines = result.componentsSeparatedByString("\n")
            self.getStage(maxStageNo + lines.count)
        })
    }

    private func sendTwitterAccount() {
        // 認証情報を送信
        let dao = TwitterTokenDao()
        let oauthToken = dao.getOauthToken()
        let oauthTokenSecret = dao.getOauthTokenSecret()
        if oauthToken == nil || oauthTokenSecret == nil {
            SVProgressHUD.dismiss()
            return
        }
        SVProgressHUD.show()
        TumeKyouenServer().registUser(oauthToken!, tokenSecret: oauthTokenSecret!, callback: {response, error in
            if error != nil {
                SVProgressHUD.showErrorWithStatus(NSLocalizedString("progress_auth_fail", comment: ""))
                return
            }
            self.twitterButton.hidden = true
            self.syncButton.hidden = false
            SVProgressHUD.showSuccessWithStatus(NSLocalizedString("progress_auth_success", comment: ""))
        })
    }
}
