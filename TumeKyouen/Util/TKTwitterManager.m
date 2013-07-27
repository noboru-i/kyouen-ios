//
//  TKTwitterManager.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/07/27.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

#import "TKTwitterManager.h"
#import "TKSignedRequest.h"

typedef void(^TKAPIHandler)(NSData *data, NSError *error);

@interface TKTwitterManager()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *accounts;

@end

@implementation TKTwitterManager

#define TW_API_ROOT                  @"https://api.twitter.com"
#define TW_X_AUTH_MODE_KEY           @"x_auth_mode"
#define TW_X_AUTH_MODE_REVERSE_AUTH  @"reverse_auth"
#define TW_X_AUTH_MODE_CLIENT_AUTH   @"client_auth"
#define TW_X_AUTH_REVERSE_PARMS      @"x_reverse_auth_parameters"
#define TW_X_AUTH_REVERSE_TARGET     @"x_reverse_auth_target"
#define TW_OAUTH_URL_REQUEST_TOKEN   TW_API_ROOT "/oauth/request_token"
#define TW_OAUTH_URL_AUTH_TOKEN      TW_API_ROOT "/oauth/access_token"

+ (BOOL)isLocalTwitterAccountAvailable
{
    BOOL available = NO;

    available = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];

    return available;
}

- (void)performReverseAuthForAccount:(ACAccount *)account withHandler:(TKAPIHandler)handler
{
    LOG(@"account=%@", account);
    [self _step1WithCompletion:^(NSData *data, NSError *error) {
        if (!data) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil, error);
            });
        } else {
            NSString *signedReverseAuthSignature = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self _step2WithAccount:account signature:signedReverseAuthSignature andHandler:^(NSData *responseData, NSError *error) {
                if (responseData) {
                    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                    NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                    for (NSString *line in parts) {
                        LOG(@"line = %@", line);
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(responseData, error);
                });
            }];
        }
    }];
}

- (void)_step1WithCompletion:(TKAPIHandler)completion
{
    NSURL *url = [NSURL URLWithString:TW_OAUTH_URL_REQUEST_TOKEN];
    NSDictionary *dict = @{TW_X_AUTH_MODE_KEY: TW_X_AUTH_MODE_REVERSE_AUTH};
    TKSignedRequest *step1Request = [[TKSignedRequest alloc] initWithURL:url parameters:dict requestMethod:TKSignedRequestMethodPOST];
    
    [step1Request performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(data, error);
        });
    }];
}

- (void)_step2WithAccount:(ACAccount *)account signature:(NSString *)signedReverseAuthSignature andHandler:(TKAPIHandler)completion
{
    NSDictionary *step2Params = @{TW_X_AUTH_REVERSE_TARGET: [TKSignedRequest consumerKey], TW_X_AUTH_REVERSE_PARMS: signedReverseAuthSignature};
    NSURL *authTokenURL = [NSURL URLWithString:TW_OAUTH_URL_AUTH_TOKEN];
    SLRequest *step2Request = [self requestWithUrl:authTokenURL parameters:step2Params requestMethod:SLRequestMethodPOST];

    [step2Request setAccount:account];
    [step2Request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(responseData, error);
        });
    }];
}

- (SLRequest *)requestWithUrl:(NSURL *)url parameters:(NSDictionary *)dict requestMethod:(SLRequestMethod )requestMethod
{
    return [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:requestMethod URL:url parameters:dict];
}

@end
