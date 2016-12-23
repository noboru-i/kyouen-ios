//
//  TKTwitterTokenDao.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/03.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

class TwitterTokenDao {
    func saveToken(_ oauthToken: NSString, oauthTokenSecret: NSString) {
        let defaults = UserDefaults.standard
        defaults.set(oauthToken, forKey: "oauthToken")
        defaults.set(oauthTokenSecret, forKey: "oauthTokenSecret")
        defaults.synchronize()
    }

    func getOauthToken() -> String? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: "oauthToken") as? String
    }

    func getOauthTokenSecret() -> String? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: "oauthTokenSecret") as? String
    }
}
