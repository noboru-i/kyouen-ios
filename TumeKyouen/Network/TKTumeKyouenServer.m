//
//  TKTumeKyouenServer.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/18.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TKTumeKyouenServer.h"

@implementation TKTumeKyouenServer

- (NSString *)getStageData:(int)currentMaxStageNo callback:(void(^)(NSString *))callback
{
    NSString *domain = @"http://localhost:8080";
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/kyouen/get?stageNo=%d", domain, currentMaxStageNo]]
                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                     timeoutInterval:10.0f];
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               NSString *resultString = [[NSString alloc] initWithData:data
                                                                              encoding:NSUTF8StringEncoding];
                               callback(resultString);
                           }];
    return nil;
}

@end
