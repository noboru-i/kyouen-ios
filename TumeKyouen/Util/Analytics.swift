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
        case Kyouen = "kyouen"
        case Not4Stone = "kyouen - not 4 stone"
        case NotKyouen = "kyouen - not selected"
    }

    class func sendShowEvent(stageNo: NSNumber) {
        FIRAnalytics.logEventWithName(kFIREventViewItem, parameters: [
            kFIRParameterContentType: "stage",
            kFIRParameterValue: stageNo.stringValue
            ]
        )
    }

    class func sendKyouenEvent(event: KyouenEvent, stageNo: NSNumber) {
        FIRAnalytics.logEventWithName(kFIREventViewItem, parameters: [
            kFIRParameterContentType: event.rawValue,
            kFIRParameterValue: stageNo.stringValue
            ]
        )
    }
}
