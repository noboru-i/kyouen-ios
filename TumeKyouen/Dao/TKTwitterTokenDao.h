//
//  TKTwitterTokenDao.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/07/27.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKTwitterTokenDao : NSObject

- (void)saveToken:(NSString *)oauthToken
    oauthTokenSecret:(NSString *)oauthTokenSecret;
- (NSString *)getOauthToken;
- (NSString *)getOauthTokenSecret;

@end
