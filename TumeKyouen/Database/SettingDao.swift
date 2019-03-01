//
//  TKSettingDao.swift
//  TumeKyouen
//
//  Created by noboru-i on 2016/02/03.
//  Copyright © 2016 noboru. All rights reserved.
//

import Foundation

class SettingDao {

    func saveStageNo(_ stageNo: Int) {
        let defaults = UserDefaults.standard
        // save as NSNumber (since Objective-C)
        defaults.set(NSNumber.init(value: stageNo), forKey: "stageNo")
        defaults.synchronize()
    }

    func loadStageNo() -> Int {
        let defaults = UserDefaults.standard
        // load as NSNumber (since Objective-C)
        guard let stageNo = defaults.object(forKey: "stageNo") as? NSNumber else {
            return 1
        }
        return Int(truncating: stageNo)
    }

    func saveCreatorName(_ creatorName: String?) {
        let defaults = UserDefaults.standard
        defaults.set(creatorName, forKey: "creatorName")
        defaults.synchronize()
    }

    func loadCreatorName() -> String {
        let defaults = UserDefaults.standard
        guard let creatorName = defaults.object(forKey: "creatorName") as? String else {
            return "no name"
        }
        return creatorName
    }
}
