//
//  TKPoint.m
//  TumeKyouen
//
//  Created by 石倉 昇 on 2013/03/09.
//  Copyright (c) 2013年 noboru. All rights reserved.
//

#import "TKPoint.h"

@implementation TKPoint

- (id)initWithX:(double)x Y:(double)y {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
    }

    return self;
}

- (double)abs {
    return sqrt(self.x * self.x + self.y * self.y);
}
- (TKPoint *)difference:(TKPoint *)point {
    return [[TKPoint alloc] initWithX:(self.x - point.x)Y:(self.y - point.y)];
}
- (TKPoint *)sum:(TKPoint *)point {
    return [[TKPoint alloc] initWithX:(self.x + point.x)Y:(self.y + point.y)];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"x = %f, y = %f", self.x, self.y];
}

@end
