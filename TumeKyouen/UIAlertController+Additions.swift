//
//  UIAlertController+Additions.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/13.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit

extension UIAlertController {

    static func alert(titleKey: String) -> UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString(titleKey, comment: ""),
            message: nil,
            preferredStyle: .Alert
        )
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)

        return alert
    }
}
