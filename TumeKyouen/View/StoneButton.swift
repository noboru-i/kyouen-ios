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
        case Blank = 0
        case Black = 1
        case White = 2
    }

    var stoneState: ButtonState = .Blank

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(size: Int, defaultState: ButtonState) {
        var stoneSize: CGFloat = 0
        if size == 6 {
            stoneSize = 51 // 306/6
        } else if size == 9 {
            stoneSize = 34 // 306/9
        } else {
            NSException(name: "IllegalArgumentException", reason: "unknown size", userInfo: nil).raise()
        }

        super.init(frame: CGRect(x: 0, y: 0, width: stoneSize, height: stoneSize))
        stoneState = defaultState
        addTarget(self, action: #selector(StoneButton.changeState(_:)), forControlEvents: .TouchUpInside)
    }

    func changeState(_: AnyObject) {
        switch stoneState {
        case .Blank:
            return
        case .Black:
            stoneState = .White
        case .White:
            stoneState = .Black
        }
        setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        let width = bounds.size.width
        let context = UIGraphicsGetCurrentContext()

        switch stoneState {
        case .Black:
            // 黒い石を描画
            CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0)
            CGContextFillEllipseInRect(context, CGRect(x: 0, y: 0, width: width, height: width))

            let colorspace = CGColorSpaceCreateDeviceRGB()
            let colorsBuffer: CFArray = [
                UIColor.init(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0).CGColor,
                UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 1.0).CGColor
            ]
            let locations: [CGFloat] = [0.0, 1.0]
            let gradient = CGGradientCreateWithColors(colorspace, colorsBuffer, locations)
            let center = CGPoint(x: width * 0.4, y: width * 0.4)
            CGContextDrawRadialGradient(context, gradient, center, 0, center, width * 0.3, .DrawsBeforeStartLocation)
        case .White:
            // 白い石を描画
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0)
            CGContextFillEllipseInRect(context, CGRect(x: 0, y: 0, width: width, height: width))

            let colorspace = CGColorSpaceCreateDeviceRGB()
            let colorsBuffer: CFArray = [
                UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0.8, alpha: 1.0).CGColor,
                UIColor.init(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0).CGColor
            ]
            let locations: [CGFloat] = [0.0, 1.0]
            let gradient = CGGradientCreateWithColors(colorspace, colorsBuffer, locations)
            let center = CGPoint(x: width * 2 / 5, y: width * 2 / 5)
            CGContextDrawRadialGradient(context, gradient, center, 0, center, width * 2 / 7, .DrawsBeforeStartLocation)
        case .Blank:
            // マス目の描画
            CGContextSetRGBStrokeColor(context, 0.25, 0.25, 0.25, 1.0)
            let points = [
                CGPoint(x: 0, y: width / 2),
                CGPoint(x: width, y: width / 2),
                CGPoint(x: width / 2, y: 0),
                CGPoint(x: width / 2, y: width)
            ]
            CGContextSetLineWidth(context, 2)
            CGContextStrokeLineSegments(context, points, 4)
        }

        super.drawRect(rect)
    }
}
