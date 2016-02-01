//
//  GameModel.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/01/30.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

class GameModel: NSObject {
    let size: Int
    let stage: String

    init(size: Int, stage: String) {
        self.size = size
        self.stage = stage
    }

    func getStoneCount(state: Int) -> Int {
        let stateString = Character(String(state))

        var count = 0
        for c in stage.characters {
            if c == stateString {
                count++
            }
        }
        return count
    }

    func isKyouen() -> KyouenData! {

        let points = getStonePoints(2)
        let p1 = points[0]
        let p2 = points[1]
        let p3 = points[2]
        let p4 = points[3]
        // p1,p2の垂直二等分線を求める
        let l12 = getMidperpendicular(p1, p2: p2)
        // p2,p3の垂直二等分線を求める
        let l23 = getMidperpendicular(p2, p2: p3)

        // 交点を求める
        let intersection123 = getIntersection(l12, l2: l23)
        if intersection123 == nil {
            // p1,p2,p3が直線上に存在する場合
            let l34 = getMidperpendicular(p3, p2: p4)
            let intersection234 = getIntersection(l23, l2: l34)
            if intersection234 == nil {
                // p2,p3,p4が直線状に存在する場合
                return KyouenData(p1: p1, p2: p2, p3: p3, p4: p4, line: Line(p1: p1, p2: p2))
            }
        } else {
            let dist1 = getDistance(p1, p2: intersection123)
            let dist2 = getDistance(p4, p2: intersection123)
            if fabs(dist1 - dist2) < 0.0000001 {
                return KyouenData(p1: p1, p2: p2, p3: p3, p4: p4, center: intersection123, radius: dist1)
            }
        }
        return nil
    }

    func getStonePoints(state: Int) -> [TKPoint] {
        let stateString = Character(String(state))

        // 指定されたstateと同一文字の座標を取得
        var points = [TKPoint]()
        for (index, c) in stage.characters.enumerate() {
            if c == stateString {
                let x = index % size
                let y = floor(Double(index) / Double(size))
                points.append(TKPoint(x: Double(x), y: y))
            }
        }
        return points
    }

    // swiftlint:disable:next variable_name
    func getDistance(p1: TKPoint, p2: TKPoint) -> Double {
        return (p1 - p2).abs()
    }

    // swiftlint:disable:next variable_name
    func getIntersection(l1: Line, l2: Line) -> TKPoint! {
        let f1 = l1.p2.x - l1.p1.x
        let g1 = l1.p2.y - l1.p1.y
        let f2 = l2.p2.x - l2.p1.x
        let g2 = l2.p2.y - l2.p1.y

        let det = f2 * g1 - f1 * g2
        if det == 0 {
            return nil
        }

        let dx = l2.p1.x - l1.p1.x
        let dy = l2.p1.y - l1.p1.y
        let t1 = (f2 * dy - g2 * dx) / det

        return TKPoint(x: l1.p1.x + f1 * t1, y: l1.p1.y + g1 * t1)
    }

    // swiftlint:disable:next variable_name
    func getMidperpendicular(p1: TKPoint, p2: TKPoint) -> Line {
        let midpoint = getMidpoint(p1, p2: p2)
        let dif = p1 - p2
        let gradient = TKPoint(x: dif.y, y:-1 * dif.x)

        return Line(p1: midpoint, p2: midpoint + gradient)
    }

    // swiftlint:disable:next variable_name
    func getMidpoint(p1: TKPoint, p2: TKPoint) -> TKPoint {
        return TKPoint(x:(p1.x + p2.x) / 2, y:(p1.y + p2.y) / 2)
    }
}
