//
//  TumeKyouenModel.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/01.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation
import CoreData

@objc(TumeKyouenModel)
class TumeKyouenModel: NSManagedObject {
    @NSManaged var stageNo: NSNumber
    @NSManaged var clearDate: NSDate
    @NSManaged var clearFlag: NSNumber
    @NSManaged var size: NSNumber
    @NSManaged var stage: String
    @NSManaged var creator: String
}
