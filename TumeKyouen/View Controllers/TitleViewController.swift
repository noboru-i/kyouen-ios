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

    private var accountStore: ACAccountStore! = nil
    private let twitterManager = TwitterManager()
    private var accounts = [ACAccount]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景色の描画
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.darkGray.cgColor
        ]
        view.layer.insertSublayer(gradient, at: 0)

        // AdMob
        AdMobUtil.show(self)

        sendTwitterAccount()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshCounts()
        refreshTwitterAccounts()
    }

    // MARK: - Actions

    @IBAction private func startKyouen(_: AnyObject) {
        // 前回終了時のステージ番号を渡す
        let stageNo = SettingDao().loadStageNo()
        let model = TumeKyouenDao().selectByStageNo(stageNo)

        let kyouenStoryboard: UIStoryboard = UIStoryboard(name: "KyouenStoryboard", bundle: Bundle.main)
        let kyouenViewController: UIViewController? = kyouenStoryboard.instantiateInitialViewController()
        if let vc = kyouenViewController as? KyouenViewController {
            vc.currentModel = model
            self.navigationController?.pushViewController(kyouenViewController!, animated: true)
        }
    }

    @IBAction private func connectTwitterAction(_: AnyObject) {
        if accounts.count == 0 {
            let alert = UIAlertController.alert("alert_no_twitter_account")
            present(alert, animated: true, completion: nil)
            return
        }

        let title = NSLocalizedString("action_title_choose", comment: "")
        let sheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let handler = { (action: UIAlertAction) -> Void in
            let index = sheet.actions.index(of: action)!
            SVProgressHUD.show()
            self.twitterManager.performReverseAuthForAccount(self.accounts[index], withHandler: {responseData, _ in
                if responseData == nil {
                    SVProgressHUD.showError(withStatus: NSLocalizedString("progress_auth_fail", comment: ""))
                    return
                }

                // 認証情報を送信
                self.sendTwitterAccount()
            })

        }
        for acct in accounts {
            sheet.addAction(UIAlertAction(title: acct.username, style: .default, handler: handler))
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(sheet, animated: true, completion: nil)
    }

    @IBAction private func syncDataAction(_: AnyObject) {
        let stages = TumeKyouenDao().selectAllClearStage()

        SVProgressHUD.show()
        TumeKyouenServer().addAllStageUser(stages, callback: {response, error in
            if error != nil {
                // 通信が異常終了
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
                return
            }
            var responseData = [NSDictionary]()
            for item in response! {
                if let dic = item as? NSDictionary {
                    responseData.append(dic)
                }
            }
            TumeKyouenDao().updateSyncClearData(responseData)
            self.refreshCounts()
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("progress_sync_complete", comment: ""))
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
            DispatchQueue.main.async(execute: {
                if !granted {
                    return
                }
                // 設定画面にてTwitter連携がされていない
                // TODO Twitterでログインボタンをdisableにする？
            })
        })
    }

    private func obtainAccessToAccountsWithBlock(_ block: @escaping (Bool) -> Void) {
        accountStore = ACAccountStore()
        let twitterType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        let handler: ACAccountStoreRequestAccessCompletionHandler = {granted, error in
            if granted {
                self.accounts.removeAll()
                for account in self.accountStore.accounts(with: twitterType) {
                    if let account = account as? ACAccount {
                        self.accounts.append(account)
                    }
                }
            }
            block(granted)
        }
        accountStore.requestAccessToAccounts(with: twitterType, options: nil, completion: handler)
    }

    private func refreshCounts() {
        // ステージ番号の描画
        let dao = TumeKyouenDao()
        let clearCount = dao.selectCountClearStage()
        let allCount = dao.selectCount()
        stageCountLabel.text = String(format: "%ld/%ld", arguments: [clearCount, allCount])
    }

    private func getStage(_ maxStageNo: Int) {
        TumeKyouenServer().getStageData(maxStageNo, callback: {result, error in
            if error != nil {
                // 取得できなかった
                self.refreshCounts()
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                return
            }
            if result?.characters.count == 0 {
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
            TumeKyouenDao().insertWithCsvString(result!)
            self.refreshCounts()
            let lines = result!.components(separatedBy: "\n")
            self.getStage(maxStageNo + lines.count)
        })
    }

    private func sendTwitterAccount() {
        // 認証情報を送信
        let dao = TwitterTokenDao()
        guard let oauthToken = dao.getOauthToken(),
            let oauthTokenSecret = dao.getOauthTokenSecret() else {
                SVProgressHUD.dismiss()
                return
        }

        SVProgressHUD.show()
        TumeKyouenServer().registUser(oauthToken, tokenSecret: oauthTokenSecret, callback: {_, error in
            if error != nil {
                SVProgressHUD.showError(withStatus: NSLocalizedString("progress_auth_fail", comment: ""))
                return
            }
            self.twitterButton.isHidden = true
            self.syncButton.isHidden = false
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("progress_auth_success", comment: ""))
        })
    }
}
