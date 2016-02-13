//
//  TKTumeKyouenDao.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/03.
//  Copyright © 2016年 noboru. All rights reserved.
//

import CoreData

class TumeKyouenDao: BaseDao {
    func insertWithCsvString(csv: String) -> Bool {
        let lines = csv.componentsSeparatedByString("\n")
        for row in lines {
            let items = row.componentsSeparatedByString(",")

            if let newObject = NSEntityDescription.insertNewObjectForEntityForName("TumeKyouenModel", inManagedObjectContext: managedObjectContext) as? TumeKyouenModel {
                newObject.stageNo = Int(items[0])!
                newObject.size = Int(items[1])!
                newObject.stage = items[2]
                newObject.creator = items[3]
            }
        }
        _ = try? managedObjectContext.save()
        return true
    }

    func selectByStageNo(stageNo: Int) -> TumeKyouenModel? {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("TumeKyouenModel", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity

        // 条件
        let predicate = NSPredicate(format: "%K = %ld", "stageNo", stageNo)
        fetchRequest.predicate = predicate

        // 取得
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
            if results.count != 1 {
                return nil
            }

            if let model = results[0] as? TumeKyouenModel {
                return model
            }
        } catch {
            // no-op
        }
        abort()
    }

    func selectCount() -> Int {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("TumeKyouenModel", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity

        // 取得
        var error: NSError? = nil
        let count = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        if count == NSNotFound {
            return 0
        }
        return count
    }

    func selectCountClearStage() -> Int {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("TumeKyouenModel", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity

        // 条件
        let predicate = NSPredicate(format: "%K = %d", "clearFlag", 1)
        fetchRequest.predicate = predicate

        // ソート順
        let stageNoDescriptor = NSSortDescriptor(key: "stageNo", ascending: true)
        fetchRequest.sortDescriptors = [stageNoDescriptor]

        // 取得
        var error: NSError? = nil
        let count = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        if count == NSNotFound {
            return 0
        }
        return count
    }

    func updateClearFlag(model: TumeKyouenModel, date: NSDate = NSDate()) {
        model.clearDate = date
        model.clearFlag = 1

        _ = try? managedObjectContext.save()
    }

    func selectAllClearStage() -> [TumeKyouenModel] {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("TumeKyouenModel", inManagedObjectContext: managedObjectContext)
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

    func updateSyncClearData(clearStages: [NSDictionary]) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "UTC")

        for dic in clearStages {
            if let stageNo = dic["stageNo"] as? Int {
                if let model = selectByStageNo(stageNo) {
                    let clearDateString = dic["clearDate"]
                    if let c = clearDateString as? String {
                        let clearDate = formatter.dateFromString(c)!
                        updateClearFlag(model, date: clearDate)
                    }
                }
            }
        }
    }
}
