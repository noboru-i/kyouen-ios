//
//  TKSettingDao.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/03.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

class SettingDao {

    func saveStageNo(_ stageNo: Int) {
        let defaults = UserDefaults.standard
        // save as NSNumber (since Objective-C)
        defaults.set(NSNumber.init(value: stageNo as Int), forKey: "stageNo")
        defaults.synchronize()
    }

    func loadStageNo() -> Int {
        let defaults = UserDefaults.standard
        // load as NSNumber (since Objective-C)
        guard let stageNo = defaults.object(forKey: "stageNo") as? NSNumber else {
            return 1
        }
        return Int(stageNo)
    }
}
