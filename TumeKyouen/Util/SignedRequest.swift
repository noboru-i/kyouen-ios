//
//  SignedRequest.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/08.
//  Copyright © 2016年 noboru. All rights reserved.
//

import OAuthCore

enum SignedRequestMethod {
    case get
    case post
    case delete
}

typealias SignedRequestHandler = (Data?, URLResponse?, NSError?) -> Void

class SignedRequest {
    static var gTKConsumerKey: String? = nil
    static var gTKConsumerSecret: String? = nil

    let authToken: String? = nil
    let authTokenSecret: String? = nil

    var url: URL
    var parameters: [String:String]
    var signedRequestMethod: SignedRequestMethod

    init(url: URL, parameters: [String:String], requestMethod: SignedRequestMethod) {
        self.url = url
        self.parameters = parameters
        self.signedRequestMethod = requestMethod
    }

    func _buildRequest() -> URLRequest {
        let method: String
        switch signedRequestMethod {
        case .post:
            method = "POST"
        case .delete:
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
        let bodyData = paramsAsString.data(using: String.Encoding.utf8)
        let authorizationHeader = OAuthorizationHeader(
            url, method, bodyData,
            SignedRequest.consumerKey(), SignedRequest.consumerSecret(),
            authToken, authTokenSecret)
        let request = NSMutableURLRequest(url: url)
        request.timeoutInterval = 8
        request.httpMethod = method
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.httpBody = bodyData
        return request as URLRequest
    }

    func performRequestWithHandler(_ handler: @escaping SignedRequestHandler) {
        NSURLConnection.sendAsynchronousRequest(_buildRequest(), queue: OperationQueue.main, completionHandler: {response, data, connectionError in
            handler(data, response, nil)
        })
    }

    class func consumerKey() -> String {
        if gTKConsumerKey == nil {
            let bundle = Bundle.main
            if let key = bundle.infoDictionary!["TWITTER_CONSUMER_KEY"] as? String {
                gTKConsumerKey = key
            }
        }
        return gTKConsumerKey!
    }

    class func consumerSecret() -> String {
        if gTKConsumerSecret == nil {
            let bundle = Bundle.main
            if let secret = bundle.infoDictionary!["TWITTER_CONSUMER_SECRET"] as? String! {
                gTKConsumerSecret = secret
            }
        }
        return gTKConsumerSecret!
    }
}
