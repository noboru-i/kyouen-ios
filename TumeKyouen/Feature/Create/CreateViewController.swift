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

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        currentModel = TumeKyouenModel(context: appDelegate.managedObjectContext)
        currentModel.stageNo = 0
        currentModel.size = 6
        currentModel.stage = "000000000000000000000000000000000000"

        kyouenView.stage = currentModel
    }
}

extension CreateViewController: CreateKyouenDelegate {
    func onChangeStage(kyouen: KyouenData?) {
        if let kyouen = kyouen {
            overlayView.drawKyouen(kyouen, tumeKyouenModel: currentModel)
        }
    }
}
