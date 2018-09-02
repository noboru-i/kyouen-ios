//
//  TitleViewModel.swift
//  TumeKyouen
//
//  Created by noboru-i on 2018/08/29.
//  Copyright © 2018 noboru. All rights reserved.
//

import Foundation
import TwitterKit
import RxSwift
import RxCocoa

final class TitleViewModel {
    enum LoggedInStatus {
        case unknown
        case none
        case loggedIn
    }
    private let disposeBag = DisposeBag()

    // Input
    private let refreshStageCountStream = PublishSubject<Void>()

    // Outputs
    let stageCount: Driver<String>
    let loggedInStatus: Driver<LoggedInStatus>
    private let showLoadingStream = PublishRelay<Void>()
    private let hideLoadingStream = PublishRelay<Void>()
    private let showErrorStream = PublishRelay<String>()
    private let showSuccessStream = PublishRelay<String>()
    private let navigateToKyouenStream = PublishSubject<TumeKyouenModel>()

    private let sendTwitterAccountStream = PublishSubject<Void>()

    init(
        input: (
            viewWillAppear: Signal<()>,
            startButtonTaps: Signal<()>,
            getStageTaps: Signal<()>,
            connectTwitterTaps: Signal<()>,
            syncDataTaps: Signal<()>
        )
    ) {
        stageCount = refreshStageCountStream
            .flatMapLatest { _ -> Observable<String> in
                let dao = TumeKyouenDao()
                let clearCount = dao.selectCountClearStage()
                let allCount = dao.selectCount()
                return Observable.just(String(format: "%ld/%ld", arguments: [clearCount, allCount]))
            }
            .asDriver(onErrorDriveWith: Driver.empty())
        // TODO: あとで実装
        loggedInStatus = Driver.just(.unknown)

        input.viewWillAppear
            .emit(to: refreshStageCountStream)
            .disposed(by: disposeBag)
        input.viewWillAppear
            .emit(to: sendTwitterAccountStream)
            .disposed(by: disposeBag)
        input.startButtonTaps.asObservable()
            .flatMapLatest { _ -> Observable<TumeKyouenModel> in
                // 前回終了時のステージ番号を渡す
                let stageNo = SettingDao().loadStageNo()
                return Observable.just(TumeKyouenDao().selectByStageNo(stageNo)!)
            }
            .bind(to: navigateToKyouenStream)
            .disposed(by: disposeBag)
        // TODO: ?
        input.getStageTaps.asObservable()
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                self?.showLoadingStream.accept(())
                let stageCount = TumeKyouenDao().selectCount()
                self?.getStage(stageCount)
                return Observable.just(true)
            }
            .subscribe()
            .disposed(by: disposeBag)
        input.connectTwitterTaps.asObservable()
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                self?.connectToTwitter()
                return Observable.just(true)
            }
            .subscribe()
            .disposed(by: disposeBag)
        input.syncDataTaps.asObservable()
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                self?.syncData()
                return Observable.just(true)
            }
            .subscribe()
            .disposed(by: disposeBag)

        sendTwitterAccountStream
            .subscribe { [weak self] _ in
                self?.sendTwitterAccount()
            }
            .disposed(by: disposeBag)
    }

    private func getStage(_ maxStageNo: Int) {
        TumeKyouenServer().getStageData(maxStageNo, callback: {result, error in
            if error != nil {
                // 取得できなかった
                self.refreshStageCountStream.onNext(())
                self.hideLoadingStream.accept(())
                if let message = error?.localizedDescription {
                    self.showErrorStream.accept(message)
                }
                return
            }
            if result?.count == 0 {
                // 取得できなかった
                self.refreshStageCountStream.onNext(())
                self.hideLoadingStream.accept(())
                return
            }
            if result == "no_data" {
                // データなし
                self.refreshStageCountStream.onNext(())
                self.hideLoadingStream.accept(())
                return
            }

            // データの登録
            TumeKyouenDao().insertWithCsvString(result!)
            self.refreshStageCountStream.onNext(())
            let lines = result!.components(separatedBy: "\n")
            self.getStage(maxStageNo + lines.count)
        })
    }

    private func connectToTwitter() {
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

    private func syncData() {
        let stages = TumeKyouenDao().selectAllClearStage()

        showLoadingStream.accept(())
        TumeKyouenServer().addAllStageUser(stages, callback: {response, error in
            if error != nil {
                // 通信が異常終了
                self.showErrorStream.accept(error!.localizedDescription)
                return
            }
            var responseData = [NSDictionary]()
            for item in response! {
                if let dic = item as? NSDictionary {
                    responseData.append(dic)
                }
            }
            TumeKyouenDao().updateSyncClearData(responseData)
            self.refreshStageCountStream.onNext(())
            self.showSuccessStream.accept(NSLocalizedString("progress_sync_complete", comment: ""))
        })

    }

    private func sendTwitterAccount() {
        // 認証情報を送信
        let dao = TwitterTokenDao()
        guard let oauthToken = dao.getOauthToken(),
            let oauthTokenSecret = dao.getOauthTokenSecret() else {
                hideLoadingStream.accept(())
                return
        }

        showLoadingStream.accept(())
        TumeKyouenServer().registUser(oauthToken, tokenSecret: oauthTokenSecret, callback: {_, error in
            if error != nil {
                self.showErrorStream.accept(NSLocalizedString("progress_auth_fail", comment: ""))
                return
            }
            // TODO: あとで実装
//            self.twitterButton.isHidden = true
//            self.syncButton.isHidden = false
            self.showSuccessStream.accept(NSLocalizedString("progress_auth_success", comment: ""))
        })
    }
}

// MARK: Output

extension TitleViewModel {
    var showLoading: Observable<Void> {
        return showLoadingStream.asObservable()
    }
    var hideLoading: Observable<Void> {
        return hideLoadingStream.asObservable()
    }
    var showError: Observable<String> {
        return showErrorStream.asObservable()
    }
    var showSuccess: Observable<String> {
        return showSuccessStream.asObservable()
    }

    var navigateToKyouen: Observable<TumeKyouenModel> {
        return navigateToKyouenStream.asObservable()
    }
}
