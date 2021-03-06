//
//  Line.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/01/29.
//  Copyright © 2016年 noboru. All rights reserved.
//

struct Line: CustomStringConvertible {
    private var p1: Point
    private var p2: Point
    var a: Double {
        return p1.y - p2.y
    }
    var b: Double {
        return p2.x - p1.x
    }
    var c: Double {
        return p1.x * p2.y - p2.x * p1.y
    }

    init(p1: Point, p2: Point) {
        self.p1 = p1
        self.p2 = p2
    }

    func getX(_ y: Double) -> Double {
        return -1 * (b * y + c) / a
    }

    func getY(_ x: Double) -> Double {
        return -1 * (a * x + c) / b
    }

    func getIntersection(_ l2: Line) -> Point? {
        let f1 = p2.x - p1.x
        let g1 = p2.y - p1.y
        let f2 = l2.p2.x - l2.p1.x
        let g2 = l2.p2.y - l2.p1.y

        let det = f2 * g1 - f1 * g2
        if det == 0 {
            return nil
        }

        let dx = l2.p1.x - p1.x
        let dy = l2.p1.y - p1.y
        let t1 = (f2 * dy - g2 * dx) / det

        return Point(x: p1.x + f1 * t1, y: p1.y + g1 * t1)
    }

    var description: String {
        return "p1 = \(p1), p2 = \(p2), a = \(a), b = \(b), c = \(c)"
    }
}
