//
//  KyouenImageView.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/07.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit

class KyouenImageView: UIView {
    var stage: TumeKyouenModel! {
        didSet {
            resetButtons()

            // 設定されているステージ情報を反映
            for (index, c) in stage.stage.enumerated() {
                let state = Int(String(c))!
                addButton(index, StoneButton.ButtonState(rawValue: state)!)
            }
        }
    }

    private var buttons = [StoneButton]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
        backgroundColor = UIColor.green
    }

    func getCurrentStage() -> String {
        return buttons.reduce("") { (stage, button) -> String in
            stage + String(button.stoneState.rawValue)
        }
    }

    private func resetButtons() {
        buttons.forEach { (button) in
            button.removeFromSuperview()
        }
        buttons = [StoneButton]()
    }

    private func addButton(_ index: Int, _ state: StoneButton.ButtonState) {
        let size = Int(truncating: stage.size)
        let x = index % size
        let y = index / size
        let stoneSize = frame.width / CGFloat(size)
        let button = StoneButton(stoneSize: stoneSize, defaultState: state)
        button.transform = CGAffineTransform(
            translationX: CGFloat(x) * button.frame.size.width, y: CGFloat(y) * button.frame.size.width)
        buttons.append(button)
        addSubview(button)
    }
}
