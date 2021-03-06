//
//  TKTumeKyouenDao.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/03.
//  Copyright © 2016年 noboru. All rights reserved.
//

import CoreData

class TumeKyouenDao: BaseDao {
    func insertWithCsvString(_ csv: String) {
        let lines = csv.components(separatedBy: "\n")
        lines.forEach { (row) in
            let items = row.components(separatedBy: ",")

            if let newObject = NSEntityDescription.insertNewObject(forEntityName: "TumeKyouenModel", into: managedObjectContext) as? TumeKyouenModel {
                newObject.stageNo = NSNumber.init(value: Int(items[0])!)
                newObject.size = NSNumber.init(value: Int(items[1])!)
                newObject.stage = items[2]
                newObject.creator = items[3]
            }
        }
        _ = try? managedObjectContext.save()
    }

    func selectByStageNo(_ stageNo: Int) -> TumeKyouenModel? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "TumeKyouenModel", in: managedObjectContext)
        fetchRequest.entity = entity

        // 条件
        let predicate = NSPredicate(format: "%K = %ld", "stageNo", stageNo)
        fetchRequest.predicate = predicate

        // 取得
        guard let results = try? managedObjectContext.fetch(fetchRequest) else {
            return nil
        }
        if results.count != 1 {
            return nil
        }
        if let model = results[0] as? TumeKyouenModel {
            return model
        }
        abort()
    }

    func selectCount() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "TumeKyouenModel", in: managedObjectContext)
        fetchRequest.entity = entity

        // 取得
        guard let count = try? managedObjectContext.count(for: fetchRequest) else {
            return 0
        }
        return count
    }

    func selectCountClearStage() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "TumeKyouenModel", in: managedObjectContext)
        fetchRequest.entity = entity

        // 条件
        let predicate = NSPredicate(format: "%K = %d", "clearFlag", 1)
        fetchRequest.predicate = predicate

        // ソート順
        let stageNoDescriptor = NSSortDescriptor(key: "stageNo", ascending: true)
        fetchRequest.sortDescriptors = [stageNoDescriptor]

        // 取得
        guard let count = try? managedObjectContext.count(for: fetchRequest) else {
                return 0
        }
        return count
    }

    func updateClearFlag(_ model: TumeKyouenModel, date: Date = Date()) {
        model.clearDate = date
        model.clearFlag = 1

        _ = try? managedObjectContext.save()
    }

    func selectAllClearStage() -> [TumeKyouenModel] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "TumeKyouenModel", in: managedObjectContext)
        fetchRequest.entity = entity

        // 条件
        let predicate = NSPredicate(format: "%K = %d", "clearFlag", 1)
        fetchRequest.predicate = predicate

        // ソート順
        let stageNoDescriptor = NSSortDescriptor(key: "stageNo", ascending: true)
        fetchRequest.sortDescriptors = [stageNoDescriptor]

        // 取得
        let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        _ = try? resultsController.performFetch()
        if let results = resultsController.fetchedObjects as? [TumeKyouenModel] {
            return results
        }
        return []
    }

    func updateSyncClearData(_ clearStages: [NSDictionary]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")

        clearStages.forEach { (dic) in
            if let stageNo = dic["stageNo"] as? Int {
                if let model = selectByStageNo(stageNo) {
                    let clearDateString = dic["clearDate"]
                    if let c = clearDateString as? String {
                        let clearDate = formatter.date(from: c)!
                        updateClearFlag(model, date: clearDate)
                    }
                }
            }
        }
    }
}
