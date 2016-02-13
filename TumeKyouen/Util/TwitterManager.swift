//
//  TwitterManager.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/08.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Accounts
import Twitter

typealias ReverseAuthResponseHandler = (NSData, NSError) -> Void

class TwitterManager {
    typealias TKAPIHandler = (NSData?, NSError?) -> Void

    class func isLocalTwitterAccountAvailable() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    }

    func performReverseAuthForAccount(account: ACAccount, withHandler handler: TKAPIHandler) {
        _step1WithCompletion({data, error in
            if data == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    handler(nil, error)
                })
            } else {
                let signedReverseAuthSignature = String(data: data!, encoding: NSUTF8StringEncoding)!
                self._step2WithAccount(account, signature: signedReverseAuthSignature, andHandler: {(responseData, error) in
                    if responseData == nil {
                        return
                    }
                    let responseStr = NSString(data: responseData!, encoding: NSUTF8StringEncoding)
                    let parts = responseStr!.componentsSeparatedByString("&")
                    var oauthToken: NSString! = nil
                    var oauthTokenSecret: NSString! = nil
                    for line in parts {
                        let keyValue = line.componentsSeparatedByString("=")
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
                        dao.saveToken(oauthToken, oauthTokenSecret: oauthTokenSecret)
                    }

                    dispatch_async(dispatch_get_main_queue(), {
                        handler(responseData, error)
                    })
                })
            }
        })
    }

    func _step1WithCompletion(completion: TKAPIHandler) {
        let url = NSURL(string: "https://api.twitter.com/oauth/request_token")!
        let dict = ["x_auth_mode" : "reverse_auth"]
        let step1Request = SignedRequest.init(url: url, parameters: dict, requestMethod: SignedRequestMethod.POST)
        step1Request.performRequestWithHandler({data, response, error in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                completion(data, error)
            })
        })
    }

    func _step2WithAccount(account: ACAccount, signature signedReverseAuthSignature: String, andHandler completion: TKAPIHandler) {
        let step2Params = [
            "x_reverse_auth_target": SignedRequest.consumerKey(),
            "x_reverse_auth_parameters": signedReverseAuthSignature
        ]
        let authTokenURL = NSURL(string: "https://api.twitter.com/oauth/access_token")!
        let step2Request = requestWithUrl(authTokenURL, parameters: step2Params, requestMethod: SLRequestMethod.POST)
        step2Request.account = account
        step2Request.performRequestWithHandler({responseData, urlResponse, error in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                completion(responseData, error)
            })
        })
    }

    func requestWithUrl(url: NSURL, parameters dict: [String:String], requestMethod: SLRequestMethod) -> SLRequest {
        return SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: requestMethod, URL: url, parameters: dict)
    }
}
