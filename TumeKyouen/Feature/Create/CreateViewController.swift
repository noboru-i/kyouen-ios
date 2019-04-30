//
//  CreateViewController.swift
//  TumeKyouen
//
//  Created by noboru-i on 2019/02/25.
//  Copyright © 2019 noboru-i. All rights reserved.
//

import UIKit
import SVProgressHUD

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

        applyButtonState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        prepareStage()
    }

    @IBAction func onBackOneStep(_ sender: Any) {
        kyouenView.backOneStep()
    }

    @IBAction func onReset(_ sender: Any) {
        kyouenView.reset()
    }

    @IBAction func onSendStage(_ sender: Any) {
        confirmSendName()
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

    private func onKyouen(kyouen: KyouenData) {
        // TODO turn stone color to white
        overlayView.drawKyouen(kyouen, tumeKyouenModel: currentModel)

        if kyouenView.stoneCount == 4 {
            let alert = UIAlertController.alert("create_send_title")
            present(alert, animated: true, completion: nil)
            return
        }

        confirmSendName()
    }

    private func confirmSendName() {
        let alert = UIAlertController(
            title: NSLocalizedString("create_send_title", comment: ""),
            message: NSLocalizedString("create_send_message", comment: ""),
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.text = SettingDao().loadCreatorName()
        }
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {[weak self, weak alert] (_) -> Void in
            guard let textFields = alert?.textFields else {
                return
            }

            let text = textFields.first?.text
            SettingDao().saveCreatorName(text)
            self?.sendStage(creator: text ?? "")
        })
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    private func sendStage(creator: String) {
        let size = currentModel.size.stringValue
        let stage = kyouenView.getStageStateForSend()
        let data = [size, stage, creator].joined(separator: ",")

        SVProgressHUD.show()

        TumeKyouenServer().postStage(data) { [weak self] response in
            SVProgressHUD.dismiss()
            switch response.result {
            case .success(let string):
                if let message = self?.convertResponseToMessage(string) {
                    let alert = UIAlertController.alert(message)
                    self?.present(alert, animated: true, completion: nil)
                }
            case .failure:
                let alert = UIAlertController.alert("create_result_failure")
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func convertResponseToMessage(_ responseString: String?) -> String {
        guard let responseString = responseString else {
            return NSLocalizedString("create_result_failure", comment: "")
        }
        guard let regex = try? NSRegularExpression(pattern: "success stageNo=([0-9]*)") else {
            return NSLocalizedString("create_result_failure", comment: "")
        }
        guard let matches = regex.firstMatch(in: responseString, range: NSRange(location: 0, length: responseString.count)) else {
            if responseString == "registered" {
                return NSLocalizedString("create_result_registered", comment: "")
            }
            return NSLocalizedString("create_result_failure", comment: "")
        }

        let stageNo = String(responseString[Range(matches.range(at: 1), in: responseString)!])
        return String(format: NSLocalizedString("create_send_success_message", comment: ""), stageNo)
    }
}

extension CreateViewController: CreateKyouenDelegate {
    func onChangeStage(kyouen: KyouenData?) {
        kyouenView.setKyouen(kyouen)
        if let kyouen = kyouen {
            onKyouen(kyouen: kyouen)
        } else {
            overlayView.reset()
        }

        applyButtonState()
    }
}
