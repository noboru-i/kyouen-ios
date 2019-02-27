//
//  CreateViewController.swift
//  TumeKyouen
//
//  Created by noboru-i on 2019/02/25.
//  Copyright © 2019 noboru-i. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController {

    @IBOutlet weak var kyouenView: CreateKyouenView!
    @IBOutlet weak var overlayView: OverlayKyouenView!

    @IBOutlet weak var backOneStepButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var sendStageButton: UIButton!

    var currentModel: TumeKyouenModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景色の描画
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.darkGray.cgColor
        ]
        view.layer.insertSublayer(gradient, at: 0)

        kyouenView.delegate = self

        prepareStage()
        applyButtonState()
    }

    @IBAction func onBackOneStep(_ sender: Any) {
        kyouenView.backOneStep()
    }

    @IBAction func onReset(_ sender: Any) {
        kyouenView.reset()
    }

    @IBAction func onSendStage(_ sender: Any) {
    }

    private func prepareStage() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        currentModel = TumeKyouenModel(context: appDelegate.managedObjectContext)
        currentModel.stageNo = 0
        currentModel.size = 6
        currentModel.stage = "000000000000000000000000000000000000"

        kyouenView.stage = currentModel
    }

    private func applyButtonState() {
        let hasStone = kyouenView.hasStone()
        backOneStepButton.isEnabled = hasStone
        resetButton.isEnabled = hasStone
        sendStageButton.isEnabled = overlayView.kyouenData != nil
    }
}

extension CreateViewController: CreateKyouenDelegate {
    func onChangeStage(kyouen: KyouenData?) {
        if let kyouen = kyouen {
            overlayView.drawKyouen(kyouen, tumeKyouenModel: currentModel)
        } else {
            overlayView.reset()
        }

        applyButtonState()
    }
}
