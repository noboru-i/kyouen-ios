//
//  TKKyouenData.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/09.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TKLine;
@class TKPoint;

@interface TKKyouenData : NSObject

@property(nonatomic, strong, readonly) NSArray *points;
@property(nonatomic, readonly) BOOL isLine;
@property(nonatomic, strong, readonly) TKPoint *center;
@property(nonatomic, readonly) double radius;
@property(nonatomic, strong, readonly) TKLine *line;

- (id)initWithLine:(TKPoint *)p1
             point:(TKPoint *)p2
             point:(TKPoint *)p3
             point:(TKPoint *)p4
              line:(TKLine *)line;
- (id)initWithOval:(TKPoint *)p1
             point:(TKPoint *)p2
             point:(TKPoint *)p3
             point:(TKPoint *)p4
            center:(TKPoint *)center
            radius:(double)radius;

@end
