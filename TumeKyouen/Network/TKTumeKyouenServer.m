//
//  TKTumeKyouenServer.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/18.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "AFNetworking.h"
#import "TKTumeKyouenServer.h"
#import "TumeKyouenModel.h"

@implementation TKTumeKyouenServer

// #define SERVER_DOMAIN @"https://my-android-server.appspot.com"
#define SERVER_DOMAIN @"http://localhost:8080"

- (NSString *)getStageData:(int)currentMaxStageNo callback:(void(^)(NSString *))callback
{
//    NSString *domain = @"https://my-android-server.appspot.com";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/kyouen/get?stageNo=%d", SERVER_DOMAIN, currentMaxStageNo]];
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

- (void)registUser:(NSString *)token tokenSecret:(NSString *)tokenSecret callback:(void(^)(NSString *))callback
{
    LOG(@"token = %@", token);
    LOG(@"tokenSecret = %@", tokenSecret);

    NSString* content = [NSString stringWithFormat:@"token=%@&token_secret=%@", token, tokenSecret];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/page/api_login", SERVER_DOMAIN]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0f];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        LOG(@"%@", operation.responseString);
        callback(operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        LOG(@"%@", error.localizedDescription);
    }];
    [operation start];

    return;
}

- (void)addAllStageUser:(NSArray *)stages callback:(void(^)(NSArray *))callback
{
    LOG_METHOD;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];

    NSMutableArray *sendJson = [[NSMutableArray alloc] init];
    for (TumeKyouenModel *model in stages) {
        [sendJson addObject:@{
         @"stageNo": [model.stageNo stringValue],
         @"clearDate": [formatter stringFromDate:model.clearDate]}];
    }
    LOG(@"sendJson = %@", sendJson);
    NSData *sendJsonData = [NSJSONSerialization dataWithJSONObject:sendJson options:kNilOptions error:nil];
    NSString *sendJsonStr= [[NSString alloc] initWithData:sendJsonData encoding:NSUTF8StringEncoding];
    LOG(@"sendjson = %@", sendJsonStr);
    NSString *content = [NSString stringWithFormat:@"data=%@", sendJsonStr];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/page/add_all", SERVER_DOMAIN]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0f];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        LOG(@"operation.responseString = %@", operation.responseString);
        NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
        NSArray *responseData = [responseJson objectForKey:@"data"];
        if (responseData == nil) {
            callback(nil);
        }
        callback(responseData);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        LOG(@"%@", error.localizedDescription);
    }];
    [operation start];

    return;
}

@end
