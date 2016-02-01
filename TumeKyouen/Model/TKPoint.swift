//
//  Point.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/01/29.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

// swiftlint:disable variable_name
class TKPoint: NSObject {
    var x: Double
    var y: Double

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    func abs() -> Double {
        return sqrt(self.x * self.x + self.y * self.y)
    }

    override var description: String {
        return "x = \(x), y = \(y)"
    }
}

func + (left: TKPoint, right: TKPoint) -> TKPoint {
    return TKPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: TKPoint, right: TKPoint) -> TKPoint {
    return TKPoint(x: left.x - right.x, y: left.y - right.y)
}
// swiftlint:enable variable_name
