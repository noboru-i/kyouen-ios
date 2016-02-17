//
//  GameModel.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/01/30.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

struct GameModel {
    let size: Int
    let stage: String

    init(size: Int, stage: String) {
        self.size = size
        self.stage = stage
    }

    func getStoneCount(state: Int) -> Int {
        let stateString = Character(String(state))

        return stage.characters.reduce(0) { (count, c) -> Int in
            count + (c == stateString ? 1 : 0)
        }
    }

    func isKyouen() -> KyouenData! {

        let points = getStonePoints(2)
        let (p1, p2, p3, p4) = (points[0], points[1], points[2], points[3])
        // p1,p2の垂直二等分線を求める
        let l12 = p1.getMidperpendicular(p2)
        // p2,p3の垂直二等分線を求める
        let l23 = p2.getMidperpendicular(p3)

        // 交点を求める
        let intersection123 = l12.getIntersection(l23)
        if intersection123 == nil {
            // p1,p2,p3が直線上に存在する場合
            let l34 = p3.getMidperpendicular(p4)
            let intersection234 = l23.getIntersection(l34)
            if intersection234 == nil {
                // p2,p3,p4が直線状に存在する場合
                return KyouenData(
                    p1: p1,
                    p2: p2,
                    p3: p3,
                    p4: p4,
                    line: Line(p1: p1, p2: p2))
            }
        } else {
            let dist1 = p1.getDistance(intersection123)
            let dist2 = p4.getDistance(intersection123)
            if fabs(dist1 - dist2) < 0.0000001 {
                return KyouenData(p1: p1, p2: p2, p3: p3, p4: p4, center: intersection123, radius: dist1)
            }
        }
        return nil
    }

    func getStonePoints(state: Int) -> [Point] {
        let stateString = Character(String(state))

        // 指定されたstateと同一文字の座標を取得
        var points = [Point]()
        for (index, c) in stage.characters.enumerate() {
            if c == stateString {
                let x = index % size
                let y = floor(Double(index) / Double(size))
                points.append(Point(x: Double(x), y: y))
            }
        }
        return points
    }
}
