//
//  BaseDao.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/03.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit
import CoreData

class BaseDao: NSObject {
    lazy var managedObjectContext: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else {
            abort()
        }
        return appDelegate.managedObjectContext
    }()
}
