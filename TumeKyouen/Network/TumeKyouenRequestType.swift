//
//  TumeKyouenRequest.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/11/16.
//  Copyright © 2016年 noboru. All rights reserved.
//

import APIKit
import Himotoki

protocol TumeKyouenRequestType: RequestType { }

extension TumeKyouenRequestType {
    var baseURL: NSURL {
        return NSURL(string: "http://my-android-server.appspot.com:8080")!
    }
    func interceptObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> AnyObject {
        guard URLResponse.statusCode != 401 else {
            throw UnAuthorizedError(object: object)
        }

        return object
    }

    func interceptURLRequest(URLRequest: NSMutableURLRequest) throws -> NSMutableURLRequest {
        NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies?
            .filter({ (cookie) -> Bool in
                return cookie.name == "sid"
            })
            .forEach({ (cookie) in
                URLRequest.addValue(String.init(format: "%@=%@", cookie.name, cookie.value), forHTTPHeaderField: "Cookie")
            })
        return URLRequest
    }
}

extension TumeKyouenRequestType where Response: Decodable {
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
}

struct UnAuthorizedError: ErrorType {
    let loggedin: Bool

    init(object: AnyObject) {
        let dictionary = object as? [String: Any]
        loggedin = dictionary?["loggedin"] as? Bool ?? true
    }
}
