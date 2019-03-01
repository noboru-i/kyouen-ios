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

    func getStoneCount(_ state: Int) -> Int {
        let stateString = Character(String(state))

        return stage.reduce(0) { (count, c) -> Int in
            count + (c == stateString ? 1 : 0)
        }
    }

    func hasKyouen() -> KyouenData? {
        let stonePoints = getStonePoints(1)
        if stonePoints.count < 4 {
            return nil
        }
        for i in 0..<(stonePoints.count - 3) {
            let p1 = stonePoints[i]
            for j in (i+1)..<(stonePoints.count - 2) {
                let p2 = stonePoints[j]
                for k in (j+1)..<(stonePoints.count - 1) {
                    let p3 = stonePoints[k]
                    for l in (k+1)..<stonePoints.count {
                        let p4 = stonePoints[l]
                        let kyouen = isKyouen(points: [p1, p2, p3, p4])
                        if kyouen != nil {
                            return kyouen
                        }
                    }
                }
            }
        }
        return nil
    }

    func isKyouen() -> KyouenData! {
        let points = getStonePoints(2)
        return isKyouen(points: points)
    }

    private func getStonePoints(_ state: Int) -> [Point] {
        let stateString = Character(String(state))

        // 指定されたstateと同一文字の座標を取得
        var points = [Point]()
        for (index, c) in stage.enumerated() where c == stateString {
            let x = index % size
            let y = floor(Double(index) / Double(size))
            points.append(Point(x: Double(x), y: y))
        }
        return points
    }

    private func isKyouen(points: [Point]) -> KyouenData? {
        let (p1, p2, p3, p4) = (points[0], points[1], points[2], points[3])
        // p1,p2の垂直二等分線を求める
        let l12 = p1.getMidperpendicular(p2)
        // p2,p3の垂直二等分線を求める
        let l23 = p2.getMidperpendicular(p3)

        // 交点を求める
        guard let intersection123 = l12.getIntersection(l23) else {
            // p1,p2,p3が直線上に存在する場合
            let l34 = p3.getMidperpendicular(p4)
            let intersection234 = l23.getIntersection(l34)
            if intersection234 == nil {
                // p2,p3,p4が直線状に存在する場合
                return KyouenData.lineKyouen([p1, p2, p3, p4], Line(p1: p1, p2: p2))
            }
            return nil
        }

        let dist1 = p1.getDistance(intersection123)
        let dist2 = p4.getDistance(intersection123)
        if fabs(dist1 - dist2) < 0.0000001 {
            return KyouenData.ovalKyouen([p1, p2, p3, p4], intersection123, dist1)
        }
        return nil
    }
}
