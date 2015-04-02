//
//  TKPoint.h
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/09.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKPoint : NSObject

@property(nonatomic) double x;
@property(nonatomic) double y;

- (id)initWithX:(double)x Y:(double)y;

- (double)abs;
- (TKPoint *)difference:(TKPoint *)point;
- (TKPoint *)sum:(TKPoint *)point;

@end
