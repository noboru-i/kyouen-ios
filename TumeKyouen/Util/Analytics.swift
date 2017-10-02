//
//  Analytics.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/11/07.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Firebase

class Analytics {

    enum KyouenEvent: String {
        case kyouen = "kyouen"
        case not4Stone = "kyouen - not 4 stone"
        case notKyouen = "kyouen - not selected"
    }

    class func sendShowEvent(_ stageNo: NSNumber) {
        FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [
            kFIRParameterContentType: "stage" as NSObject,
            kFIRParameterValue: stageNo.stringValue as NSObject
            ]
        )
    }

    class func sendKyouenEvent(_ event: KyouenEvent, stageNo: NSNumber) {
        FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [
            kFIRParameterContentType: event.rawValue as NSObject,
            kFIRParameterValue: stageNo.stringValue as NSObject
            ]
        )
    }
}
