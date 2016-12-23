//
//  KyouenData.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/01/30.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

enum KyouenData: CustomStringConvertible {
    case lineKyouen([Point], Line)
    case ovalKyouen([Point], Point, Double)

    var description: String {
        switch self {
        case .lineKyouen(let points, let line):
            return "points = \(points), line = \(line)"
        case .ovalKyouen(let points, let center, let radius):
            return "points = \(points), center = \(center), radius = \(radius)"
        }
    }
}
