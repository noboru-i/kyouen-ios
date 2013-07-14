//
//  TKTumeKyouenServer.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/18.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "AFNetworking.h"
#import "TKTumeKyouenServer.h"

@implementation TKTumeKyouenServer

- (NSString *)getStageData:(int)currentMaxStageNo callback:(void(^)(NSString *))callback
{
    NSString *domain = @"http://localhost:8080";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/kyouen/get?stageNo=%d", domain, currentMaxStageNo]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                     timeoutInterval:10.0f];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        LOG(@"%@", operation.responseString);
        callback(operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        LOG(@"%@", error.localizedDescription);
    }];
    [operation start];

    return nil;
}

@end
