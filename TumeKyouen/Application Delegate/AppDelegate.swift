//
//  AppDelegate.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/11.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - Application lifecycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // 例外のハンドリング
        NSSetUncaughtExceptionHandler { exception in
            print(exception.name)
            print(exception.reason)
            print(exception.callStackSymbols.description)
        }

        SVProgressHUD.setDefaultMaskType(.Black)
        SVProgressHUD.setMinimumDismissTimeInterval(0)

        initializeData()

        FIRApp.configure()

        // PUSH通知の設定
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)

        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Badgeの消去
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = "\(deviceToken)"
            .stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString:"<>"))
            .stringByReplacingOccurrencesOfString(" ", withString: "")
        print("deviceToken: \(token)")

        let server = TumeKyouenServer()
        server.registDeviceToken(token)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Errorinregistration:\(error)")
    }

    // MARK: - Core Data stack
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("TumeKyouen", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("TumeKyouen.CDBStore")
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
        } catch {
            NSLog("Unresolved error \(error)")
            abort()
        }

        return coordinator
    }()

    // MARK: - Application's documents directory
    lazy var applicationDocumentsDirectory: NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }()

    // MARK: -
    private func initializeData() {
        let dao = TumeKyouenDao()
        let count = dao.selectCount()
        if count != 0 {
            print("初期データ投入の必要なし")
            return
        }

        let csvUrl = NSBundle.mainBundle().URLForResource("initial_stage", withExtension: "csv")
        do {
            let content = try String(contentsOfURL: csvUrl!, encoding: NSUTF8StringEncoding)
            dao.insertWithCsvString(content)
        } catch {
            print("cannot load initial_stage.csv")
            abort()
        }
    }
}
