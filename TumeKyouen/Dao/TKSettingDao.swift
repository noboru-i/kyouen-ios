//
//  TKSettingDao.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/03.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

class TKSettingDao: NSObject {

    func saveStageNo(stageNo: NSNumber) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(stageNo, forKey: "stageNo")
        defaults.synchronize()
    }

    func loadStageNo() -> NSNumber {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let stageNo = defaults.objectForKey("stageNo") as? NSNumber {
            return stageNo
        }

        return 1
    }
}
