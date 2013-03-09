//
//  TKLine.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/09.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TKPoint;

@interface TKLine : NSObject

@property (nonatomic, readonly) TKPoint *p1;
@property (nonatomic, readonly) TKPoint *p2;
@property (nonatomic, readonly) double a;
@property (nonatomic, readonly) double b;
@property (nonatomic, readonly) double c;

- (id)initWithPoints:(TKPoint *)p1 anotherPoint:(TKPoint *)p2;

@end
