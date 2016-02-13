//
//  KyouenData.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/01/30.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

// swiftlint:disable variable_name
class KyouenData: CustomStringConvertible {
    var points: [Point]
    var isLine: Bool
    var center: Point?
    var radius: Double
    var line: Line?

    init(p1: Point, p2: Point, p3: Point, p4: Point, line: Line) {
        self.points = [p1, p2, p3, p4]
        self.isLine = true
        self.center = nil
        self.radius = 0
        self.line = line
    }

    // swiftlint:disable:next function_parameter_count
    init(p1: Point, p2: Point, p3: Point, p4: Point, center: Point, radius: Double) {
        self.points = [p1, p2, p3, p4]
        self.isLine = false
        self.center = center
        self.radius = radius
        self.line = nil
    }

    var description: String {
        return "points = \(points), isLine = \(isLine), center = \(center), radius = \(radius), line = \(line)"
    }
}
// swiftlint:enable variable_name
