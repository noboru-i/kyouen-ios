//
//  TKSettingDao.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/03.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

class SettingDao: NSObject {

    func saveStageNo(stageNo: Int) {
        let defaults = NSUserDefaults.standardUserDefaults()
        // save as NSNumber (since Objective-C)
        defaults.setObject(NSNumber.init(integer: stageNo), forKey: "stageNo")
        defaults.synchronize()
    }

    func loadStageNo() -> Int {
        let defaults = NSUserDefaults.standardUserDefaults()
        // load as NSNumber (since Objective-C)
        guard let stageNo = defaults.objectForKey("stageNo") as? NSNumber else {
            return 1
        }
        return Int(stageNo)
    }
}
