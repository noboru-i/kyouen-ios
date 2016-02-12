//
//  Line.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/01/29.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

// swiftlint:disable variable_name
class Line: NSObject {
    var p1: Point
    var p2: Point
    var a: Double
    var b: Double
    var c: Double

    init(p1: Point, p2: Point) {
        self.p1 = p1
        self.p2 = p2

        self.a = p1.y - p2.y
        self.b = p2.x - p1.x
        self.c = p1.x * p2.y - p2.x * p1.y
    }

    func getX(y: Double) -> Double {
        return -1 * (self.b * y + self.c) / self.a
    }

    func getY(x: Double) -> Double {
        return -1 * (self.a * x + self.c) / self.b
    }

    override var description: String {
        return "p1 = \(p1), p2 = \(p2), a = \(a), b = \(b), c = \(c)"
    }
}
// swiftlint:enable variable_name
