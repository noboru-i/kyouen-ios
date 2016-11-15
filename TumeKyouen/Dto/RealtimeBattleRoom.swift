//
//  RealtimeBattleRoom.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/11/13.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

struct RealtimeBattleRoom {
    var player1: User
    var player2: User
    var size: Int
    var stage: String
    var startDate: String
    var updateDate: String
}

struct User {
    var scscreenName: String
}
