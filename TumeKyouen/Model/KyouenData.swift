//
//  KyouenData.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/01/30.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

class KyouenData: NSObject {
    var points: [TKPoint]
    var isLine: Bool
    var center: TKPoint!
    var radius: Double
    var line: Line!

    // swiftlint:disable:next variable_name
    init(p1: TKPoint, p2: TKPoint, p3: TKPoint, p4: TKPoint, line: Line) {
        self.points = [p1, p2, p3, p4]
        self.isLine = true
        self.center = nil
        self.radius = 0
        self.line = line
    }

    // swiftlint:disable:next variable_name
    init(p1: TKPoint, p2: TKPoint, p3: TKPoint, p4: TKPoint, center: TKPoint, radius: Double) {
        self.points = [p1, p2, p3, p4]
        self.isLine = false
        self.center = center
        self.radius = radius
        self.line = nil
    }

    override var description: String {
        return "points = \(points), isLine = \(isLine), center = \(center), radius = \(radius), line = \(line)"
    }
}
