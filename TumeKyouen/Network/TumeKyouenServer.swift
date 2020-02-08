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
    let serverDomain = "https://kyouen.app"

    func getStageData(_ currentMaxStageNo: Int, callback: @escaping (String?, Error?) -> Void) {
        let url = serverDomain + "/kyouen/get"
        AF.request(url, method: .get, parameters: ["stageNo": String(currentMaxStageNo)])
            .responseString { response in
                switch response.result {
                case .success(let value):
                    callback(value, nil)
                case .failure(let error):
                    // TODO handling error
                    print("error: \(error)")
                    return
                }
            }
    }

    func registUser(_ token: String, tokenSecret: String, callback: @escaping (String?, Error?) -> Void) {
        let url = serverDomain + "/page/api_login"
        AF.request(url, method: .post, parameters: ["token": token, "token_secret": tokenSecret])
            .responseString { response in
                switch response.result {
                case .success(let value):
                    callback(value, nil)
                case .failure(let error):
                    // TODO handling error
                    print("error: \(error)")
                    return
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
        AF.request(url, method: .post, parameters: ["data": sendJsonStr])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: AnyObject] {
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
        _ = AF.request(url, method: .post, parameters: ["stageNo": stageNo])
    }

    func postStage(_ data: String, callback: @escaping (AFDataResponse<String>) -> Void) {
        let url = serverDomain + "/kyouen/regist"
        AF.request(url, method: .post, parameters: ["data": data])
            .responseString { response in callback(response) }
    }
}
