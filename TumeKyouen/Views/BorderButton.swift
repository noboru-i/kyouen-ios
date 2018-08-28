//
//  BorderButton.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/11/03.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit

@IBDesignable
class BorderButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0.0

    @IBInspectable var borderColor: UIColor = UIColor.clear
    @IBInspectable var borderWidth: CGFloat = 0.0

    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = (cornerRadius > 0)

        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth

        super.draw(rect)
    }
}
