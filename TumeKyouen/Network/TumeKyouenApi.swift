//
//  TumeKyouenApi.swift
//  TumeKyouen
//
//  Created by noboru-i on 2018/09/03.
//  Copyright © 2018 noboru. All rights reserved.
//

import Foundation
import Moya

enum TumeKyouenApi {
    case getKyouen(Int)
}

extension TumeKyouenApi: TargetType {
    var baseURL: URL { return URL(string: "https://kyouen.app")! }
    var path: String {
        switch self {
        case .getKyouen:
            return "/kyouen/get"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getKyouen:
            return .get
        }
    }
    var task: Task {
        switch self {
        case let .getKyouen(currentMaxStageNo):
            return .requestParameters(parameters: ["stageNo": String(currentMaxStageNo)], encoding: URLEncoding.queryString)
        }
    }
    var sampleData: Data {
        switch self {
        case .getKyouen:
            return "no_data".utf8Encoded
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - Helpers

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
