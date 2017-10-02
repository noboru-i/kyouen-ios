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
    static var consumerKey: String {
        let bundle = Bundle.main
        if let key = bundle.infoDictionary!["TWITTER_CONSUMER_KEY"] as? String {
            return key
        }
        abort()
    }
    static var consumerSecret: String {
        let bundle = Bundle.main
        if let secret = bundle.infoDictionary!["TWITTER_CONSUMER_SECRET"] as? String! {
            return secret
        }
        abort()
    }

    private var url: URL
    private var parameters: [String:String]
    private var signedRequestMethod: SignedRequestMethod

    init(url: URL, parameters: [String:String], requestMethod: SignedRequestMethod) {
        self.url = url
        self.parameters = parameters
        self.signedRequestMethod = requestMethod
    }

    func buildRequest() -> URLRequest {
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
            SignedRequest.consumerKey, SignedRequest.consumerSecret,
            nil, nil)
        let request = NSMutableURLRequest(url: url)
        request.timeoutInterval = 8
        request.httpMethod = method
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.httpBody = bodyData
        return request as URLRequest
    }

    func performRequestWithHandler(_ handler: @escaping SignedRequestHandler) {
        NSURLConnection.sendAsynchronousRequest(buildRequest(), queue: OperationQueue.main, completionHandler: {response, data, _ in
            handler(data, response, nil)
        })
    }
}
