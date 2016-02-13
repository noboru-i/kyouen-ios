//
//  KyouenImageView.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/07.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit

class KyouenImageView: UIView {
    var buttons = [StoneButton]()
    var model: TumeKyouenModel? = nil

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        userInteractionEnabled = true
        backgroundColor = UIColor.greenColor()
    }

    func setStage(model: TumeKyouenModel) {
        self.model = model

        // ボタン情報を初期化
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons = [StoneButton]()

        // 設定されているステージ情報を反映
        let size = Int(model.size)
        for (index, c) in model.stage.characters.enumerate() {
            let state = Int(String(c))!
            let x = index % size
            let y = index / size
            let button = StoneButton(size: size, defaultState: state)
            button.transform = CGAffineTransformMakeTranslation(
                CGFloat(x) * button.frame.size.width, CGFloat(y) * button.frame.size.width)
            buttons.append(button)
            addSubview(button)
        }
    }

    func getCurrentStage() -> String {
        return buttons.reduce("") { (stage, button) -> String in
            stage + String(button.stoneState)
        }
    }
}
