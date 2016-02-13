//
//  TKTumeKyouenServer.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/01/24.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation
import Alamofire

class TumeKyouenServer {
    //#define SERVER_DOMAIN @"https://my-android-server.appspot.com"
    //// #define SERVER_DOMAIN @"http://kyouen.jp:8080"
    let serverDomain = "https://my-android-server.appspot.com"

    func getStageData(currentMaxStageNo: Int, callback: (String!, NSError!) -> Void) {
        let url = serverDomain + "/kyouen/get"
        Alamofire.request(.GET, url, parameters: ["stageNo": String(currentMaxStageNo)])
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
                // TODO: when failed
                if response.result.isSuccess {
                    callback(response.result.value, nil)
                }
            }
    }

    func registUser(token: NSString, tokenSecret: NSString, callback: (NSString!, NSError!) -> Void) {
        let url = serverDomain + "/page/api_login"
        Alamofire.request(.POST, url, parameters: ["token": token, "token_secret": tokenSecret])
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
                // TODO: when failed
                if response.result.isSuccess {
                    callback(response.result.value, nil)
                }
            }
    }

    func addAllStageUser(stages: [TumeKyouenModel], callback: (NSArray!, NSError!) -> Void) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "UTC")

        var sendJson = [Dictionary<String, String>]()
        for model in stages {
            sendJson.append(
                [
                    "stageNo": String(model.stageNo),
                    "clearDate": formatter.stringFromDate(model.clearDate)
                ]
            )
        }
        print("sendJson = \(sendJson)")

        let sendJsonStr: String
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(sendJson, options: [])
            sendJsonStr = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
        } catch {
            print("Error!: \(error)")
            fatalError("JSON serialization error")
        }
        print("sendJsonStr = \(sendJsonStr)")

        let url = serverDomain + "/page/add_all"
        Alamofire.request(.POST, url, parameters: ["data": sendJsonStr])
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let JSON = response.result.value {
                        let jsonData = JSON["data"] as? NSArray
                        print("jsonData: \(jsonData)")
                        callback(jsonData, nil)
                        return
                    }
                    callback(nil, nil)
                case .Failure(let error):
                    callback(nil, error)
                }
            }
    }

    func addStageUser(stageNo: NSNumber) {
        let url = serverDomain + "/page/add"
        Alamofire.request(.POST, url, parameters: ["stageNo": stageNo])
    }

    func registDeviceToken(deviceToken: NSString) {
        let url = serverDomain + "/apns/regist"
        Alamofire.request(.POST, url, parameters: ["device_token": deviceToken])
    }
}
