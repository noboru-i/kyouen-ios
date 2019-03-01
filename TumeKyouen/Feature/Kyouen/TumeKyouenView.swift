//
//  TumeKyouenView.swift
//  TumeKyouen
//
//  Created by noboru-i on 2019/02/26.
//  Copyright © 2019 noboru-i. All rights reserved.
//

import UIKit

class TumeKyouenView: KyouenImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension TumeKyouenView: StoneButtonDelegate {
    func onClickButton(button: StoneButton) {
        switch button.stoneState {
        case .blank:
            return
        case .black:
            button.stoneState = .white
        case .white:
            button.stoneState = .black
        }
    }
}
