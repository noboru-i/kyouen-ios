//
//  OverlayKyouenView.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/07.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit

class OverlayKyouenView: UIView {
    var kyouenData: KyouenData?
    var tumeKyouenModel: TumeKyouenModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func drawKyouen(_ kyouenData: KyouenData, tumeKyouenModel: TumeKyouenModel) {
        self.kyouenData = kyouenData
        self.tumeKyouenModel = tumeKyouenModel
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let kyouenData = self.kyouenData else {
            alpha = 0
            return
        }

        alpha = 1
        let context = UIGraphicsGetCurrentContext()
        context!.setStrokeColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        context!.setLineWidth(3)

        let width = Double(bounds.size.width)
        let size = Double(tumeKyouenModel!.size)
        let stoneSize: Double = 306.0 / Double(size)
        switch kyouenData {
        case .lineKyouen(_, let line):
            // 直線の場合
            drawLine(context, line: line, size: size, width: width, stoneSize: stoneSize)
        case .ovalKyouen(_, let center, let radius):
            // 円の場合
            drawOval(context, center: center, radius: radius, stoneSize: stoneSize)
        }

        self.kyouenData = nil
        super.draw(rect)
    }

    fileprivate func drawLine(_ context: CGContext?, line: Line, size: Double, width: Double, stoneSize: Double) {
        var startX: Double = 0.0
        var startY: Double = 0.0
        var endX: Double = 0.0
        var endY: Double = 0.0
        if line.a == 0 {
            // x軸と並行な場合
            startX = 0
            startY = (line.getY(0) + 0.5) * stoneSize
            endX = width
            endY = (line.getY(width) + 0.5) * stoneSize
        } else if line.b == 0 {
            // y軸と並行な場合
            startX = (line.getX(0) + 0.5) * stoneSize
            startY = 0
            endX = (line.getX(width) + 0.5) * stoneSize
            endY = width
        } else {
            // 斜めの場合
            if line.c / line.b < 0 {
                startX = (line.getX(-0.5) + 0.5) * stoneSize
                startY = 0
                endX = (line.getX(size - 0.5) + 0.5) * stoneSize
                endY = width
            } else {
                startX = 0
                startY = (line.getY(-0.5) + 0.5) * stoneSize
                endX = width
                endY = (line.getY(size - 0.5) + 0.5) * stoneSize
            }
        }

        let points = [
            CGPoint(x: CGFloat(startX), y: CGFloat(startY)),
            CGPoint(x: CGFloat(endX), y: CGFloat(endY))
        ]
        context!.strokeLineSegments(between: points)
    }

    fileprivate func drawOval(_ context: CGContext?, center: Point, radius: Double, stoneSize: Double) {
        let cx = (center.x + 0.5) * stoneSize
        let cy = (center.y + 0.5) * stoneSize
        let radius = radius * stoneSize
        let rectEllipse = CGRect(
            x: CGFloat(cx - radius),
            y: CGFloat(cy - radius),
            width: CGFloat(radius * 2),
            height: CGFloat(radius * 2))
        context!.strokeEllipse(in: rectEllipse)
    }
}
