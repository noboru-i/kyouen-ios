//
//  BattleViewController.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/09.
//  Copyright © 2016年 noboru. All rights reserved.
//

import SVProgressHUD

class BattleViewController: UIViewController {
    @IBOutlet private weak var mKyouenImageView: KyouenImageView!
    @IBOutlet private weak var mOverlayKyouenView: OverlayKyouenView!

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

        mKyouenImageView.delegate = KyouenDelegate()

        AdMobUtil.show(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 初期化
        setStage(currentModel!, to: mKyouenImageView!)
    }

    // MARK: - actions
    @IBAction private func checkKyouen(_: AnyObject) {
        let model = GameModel(size: Int(currentModel!.size), stage: mKyouenImageView.getCurrentStage())
        // 4つ選択されているかのチェック
        if model.getStoneCount(2) != 4 {
            let alert = UIAlertController.alert("alert_less_stone")
            presentViewController(alert, animated: true, completion: nil)
            Analytics.sendKyouenEvent(.Not4Stone, stageNo: currentModel!.stageNo)
            return
        }

        // 共円のチェック
        let kyouenData = model.isKyouen()
        if kyouenData == nil {
            setStage(currentModel!, to: mKyouenImageView)
            let alert = UIAlertController.alert("alert_not_kyouen")
            presentViewController(alert, animated: true, completion: nil)
            Analytics.sendKyouenEvent(.NotKyouen, stageNo: currentModel!.stageNo)
            return
        }

        // 共円の場合
        TumeKyouenDao().updateClearFlag(currentModel!)
        mOverlayKyouenView.drawKyouen(kyouenData, tumeKyouenModel: currentModel!)
        mOverlayKyouenView.layer.zPosition = 3

        let alert = UIAlertController(title: NSLocalizedString("kyouen", comment: ""),
            message: nil,
            preferredStyle: .Alert)
        let nextButton = UIAlertAction(title: "Next", style: .Default) { (_) -> Void in
            let nextStageNo = Int(self.currentModel!.stageNo) + 1
            self.moveStage(nextStageNo, direction: 1)
        }
        alert.addAction(nextButton)
        presentViewController(alert, animated: true, completion: nil)

        // クリアデータの送信
        TumeKyouenServer().addStageUser(currentModel!.stageNo)
        Analytics.sendKyouenEvent(.Kyouen, stageNo: currentModel!.stageNo)
    }

    // MARK: - private methods
    private func moveStage(stageNo: Int, direction: Int) {

        guard let model = TumeKyouenDao().selectByStageNo(stageNo) else {
            // 取得できなかった場合の処理
            SVProgressHUD.show()

            TumeKyouenServer().getStageData(stageNo - 1, callback: {result, error in
                if error != nil || result == nil || result.characters.count == 0 {
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
                if !TumeKyouenDao().insertWithCsvString(result) {
                    // エラー発生時
                }
                SVProgressHUD.dismiss()

                // ステージの移動
                self.moveStage(stageNo, direction: direction)
            })
            return
        }

        // 表示したステージ番号を保存
        SettingDao().saveStageNo(Int(model.stageNo))
    }

    private func setStage(model: TumeKyouenModel, to imageView: KyouenImageView) {
        currentModel = model
        imageView.stage = currentModel

        mOverlayKyouenView.alpha = 0

        Analytics.sendShowEvent(model.stageNo)
    }
}
