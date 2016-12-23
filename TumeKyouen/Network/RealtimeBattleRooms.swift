//
//  RealtimeBattleRooms.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/11/16.
//  Copyright © 2016年 noboru. All rights reserved.
//

import APIKit
import Himotoki

struct RealtimeBattleRoomRequest: TumeKyouenRequestType {
    typealias Response = [RealtimeBattleRoom]

    var method: HTTPMethod {
        return .GET
    }

    var path: String {
        return "/realtime/room"
    }
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        return try decodeArray(object)
    }
}

struct PostRealtimeBattleRoomRequest: TumeKyouenRequestType {
    typealias Response = RealtimeBattleRoom

    var method: HTTPMethod {
        return .POST
    }

    var path: String {
        return "/realtime/room"
    }
}

struct RealtimeBattleRoom: Decodable, KyouenStage {
    let id: Int
    let size: Int
    let stage: String
    let startDate: NSDate
    let updateDate: NSDate
    let player1: BattleUser
    let player2: BattleUser?

    static func decode(extractor: Extractor) throws -> RealtimeBattleRoom {
        return try RealtimeBattleRoom (
            id: extractor <| "id",
            size: extractor <| "size",
            stage: extractor <| "stage",
            startDate: dateTimeTransformer.apply(extractor <| "startDate"),
            updateDate: dateTimeTransformer.apply(extractor <| "updateDate"),
            player1: extractor <| "player1",
            player2: extractor <|? "player2"
        )
    }
}

struct BattleUser: Decodable {
    let screenName: String

    static func decode(extractor: Extractor) throws -> BattleUser {
        return try BattleUser (
            screenName: extractor <| "screenName"
        )
    }
}

public let dateTimeTransformer = Transformer<String, NSDate> { dateString throws -> NSDate in
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS'"
    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")

    if let date = dateFormatter.dateFromString(dateString) {
        return date
    }

    throw customError("Invalid datetime string: \(dateString)")
}
