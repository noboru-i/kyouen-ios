//
//  TKSignedRequest.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/07/27.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TKSignedRequest.h"

#import "OAuthCore.h"

#define TW_HTTP_METHOD_GET @"GET"
#define TW_HTTP_METHOD_POST @"POST"
#define TW_HTTP_METHOD_DELETE @"DELETE"
#define TW_HTTP_HEADER_AUTHORIZATION @"Authorization"
#define TW_CONSUMER_KEY @"TWITTER_CONSUMER_KEY"
#define TW_CONSUMER_SECRET @"TWITTER_CONSUMER_SECRET"

#define REQUEST_TIMEOUT_INTERVAL 8

static NSString *gTKConsumerKey;
static NSString *gTKConsumerSecret;

@interface TKSignedRequest () {
    NSURL *_url;
    NSDictionary *_parameters;
    TKSignedRequestMethod _signedRequestMethod;
}

- (NSURLRequest *)_buildRequest;

@end

@implementation TKSignedRequest
@synthesize authToken = _authToken;
@synthesize authTokenSecret = _authTokenSecret;

- (id)initWithURL:(NSURL *)url
       parameters:(NSDictionary *)parameters
    requestMethod:(TKSignedRequestMethod)requestMethod {
    self = [super init];
    if (self) {
        _url = url;
        _parameters = parameters;
        _signedRequestMethod = requestMethod;
    }
    return self;
}

- (NSURLRequest *)_buildRequest {
    NSString *method;

    switch (_signedRequestMethod) {
        case TKSignedRequestMethodPOST:
            method = TW_HTTP_METHOD_POST;
            break;
        case TKSignedRequestMethodDELETE:
            method = TW_HTTP_METHOD_DELETE;
            break;
        case TKSignedRequestMethodGET:
        default:
            method = TW_HTTP_METHOD_GET;
    }

    //  Build our parameter string
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [_parameters
        enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
          [paramsAsString appendFormat:@"%@=%@&", key, obj];
        }];

    //  Create the authorization header and attach to our request
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authorizationHeader = OAuthorizationHeader(
        _url, method, bodyData, [TKSignedRequest consumerKey],
        [TKSignedRequest consumerSecret], _authToken, _authTokenSecret);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
    [request setTimeoutInterval:REQUEST_TIMEOUT_INTERVAL];
    [request setHTTPMethod:method];
    [request setValue:authorizationHeader
        forHTTPHeaderField:TW_HTTP_HEADER_AUTHORIZATION];
    [request setHTTPBody:bodyData];

    return request;
}

- (void)performRequestWithHandler:(TKSignedRequestHandler)handler {
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          NSURLResponse *response;
          NSError *error;
          NSData *data =
              [NSURLConnection sendSynchronousRequest:[self _buildRequest]
                                    returningResponse:&response
                                                error:&error];
          handler(data, response, error);
        });
}

+ (NSString *)consumerKey {
    if (!gTKConsumerKey) {
        NSBundle *bundle = [NSBundle mainBundle];
        gTKConsumerKey = bundle.infoDictionary[TW_CONSUMER_KEY];
    }

    return gTKConsumerKey;
}

+ (NSString *)consumerSecret {
    if (!gTKConsumerSecret) {
        NSBundle *bundle = [NSBundle mainBundle];
        gTKConsumerSecret = bundle.infoDictionary[TW_CONSUMER_SECRET];
    }

    return gTKConsumerSecret;
}

@end
