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
}

extension TumeKyouenRequestType where Response: Decodable {
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
}
