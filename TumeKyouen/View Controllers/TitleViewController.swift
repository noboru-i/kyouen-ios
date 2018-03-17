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
import GoogleMobileAds

class TitleViewController: UIViewController {
    @IBOutlet private weak var twitterButton: UIButton!
    @IBOutlet private weak var syncButton: UIButton!
    @IBOutlet private weak var stageCountLabel: UILabel!
    @IBOutlet private weak var bannerView: GADBannerView!

    private var accountStore: ACAccountStore! = nil
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
        AdMobUtil.applyUnitId(bannerView: bannerView, controller: self)

        sendTwitterAccount()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshCounts()
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
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            guard let session = session else {
                print("error: \(error!.localizedDescription)")
                return
            }
            print("signed in as \(session.userName)")

            let dao = TwitterTokenDao()
            dao.saveToken(session.authToken, oauthTokenSecret: session.authTokenSecret)

            self.sendTwitterAccount()
        })
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
            if result?.count == 0 {
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
