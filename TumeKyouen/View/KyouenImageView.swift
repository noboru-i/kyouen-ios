//
//  KyouenImageView.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/07.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit

class KyouenImageView: UIView {
    var stage: TumeKyouenModel? {
        didSet {
            resetButtons()

            // 設定されているステージ情報を反映
            for (index, c) in stage!.stage.characters.enumerate() {
                let state = Int(String(c))!
                addButton(index, StoneButton.ButtonState(rawValue: state)!)
                setButtonDelegate()
            }
        }
    }
    var delegate: TapDelegate = TumeKyouenDelegate() {
        didSet {
            setButtonDelegate()
        }
    }

    private var buttons = [StoneButton]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        userInteractionEnabled = true
        backgroundColor = UIColor.greenColor()
    }

    func getCurrentStage() -> String {
        return buttons.reduce("") { (stage, button) -> String in
            stage + String(button.stoneState.rawValue)
        }
    }

    private func resetButtons() {
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons = [StoneButton]()
        setButtonDelegate()
    }

    private func setButtonDelegate() {
        buttons.forEach { (button) in
            button.delegate = delegate
        }
    }

    private func addButton(index: Int, _ state: StoneButton.ButtonState) {
        let size = Int(stage!.size)
        let x = index % size
        let y = index / size
        let stoneSize = frame.width / CGFloat(size)
        let button = StoneButton(stoneSize: stoneSize, defaultState: state)
        button.transform = CGAffineTransformMakeTranslation(
            CGFloat(x) * button.frame.size.width, CGFloat(y) * button.frame.size.width)
        buttons.append(button)
        addSubview(button)
    }
}
