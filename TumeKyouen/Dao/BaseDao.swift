//
//  BaseDao.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/03.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BaseDao: NSObject {
    let managedObjectContext: NSManagedObjectContext

    override init() {
        // swiftlint:disable:next force_cast
        let appDelegate = UIApplication.sharedApplication().delegate as! TKAppDelegate
        managedObjectContext = appDelegate.managedObjectContext
    }
}
