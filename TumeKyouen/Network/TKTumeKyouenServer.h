//
//  TKTumeKyouenServer.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/18.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKTumeKyouenServer : NSObject

- (NSString *)getStageData:(int)currentMaxStageNo callback:(void(^)(NSString *))callback;

@end
