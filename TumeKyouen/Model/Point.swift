//
//  Point.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/01/29.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

// swiftlint:disable variable_name
struct Point: CustomStringConvertible {
    var x: Double
    var y: Double

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    func abs() -> Double {
        return sqrt(self.x * self.x + self.y * self.y)
    }

    func getMidperpendicular(p2: Point) -> Line {
        let midpoint = self.getMidpoint(p2)
        let dif = self - p2
        let gradient = Point(x: dif.y, y:-1 * dif.x)

        return Line(p1: midpoint, p2: midpoint + gradient)
    }

    func getMidpoint(p2: Point) -> Point {
        return Point(x:(self.x + p2.x) / 2, y:(self.y + p2.y) / 2)
    }

    func getDistance(p2: Point) -> Double {
        return (self - p2).abs()
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
// swiftlint:enable variable_name
