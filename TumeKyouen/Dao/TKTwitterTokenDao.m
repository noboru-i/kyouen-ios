//
//  TKTwitterTokenDao.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/07/27.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TKTwitterTokenDao.h"

@implementation TKTwitterTokenDao

- (void)saveToken:(NSString *)oauthToken
    oauthTokenSecret:(NSString *)oauthTokenSecret {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:oauthToken forKey:@"oauthToken"];
    [defaults setObject:oauthTokenSecret forKey:@"oauthTokenSecret"];
    [defaults synchronize];
}

- (NSString *)getOauthToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *oauthToken = [defaults objectForKey:@"oauthToken"];
    return oauthToken;
}

- (NSString *)getOauthTokenSecret {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *oauthTokenSecret = [defaults objectForKey:@"oauthTokenSecret"];
    return oauthTokenSecret;
}

@end
