//
//  TitleViewController.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/09.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation
import SVProgressHUD

enum TKAlertTag: Int {
    case Kyouen = 1
    case StageSelect = 2
}

class KyouenViewController: UIViewController, UIAlertViewDelegate {
    @IBOutlet weak var mPrevButton: UIButton!
    @IBOutlet weak var mNextButton: UIButton!
    @IBOutlet weak var mStageNo: UILabel!
    @IBOutlet weak var mCreator: UILabel!
    @IBOutlet weak var mKyouenImageView1: KyouenImageView!
    @IBOutlet weak var mKyouenImageView2: KyouenImageView!
    @IBOutlet weak var mOverlayKyouenView: OverlayKyouenView!

    var currentModel: TumeKyouenModel? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景色の描画
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor.blackColor().CGColor,
            UIColor.darkGrayColor().CGColor
        ]
        view.layer.insertSublayer(gradient, atIndex: 0)

        let screenSize = UIScreen.mainScreen().bounds.size
        if screenSize.width >= 320.0 && screenSize.height >= 568.0 {
            // 4インチの場合
            AdMobUtil.show(self)
        }

        // 初期化
        setStage(currentModel!, to: mKyouenImageView1!)
    }

    // MARK: - actions
    @IBAction func moveNextStage(_: AnyObject) {
        let nextStageNo = Int(currentModel!.stageNo) + 1
        moveStage(nextStageNo, direction: 1)
    }

    @IBAction func movePrevStage(_: AnyObject) {
        let nextStageNo = Int(currentModel!.stageNo) - 1
        moveStage(nextStageNo, direction: -1)
    }

    @IBAction func checkKyouen(_: AnyObject) {
        let model = GameModel(size: Int(currentModel!.size), stage: mKyouenImageView1.getCurrentStage())
        // 4つ選択されているかのチェック
        if model.getStoneCount(2) != 4 {
            let alert = UIAlertView(title: NSLocalizedString("alert_less_stone", comment: ""),
                message: "",
                delegate: nil,
                cancelButtonTitle: nil,
                otherButtonTitles: "OK")
            alert.show()
            return
        }

        // 共円のチェック
        let kyouenData = model.isKyouen()
        if kyouenData == nil {
            setStage(currentModel!, to: mKyouenImageView1)
            let alert = UIAlertView(title: NSLocalizedString("alert_not_kyouen", comment: ""),
                message: "",
                delegate: nil,
                cancelButtonTitle: nil,
                otherButtonTitles: "OK")
            alert.show()
            return
        }

        // 共円の場合
        let dao = TumeKyouenDao()
        dao.updateClearFlag(currentModel!, date: nil)
        mStageNo.textColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1)
        mOverlayKyouenView.drawKyouen(kyouenData, tumeKyouenModel: currentModel!)
        mOverlayKyouenView.layer.zPosition = 3
        let alert = UIAlertView(title: NSLocalizedString("kyouen", comment: ""),
            message: "",
            delegate: self,
            cancelButtonTitle: nil,
            otherButtonTitles: "Next")
        alert.tag = TKAlertTag.Kyouen.rawValue
        alert.show()

        // クリアデータの送信
        let server = TumeKyouenServer()
        server.addStageUser(currentModel!.stageNo)
    }

    @IBAction func selectStage(_: AnyObject) {
        let dao = TumeKyouenDao()
        let maxStageNo = dao.selectCount()
        let title = String(format: NSLocalizedString("dialog_title_stage_select", comment: ""), arguments: [1, maxStageNo])
        let message = UIAlertView(title: title,
            message: "",
            delegate: nil,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: NSLocalizedString("dialog_select", comment: ""))
        message.tag = TKAlertTag.StageSelect.rawValue
        message.alertViewStyle = UIAlertViewStyle.PlainTextInput
        message.textFieldAtIndex(0)?.keyboardType = UIKeyboardType.NumbersAndPunctuation
        message.show()
    }

    // MARK: - delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        print(alertView.tag)
        switch alertView.tag {
        case TKAlertTag.Kyouen.rawValue:
            let nextStageNo = Int(currentModel!.stageNo) + 1
            moveStage(nextStageNo, direction: 1)
        case TKAlertTag.StageSelect.rawValue:
            if buttonIndex == 0 {
                break
            }
            let inputText = alertView.textFieldAtIndex(0)!.text!
            let nextStageNo = Int(inputText)!
            if nextStageNo == 0 {
                break
            }
            let dao = TumeKyouenDao()
            let model = dao.selectByStageNo(nextStageNo)
            if model == nil {
                // 取得できなかった場合は終了
                break
            }
            moveStage(nextStageNo, direction: 1)
        default:
            break
        }
    }

    // MARK: - private methods
    private func moveStage(stageNo: Int, direction: Int) {

        let dao = TumeKyouenDao()
        let model = dao.selectByStageNo(stageNo)
        if model == nil {
            // 取得できなかった場合の処理
            SVProgressHUD.show()

            let server = TumeKyouenServer()
            server.getStageData(stageNo - 1, callback: {result, error in
                if error != nil || result == nil || result.length == 0 {
                    // 取得できなかった
                    SVProgressHUD.dismiss()
                    return
                }
                if result == "no_data" {
                    // データなし
                    SVProgressHUD.dismiss()
                    return
                }

                // データの登録
                let dao = TumeKyouenDao()
                if !dao.insertWithCsvString(result) {
                    // エラー発生時
                }
                SVProgressHUD.dismiss()

                // ステージの移動
                self.moveStage(stageNo, direction: direction)
            })
            return
        }
        setStageWithAnimation(model, direction: direction)

        // 表示したステージ番号を保存
        let settingDao = SettingDao()
        settingDao.saveStageNo(model.stageNo)
    }

    private func setStageWithAnimation(model: TumeKyouenModel, direction: Int) {
        let currentImageView = self.mKyouenImageView1
        let nextImageView = self.mKyouenImageView2
        nextImageView.alpha = 1.0
        setStage(model, to: nextImageView)

        // 移動ボタンを無効化
        mPrevButton.enabled = false
        mNextButton.enabled = false

        // 次に表示するViewを画面外に用意
        var frame = currentImageView.frame
        let origX = frame.origin.x
        frame.origin.x = origX + CGFloat(direction) * 320.0
        nextImageView.frame = frame
        currentImageView.layer.zPosition = 1
        nextImageView.layer.zPosition = 2

        // 2つのImageViewを移動
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStopSelector("endSetStageAnimation")
        UIView.setAnimationDuration(0.4)
        currentImageView.alpha = 0.0
        frame.origin.x = origX
        nextImageView.frame = frame
        UIView.commitAnimations()

        mKyouenImageView1 = nextImageView
        mKyouenImageView2 = currentImageView
    }

    private func setStage(model: TumeKyouenModel, to imageView: KyouenImageView) {
        // 移動ボタンを無効化
        mPrevButton.enabled = false
        mNextButton.enabled = false

        currentModel = model
        if currentModel?.clearFlag == 1 {
            mStageNo.textColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1)
        } else {
            mStageNo.textColor = UIColor.whiteColor()
        }
        mStageNo.text = String(format: "STAGE:%@", currentModel!.stageNo)
        mCreator.text = String(format: "created by %@", arguments: [currentModel!.creator])
        imageView.setStage(currentModel!)

        mOverlayKyouenView.alpha = 0

        endSetStageAnimation()
    }

    func endSetStageAnimation() {
        if currentModel?.stageNo != 1 {
            // ステージ１の場合は戻れない
            mPrevButton.enabled = true
        }
        // 移動ボタンを有効化
        mNextButton.enabled = true
    }
}
