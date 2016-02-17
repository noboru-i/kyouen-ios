//
//  KyouenData.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/01/30.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

// swiftlint:disable variable_name
enum KyouenData: CustomStringConvertible {
    case LineKyouen([Point], Line)
    case OvalKyouen([Point], Point, Double)

    var description: String {
        switch self {
        case .LineKyouen(let points, let line):
            return "points = \(points), line = \(line)"
        case .OvalKyouen(let points, let center, let radius):
            return "points = \(points), center = \(center), radius = \(radius)"
        }
    }
}
// swiftlint:enable variable_name
