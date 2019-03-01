//
//  KyouenViewController.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/09.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit
import QuartzCore
import SVProgressHUD
import GoogleMobileAds
import TwitterKit
import RxSwift
import RxCocoa

class TitleViewController: UIViewController {
    @IBOutlet private weak var stageCountLabel: UILabel!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var getStageButton: UIButton!
    @IBOutlet private weak var createButton: UIButton!
    @IBOutlet private weak var twitterButton: UIButton!
    @IBOutlet private weak var syncButton: UIButton!
    @IBOutlet private weak var bannerView: GADBannerView!

    private let disposeBag = DisposeBag()

    private var viewModel: TitleViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewModel = TitleViewModel(
            input: (
                viewWillAppear: rx.sentMessage(#selector(viewWillAppear(_:)))
                    .map { _ in }
                    .asSignal(onErrorSignalWith: Signal.empty()),
                startButtonTaps: startButton.rx.tap.asSignal(),
                getStageTaps: getStageButton.rx.tap.asSignal(),
                createStageTaps: createButton.rx.tap.asSignal(),
                connectTwitterTaps: twitterButton.rx.tap.asSignal(),
                syncDataTaps: syncButton.rx.tap.asSignal()
            )
        )

        viewModel.stageCount
            .drive(stageCountLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.loggedInStatus
            .drive(onNext: handleLoggedInStatus)
            .disposed(by: disposeBag)

        viewModel.dialogStatus
            .drive(onNext: handleDialog)
            .disposed(by: disposeBag)
        viewModel.navigateToKyouen
            .bind { [weak self] model in
                self?.navigateToKyouen(model: model)
            }
            .disposed(by: disposeBag)
        viewModel.navigateToCreate
            .bind { [weak self] in
                self?.navigateToCreate()
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
    }

    private func navigateToKyouen(model: TumeKyouenModel) {
        let kyouenStoryboard: UIStoryboard = UIStoryboard(name: "KyouenStoryboard", bundle: Bundle.main)
        let kyouenViewController: UIViewController? = kyouenStoryboard.instantiateInitialViewController()
        if let vc = kyouenViewController as? KyouenViewController {
            vc.currentModel = model
            self.navigationController?.pushViewController(kyouenViewController!, animated: true)
        }
    }

    private func navigateToCreate() {
        let storyboard: UIStoryboard = UIStoryboard(name: "CreateViewController", bundle: Bundle.main)
        let viewController: UIViewController? = storyboard.instantiateInitialViewController()
        if let vc = viewController as? CreateViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func handleLoggedInStatus(_ status: TitleViewModel.LoggedInStatus) {
        switch status {
        case .unknown:
            self.twitterButton.isHidden = false
            self.syncButton.isHidden = true
        case .none:
            self.twitterButton.isHidden = false
            self.syncButton.isHidden = true
        case .loggedIn:
            self.twitterButton.isHidden = true
            self.syncButton.isHidden = false
        }
    }

    private func handleDialog(_ status: TitleViewModel.DialogStatus) {
        switch status {
        case .none:
            SVProgressHUD.dismiss()
        case .loading:
            SVProgressHUD.show()
        case let .error(message):
            SVProgressHUD.showError(withStatus: message)
        case let .success(message):
            SVProgressHUD.showSuccess(withStatus: message)
        }
    }
}
