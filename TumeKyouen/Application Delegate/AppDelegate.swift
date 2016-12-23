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
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // 例外のハンドリング
        NSSetUncaughtExceptionHandler { exception in
            print(exception.name)
            print(exception.reason ?? "")
            print(exception.callStackSymbols.description)
        }

        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setMinimumDismissTimeInterval(0)

        initializeData()

        FIRApp.configure()

        // PUSH通知の設定
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.registerUserNotificationSettings(settings)

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Badgeの消去
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = "\(deviceToken)"
            .trimmingCharacters(in: CharacterSet(charactersIn:"<>"))
            .replacingOccurrences(of: " ", with: "")
        print("deviceToken: \(token)")

        let server = TumeKyouenServer()
        server.registDeviceToken(token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Errorinregistration:\(error)")
    }

    // MARK: - Core Data stack
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "TumeKyouen", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let storeURL = self.applicationDocumentsDirectory.appendingPathComponent("TumeKyouen.CDBStore")
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch {
            NSLog("Unresolved error \(error)")
            abort()
        }

        return coordinator
    }()

    // MARK: - Application's documents directory
    lazy var applicationDocumentsDirectory: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }()

    // MARK: -
    fileprivate func initializeData() {
        let dao = TumeKyouenDao()
        let count = dao.selectCount()
        if count != 0 {
            print("初期データ投入の必要なし")
            return
        }

        let csvUrl = Bundle.main.url(forResource: "initial_stage", withExtension: "csv")
        do {
            let content = try String(contentsOf: csvUrl!, encoding: String.Encoding.utf8)
            dao.insertWithCsvString(content)
        } catch {
            print("cannot load initial_stage.csv")
            abort()
        }
    }
}
