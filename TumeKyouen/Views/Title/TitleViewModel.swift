//
//  TitleViewModel.swift
//  TumeKyouen
//
//  Created by noboru-i on 2018/08/29.
//  Copyright © 2018 noboru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TitleViewModel {
    private let disposeBag = DisposeBag()

    private let refreshStageCountStream = PublishSubject<Void>()

    // Outputs
    let stageCount: Driver<String>
    private let showLoadingStream = PublishRelay<Void>()
    private let hideLoadingStream = PublishSubject<Void>()
    private let showErrorStream = PublishRelay<String>()
    private let navigateToKyouenStream = PublishSubject<TumeKyouenModel>()

    init(
        input: (
            startButtonTaps: Signal<()>,
            getStageTaps: Signal<()>
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
    }

    private func getStage(_ maxStageNo: Int) {
        TumeKyouenServer().getStageData(maxStageNo, callback: {result, error in
            if error != nil {
                // 取得できなかった
                self.refreshStageCountStream.onNext(())
                self.hideLoadingStream.onNext(())
                if let message = error?.localizedDescription {
                    self.showErrorStream.accept(message)
                }
                return
            }
            if result?.count == 0 {
                // 取得できなかった
                self.refreshStageCountStream.onNext(())
                self.hideLoadingStream.onNext(())
                return
            }
            if result == "no_data" {
                // データなし
                self.refreshStageCountStream.onNext(())
                self.hideLoadingStream.onNext(())
                return
            }

            // データの登録
            TumeKyouenDao().insertWithCsvString(result!)
            self.refreshStageCountStream.onNext(())
            let lines = result!.components(separatedBy: "\n")
            self.getStage(maxStageNo + lines.count)
        })
    }
}

// MARK: Input

extension TitleViewModel {
    var refreshStageCount: AnyObserver<()> {
        return refreshStageCountStream.asObserver()
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

    var navigateToKyouen: Observable<TumeKyouenModel> {
        return navigateToKyouenStream.asObservable()
    }
}
