//
//  TKKyouenViewController.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/09.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import Accounts
import SVProgressHUD

class TKTitleViewController: UIViewController, UIActionSheetDelegate {
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var stageCountLabel: UILabel!

    var accountStore: ACAccountStore! = nil
    var twitterManager: TKTwitterManager! = nil
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

        twitterManager = TKTwitterManager()

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
            let settingDao = TKSettingDao()
            let stageNo = settingDao.loadStageNo()
            let dao = TKTumeKyouenDao()
            let model = dao.selectByStageNo(stageNo)
            if let vc = segue.destinationViewController as? TKKyouenViewController {
                vc.currentModel = model
            }
        }
    }

    @IBAction func connectTwitterAction(_: AnyObject) {
        if accounts.count == 0 {
            let alert = UIAlertView(title: NSLocalizedString("alert_no_twitter_account", comment: ""),
                message: "",
                delegate: nil,
                cancelButtonTitle: "OK")
            alert.show()
            return
        }

        let title = NSLocalizedString("action_title_choose", comment: "")
        let sheet = UIActionSheet(title: title, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        for acct in accounts {
            sheet.addButtonWithTitle(acct.username)
        }
        sheet.cancelButtonIndex = sheet.addButtonWithTitle("Cancel")
        sheet.showInView(view)
    }

    @IBAction func syncDataAction(_: AnyObject) {
        let dao = TKTumeKyouenDao()
        let stages = dao.selectAllClearStage()

        SVProgressHUD.show()
        let server = TumeKyouenServer()
        server.addAllStageUser(stages, callback: {response, error in
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
            dao.updateSyncClearData(responseData)
            self.refreshCounts()
            SVProgressHUD.showSuccessWithStatus(NSLocalizedString("progress_sync_complete", comment: ""))
        })
    }

    @IBAction func getStages(_: AnyObject) {
        SVProgressHUD.show()

        let dao = TKTumeKyouenDao()
        let stageCount = dao.selectCount()
        let server = TumeKyouenServer()
        getStage(stageCount, server: server, kyouenDao: dao)
    }

    // MARK: - UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == actionSheet.cancelButtonIndex {
            return
        }

        SVProgressHUD.show()
        twitterManager.performReverseAuthForAccount(accounts[buttonIndex], withHandler: {responseData, error in
            if responseData == nil {
                SVProgressHUD.showErrorWithStatus(NSLocalizedString("progress_auth_fail", comment: ""))
                return
            }

            // 認証情報を送信
            self.sendTwitterAccount()
        })
    }

    // MARK: - Private
    private func refreshTwitterAccounts() {
        if !TKTwitterManager.isLocalTwitterAccountAvailable() {
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
        let dao = TKTumeKyouenDao()
        let clearCount = dao.selectCountClearStage()
        let allCount = dao.selectCount()
        stageCountLabel.text = String(format: "%ld/%ld", arguments: [clearCount, allCount])
    }

    private func getStage(maxStageNo: Int, server: TumeKyouenServer, kyouenDao dao: TKTumeKyouenDao) {
        server.getStageData(maxStageNo, callback: {result, error in
            if error != nil {
                // 取得できなかった
                self.refreshCounts()
                SVProgressHUD.showErrorWithStatus(error.localizedDescription)
                return
            }
            if result?.length == 0 {
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
            if !dao.insertWithCsvString(result) {
                // エラー発生時
            }
            self.refreshCounts()
            let lines = result.componentsSeparatedByString("\n")
            self.getStage(maxStageNo + lines.count, server: server, kyouenDao: dao)
        })
    }

    private func sendTwitterAccount() {
        // 認証情報を送信
        let dao = TKTwitterTokenDao()
        let oauthToken = dao.getOauthToken()
        let oauthTokenSecret = dao.getOauthTokenSecret()
        if oauthToken == nil || oauthTokenSecret == nil {
            SVProgressHUD.dismiss()
            return
        }
        SVProgressHUD.show()
        let server = TumeKyouenServer()
        server.registUser(oauthToken!, tokenSecret: oauthTokenSecret!, callback: {response, error in
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
