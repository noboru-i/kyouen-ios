//
//  SignedRequest.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/08.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation
import OAuthCore

enum SignedRequestMethod {
    case GET
    case POST
    case DELETE
}

typealias SignedRequestHandler = (NSData?, NSURLResponse?, NSError?) -> Void

class SignedRequest: NSObject {
    static var gTKConsumerKey: String? = nil
    static var gTKConsumerSecret: String? = nil

    let authToken: String? = nil
    let authTokenSecret: String? = nil

    var url: NSURL
    var parameters: [String:String]
    var signedRequestMethod: SignedRequestMethod

    init(url: NSURL, parameters: [String:String], requestMethod: SignedRequestMethod) {
        self.url = url
        self.parameters = parameters
        self.signedRequestMethod = requestMethod
        super.init()
    }

    func _buildRequest() -> NSURLRequest {
        let method: String
        switch signedRequestMethod {
        case .POST:
            method = "POST"
        case .DELETE:
            method = "DELETE"
        default:
            method = "GET"
        }

        // Build our parameter string
        var paramsAsString = ""
        for (key, obj) in parameters {
            paramsAsString += "\(key)=\(obj)"
        }

        // Create the authorization header and attach to our request
        let bodyData = paramsAsString.dataUsingEncoding(NSUTF8StringEncoding)
        let authorizationHeader = OAuthorizationHeader(
            url, method, bodyData,
            SignedRequest.consumerKey(), SignedRequest.consumerSecret(),
            authToken, authTokenSecret)
        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = 8
        request.HTTPMethod = method
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.HTTPBody = bodyData
        return request
    }

    func performRequestWithHandler(handler: SignedRequestHandler) {
        NSURLConnection.sendAsynchronousRequest(_buildRequest(), queue: NSOperationQueue.mainQueue(), completionHandler: {response, data, connectionError in
            handler(data, response, nil)
        })
    }

    class func consumerKey() -> String {
        if gTKConsumerKey == nil {
            let bundle = NSBundle.mainBundle()
            if let key = bundle.infoDictionary!["TWITTER_CONSUMER_KEY"] as? String {
                gTKConsumerKey = key
            }
        }
        return gTKConsumerKey!
    }

    class func consumerSecret() -> String {
        if gTKConsumerSecret == nil {
            let bundle = NSBundle.mainBundle()
            if let secret = bundle.infoDictionary!["TWITTER_CONSUMER_SECRET"] as? String! {
                gTKConsumerSecret = secret
            }
        }
        return gTKConsumerSecret!
    }
}
