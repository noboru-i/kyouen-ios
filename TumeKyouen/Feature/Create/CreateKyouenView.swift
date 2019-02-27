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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
