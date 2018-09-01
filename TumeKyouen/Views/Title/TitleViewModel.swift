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

    private let viewWillAppearStream = PublishSubject<Void>()

    private let stageCountStream = BehaviorSubject<String>(value: "")

    init() {
        viewWillAppearStream
            .flatMapLatest { _ -> Observable<String> in
                let dao = TumeKyouenDao()
                let clearCount = dao.selectCountClearStage()
                let allCount = dao.selectCount()
                return Observable.just(String(format: "%ld/%ld", arguments: [clearCount, allCount]))
            }
            .bind(to: stageCountStream)
            .disposed(by: disposeBag)
    }
}

// MARK: Input

extension TitleViewModel {
    var viewWillAppear: AnyObserver<()> {
        return viewWillAppearStream.asObserver()
    }
}

// MARK: Output

extension TitleViewModel {
    var stageCount: Observable<String> {
        return stageCountStream.asObservable()
    }
}
