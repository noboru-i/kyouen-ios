//
//  TwitterManager.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/08.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Accounts
import Social

typealias ReverseAuthResponseHandler = (Data, Error) -> Void

class TwitterManager {
    typealias TKAPIHandler = (Data?, Error?) -> Void

    class func isLocalTwitterAccountAvailable() -> Bool {
        return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)
    }

    func performReverseAuthForAccount(_ account: ACAccount, withHandler handler: @escaping TKAPIHandler) {
        _step1WithCompletion({data, error in
            if data == nil {
                DispatchQueue.main.async(execute: {
                    handler(nil, error)
                })
            } else {
                let signedReverseAuthSignature = String(data: data!, encoding: String.Encoding.utf8)!
                self._step2WithAccount(account, signature: signedReverseAuthSignature, andHandler: {(responseData, error) in
                    if responseData == nil {
                        return
                    }
                    let responseStr = NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)
                    let parts = responseStr!.components(separatedBy: "&")
                    var oauthToken: NSString! = nil
                    var oauthTokenSecret: NSString! = nil
                    for line in parts {
                        let keyValue = line.components(separatedBy: "=")
                        let key = keyValue[0]
                        if key == "oauth_token" {
                            oauthToken = keyValue[1] as NSString!
                        } else if key == "oauth_token_secret" {
                            oauthTokenSecret = keyValue[1] as NSString!
                        }
                    }

                    if oauthToken != nil && oauthTokenSecret != nil {
                        // 保存する
                        let dao = TwitterTokenDao()
                        dao.saveToken(oauthToken, oauthTokenSecret: oauthTokenSecret)
                    }

                    DispatchQueue.main.async(execute: {
                        handler(responseData, error)
                    })
                })
            }
        })
    }

    func _step1WithCompletion(_ completion: @escaping TKAPIHandler) {
        let url = URL(string: "https://api.twitter.com/oauth/request_token")!
        let dict = ["x_auth_mode" : "reverse_auth"]
        let step1Request = SignedRequest.init(url: url, parameters: dict, requestMethod: SignedRequestMethod.post)
        step1Request.performRequestWithHandler({data, response, error in
            DispatchQueue.global().async(execute: {
                completion(data, error)
            })
        })
    }

    func _step2WithAccount(_ account: ACAccount, signature signedReverseAuthSignature: String, andHandler completion: @escaping TKAPIHandler) {
        let step2Params = [
            "x_reverse_auth_target": SignedRequest.consumerKey(),
            "x_reverse_auth_parameters": signedReverseAuthSignature
        ]
        let authTokenURL = URL(string: "https://api.twitter.com/oauth/access_token")!
        let step2Request = requestWithUrl(authTokenURL, parameters: step2Params, requestMethod: SLRequestMethod.POST)
        step2Request.account = account
        // (Data?, HTTPURLResponse?, Error?) -> Swift.Void
        step2Request.perform(handler: {(responseData, urlResponse, error) -> Void in
            DispatchQueue.global().async(execute: {
                completion(responseData, error)
            })
        })
    }

    func requestWithUrl(_ url: URL, parameters dict: [String:String], requestMethod: SLRequestMethod) -> SLRequest {
        return SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: requestMethod, url: url, parameters: dict)
    }
}
