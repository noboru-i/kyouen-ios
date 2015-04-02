//
//  TKTwitterManager.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/07/27.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ReverseAuthResponseHandler)(NSData *responseData,
                                           NSError *error);

@interface TKTwitterManager : NSObject

- (void)performReverseAuthForAccount:(ACAccount *)account
                         withHandler:(ReverseAuthResponseHandler)handler;

+ (BOOL)isLocalTwitterAccountAvailable;

@end
