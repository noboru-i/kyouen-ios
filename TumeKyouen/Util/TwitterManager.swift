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
    typealias APIHandler = (Data?, Error?) -> Void

    class func isLocalTwitterAccountAvailable() -> Bool {
        return SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)
    }

    func performReverseAuthForAccount(_ account: ACAccount, withHandler handler: @escaping APIHandler) {
        _step1WithCompletion({d, error in
            guard let data = d else {
                DispatchQueue.main.async(execute: {
                    handler(nil, error)
                })
                return
            }
            let signedReverseAuthSignature = String(data: data, encoding: String.Encoding.utf8)!
            self._step2WithAccount(account, signature: signedReverseAuthSignature, andHandler: {(r, error) in
                guard let responseData = r else {
                    return
                }
                let responseStr = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue)!
                let parts = responseStr.components(separatedBy: "&")
                var oauthToken: String? = nil
                var oauthTokenSecret: String? = nil
                parts.forEach { line in
                    let keyValue = line.components(separatedBy: "=")
                    let key = keyValue[0]
                    if key == "oauth_token" {
                        oauthToken = keyValue[1]
                    } else if key == "oauth_token_secret" {
                        oauthTokenSecret = keyValue[1]
                    }
                }

                if oauthToken != nil && oauthTokenSecret != nil {
                    // 保存する
                    let dao = TwitterTokenDao()
                    dao.saveToken(oauthToken!, oauthTokenSecret: oauthTokenSecret!)
                }

                DispatchQueue.main.async(execute: {
                    handler(responseData, error)
                })
            })
        })
    }

    private func _step1WithCompletion(_ completion: @escaping APIHandler) {
        let url = URL(string: "https://api.twitter.com/oauth/request_token")!
        let dict = ["x_auth_mode": "reverse_auth"]
        let step1Request = SignedRequest.init(url: url, parameters: dict, requestMethod: SignedRequestMethod.post)
        step1Request.performRequestWithHandler({data, _, error in
            DispatchQueue.global().async(execute: {
                completion(data, error)
            })
        })
    }

    private func _step2WithAccount(_ account: ACAccount, signature signedReverseAuthSignature: String, andHandler completion: @escaping APIHandler) {
        let step2Params = [
            "x_reverse_auth_target": SignedRequest.consumerKey,
            "x_reverse_auth_parameters": signedReverseAuthSignature
        ]
        let authTokenURL = URL(string: "https://api.twitter.com/oauth/access_token")!
        let step2Request = requestWithUrl(authTokenURL, parameters: step2Params, requestMethod: SLRequestMethod.POST)
        step2Request.account = account
        step2Request.perform(handler: {(responseData, _, error) -> Void in
            DispatchQueue.global().async(execute: {
                completion(responseData, error)
            })
        })
    }

    private func requestWithUrl(_ url: URL, parameters dict: [String:String], requestMethod: SLRequestMethod) -> SLRequest {
        return SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: requestMethod, url: url, parameters: dict)
    }
}
