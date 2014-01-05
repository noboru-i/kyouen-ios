//
//  TKTumeKyouenServer.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/18.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKTumeKyouenServer : NSObject

- (NSString *)getStageData:(int)currentMaxStageNo callback:(void(^)(NSString *, NSError *))callback;
- (void)registUser:(NSString *)token tokenSecret:(NSString *)tokenSecret callback:(void(^)(NSString *, NSError *))callback;
- (void)addAllStageUser:(NSArray *)stages callback:(void(^)(NSArray *))callback;
- (void)addStageUser:(NSNumber *) stageNo;
- (void)registDeviceToken:(NSString *)deviceToken;

@end
