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
import TwitterKit
import RxSwift

class TitleViewController: UIViewController {
    @IBOutlet private weak var stageCountLabel: UILabel!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var getStageButton: UIButton!
    @IBOutlet private weak var twitterButton: UIButton!
    @IBOutlet private weak var syncButton: UIButton!
    @IBOutlet private weak var bannerView: GADBannerView!

    private let disposeBag = DisposeBag()

    private var viewModel: TitleViewModel?

    private var accountStore: ACAccountStore! = nil
    private var accounts = [ACAccount]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewModel = TitleViewModel(
            input: (
                startButtonTaps: startButton.rx.tap.asSignal(),
                getStageTaps: getStageButton.rx.tap.asSignal()
            )
        )

        rx.sentMessage(#selector(viewWillAppear(_:)))
            .map { _ in }
            .bind(to: viewModel.refreshStageCount)
            .disposed(by: disposeBag)

        viewModel.stageCount
            .drive(stageCountLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.showLoading
            .bind { _ in
                SVProgressHUD.show()
            }
            .disposed(by: disposeBag)
        viewModel.hideLoading
            .bind { _ in
                SVProgressHUD.dismiss()
            }
            .disposed(by: disposeBag)
        viewModel.showError
            .bind { message in
                SVProgressHUD.showError(withStatus: message)
            }
            .disposed(by: disposeBag)
        viewModel.navigateToKyouen
            .bind { [weak self] model in
                self?.navigateToKyouen(model: model)
            }
            .disposed(by: disposeBag)

        self.viewModel = viewModel

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

    // MARK: - Actions

    private func navigateToKyouen(model: TumeKyouenModel) {
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
            self.viewModel!.refreshStageCount.onNext(())
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("progress_sync_complete", comment: ""))
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
