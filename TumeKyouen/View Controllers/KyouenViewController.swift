//
//  TitleViewController.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/09.
//  Copyright © 2016年 noboru. All rights reserved.
//

import SVProgressHUD
import GoogleMobileAds

class KyouenViewController: UIViewController {
    @IBOutlet private weak var mPrevButton: UIButton!
    @IBOutlet private weak var mNextButton: UIButton!
    @IBOutlet private weak var mStageNo: UILabel!
    @IBOutlet private weak var mCreator: UILabel!
    @IBOutlet private weak var bannerView: GADBannerView!
    @IBOutlet private weak var mKyouenImageView1: KyouenImageView!
    @IBOutlet private weak var mKyouenImageView2: KyouenImageView!
    @IBOutlet private weak var mOverlayKyouenView: OverlayKyouenView!

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

        AdMobUtil.applyUnitId(bannerView: bannerView, controller: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 初期化
        setStage(currentModel, to: mKyouenImageView1!)
    }

    // MARK: - actions
    @IBAction private func moveNextStage(_: AnyObject) {
        let nextStageNo = Int(truncating: currentModel.stageNo) + 1
        moveStage(nextStageNo, direction: 1)
    }

    @IBAction private func movePrevStage(_: AnyObject) {
        let nextStageNo = Int(truncating: currentModel.stageNo) - 1
        moveStage(nextStageNo, direction: -1)
    }

    @IBAction private func checkKyouen(_: AnyObject) {
        let model = GameModel(size: Int(truncating: currentModel.size), stage: mKyouenImageView1.getCurrentStage())
        // 4つ選択されているかのチェック
        if model.getStoneCount(2) != 4 {
            let alert = UIAlertController.alert("alert_less_stone")
            present(alert, animated: true, completion: nil)
            Analytics.sendKyouenEvent(.not4Stone, stageNo: currentModel.stageNo)
            return
        }

        // 共円のチェック
        guard let kyouenData = model.isKyouen() else {
            setStage(currentModel, to: mKyouenImageView1)
            let alert = UIAlertController.alert("alert_not_kyouen")
            present(alert, animated: true, completion: nil)
            Analytics.sendKyouenEvent(.notKyouen, stageNo: currentModel.stageNo)
            return
        }

        // 共円の場合
        TumeKyouenDao().updateClearFlag(currentModel)
        mStageNo.textColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1)
        mOverlayKyouenView.drawKyouen(kyouenData, tumeKyouenModel: currentModel)
        mOverlayKyouenView.layer.zPosition = 3

        let alert = UIAlertController(title: NSLocalizedString("kyouen", comment: ""),
            message: nil,
            preferredStyle: .alert)
        let nextButton = UIAlertAction(title: "Next", style: .default) { (_) -> Void in
            let nextStageNo = Int(truncating: self.currentModel.stageNo) + 1
            self.moveStage(nextStageNo, direction: 1)
        }
        alert.addAction(nextButton)
        present(alert, animated: true, completion: nil)

        // クリアデータの送信
        TumeKyouenServer().addStageUser(currentModel.stageNo)
        Analytics.sendKyouenEvent(.kyouen, stageNo: currentModel.stageNo)
    }

    @IBAction private func selectStage(_: AnyObject) {
        let maxStageNo = TumeKyouenDao().selectCount()
        let title = String(format: NSLocalizedString("dialog_title_stage_select", comment: ""), arguments: [1, maxStageNo])
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let selectButton = UIAlertAction(title: NSLocalizedString("dialog_select", comment: ""), style: .default) { _ -> Void in
            let inputText = alert.textFields![0].text!
            let nextStageNo = Int(inputText)
            if nextStageNo == nil || nextStageNo == 0 {
                return
            }
            if TumeKyouenDao().selectByStageNo(nextStageNo!) == nil {
                // 取得できなかった場合は終了
                return
            }
            self.moveStage(nextStageNo!, direction: 1)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addTextField { (_) -> Void in
        }
        alert.addAction(selectButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - private methods
    private func moveStage(_ stageNo: Int, direction: Int) {

        guard let model = TumeKyouenDao().selectByStageNo(stageNo) else {
            // 取得できなかった場合の処理
            SVProgressHUD.show()

            TumeKyouenServer().getStageData(stageNo - 1, callback: {result, error in
                if error != nil || result == nil || result!.count == 0 {
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
                TumeKyouenDao().insertWithCsvString(result!)
                SVProgressHUD.dismiss()

                // ステージの移動
                self.moveStage(stageNo, direction: direction)
            })
            return
        }
        setStageWithAnimation(model, direction: direction)

        // 表示したステージ番号を保存
        SettingDao().saveStageNo(Int(truncating: model.stageNo))
    }

    private func setStageWithAnimation(_ model: TumeKyouenModel, direction: Int) {
        let currentImageView = self.mKyouenImageView1!
        let nextImageView = self.mKyouenImageView2!
        nextImageView.alpha = 1.0
        setStage(model, to: nextImageView)

        // 移動ボタンを無効化
        mPrevButton.isEnabled = false
        mNextButton.isEnabled = false

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
        UIView.setAnimationDidStop(#selector(KyouenViewController.endSetStageAnimation))
        UIView.setAnimationDuration(0.4)
        currentImageView.alpha = 0.0
        frame.origin.x = origX
        nextImageView.frame = frame
        UIView.commitAnimations()

        mKyouenImageView1 = nextImageView
        mKyouenImageView2 = currentImageView
    }

    private func setStage(_ model: TumeKyouenModel, to imageView: KyouenImageView) {
        // 移動ボタンを無効化
        mPrevButton.isEnabled = false
        mNextButton.isEnabled = false

        currentModel = model
        if currentModel.clearFlag == 1 {
            mStageNo.textColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1)
        } else {
            mStageNo.textColor = UIColor.white
        }
        mStageNo.text = String(format: "STAGE:%@", currentModel.stageNo)
        mCreator.text = String(format: "created by %@", arguments: [currentModel.creator])
        imageView.stage = currentModel

        mOverlayKyouenView.alpha = 0

        endSetStageAnimation()

        Analytics.sendShowEvent(model.stageNo)
    }

    @objc func endSetStageAnimation() {
        if currentModel.stageNo != 1 {
            // ステージ１の場合は戻れない
            mPrevButton.isEnabled = true
        }
        // 移動ボタンを有効化
        mNextButton.isEnabled = true
    }
}
