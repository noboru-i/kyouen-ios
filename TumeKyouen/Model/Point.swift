//
//  Point.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/01/29.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

struct Point: CustomStringConvertible {
    var x: Double
    var y: Double
    var abs: Double {
        return sqrt(x * x + y * y)
    }

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    func getMidperpendicular(_ p2: Point) -> Line {
        let midpoint = getMidpoint(p2)
        let dif = self - p2
        let gradient = Point(x: dif.y, y: -1 * dif.x)

        return Line(p1: midpoint, p2: midpoint + gradient)
    }

    func getMidpoint(_ p2: Point) -> Point {
        return Point(x: (x + p2.x) / 2, y: (y + p2.y) / 2)
    }

    func getDistance(_ p2: Point) -> Double {
        return (self - p2).abs
    }

    var description: String {
        return "x = \(x), y = \(y)"
    }
}

func + (left: Point, right: Point) -> Point {
    return Point(x: left.x + right.x, y: left.y + right.y)
}

func - (left: Point, right: Point) -> Point {
    return Point(x: left.x - right.x, y: left.y - right.y)
}
