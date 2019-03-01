//
//  CreateKyouenView.swift
//  TumeKyouen
//
//  Created by noboru-i on 2019/02/26.
//  Copyright © 2019 noboru-i. All rights reserved.
//

import UIKit

protocol CreateKyouenDelegate: class {
    func onChangeStage(kyouen: KyouenData?)
}

class CreateKyouenView: KyouenImageView {

    weak var delegate: CreateKyouenDelegate?

    private var stackButton: [StoneButton] = []

    var stoneCount: Int {
        return stackButton.count
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func backOneStep() {
        guard let lastButton = stackButton.popLast() else {
            return
        }
        lastButton.stoneState = .blank
        delegate?.onChangeStage(kyouen: nil)
    }

    func reset() {
        stackButton.forEach { (button) in
            button.stoneState = .blank
        }
        stackButton.removeAll()
        delegate?.onChangeStage(kyouen: nil)
    }

    func getStageStateForSend() -> String {
        return getCurrentStage().replacingOccurrences(of: "2", with: "1")
    }

    private func checkKyouen() -> KyouenData? {
        let model = GameModel(size: Int(truncating: stage.size), stage: getCurrentStage())

        // check kyouen
        guard let kyouenData = model.hasKyouen() else {
            return nil
        }
        return kyouenData
    }
}

extension CreateKyouenView: StoneButtonDelegate {
    func onClickButton(button: StoneButton) {
        switch button.stoneState {
        case .blank:
            stackButton.append(button)
            button.stoneState = .black
        case .black:
            return
        case .white:
            return
        }

        let kyouenData = checkKyouen()
        delegate?.onChangeStage(kyouen: kyouenData)
    }
}
