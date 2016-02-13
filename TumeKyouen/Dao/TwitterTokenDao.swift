//
//  TKTwitterTokenDao.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/02/03.
//  Copyright © 2016年 noboru. All rights reserved.
//

import Foundation

class TwitterTokenDao: NSObject {
    func saveToken(oauthToken: NSString, oauthTokenSecret: NSString) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(oauthToken, forKey: "oauthToken")
        defaults.setObject(oauthTokenSecret, forKey: "oauthTokenSecret")
        defaults.synchronize()
    }

    func getOauthToken() -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.objectForKey("oauthToken") as? String
    }

    func getOauthTokenSecret() -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.objectForKey("oauthTokenSecret") as? String
    }
}
