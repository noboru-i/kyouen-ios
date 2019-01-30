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

    func getStageData(_ currentMaxStageNo: Int, callback: @escaping (String?, Error?) -> Void) {
        let url = serverDomain + "/kyouen/get"
        Alamofire.request(url, method: .get, parameters: ["stageNo": String(currentMaxStageNo)])
            .responseString { response in
                // TODO: when failed
                if response.result.isSuccess {
                    callback(response.result.value, nil)
                }
            }
    }

    func registUser(_ token: String, tokenSecret: String, callback: @escaping (String?, Error?) -> Void) {
        let url = serverDomain + "/page/api_login"
        Alamofire.request(url, method: .post, parameters: ["token": token, "token_secret": tokenSecret])
            .responseString { response in
                // TODO: when failed
                if response.result.isSuccess {
                    callback(response.result.value, nil)
                }
            }
    }

    func addAllStageUser(_ stages: [TumeKyouenModel], callback: @escaping (NSArray?, Error?) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")

        var sendJson = [[String: String]]()
        for model in stages {
            sendJson.append(
                [
                    "stageNo": String(describing: model.stageNo),
                    "clearDate": formatter.string(from: model.clearDate as Date)
                ]
            )
        }
        print("sendJson = \(sendJson)")

        let sendJsonStr: String
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sendJson, options: [])
            sendJsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        } catch {
            print("Error!: \(error)")
            fatalError("JSON serialization error")
        }
        print("sendJsonStr = \(sendJsonStr)")

        let url = serverDomain + "/page/add_all"
        Alamofire.request(url, method: .post, parameters: ["data": sendJsonStr])
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value as? [String: AnyObject] {
                        let jsonData = json["data"] as? NSArray
                        callback(jsonData, nil)
                        return
                    }
                case .failure(let error):
                    callback(nil, error as NSError?)
                }
            }
    }

    func addStageUser(_ stageNo: NSNumber) {
        let url = serverDomain + "/page/add"
        _ = Alamofire.request(url, method: .post, parameters: ["stageNo": stageNo])
    }
}
