//
//  AppDelegate.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/11.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import SVProgressHUD
import Firebase
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - Application lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 例外のハンドリング
        NSSetUncaughtExceptionHandler { exception in
            print(exception.name)
            print(exception.reason ?? "")
            print(exception.callStackSymbols.description)
        }

        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setMinimumDismissTimeInterval(0)

        initializeData()

        FirebaseApp.configure()

        TWTRTwitter.sharedInstance().start(withConsumerKey: SignedRequest.consumerKey,
                                       consumerSecret: SignedRequest.consumerSecret)

        // PUSH通知の設定
        // TODO need this? https://github.com/firebase/quickstart-ios/blob/f6e361242d3cb660a528ff87b05d61db8ab38082/messaging/MessagingExampleSwift/AppDelegate.swift#L117
//        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        Messaging.messaging().subscribe(toTopic: "all") { error in
            print("Subscribed to 'all' topic \(error.debugDescription)")
        }

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType != NSUserActivityTypeBrowsingWeb {
            return false
        }
        if handleUniversalLinks(userActivity) {
            return true
        }

        let alert = UIAlertController.alert("alert_fetch_first")
        guard let navigationController = window?.rootViewController as? UINavigationController else {
            return false
        }
        navigationController.present(alert, animated: true, completion: nil)
        return true
    }

    private func handleUniversalLinks(_ userActivity: NSUserActivity) -> Bool {
        guard let webpageURL = userActivity.webpageURL else {
            return false
        }
        guard let stageNo = getStageNo(url: webpageURL) else {
            return false
        }
        guard let model = TumeKyouenDao().selectByStageNo(stageNo) else {
            return false
        }
        let kyouenStoryboard: UIStoryboard = UIStoryboard(name: "KyouenStoryboard", bundle: Bundle.main)
        let kyouenViewController: UIViewController? = kyouenStoryboard.instantiateInitialViewController()
        guard let vc = kyouenViewController as? KyouenViewController else {
            return false
        }
        guard let navigationController = window?.rootViewController as? UINavigationController else {
            return false
        }

        vc.currentModel = model
        navigationController.pushViewController(kyouenViewController!, animated: true)
        return true
    }

    private func getStageNo(url webpageURL: URL) -> Int? {
        if let components = NSURLComponents(url: webpageURL, resolvingAgainstBaseURL: true), let pathComponents = components.queryItems {
            for item in pathComponents where item.name == "open" {
                if let number = item.value {
                    return Int(number)
                }
            }
        }
        return nil
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Badgeの消去
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = "\(deviceToken)"
            .trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
            .replacingOccurrences(of: " ", with: "")
        print("deviceToken: \(token)")

        // no need to send to my server (use Firebase topic).
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Errorinregistration:\(error)")
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
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
    private func initializeData() {
        let dao = TumeKyouenDao()
        if dao.selectCount() != 0 {
            print("初期データ投入の必要なし")
            return
        }

        let csvUrl = Bundle.main.url(forResource: "initial_stage", withExtension: "csv")!
        let content = try? String(contentsOf: csvUrl, encoding: String.Encoding.utf8)
        dao.insertWithCsvString(content!)
    }
}
