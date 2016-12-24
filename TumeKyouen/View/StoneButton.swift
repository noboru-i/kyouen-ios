//
//  StoneButton.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/07.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit

class StoneButton: UIButton {
    enum ButtonState: Int {
        case blank = 0
        case black = 1
        case white = 2
    }

    var stoneState: ButtonState = .blank

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(stoneSize: CGFloat, defaultState: ButtonState) {
        super.init(frame: CGRect(x: 0, y: 0, width: stoneSize, height: stoneSize))
        stoneState = defaultState
        addTarget(self, action: #selector(StoneButton.changeState(_:)), for: .touchUpInside)
    }

    func changeState(_: AnyObject) {
        switch stoneState {
        case .blank:
            return
        case .black:
            stoneState = .white
        case .white:
            stoneState = .black
        }
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        let width = bounds.size.width
        let context = UIGraphicsGetCurrentContext()!

        switch stoneState {
        case .black:
            // 黒い石を描画
            context.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            context.fillEllipse(in: CGRect(x: 0, y: 0, width: width, height: width))

            let colorspace = CGColorSpaceCreateDeviceRGB()
            let colorsBuffer = [
                UIColor.init(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0).cgColor,
                UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 1.0).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0.0, 1.0]
            let gradient = CGGradient(colorsSpace: colorspace, colors: colorsBuffer, locations: locations)!
            let center = CGPoint(x: width * 0.4, y: width * 0.4)
            context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: width * 0.3, options: .drawsBeforeStartLocation)
        case .white:
            // 白い石を描画
            context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            context.fillEllipse(in: CGRect(x: 0, y: 0, width: width, height: width))

            let colorspace = CGColorSpaceCreateDeviceRGB()
            let colorsBuffer = [
                UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0.8, alpha: 1.0).cgColor,
                UIColor.init(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0.0, 1.0]
            let gradient = CGGradient(colorsSpace: colorspace, colors: colorsBuffer, locations: locations)!
            let center = CGPoint(x: width * 2 / 5, y: width * 2 / 5)
            context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: width * 2 / 7, options: .drawsBeforeStartLocation)
        case .blank:
            // マス目の描画
            context.setStrokeColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
            let points = [
                CGPoint(x: 0, y: width / 2),
                CGPoint(x: width, y: width / 2),
                CGPoint(x: width / 2, y: 0),
                CGPoint(x: width / 2, y: width)
            ]
            context.setLineWidth(2)
            context.strokeLineSegments(between: points)
        }

        super.draw(rect)
    }
}
