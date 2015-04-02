//
//  TKSignedRequest.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/07/27.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Foundation/Foundation.h>

enum TKSignedRequestMethod {
    TKSignedRequestMethodGET,
    TKSignedRequestMethodPOST,
    TKSignedRequestMethodDELETE
};

typedef enum TKSignedRequestMethod TKSignedRequestMethod;

typedef void (^TKSignedRequestHandler)(NSData *data, NSURLResponse *response,
                                       NSError *error);

@interface TKSignedRequest : NSObject

@property(nonatomic, copy) NSString *authToken;
@property(nonatomic, copy) NSString *authTokenSecret;

// Creates a new request
- (id)initWithURL:(NSURL *)url
       parameters:(NSDictionary *)parameters
    requestMethod:(TKSignedRequestMethod)requestMethod;

// Perform the request, and notify handler of results
- (void)performRequestWithHandler:(TKSignedRequestHandler)handler;

// You should ensure that you obfuscate your keys before shipping
+ (NSString *)consumerKey;
+ (NSString *)consumerSecret;
@end
