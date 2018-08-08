//
//  SignedRequest.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/08.
//  Copyright © 2016年 noboru. All rights reserved.
//

import OAuthCore

class SignedRequest {
    static var consumerKey: String {
        let bundle = Bundle.main
        if let key = bundle.infoDictionary!["TWITTER_CONSUMER_KEY"] as? String {
            return key
        }
        abort()
    }
    static var consumerSecret: String {
        let bundle = Bundle.main
        if let secret = bundle.infoDictionary!["TWITTER_CONSUMER_SECRET"] as? String {
            return secret
        }
        abort()
    }
}
